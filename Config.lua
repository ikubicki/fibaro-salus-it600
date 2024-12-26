--[[
Configuration handler
@author ikubicki
]]
class 'Config'

function Config:new(app)
    self.app = app
    self.user = nil
    self.password = nil
    self.host = nil
    self.port = nil
    self.device_id = nil
    self.interval = nil
    self:init()
    return self
end

function Config:getUser()
    if self.user and self.user:len() > 3 then
        return self.user
    end
    return nil
end

function Config:getPassword()
    return self.password
end

function Config:getHost()
    if self.host and self.host:len() > 3 then
        return self.host
    end
    return nil
end

function Config:getPort()
    if self.port and string.len(self.port) > 1 then
        return self.port
    end
    return '80'
end

function Config:getDeviceID()
    return self.device_id
end

function Config:setDeviceID(device_id)
    self.device_id = device_id
end

function Config:getInterval()
    return tonumber(self.interval) * 1000
end

--[[
This function takes variables and sets as global variables if those are not set already.
This way, adding other devices might be optional and leaves option for users, 
what they want to add into HC3 virtual devices.
]]
function Config:init()
    self.user = self.app:getVariable('User')
    self.password = self.app:getVariable('Password')
    self.host = self.app:getVariable('Host')
    self.port = self.app:getVariable('Port')
    self.device_id = self.app:getVariable('DeviceID')
    self.interval = self.app:getVariable('Interval')

    local storedUsername = Globals:get('salus_username', '')
    local storedPassword = Globals:get('salus_password', '')
    local storedHost = Globals:get('salus_host', '')
    local storedPort = tonumber(Globals:get('salus_port', ''))

    -- handling username
    if string.len(self.user) < 4 and string.len(storedUsername) > 3 then
        self.app:setVariable("User", storedUsername)
        self.user = storedUsername
    elseif (storedUsername == '' and self.user) then
        Globals:set('salus_username', self.user)
    end
    -- handling password
    if string.len(self.password) < 4 and string.len(storedPassword) > 3 then
        self.app:setVariable("Password", storedPassword)
        self.password = storedPassword
    elseif (storedPassword == '' and self.password) then
        Globals:set('salus_password', self.password)
    end
    -- handling host
    if string.len(self.host) < 4 and string.len(storedHost) > 3 then
        self.app:setVariable("Host", storedHost)
        self.host = storedHost
    elseif (storedHost == '' and self.host) then
        Globals:set('salus_host', self.host)
    end
    -- handling port
    if string.len(self.host) < 2 and string.len(storedPort) > 3 then
        self.app:setVariable("Port", storedPort)
        self.port = storedPort
    elseif (storedPort == '' and self.port) then
        Globals:set('salus_port', self.port)
    end
    -- handling interval
    if not self.interval or self.interval == "" then
        self.app:setVariable("Interval", 5)
        self.interval = 5
    end
end