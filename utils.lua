--[[
LUA utilities
@author ikubicki
]]
class 'utils'

function utils:new()
    return self
end

function utils:contains(a, n)
    for k, v in pairs(a) do
        if v == n then
            return k
        end
    end
    return false
end