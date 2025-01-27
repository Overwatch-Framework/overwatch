--- Localization library
-- @module ow.localization

ow.localization = {}
ow.localization.stored = {}

--- Register a new language.
-- @param language The language code.
-- @param data The language data.
function ow.localization:Register(language, data)
    if ( !language ) then
        ow.util:PrintError("Attempted to register a language without a language code!")
        return
    end

    if ( !data ) then
        ow.util:PrintError("Attempted to register a language without data!")
        return
    end
    
    if ( self.stored[language] ) then
        self.stored[language] = table.Merge(table.Copy(self.stored[language]), data)
    else
        self.stored[language] = data 
    end
end

--- Get a language.
-- @param language The language code.
-- @return The language data.
function ow.localization:Get(language)
    return self.stored[language]
end

--- Get a localized string.
-- @param language The language code.
-- @param key The key of the string.
-- @return The localized string.

function ow.localization:GetPhrase(key, language)
    if ( language == nil ) then
        -- TODO: Replace with options ;9
        language = "en"
    end
    
    return self.stored[language][key]
end