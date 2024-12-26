--[[
Salus IT600 thermostats integration
@author ikubicki
@version 2.0.0
]]

local REFRESH_BUTTON = "button2_2"
local SEARCH_BUTTON = "button2_1"
local STATUS_LABEL = "label1"
local STATS_LABEL = "label2"
local TITLE_LABEL = "title"

function QuickApp:onInit()
    self.config = Config:new(self)
    self.failover = false
    -- self.sdk = SalusCloud:new(self.config)
    self.sdk = SalusProxy:new(self.config)
    self.i18n = i18n:new(api.get("/settings/info").defaultLanguage)
    self:trace('')
    self:trace(string.format(self.i18n:get('name'), self.name))
    self:updateProperty('manufacturer', 'Salus')
    self:updateProperty('model', 'IT600')
    self.childrenIds = {}
    if not Utils:contains(self.interfaces, "thermostatOperatingState") then
        self:addInterfaces({"thermostatOperatingState"})
    end

    self:searchEvent()
    if self.config:getDeviceID() then
        self:updateView("deviceSelect", "selectedItem", self.config:getDeviceID())
    end

    self:updateProperty("supportedThermostatModes", {"Off", "Heat", "Auto"})
    self:updateProperty("heatingThermostatSetpointCapabilitiesMax", 35)
    self:updateProperty("heatingThermostatSetpointCapabilitiesMin", 15)
    self:updateProperty("autoThermostatSetpointCapabilitiesMax", 35)
    self:updateProperty("autoThermostatSetpointCapabilitiesMin", 15)

    self:updateView(TITLE_LABEL, "text", string.format(self.i18n:get('name'), self.name))
    self:updateView(SEARCH_BUTTON, "text", self.i18n:get('search-devices'))
    self:updateView(REFRESH_BUTTON, "text", self.i18n:get('refresh'))

    self:initChildDevices({
        ["com.fibaro.temperatureSensor"] = SalusTemperature,
        ["com.fibaro.humiditySensor"] = SalusHumidity,
    })
    for id, device in pairs(self.childDevices) do
        self.childrenIds[device.type] = id
    end

    if string.len(self.config:getDeviceID()) > 10 then
        if self.childrenIds["com.fibaro.temperatureSensor"] == nil then
            local child = self:createChildDevice({
                name = self.name .. ' Temperature',
                type = "com.fibaro.temperatureSensor",
            }, SalusTemperature)
        end
        if self.childrenIds["com.fibaro.humiditySensor"] == nil then
            local child = self:createChildDevice({
                name = self.name .. ' Humidity',
                type = "com.fibaro.humiditySensor",
            }, SalusHumidity)
        end
        self:run()
    else 
        self:updateView(STATS_LABEL, "text", self.i18n:get('not-configured'))
    end
end

function QuickApp:setThermostatMode(mode)
    self:updateProperty("thermostatMode", mode)
    local ok = function(r)
        self:updateView(STATUS_LABEL, "text", "Setpoint updated")
        self:pullDataFromCloud()
    end
    local nok = function(r)
        self:updateView(STATUS_LABEL, "text", r.status .. ": Unable to update thermostat mode")
    end
    self.sdk:setHoldtype(SalusUtils:translateMode(mode), ok, nok)
end

function QuickApp:setHeatingThermostatSetpoint(value) 
    self:updateProperty("heatingThermostatSetpoint", value)
    local ok = function(response)
        self:updateView(STATUS_LABEL, "text", "Thermostat mode updated")
        self:pullDataFromCloud()
    end
    local nok = function(r)
        self:updateView(STATUS_LABEL, "text", r.status .. ": Unable to update thermostat setpoint")
    end
    self.sdk:setHeatingSetpoint(value, ok, nok)
end

function QuickApp:refreshEvent(event)
    self:updateView(STATUS_LABEL, "text", self.i18n:get('refreshing'))
    self:pullDataFromCloud()
end

function QuickApp:run()
    self:pullDataFromCloud()
    local interval = self.config:getInterval()
    if self.failover then
        interval = 3600000
    end
    if (interval > 0) then
        fibaro.setTimeout(interval, function() self:run() end)
    end
end

