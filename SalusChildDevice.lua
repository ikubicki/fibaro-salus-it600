class 'SalusChildDevice' (QuickAppChild)

function SalusChildDevice:__init(device)
    QuickAppChild.__init(self, device)
end

function SalusChildDevice:setValue(value)
    self:updateProperty("value", value)
end

function SalusChildDevice:setState(value)
    self:updateProperty("state", value > 0)
end