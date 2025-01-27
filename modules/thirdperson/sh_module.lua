local MODULE = MODULE

MODULE.Name = "Third Person"
MODULE.Description = "Allows players to view themselves in third person."
MODULE.Author = "Riggs"

ow.localization:Register("english", {
    ["ow.option.thirdperson"] = "Third Person",
    ["ow.option.thirdperson.enable"] = "Enable Third Person",
    ["ow.option.thirdperson.enable.help"] = "Enable or disable third person view.",
    ["ow.option.thirdperson.distance"] = "Third Person Distance",
    ["ow.option.thirdperson.distance.help"] = "Set the distance of the third person camera.",
    ["ow.option.thirdperson.angles"] = "Third Person Angles",
    ["ow.option.thirdperson.angles.help"] = "Set the angles of the third person camera.",
    ["ow.option.thirdperson.angles.pitch"] = "Pitch",
    ["ow.option.thirdperson.angles.yaw"] = "Yaw",
    ["ow.option.thirdperson.angles.roll"] = "Roll",
    ["ow.option.thirdperson.angles.reset"] = "Reset",
})

ow.util:LoadFile("cl_hooks.lua")