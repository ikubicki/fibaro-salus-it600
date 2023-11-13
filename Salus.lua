--[[
Salus IT600 SDK
@author ikubicki
]]
class 'Salus'

function Salus:new(config)
    self.user = config:getUsername()
    self.pass = config:getPassword()
    self.device_id = config:getDeviceID()
    self.token = Globals:get('salus_token', '')
    self.token_time = tonumber(Globals:get('salus_token_time', 0))
    self.http = HTTPClient:new({
        baseUrl = 'https://eu.salusconnect.io'
    })
    return self
end

function Salus:getProperties(callback, failCallback)
    local properties = {}
    local batteryLevelCallback = function(response)
        properties["battery"] = response.value
        callback(properties)
    end
    local holdtypeCallback = function(response)
        properties["holdtype"] = response.value
        Salus:batteryLevel(batteryLevelCallback, failCallback)
    end
    local runningCallback = function(response)
        properties["running"] = response.value
        Salus:holdtype(holdtypeCallback, failCallback)
    end
    local humidityCallback = function(response)
        properties["humidity"] = response.value
        Salus:running(runningCallback, failCallback)
    end
    local heatingSetpointCallback = function(response)
        properties["heatingSetpoint"] = response.value / 100
        Salus:humidity(humidityCallback, failCallback)
    end
    local temperatureCallback = function(response)
        properties["temperature"] = response.value / 100
        Salus:heatingSetpoint(heatingSetpointCallback, failCallback)
    end
    local authCallback = function(response)
        Salus:temperature(temperatureCallback, failCallback)
    end
    Salus:auth(authCallback, failCallback)
end

function Salus:searchDevices(callback)
    local buildGateway = function(data) 
        return {
            id = data.dsn,
            name = data.product_name,
            ip = data.lan_ip,
            devices = {}
        }
    end
    local buildDevice = function(data)
        return {
            id = data.dsn,
            name = data.product_name,
            model = data.oem_model,
        }
    end
    local listDevicesCallback = function(response)
        QuickApp:debug('OK');
        local gateways = {}
        -- gateways
        for _, d in ipairs(response) do
            if d.device.device_type == 'Gateway' then
                gateways[d.device.dsn] = buildGateway(d.device)
            end
        end
        -- devices
        for _, d in ipairs(response) do
            if d.device.dsn ~= d.device.product_name and d.device.device_type == 'Node' and gateways[d.device.gateway_dsn] ~= nil then
                table.insert(gateways[d.device.gateway_dsn].devices, buildDevice(d.device))
            end
        end
        callback(gateways)
    end
    local authCallback = function(response)
        Salus:listDevices(listDevicesCallback)
    end
    Salus:auth(authCallback)
end

function Salus:batteryLevel(callback, failCallback, attempt)
    if attempt == nil then
        attempt = 1
    end
    local fail = function(response)
        if response.status == 404 then
            return callback({})
        end
        if failCallback then
            failCallback(json.encode(response))
        end
        QuickApp:error('Unable to pull battery level')
        Salus:setToken('')
        -- QuickApp:debug(json.encode(response))
        
        if attempt < 2 then
            attempt = attempt + 1
            fibaro.setTimeout(3000, function()
                QuickApp:debug('Salus:batteryLevel - Retry attempt #' .. attempt)
                local authCallback = function(response)
                    self:batteryLevel(callback, failCallback, attempt)
                end
                Salus:auth(authCallback, failCallback)
            end)
        end
    end
    local success = function(response)
        if response.status > 299 then
            fail(response)
            return
        end
        local data = json.decode(response.data)
        if callback ~= nil then
            callback(data.property)
        end
    end
    local url = "/apiv1/dsns/" .. self.device_id .. "/properties/ep_9:sIT600TH:BatteryLevel.json"
    local headers = {
        Authorization = "Bearer " .. Salus:getToken()
    }
    self.http:get(url, success, fail, headers)
end

