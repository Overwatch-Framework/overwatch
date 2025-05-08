--[[
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
    OnChange = function(self, value)
        -- GMOD blocks the console command gmod_language from being run in the console
        RunConsoleCommand("gmod_language", value)
    end,
    Populate = function()
        return languages
    end
})
]]

ow.option:Register("inventory.sort", {
    Name = "options.inventory.sort",
    Description = "options.inventory.sort.help",
    Type = ow.type.array,
    Default = "name",
    NoNetworking = true,
    Populate = function()
        return {
            ["name"] = "Name",
            ["weight"] = "Weight",
            ["category"] = "Category",
        }
    end
})

ow.option:Register("vignette", {
    Name = "options.vignette",
    Description = "options.vignette.help",
    Type = ow.type.bool,
    Default = true,
    NoNetworking = true
})

ow.option:Register("tab.fade.time", {
    Name = "options.tab.fade.time",
    Description = "options.tab.fade.time.help",
    Type = ow.type.number,
    NoNetworking = true,
    Default = 0.4,
    Min = 0,
    Max = 1,
    Decimals = 2
})

ow.option:Register("tab.anchor.time", {
    Name = "options.tab.anchor.time",
    Description = "options.tab.anchor.time.help",
    Type = ow.type.number,
    Default = 0.4,
    NoNetworking = true,
    Min = 0,
    Max = 1,
    Decimals = 2
})

ow.option:Register("mainmenu.music", {
    Name = "options.mainmenu.music",
    Description = "options.mainmenu.music.help",
    SubCategory = "category.mainmenu",
    Type = ow.type.bool,
    Default = true,
    NoNetworking = true
})

ow.option:Register("mainmenu.music.volume", {
    Name = "options.mainmenu.music.volume",
    Description = "options.mainmenu.music.volume.help",
    SubCategory = "category.mainmenu",
    Type = ow.type.number,
    Default = 50,
    NoNetworking = true,
    Min = 0,
    Max = 100,
    Decimals = 0
})

ow.option:Register("mainmenu.music.loop", {
    Name = "options.mainmenu.music.loop",
    Description = "options.mainmenu.music.loop.help",
    SubCategory = "category.mainmenu",
    Type = ow.type.bool,
    Default = true,
    NoNetworking = true
})

ow.option:Register("performance.blur", {
    Name = "options.performance.blur",
    Description = "options.performance.blur.help",
    Category = "category.performance",
    Type = ow.type.bool,
    Default = true,
    NoNetworking = true
})

ow.option:Register("performance.animations", {
    Name = "options.performance.animations",
    Description = "options.performance.animations.help",
    Category = "category.performance",
    Type = ow.type.bool,
    Default = true,
    NoNetworking = true
})

ow.option:Register("chat.size.font", {
    Name = "options.chat.size.font",
    Description = "options.chat.size.font.help",
    Category = "category.chat",
    Type = ow.type.number,
    Default = 1,
    NoNetworking = true,
    Min = 0,
    Max = 2,
    Decimals = 2,
    OnChange = function(self, value)
        hook.Run("LoadFonts")

        for _, v in ipairs(ow.chat.messages) do
            if ( !IsValid(v) ) then continue end

            v:SizeToContents()
        end
    end
})