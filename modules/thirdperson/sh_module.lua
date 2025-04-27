local MODULE = MODULE

MODULE.Name = "Third Person"
MODULE.Description = "Allows players to view themselves in third person."
MODULE.Author = "Riggs"

ow.localization:Register("en", {
    ["category.thirdperson"] = "Third Person",
    ["option.thirdperson"] = "Third Person",
    ["option.thirdperson.enable"] = "Enable Third Person",
    ["option.thirdperson.enable.help"] = "Enable or disable third person view.",
    ["options.thirdperson.followhead"] = "Follow Head",
    ["options.thirdperson.followhead.help"] = "Follow the player's head with the third person camera.",
    ["options.thirdperson.position.x"] = "Position X",
    ["options.thirdperson.position.x.help"] = "Set the X position of the third person camera.",
    ["options.thirdperson.position.y"] = "Position Y",
    ["options.thirdperson.position.y.help"] = "Set the Y position of the third person camera.",
    ["options.thirdperson.position.z"] = "Position Z",
    ["options.thirdperson.position.z.help"] = "Set the Z position of the third person camera.",
    ["options.thirdperson.reset"] = "Reset third person camera position.",
    ["options.thirdperson.toggle"] = "Toggle third person view.",
})

ow.option:Register("thirdperson", {
    Name = "option.thirdperson",
    Type = ow.type.bool,
    Default = false,
    Description = "option.thirdperson.enable.help",
    bNoNetworking = true,
    Category = "category.thirdperson"
})

ow.option:Register("thirdperson.followhead", {
    Name = "options.thirdperson.followhead",
    Type = ow.type.bool,
    Default = false,
    Description = "options.thirdperson.followhead.help",
    bNoNetworking = true,
    Category = "category.thirdperson"
})

ow.option:Register("thirdperson.position.x", {
    Name = "options.thirdperson.position.x",
    Type = ow.type.number,
    Default = 50,
    Min = -100,
    Max = 100,
    Decimals = 0,
    Description = "options.thirdperson.position.x.help",
    bNoNetworking = true,
    Category = "category.thirdperson"
})

ow.option:Register("thirdperson.position.y", {
    Name = "options.thirdperson.position.y",
    Type = ow.type.number,
    Default = 25,
    Min = -100,
    Max = 100,
    Decimals = 0,
    Description = "options.thirdperson.position.y.help",
    bNoNetworking = true,
    Category = "category.thirdperson"
})

ow.option:Register("thirdperson.position.z", {
    Name = "options.thirdperson.position.z",
    Type = ow.type.number,
    Default = 0,
    Min = -100,
    Max = 100,
    Decimals = 0,
    Description = "options.thirdperson.position.z.help",
    bNoNetworking = true,
    Category = "category.thirdperson"
})

local meta = FindMetaTable("Player")
function meta:InThirdperson()
    return SERVER and ow.option:Get(self, "thirdperson", false) or ow.option:Get("thirdperson", false)
end

ow.util:LoadFile("cl_hooks.lua")