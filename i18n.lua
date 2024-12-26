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
        ['name'] = 'Salus - %s',
        ['search-devices'] = 'Szukaj urządzeń',
        ['searching-devices'] = 'Szukam...',
        ['refresh'] = 'Odśwież dane',
        ['refreshing'] = 'Odświeżam...',
        ['device-updated'] = 'Zaktualizowano dane urządzenia',
        ['last-update'] = 'Ostatnia aktualizacja: %s',
        ['not-configured'] = 'Urządzenie nie skonfigurowane',
        ['check-select'] = 'Zakończono wyszukiwanie. Zaktualizowano pole wyboru powyżej. Może być wymagane zamknięcie i ponowne otwarcie panelu tego urządzenia.',
        ['device-selected'] = 'Wybrano urządzenie.',
        ['heating'] = 'Grzanie',
        ['off'] = 'Wyłączony',
        ['temperature-suffix'] = '%s - Temperatura',
        ['humidity-suffix'] = '%s - Wilgotność',
    },
    en = {
        ['name'] = 'Salus - %s',
        ['search-devices'] = 'Search devices',
        ['searching-devices'] = 'Searching...',
        ['refresh'] = 'Update data',
        ['refreshing'] = 'Updating...',
        ['device-updated'] = 'Device updates',
        ['last-update'] = 'Last update: %s',
        ['not-configured'] = 'Device not configured',
        ['check-select'] = 'Search complete. Select field above have been updated. Reopening a popup of this device might be necessary.',
        ['device-selected'] = 'Device selected.',
        ['heating'] = 'Heating',
        ['off'] = 'Off',
        ['temperature-suffix'] = '%s - Temperature',
        ['humidity-suffix'] = '%s - Temperature',
    },
}