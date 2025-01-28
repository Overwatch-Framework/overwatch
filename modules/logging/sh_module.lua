local MODULE = MODULE

MODULE.Name = "Logging"
MODULE.Description = "Adds some sort of logging system."
MODULE.Author = "Riggs, eon (bloodycop)"

CAMI.RegisterPrivilege({
    Name = "Overwatch - Logging",
    MinAccess = "admin"
})

function MODULE:FormatPlayer(ply)
    if ( !IsValid(ply) ) then return "Console" end

    return ply:SteamName() .. " (" .. ply:SteamID64() .. ")"
end

ow.color:Register("ow.log.message", Color(250, 200, 25))

ow.util:LoadFile("cl_module.lua")
ow.util:LoadFile("sv_module.lua")

ow.util:LoadFile("sv_hooks.lua")