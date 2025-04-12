--- Localization library
-- @module ow.localization

ow.localization = {}
ow.localization.stored = {}

--- Register a new language.
-- @realm shared
-- @param language The language code.
-- @param data The language data.
function ow.localization:Register(language, data)
    if ( language == nil or !isstring(language) ) then
        ow.util:PrintError("Attempted to register a language without a language code!")
        return
    end

    if ( data == nil or !istable(data) ) then
        ow.util:PrintError("Attempted to register a language without data!")
        return
    end

    if ( self.stored[language] ) then
        self.stored[language] = table.Merge(table.Copy(self.stored[language]), data)
    else
        self.stored[language] = data
    end

    hook.Run("OnLanguageRegistered", language, data)
end

--- Get a language.
-- @realm shared
-- @param language The language code.
-- @return The language data.
function ow.localization:Get(language)
    return self.stored[language]
end

--- Get a localized string.
-- @realm shared
-- @param key The key of the string.
-- @param language The language code.
-- @return The localized string.
function ow.localization:GetPhrase(key, language)
    if ( language == nil ) then
        language = ow.option:Get("language", "eng")
    end

    return self:Get(language)[key]
end