function Salus:temperature(callback, failCallback, attempt)
    if attempt == nil then
        attempt = 1
    end
    local fail = function(response)
        if failCallback then
            failCallback(json.encode(response))
        end
        QuickApp:error('Unable to pull temperature')
        Salus:setToken('')
        --QuickApp:debug(json.encode(response))
        
        if attempt < 2 then
            attempt = attempt + 1
            fibaro.setTimeout(3000, function()
                QuickApp:debug('Salus:temperature - Retry attempt #' .. attempt)
                local authCallback = function(response)
                    self:temperature(callback, failCallback, attempt)
                end
                Salus:auth(authCallback, failCallback)
            end)
        end
    end
    local success = function(response)
        if response.status > 299 then
            fail(response)
            return
        end
        local data = json.decode(response.data)
        if callback ~= nil then
            callback(data.property)
        end
    end
    local url = "/apiv1/dsns/" .. self.device_id .. "/properties/ep_9:sIT600TH:LocalTemperature_x100.json"
    local headers = {
        Authorization = "Bearer " .. Salus:getToken()
    }
    self.http:get(url, success, fail, headers)
end

function Salus:heatingSetpoint(callback, failCallback)
    local fail = function(response)
        if failCallback then
            failCallback(json.encode(response))
        end
        QuickApp:error('Unable to pull heating setpoint')
        Salus:setToken('')
    end
    local success = function(response)
        if response.status > 299 then
            fail(response)
            return
        end
        local data = json.decode(response.data)
        if callback ~= nil then
            callback(data.property)
        end
    end
    local url = "/apiv1/dsns/" .. self.device_id .. "/properties/ep_9:sIT600TH:HeatingSetpoint_x100.json"
    local headers = {
        Authorization = "Bearer " .. Salus:getToken()
    }
    self.http:get(url, success, fail, headers)
end

function Salus:setHeatingSetpoint(heatingSetpoint, callback, failCallback)
    local fail = function(response)
        if failCallback then
            failCallback(json.encode(response))
        end
        QuickApp:error('Unable to update heatingSetpoint')
        Salus:setToken('')
    end
    local success = function(response)
        if response.status > 299 then
            fail(response)
            return
        end
        local data = json.decode(response.data)
        if callback ~= nil then
            callback(data.property)
        end
    end
    local url = "/apiv1/dsns/" .. self.device_id .. "/properties/ep_9:sIT600TH:SetHeatingSetpoint_x100/datapoints.json"
    local headers = {
        Authorization = "Bearer " .. Salus:getToken(),
        ["Content-Type"] = "application/json",
    }
    local data = {
        datapoint = {
            value = heatingSetpoint * 100
        }
    }
    self.http:post(url, data, success, fail, headers)
end

function Salus:humidity(callback, failCallback)
    local fail = function(response)
        if failCallback then
            failCallback(json.encode(response))
        end
        QuickApp:error('Unable to pull humidity')
        Salus:setToken('')
    end
    local success = function(response)
        if response.status > 299 then
            fail(response)
            return
        end
        local data = json.decode(response.data)
        if callback ~= nil then
            callback(data.property)
        end
    end
    local url = "/apiv1/dsns/" .. self.device_id .. "/properties/ep_9:sIT600TH:SunnySetpoint_x100.json"
    local headers = {
        Authorization = "Bearer " .. Salus:getToken()
    }
    self.http:get(url, success, fail, headers)
end

function Salus:running(callback, failCallback)
    local fail = function(response)
        if failCallback then
            failCallback(json.encode(response))
        end
        QuickApp:error('Unable to pull mode')
        Salus:setToken('')
    end
    local success = function(response)
        if response.status > 299 then
            fail(response)
            return
        end
        local data = json.decode(response.data)
        if callback ~= nil then
            callback(data.property)
        end
    end
    local url = "/apiv1/dsns/" .. self.device_id .. "/properties/ep_9:sIT600TH:RunningState.json"
    local headers = {
        Authorization = "Bearer " .. Salus:getToken()
    }
    self.http:get(url, success, fail, headers)
end

