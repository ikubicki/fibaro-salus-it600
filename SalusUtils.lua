--[[
Salus utilities
@author ikubicki
]]
class 'SalusUtils'

function SalusUtils:translateHoldType(holdtype)
    if holdtype == 2 then
        return 'Heat'
    elseif holdtype == 7 then
        return 'Off'
    end
    return 'Auto' -- 0 or 1
end

function SalusUtils:translateBattery(battery)
    if battery > 4 then return 100 end;
    if battery == 4 then return 75 end;
    if battery == 3 then return 50 end;
    if battery == 2 then return 25 end;
    if battery > 2 then return 0 end;
end

function SalusUtils:translateMode(mode)
    if mode == 'Off' then
        return 7
    elseif mode == 'Heat' then
        return 2
    end
    return 0
end