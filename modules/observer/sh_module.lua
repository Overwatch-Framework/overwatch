local MODULE = MODULE

MODULE.Name = "Observer"
MODULE.Author = "Riggs & bloodycop"
MODULE.Description = "Provides a system for observer mode."

local meta = FindMetaTable("Player")
function meta:InObserver()
    return self:GetMoveType() == MOVETYPE_NOCLIP and CAMI.PlayerHasAccess(self, "Overwatch - Observer", nil)
end

CAMI.RegisterPrivilege({
    Name = "Overwatch - Observer",
    MinAccess = "admin"
})

ow.util:LoadFile("sh_hooks.lua")
ow.util:LoadFile("sv_hooks.lua")