function Salus:holdtype(callback, failCallback)
    local fail = function(response)
        if failCallback then
            failCallback(json.encode(response))
        end
        QuickApp:error('Unable to pull mode')
        Salus:setToken('')
    end
    local success = function(response)
        if response.status > 299 then
            fail(response)
            return
        end
        local data = json.decode(response.data)
        if callback ~= nil then
            callback(data.property)
        end
    end
    local url = "/apiv1/dsns/" .. self.device_id .. "/properties/ep_9:sIT600TH:HoldType.json"
    local headers = {
        Authorization = "Bearer " .. Salus:getToken()
    }
    self.http:get(url, success, fail, headers)
end

function Salus:setHoldtype(holdtype, callback, failCallback)
    local fail = function(response)
        if failCallback then
            failCallback(json.encode(response))
        end
        QuickApp:error('Unable to update holdtype')
        Salus:setToken('')
    end
    local success = function(response)
        if response.status > 299 then
            fail(response)
            return
        end
        local data = json.decode(response.data)
        if callback ~= nil then
            callback(data.property)
        end
    end
    local url = "/apiv1/dsns/" .. self.device_id .. "/properties/ep_9:sIT600TH:SetHoldType/datapoints.json"
    local headers = {
        Authorization = "Bearer " .. Salus:getToken(),
        ["Content-Type"] = "application/json",
    }
    local data = {
        datapoint = {
            value = holdtype
        }
    }
    self.http:post(url, data, success, fail, headers)
end

function Salus:listDevices(callback, fail, attempt)
    if attempt == nil then
        attempt = 1
    end
    if fail == nil then
        local fail = function(response)
            if failCallback then
                failCallback(json.encode(response))
            end
            QuickApp:error('Unable to pull devices')
            Salus:setToken('')
            
            if attempt < 2 then
                attempt = attempt + 1
                fibaro.setTimeout(3000, function()
                    QuickApp:debug('Salus:listDevices - Retry attempt #' .. attempt)
                    local authCallback = function(response)
                        self:listDevices(callback, nil, attempt)
                    end
                    Salus:auth(authCallback)
                end)
            end
        end
    end
    local success = function(response)
        if response.status > 299 then
            fail(response)
            return
        end
        local data = json.decode(response.data)
        if callback ~= nil then
            callback(data)
        end
    end
    local url = "/apiv1/devices.json"
    local headers = {
        Authorization = "Bearer " .. Salus:getToken()
    }
    self.http:get(url, success, fail, headers)
end

function Salus:auth(callback, failCallback)
    if string.len(self.token) > 1 then
        -- QuickApp:debug('Already authenticated')
        if callback ~= nil then
            callback({})
        end
        return
    end
    local fail = function(response)
        if failCallback then
            failCallback(json.encode(response))
        end
        QuickApp:error('Unable to authenticate')
        Salus:setToken('')
    end
    local success = function(response)
        -- QuickApp:debug(json.encode(response))
        if response.status > 299 then
            fail(response)
            return
        end
        local data = json.decode(response.data)
        Salus:setToken(data.access_token)
        if callback ~= nil then
            callback(data)
        end
    end
    local url = "/users/sign_in.json"
    local headers = {
        ["Content-Type"] = "application/json"
    }
    local data = {
        user = {
            email = self.user,
            password = self.pass,
        }
    }
    self.http:post(url, data, success, fail, headers)
end

function Salus:setToken(token)
    self.token = token
    self.token_time = os.time(os.date("!*t"))
    Globals:set('salus_token', token)
    Globals:set('salus_token_time', self.token_time)
end

function Salus:getToken()
    if not self:checkTokenTime() then
        self:setToken('')
        return ''
    end
    if string.len(self.token) > 10 then
        return self.token
    elseif string.len(Globals:get('salus_token', '')) > 10 then
        return Globals:get('salus_token', '')
    end
    return ''
end

function Salus:checkTokenTime()
    if self.token_time < 1 then
        self.token_time = tonumber(Globals:get('salus_token_time', 0))
    end
    return self.token_time > 0 and os.time(os.date("!*t")) - self.token_time < 43200
end

function Salus:translateBatteryLevel(batteryLevel)
    if batteryLevel > 4 then return 100 end;
    if batteryLevel == 4 then return 75 end;
    if batteryLevel == 3 then return 50 end;
    if batteryLevel == 2 then return 25 end;
    if batteryLevel > 2 then return 0 end;
end