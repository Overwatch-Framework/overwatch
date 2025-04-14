local MODULE = MODULE

MODULE.Name = "Observer"
MODULE.Author = "Riggs & bloodycop"
MODULE.Description = "Provides a system for observer mode."

CAMI.RegisterPrivilege({
    Name = "Overwatch - Observer",
    MinAccess = "admin"
})

ow.util:LoadFile("sh_hooks.lua")
ow.util:LoadFile("sv_hooks.lua")