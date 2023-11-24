--[[
Internationalization tool
@author ikubicki
]]
class 'i18n'

function i18n:new(langCode)
    if phrases[langCode] == nil then
        langCode = 'en'
    end
    self.phrases = phrases[langCode]
    return self
end

function i18n:get(key)
    if self.phrases[key] then
        return self.phrases[key]
    end
    return key
end

phrases = {
    pl = {
        ['name'] = 'Salus IT600 - %s',
        ['search-devices'] = 'Szukaj urządzeń',
        ['searching-devices'] = 'Szukam...',
        ['refresh'] = 'Odśwież dane',
        ['refreshing'] = 'Odświeżam...',
        ['device-updated'] = 'Zaktualizowano dane urządzenia',
        ['last-update'] = 'Ostatnia aktualizacja: %s',
        ['not-configured'] = 'Urządzenie nie skonfigurowane',
        ['check-logs'] = 'Zakończono wyszukiwanie. Sprawdź logi tego urządzenia: %s',
        ['search-row-gateway'] = '__ BRAMKA %s (# %s)',
        ['search-row-gateway-devices'] = '__ Wykryto %d urządzeń',
        ['search-row-device'] = '____ URZĄDZENIE %s (DeviceID: %s, Model: %s)',
        ['heating'] = 'Grzanie',
        ['off'] = 'Wyłączony',
    },
    en = {
        ['name'] = 'Salus IT600 - %s',
        ['search-devices'] = 'Search devices',
        ['searching-devices'] = 'Searching...',
        ['refresh'] = 'Update data',
        ['refreshing'] = 'Updating...',
        ['device-updated'] = 'Device updates',
        ['last-update'] = 'Last update: %s',
        ['not-configured'] = 'Device not configured',
        ['check-logs'] = 'Check device logs (%s) for search results',
        ['search-row-gateway'] = '__ GATEWAY %s (# %s)',
        ['search-row-gateway-devices'] = '__ %d devices found',
        ['search-row-device'] = '____ DEVICE %s (DeviceID: %s, Model: %s)',
        ['heating'] = 'Heating',
        ['off'] = 'Off',
    },
}