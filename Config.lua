--[[
Configuration handler
@author ikubicki
]]
class 'Config'

function Config:new(app)
    self.app = app
    self:init()
    return self
end

function Config:getUsername()
    if self.username and self.username:len() > 3 then
        return self.username
    end
    return nil
end

function Config:getPassword()
    return self.password
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
    self.username = self.app:getVariable('Username')
    self.password = self.app:getVariable('Password')
    self.device_id = self.app:getVariable('DeviceID')
    self.interval = self.app:getVariable('Interval')

    local storedUsername = Globals:get('salus_username', '')
    local storedPassword = Globals:get('salus_password', '')

    -- handling username
    if string.len(self.username) < 4 and string.len(storedUsername) > 3 then
        self.app:setVariable("Username", storedUsername)
        self.username = storedUsername
    elseif (storedUsername == '' and self.username) then
        Globals:set('salus_username', self.username)
    end
    -- handling password
    if string.len(self.password) < 4 and string.len(storedPassword) > 3 then
        self.app:setVariable("Password", storedPassword)
        self.password = storedPassword
    elseif (storedPassword == '' and self.password) then
        Globals:set('salus_password', self.password)
    end
    -- handling interval
    if not self.interval or self.interval == "" then
        self.app:setVariable("Interval", 30)
        self.interval = 30
    end
end