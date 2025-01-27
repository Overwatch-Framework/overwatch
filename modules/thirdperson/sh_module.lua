local MODULE = MODULE

MODULE.Name = "Third Person"
MODULE.Description = "Allows players to view themselves in third person."
MODULE.Author = "Riggs"

ow.localization:Register("eng", {
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
    ["ow.options.thirdperson.toggle"] = "Toggle third person view."
})

ow.util:LoadFile("cl_hooks.lua")