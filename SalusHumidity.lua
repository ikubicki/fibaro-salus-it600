--[[
Salus humidity sensor child device class
@author ikubicki
]]

class 'SalusHumidity' (QuickAppChild)

function SalusHumidity:__init(device)
    QuickAppChild.__init(self, device)
end

function SalusHumidity:setName(name)
    api.put('/devices/' .. self.id, {
        name = name,
    })
end

function SalusHumidity:setValue(value)
    self:updateProperty("value", value)
end
