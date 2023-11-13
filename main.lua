--[[
Salus IT600 thermostats integration v 1.1.1
@author ikubicki
]]

function QuickApp:onInit()
    self.config = Config:new(self)
    self.failover = false
    self.salus = Salus:new(self.config)
    self.i18n = i18n:new(api.get("/settings/info").defaultLanguage)
    self:trace('')
    self:trace(string.format(self.i18n:get('name'), self.name))
    self:updateProperty('manufacturer', 'Salus')
    self:updateProperty('model', 'IT600')
    self.childrenIds = {}
    self.interfaces = api.get("/devices/" .. self.id).interfaces

    self:updateProperty("supportedThermostatModes", {"Off", "Heat", "Auto"})
    self:updateProperty("heatingThermostatSetpointCapabilitiesMax", 35)
    self:updateProperty("heatingThermostatSetpointCapabilitiesMin", 10)

    self:updateView("label1", "text", string.format(self.i18n:get('name'), self.name))
    self:updateView("button2_1", "text", self.i18n:get('search-devices'))
    self:updateView("button2_2", "text", self.i18n:get('refresh'))

    self:initChildDevices({
        ["com.fibaro.temperatureSensor"] = SalusChildDevice,
        ["com.fibaro.humiditySensor"] = SalusChildDevice,
        ["com.fibaro.binarySwitch"] = SalusChildDevice,
    })
    for id, device in pairs(self.childDevices) do
        self.childrenIds[device.type] = id
    end

    if string.len(self.config:getDeviceID()) > 10 then
        if self.childrenIds["com.fibaro.temperatureSensor"] == nil then
            local child = self:createChildDevice({
                name = self.name .. ' Temperature',
                type = "com.fibaro.temperatureSensor",
            }, SalusChildDevice)
        end
        if self.childrenIds["com.fibaro.humiditySensor"] == nil then
            local child = self:createChildDevice({
                name = self.name .. ' Humidity',
                type = "com.fibaro.humiditySensor",
            }, SalusChildDevice)
        end
        if self.childrenIds["com.fibaro.binarySwitch"] == nil then
            local child = self:createChildDevice({
                name = self.name .. ' Heating',
                type = "com.fibaro.binarySwitch",
                deviceRole = 'Valve',
                isLight = false,
            }, SalusChildDevice)
        end
        self:run()
    else 
        self:updateView("label1", "text", self.i18n:get('not-configured'))
    end
end

function QuickApp:setThermostatMode(mode)
    self:updateProperty("thermostatMode", mode)
    local holdtype = 0
    if mode == 'Off' then
        holdtype = 7
    elseif mode == 'Heat' then
        holdtype = 2
    end
    local setHoldtypeCallback = function(response)
        self:pullDataFromCloud()
    end
    self.salus:setHoldtype(holdtype, setHoldtypeCallback)
end

function QuickApp:setHeatingThermostatSetpoint(value) 
    self:updateProperty("heatingThermostatSetpoint", value)
    local setHeatingSetpointCallback = function(response)
        self:pullDataFromCloud()
    end
    self.salus:setHeatingSetpoint(value, setHeatingSetpointCallback)
end

function QuickApp:refreshEvent(event)
    self:updateView("label", "text", self.i18n:get('refreshing'))
    self:pullDataFromCloud()
end

function QuickApp:run()
    self:pullDataFromCloud()
    local interval = self.config:getInterval()
    if self.failover then
        interval = 300000
    end
    if (interval > 0) then
        fibaro.setTimeout(interval, function() self:run() end)
    end
end

function QuickApp:pullDataFromCloud()
    local getFailCallback = function()
        self.failover = true
    end
    local getPropertiesCallback = function(properties)
        self.failover = false
        -- QuickApp:debug(json.encode(properties))
        self:updateView("button2_2", "text", self.i18n:get('refresh'))
        if self.childrenIds["com.fibaro.temperatureSensor"] ~= nil then
            self.childDevices[self.childrenIds["com.fibaro.temperatureSensor"]]:setValue(properties.temperature)
        end
        if self.childrenIds["com.fibaro.humiditySensor"] ~= nil then
            self.childDevices[self.childrenIds["com.fibaro.humiditySensor"]]:setValue(properties.humidity)
        end
        if self.childrenIds["com.fibaro.binarySwitch"] ~= nil then
            local isRunningValue = 0
            if properties.running and properties.running > 0 then
                isRunningValue = 1
            end
            self.childDevices[self.childrenIds["com.fibaro.binarySwitch"]]:setValue(isRunningValue > 0)
        end
        local mode = 'Auto' -- 0 or 1
        if properties.holdtype == 2 then
            mode = 'Heat'
        elseif properties.holdtype == 7 then
            mode = 'Off'
        end
        self:updateProperty("thermostatMode", mode)
        self:updateProperty("heatingThermostatSetpoint", properties.heatingSetpoint)
        self:updateView("label1", "text", string.format(self.i18n:get('last-update'), os.date('%Y-%m-%d %H:%M:%S')))
        
        if properties.battery ~= nil then
            self:updateProperty("batteryLevel", Salus:translateBatteryLevel(properties.battery))
            if not utils:contains(self.interfaces, "battery") then
                api.put("/devices/" .. self.id, { interfaces = {
                    "quickApp", "battery", "heatingThermostatSetpoint", "thermostatMode"
                }})
            end
        else

            if not utils:contains(self.interfaces, "power") then
                api.put("/devices/" .. self.id, { interfaces = {
                    "quickApp", "power", "heatingThermostatSetpoint", "thermostatMode"
                }})
            end
        end
    end
    self:updateView("button2_2", "text", self.i18n:get('refreshing'))
    self.salus:getProperties(getPropertiesCallback, getFailCallback)
end

function QuickApp:searchEvent(param)
    self:debug(self.i18n:get('searching-devices'))
    self:updateView("button2_1", "text", self.i18n:get('searching-devices'))
    local searchDevicesCallback = function(gateways)
        -- QuickApp:debug(json.encode(gateways))
        self:updateView("button2_1", "text", self.i18n:get('search-devices'))
        -- printing results
        for _, gateway in pairs(gateways) do
            QuickApp:trace(string.format(self.i18n:get('search-row-gateway'), gateway.name, gateway.id))
            QuickApp:trace(string.format(self.i18n:get('search-row-gateway-devices'), #gateway.devices))
            for __, device in ipairs(gateway.devices) do
                QuickApp:trace(string.format(self.i18n:get('search-row-device'), device.name, device.id, device.model))
            end
        end
        self:updateView("label2", "text", string.format(self.i18n:get('check-logs'), 'QUICKAPP' .. self.id))
    end
    self.salus:searchDevices(searchDevicesCallback)
end
