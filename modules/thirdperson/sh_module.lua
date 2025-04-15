local MODULE = MODULE

MODULE.Name = "Third Person"
MODULE.Description = "Allows players to view themselves in third person."
MODULE.Author = "Riggs"

ow.localization:Register("en", {
    ["ow.option.thirdperson"] = "Third Person",

    ["ow.option.thirdperson.enable"] = "Enable Third Person",
    ["ow.option.thirdperson.enable.help"] = "Enable or disable third person view.",

    ["ow.options.thirdperson.followhead"] = "Follow Head",
    ["ow.options.thirdperson.followhead.help"] = "Follow the player's head with the third person camera.",

    ["ow.options.thirdperson.position.x"] = "Position X",
    ["ow.options.thirdperson.position.x.help"] = "Set the X position of the third person camera.",

    ["ow.options.thirdperson.position.y"] = "Position Y",
    ["ow.options.thirdperson.position.y.help"] = "Set the Y position of the third person camera.",

    ["ow.options.thirdperson.position.z"] = "Position Z",
    ["ow.options.thirdperson.position.z.help"] = "Set the Z position of the third person camera.",

    ["ow.options.thirdperson.reset"] = "Reset third person camera position.",
    ["ow.options.thirdperson.toggle"] = "Toggle third person view.",

    ["ow.category.thirdperson"] = "Third Person",
})

ow.option:Register("thirdperson", {
    DisplayName = "ow.option.thirdperson",
    Type = ow.type.bool,
    Default = false,
    Description = "ow.option.thirdperson.enable.help",
    Category = "ow.category.thirdperson"
})

ow.option:Register("thirdperson.followhead", {
    DisplayName = "ow.options.thirdperson.followhead",
    Type = ow.type.bool,
    Default = false,
    Description = "ow.options.thirdperson.followhead.help",
    Category = "ow.category.thirdperson"
})

ow.option:Register("thirdperson.position.x", {
    DisplayName = "ow.options.thirdperson.position.x",
    Type = ow.type.number,
    Default = 0,
    Description = "ow.options.thirdperson.position.x.help",
    Category = "ow.category.thirdperson"
})

ow.option:Register("thirdperson.position.y", {
    DisplayName = "ow.options.thirdperson.position.y",
    Type = ow.type.number,
    Default = 0,
    Description = "ow.options.thirdperson.position.y.help",
    Category = "ow.category.thirdperson"
})

ow.option:Register("thirdperson.position.z", {
    DisplayName = "ow.options.thirdperson.position.z",
    Type = ow.type.number,
    Default = 0,
    Description = "ow.options.thirdperson.position.z.help",
    Category = "ow.category.thirdperson"
})

local meta = FindMetaTable("Player")
function meta:InThirdperson()
    return SERVER and ow.option:Get(self, "thirdperson", false) or ow.option:Get("thirdperson", false)
end

ow.util:LoadFile("cl_hooks.lua")