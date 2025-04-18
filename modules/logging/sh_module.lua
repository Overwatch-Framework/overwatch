local MODULE = MODULE

MODULE.Name = "Logging"
MODULE.Description = "Adds some sort of logging system."
MODULE.Author = "Riggs, bloodycop"

CAMI.RegisterPrivilege({
    Name = "Overwatch - Logging",
    MinAccess = "admin"
})

function MODULE:FormatPlayer(ply)
    if ( !IsValid(ply) ) then return "Console" end

    return ply:SteamName() .. " (" .. ply:Name() .. " / " .. ply:SteamID64() .. ")"
end

function MODULE:FormatEntity(ent)
    if ( !IsValid(ent) or ent == Entity(0) ) then return "world" end

    if ( ent:IsPlayer() ) then
        return self:FormatPlayer(ent)
    end

    return ent:GetClass() .. " (" .. ent:GetModel() .. " / " .. ent:EntIndex() .. ")"
end

ow.color:Register("ow.log.message", Color(250, 200, 25))

ow.util:LoadFile("cl_module.lua")
ow.util:LoadFile("sv_module.lua")

ow.util:LoadFile("sv_hooks.lua")