local MODULE = MODULE

MODULE.Name = "Third Person"
MODULE.Description = "Allows players to view themselves in third person."
MODULE.Author = "Riggs"

ow.localization:Register("en", {
    ["category.thirdperson"] = "Third Person",
    ["option.thirdperson"] = "Third Person",
    ["option.thirdperson.enable"] = "Enable Third Person",
    ["option.thirdperson.enable.help"] = "Enable or disable third person view.",
    ["options.thirdperson.follow.head"] = "Follow Head",
    ["options.thirdperson.follow.head.help"] = "Follow the player's head with the third person camera.",
    ["options.thirdperson.follow.hit.angles"] = "Follow Hit Angles",
    ["options.thirdperson.follow.hit.angles.help"] = "Follow the hit angles with the third person camera.",
    ["options.thirdperson.follow.hit.fov"] = "Follow Hit FOV",
    ["options.thirdperson.follow.hit.fov.help"] = "Follow the hit FOV with the third person camera.",
    ["options.thirdperson.position.x"] = "Position X",
    ["options.thirdperson.position.x.help"] = "Set the X position of the third person camera.",
    ["options.thirdperson.position.y"] = "Position Y",
    ["options.thirdperson.position.y.help"] = "Set the Y position of the third person camera.",
    ["options.thirdperson.position.z"] = "Position Z",
    ["options.thirdperson.position.z.help"] = "Set the Z position of the third person camera.",
    ["options.thirdperson.reset"] = "Reset third person camera position.",
    ["options.thirdperson.toggle"] = "Toggle third person view.",
    ["options.thirdperson.traceplayercheck"] = "Trace Player Check",
    ["options.thirdperson.traceplayercheck.help"] = "Draw only the players that the person would see as if they were in firstperson.",
})

ow.option:Register("thirdperson", {
    Name = "option.thirdperson",
    Type = ow.types.bool,
    Default = false,
    Description = "option.thirdperson.enable.help",
    NoNetworking = true,
    Category = "category.thirdperson"
})

ow.option:Register("thirdperson.follow.head", {
    Name = "options.thirdperson.follow.head",
    Type = ow.types.bool,
    Default = false,
    Description = "options.thirdperson.follow.head.help",
    NoNetworking = true,
    Category = "category.thirdperson"
})

ow.option:Register("thirdperson.follow.hit.angles", {
    Name = "options.thirdperson.follow.hit.angles",
    Type = ow.types.bool,
    Default = true,
    Description = "options.thirdperson.follow.hit.angles.help",
    NoNetworking = true,
    Category = "category.thirdperson"
})

ow.option:Register("thirdperson.follow.hit.fov", {
    Name = "options.thirdperson.follow.hit.fov",
    Type = ow.types.bool,
    Default = true,
    Description = "options.thirdperson.follow.hit.fov.help",
    NoNetworking = true,
    Category = "category.thirdperson"
})

ow.option:Register("thirdperson.position.x", {
    Name = "options.thirdperson.position.x",
    Type = ow.types.number,
    Default = 50,
    Min = -100,
    Max = 100,
    Decimals = 0,
    Description = "options.thirdperson.position.x.help",
    NoNetworking = true,
    Category = "category.thirdperson"
})

ow.option:Register("thirdperson.position.y", {
    Name = "options.thirdperson.position.y",
    Type = ow.types.number,
    Default = 25,
    Min = -100,
    Max = 100,
    Decimals = 0,
    Description = "options.thirdperson.position.y.help",
    NoNetworking = true,
    Category = "category.thirdperson"
})

ow.option:Register("thirdperson.position.z", {
    Name = "options.thirdperson.position.z",
    Type = ow.types.number,
    Default = 0,
    Min = -100,
    Max = 100,
    Decimals = 0,
    Description = "options.thirdperson.position.z.help",
    NoNetworking = true,
    Category = "category.thirdperson"
})

ow.config:Register("thirdperson.tracecheck", {
    Name = "options.thirdperson.traceplayercheck",
    Type = ow.types.bool,
    Default = false,
    Description = "options.thirdperson.traceplayercheck.help",
    Category = "category.thirdperson"
})

local meta = FindMetaTable("Player")
function meta:InThirdperson()
    return SERVER and ow.option:Get(self, "thirdperson", false) or ow.option:Get("thirdperson", false)
end

ow.util:LoadFile("cl_hooks.lua")