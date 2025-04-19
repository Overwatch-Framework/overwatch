if ( !tobool(CAMI) ) then
    ow.util:PrintError("CAMI is not installed.")
    return
end

CAMI.RegisterPrivilege({
    Name = "Overwatch - Toolgun",
    MinAccess = "admin"
})

CAMI.RegisterPrivilege({
    Name = "Overwatch - Physgun",
    MinAccess = "admin"
})

CAMI.RegisterPrivilege({
    Name = "Overwatch - Manage Flags",
    MinAccess = "admin"
})

CAMI.RegisterPrivilege({
    Name = "Overwatch - Manage Config",
    MinAccess = "superadmin",
})