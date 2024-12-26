--[[
Salus temperature sendor child device class
@author ikubicki
]]
class 'SalusTemperature' (QuickAppChild)

function SalusTemperature:__init(device)
    QuickAppChild.__init(self, device)
end

function SalusTemperature:setName(name)
    api.put('/devices/' .. self.id, {
        name = name,
    })
end

function SalusTemperature:setValue(value)
    self:updateProperty("value", value)
end
