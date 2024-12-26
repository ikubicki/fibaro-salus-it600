--[[
Salus valve child device class
@author ikubicki
]]
class 'SalusValve' (QuickAppChild)

function SalusValve:__init(device)
    QuickAppChild.__init(self, device)
end

function SalusValve:setName(name)
    api.put('/devices/' .. self.id, {
        name = name,
    })
end

function SalusValve:setValue(value)
    self:updateProperty("value", value)
end
