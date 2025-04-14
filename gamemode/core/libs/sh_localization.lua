--- Localization library
-- @module ow.localization

ow.localization = {}
ow.localization.stored = {}

--- Register a new language.
-- @realm shared
-- @param language The language code.
-- @param data The language data.
function ow.localization:Register(languageName, data)
    if ( languageName == nil or !isstring(languageName) ) then
        ow.util:PrintError("Attempted to register a language without a language code!")
        return false
    end

    if ( data == nil or !istable(data) ) then
        ow.util:PrintError("Attempted to register a language without data!")
        return false
    end

    local stored = self.stored[languageName]
    if ( stored == nil ) then
        self.stored[languageName] = {}
    end

    self.stored[languageName] = table.Merge(table.Copy(self.stored[languageName]), data)

    hook.Run("OnLanguageRegistered", languageName, data)
end

--- Get a language.
-- @realm shared
-- @param language The language code.
-- @return The language data.
function ow.localization:Get(languageName)
    return self.stored[languageName]
end

--- Get a localized string.
-- @realm shared
-- @param key The key of the string.
-- @param language The language code.
-- @return The localized string.
if ( CLIENT ) then
    function ow.localization:GetPhrase(key, languageName)
        return self:Get(GetConVar("gmod_language"):GetString())[key]
    end
end