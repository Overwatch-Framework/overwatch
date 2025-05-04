local MODULE = MODULE

MODULE.Name = "Animations"
MODULE.Author = "Riggs"
MODULE.Description = "Handles player animations."

ow.animations = ow.animations or {}
ow.animations.stored = ow.animations.stored or {}
ow.animations.translations = ow.animations.translations or {}

ow.animations.stored["citizen_male"] = {
    [ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE}
}

ow.animations.stored["citizen_female"] = {
    [ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE}
}

ow.animations.stored["overwatch"] = {
    [ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE}
}

ow.animations.stored["metrocop"] = {
    [ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE}
}

ow.animations.stored["vortigaunt"] = {
    [ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE}
}

function ow.animations:SetModelClass(model, class)
    if ( !model or !class ) then return end

    class = string.lower(class)

    if ( !self.stored[class] ) then
        ow.util:PrintError("Animation class '" .. class .. "' does not exist!")
        return false
    end

    model = string.lower(model)

    self.translations[model] = class
end

function ow.animations:GetModelClass(model)
    if ( !model ) then return end

    model = string.lower(model)

    if ( self.translations[model] ) then
        return self.translations[model]
    end

    return "citizen_male"
end

ow.animations:SetModelClass("models/combine_soldier.mdl", "overwatch")
ow.animations:SetModelClass("models/combine_soldier_prisonGuard.mdl", "overwatch")
ow.animations:SetModelClass("models/combine_super_soldier.mdl", "overwatch")
ow.animations:SetModelClass("models/police.mdl", "metrocop")
ow.animations:SetModelClass("models/vortigaunt.mdl", "vortigaunt")
ow.animations:SetModelClass("models/vortigaunt_blue.mdl", "vortigaunt")
ow.animations:SetModelClass("models/vortigaunt_doctor.mdl", "vortigaunt")
ow.animations:SetModelClass("models/vortigaunt_slave.mdl", "vortigaunt")

ow.util:LoadFile("cl_module.lua")
ow.util:LoadFile("sv_module.lua")

ow.util:LoadFile("sh_hooks.lua")
ow.util:LoadFile("sv_hooks.lua")