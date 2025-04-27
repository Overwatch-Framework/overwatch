-- Don't know if there is are more efficient way to do this or to retrieve the languages from gmod itself.
local languages = {
    ["en"] = "English",
    ["de"] = "German",
    ["fr"] = "French",
    ["it"] = "Italian",
    ["es"] = "Spanish (Spain)",
    ["pt"] = "Portuguese (Portugal)",
    ["pt-br"] = "Portuguese (Brazil)",
    ["ru"] = "Russian",
    ["pl"] = "Polish",
    ["ja"] = "Japanese",
    ["ko"] = "Korean",
    ["zh-cn"] = "Chinese (Simplified)",
    ["zh-tw"] = "Chinese (Traditional)",
    ["da"] = "Danish",
    ["nl"] = "Dutch",
    ["fi"] = "Finnish",
    ["no"] = "Norwegian",
    ["sv"] = "Swedish",
    ["tr"] = "Turkish",
    ["uk"] = "Ukrainian",
    ["cs"] = "Czech",
    ["hu"] = "Hungarian",
    ["ro"] = "Romanian",
    ["bg"] = "Bulgarian",
    ["el"] = "Greek",
    ["th"] = "Thai",
    ["vi"] = "Vietnamese"
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