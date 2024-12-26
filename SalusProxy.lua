--[[
Salus IT600 Proxy SDK
@author ikubicki
]]
class 'SalusProxy'

function SalusProxy:new(config)
    self.config = config
    self.user = config:getUser()
    self.pass = config:getPassword()
    self.device_id = config:getDeviceID()
    self.token = Utils:base64(config:getUser() .. ':' .. config:getPassword())
    self.http = HTTPClient:new({
        baseUrl = 'http://' .. config:getHost() .. ':' .. config:getPort() .. '/api/v1'
    })
    return self
end

function SalusProxy:getProperties(ok, nok)
    local h = function(r)
        if (r.status > 200) then
            return nok(r)
        end
        local data = json.decode(r.data)
        local running = 0
        if data.isRunning then running = 1 end
        return ok({
            id = data.id,
            name = data.name,
            model = data.model,
            heatingSetpoint = data.temperature,
            temperature = data.currentTemperature,
            humidity = data.humidity,
            running = running,
            holdtype = data.mode,
            battery = data.battery,
        })
    end
    local headers = {
        Authorization = 'Basic ' .. self.token,
        ['Content-Type'] = 'application/json',
    }
    if not nok then nok = function() end end
    self.http:get('/devices/' .. self.config:getDeviceID(), h, nok, headers)
end

function SalusProxy:searchDevices(ok, nok)
    local h = function(r)
        if (r.status > 200) then
            return nok(r)
        end
        return ok({{
            name = 'proxy',
            devices = json.decode(r.data)
        }})
    end
    local headers = {
        Authorization = 'Basic ' .. self.token,
        ['Content-Type'] = 'application/json',
    }
    if not nok then nok = function() end end
    self.http:get('/devices', h, nok, headers)
end

function SalusProxy:setHeatingSetpoint(setpoint, ok, nok)
local h = function(r)
        if (r.status > 200) then
            return nok(r)
        end
        return ok({{
            name = 'proxy',
            devices = json.decode(r.data)
        }})
    end
    local headers = {
        Authorization = 'Basic ' .. self.token,
        ['Content-Type'] = 'application/json',
    }
    local d = {
        temperature = setpoint,
    }
    if not nok then nok = function() end end
    self.http:post('/devices/' .. self.config:getDeviceID() .. '/temperature', d, h, nok, headers)
end


function SalusProxy:setHoldtype(holdtype, ok, nok)
    local h = function(r)
        if (r.status > 200) then
            return nok(r)
        end
        return ok({{
            name = 'proxy',
            devices = json.decode(r.data)
        }})
    end
    local headers = {
        Authorization = 'Basic ' .. self.token,
        ['Content-Type'] = 'application/json',
    }
    local d = {
        mode = holdtype,
    }
    if not nok then nok = function() end end
    self.http:post('/devices/' .. self.config:getDeviceID() .. '/mode', d, h, nok, headers)
end