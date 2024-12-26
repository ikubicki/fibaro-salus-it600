--[[
LUA utilities
@author ikubicki
]]
class 'Utils'

function Utils:new()
    return self
end

function Utils:contains(a, n)
    for k, v in pairs(a) do
        if v == n then
            return k
        end
    end
    return false
end

-- borrowed from https://github.com/jangabrielsson/TQAE
function Utils:base64(data)
    __assert_type(data,"string")
    local bC='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x) 
            local r,b='',x:byte() for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
            return r;
        end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return bC:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end