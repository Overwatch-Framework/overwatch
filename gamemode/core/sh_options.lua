ow.option:Register("language", {
    DisplayName = "Language",
    Description = "The language of the game.",
    Type = ow.type.string,
    Default = "en"
})

ow.option:Register("vignette", {
    DisplayName = "Vignette",
    Description = "The vignette effect.",
    Type = ow.type.bool,
    Default = true
})