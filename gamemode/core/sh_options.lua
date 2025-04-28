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
    Name = "options.language",
    Description = "options.language.help",
    Type = ow.type.array,
    Default = "en",
    Populate = function()
        return languages
    end,
})

ow.option:Register("vignette", {
    Name = "options.vignette",
    Description = "options.vignette.help",
    Type = ow.type.bool,
    Default = true
})

ow.option:Register("tab.fade.time", {
    Name = "options.tab.fade.time",
    Description = "options.tab.fade.time.help",
    Type = ow.type.number,
    Default = 0.4
})

ow.option:Register("tab.anchor.time", {
    Name = "options.tab.anchor.time",
    Description = "options.tab.anchor.time.help",
    Type = ow.type.number,
    Default = 0.4
})

ow.option:Register("performance.blur", {
    Name = "options.performance.blur",
    Description = "options.performance.blur.help",
    Category = "category.performance",
    Type = ow.type.bool,
    Default = true
})

ow.option:Register("performance.animations", {
    Name = "options.performance.animations",
    Description = "options.performance.animations.help",
    Category = "category.performance",
    Type = ow.type.bool,
    Default = true
})