ow.option:Register("language", {
    Name = "Language",
    Description = "The language of the game.",
    Type = ow.type.string,
    Default = "en"
})

ow.option:Register("vignette", {
    Name = "Vignette",
    Description = "The vignette effect.",
    Type = ow.type.bool,
    Default = true
})