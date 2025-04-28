-- Don't know if there is are more efficient way to do this or to retrieve the languages from gmod itself.
local languages = {
    ["bg"] = "Bulgarian",
    ["cs"] = "Czech",
    ["da"] = "Danish",
    ["de"] = "German",
    ["el"] = "Greek",
    ["en"] = "English",
    ["en-PT"] = "English (Pirate)",
    ["es"] = "Spanish (Spain)",
    ["fi"] = "Finnish",
    ["fr"] = "French",
    ["he"] = "Hebrew",
    ["hr"] = "Croatian",
    ["hu"] = "Hungarian",
    ["it"] = "Italian",
    ["ja"] = "Japanese",
    ["ko"] = "Korean",
    ["nl"] = "Dutch",
    ["no"] = "Norwegian",
    ["pl"] = "Polish",
    ["pt"] = "Portuguese (Portugal)",
    ["pt-br"] = "Portuguese (Brazil)",
    ["ro"] = "Romanian",
    ["ru"] = "Russian",
    ["sk"] = "Slovak",
    ["sr"] = "Serbian", 
    ["sv"] = "Swedish",
    ["th"] = "Thai",
    ["tr"] = "Turkish",
    ["uk"] = "Ukrainian",
    ["vi"] = "Vietnamese",
    ["zh-cn"] = "Chinese (Simplified)",
    ["zh-tw"] = "Chinese (Traditional)",
}

ow.option:Register("language", {
    Name = "Language",
    Description = "The language of the game.",
    Type = ow.type.array,
    Default = "en",
    Populate = function()
        return languages
    end,
})

ow.option:Register("vignette", {
    Name = "Vignette",
    Description = "The vignette effect.",
    Type = ow.type.bool,
    Default = true
})