function QuickApp:pullDataFromCloud()
    local nok = function(error)
        self:updateView(REFRESH_BUTTON, "text", self.i18n:get('refresh'))
        self:updateView(STATUS_LABEL, "text", error.status .. ": Unable to pull device data")
        self:updateView(STATS_LABEL, "text", "")
        self.failover = true
    end
    local ok = function(properties)
        local label2Text = ""
        self.failover = false
        self:updateView(TITLE_LABEL, "text", "Salus " .. properties.model .. ' - ' .. properties.name)
        self:updateView(REFRESH_BUTTON, "text", self.i18n:get('refresh'))
        if self.childrenIds["com.fibaro.temperatureSensor"] ~= nil then
            self.childDevices[self.childrenIds["com.fibaro.temperatureSensor"]]:setValue(properties.temperature)
            label2Text = properties.temperature .. "C / " .. properties.heatingSetpoint .. "C" 
        end
        if self.childrenIds["com.fibaro.humiditySensor"] ~= nil then
            self.childDevices[self.childrenIds["com.fibaro.humiditySensor"]]:setValue(properties.humidity)
            label2Text = label2Text .. " / " .. properties.humidity .. "%"
        end
        local operatingState = 'Idle'
        local isRunningValue = 0
        if properties.running and properties.running > 0 then
            operatingState = 'Heating'
            isRunningValue = 1
        end
        self:updateProperty("thermostatOperatingState", operatingState)
        if isRunningValue > 0 then
            label2Text = self.i18n:get('heating') .. " / " .. label2Text
        else
            label2Text = self.i18n:get('off') .. " / " .. label2Text
        end

        self:updateProperty("thermostatMode", SalusUtils:translateHoldType(properties.holdtype))
        self:updateProperty("heatingThermostatSetpoint", properties.heatingSetpoint)
        self:updateView(STATUS_LABEL, "text", string.format(self.i18n:get('last-update'), os.date('%Y-%m-%d %H:%M:%S')))
        self:updateView(STATS_LABEL, "text", label2Text)
        if properties.battery ~= nil then
            self:updateProperty("batteryLevel", SalusUtils:translateBattery(properties.battery))
            if not Utils:contains(self.interfaces, "battery") then
                self:addInterfaces({"battery"})
            end
        else
            if not Utils:contains(self.interfaces, "power") then
                self:addInterfaces({"power"})
            end
        end
    end
    self:updateView(REFRESH_BUTTON, "text", self.i18n:get('refreshing'))
    self.sdk:getProperties(ok, nok)
end

function QuickApp:searchEvent(param)
    self:updateView(STATUS_LABEL, "text", self.i18n:get('searching-devices'))
    self:updateView(SEARCH_BUTTON, "text", self.i18n:get('searching-devices'))
    local searchDevicesCallback = function(gateways)
        -- QuickApp:debug(json.encode(gateways))
        self:updateView(SEARCH_BUTTON, "text", self.i18n:get('search-devices'))
        local options = {}
        for _, gateway in pairs(gateways) do
            -- do nothing with gateway anymore
            for __, device in pairs(gateway.devices) do
                table.insert(options, {
                    type = 'option',
                    text = device.model .. ' - ' .. device.name,
                    value = device.id,
                })
            end
        end
        self:updateView("deviceSelect", "options", options)
        self:updateView(STATUS_LABEL, "text", string.format(self.i18n:get('check-select')))
    end
    local nok = function(r)
        self:updateView(SEARCH_BUTTON, "text", self.i18n:get('search-devices'))
        self:updateView(STATUS_LABEL, "text", r.status .. ": Unable to pull devices")
    end
    self.sdk:searchDevices(searchDevicesCallback, nok)
end

function QuickApp:selectDeviceEvent(args)
    self:setVariable('DeviceID', args.values[1])
    self:updateView(STATS_LABEL, "text", "")
    self:updateView(STATUS_LABEL, "text", self.i18n:get('device-selected'))
    self.config:setDeviceID(args.values[1])
    local QA = self
    local ok = function(p)
        if self.childrenIds["com.fibaro.temperatureSensor"] ~= nil then
            self.childDevices[self.childrenIds["com.fibaro.temperatureSensor"]]:setName(
                string.format(self.i18n:get('temperature-suffix'), p.name)
            )
        end
        if self.childrenIds["com.fibaro.humiditySensor"] ~= nil then
            self.childDevices[self.childrenIds["com.fibaro.humiditySensor"]]:setName(
                string.format(self.i18n:get('humidity-suffix'), p.name)
            )
        end
        self:setName(p.name)

    end
    local nok = function(r)
        self:updateView(STATUS_LABEL, "text", r.status .. ": Unable to pull selected device information")
    end

    self.sdk:getProperties(ok, nok)

end

function QuickApp:setName(name)
    api.put('/devices/' .. self.id, {
        name = name,
    })
end
