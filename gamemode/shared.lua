GM.Name = "Overwatch"
GM.Author = "Riggs & eon (bloodycop)"
GM.Description = "A roleplaying gamemode for Garry's Mod."
GM.Version = "Foundation"

ow.util:Print("Initializing...")
ow.util:LoadFolder("core/thirdparty")
ow.util:LoadFolder("core/thirdparty/paint")
ow.util:LoadFolder("core/libs")
ow.util:LoadFolder("core/meta")
ow.util:LoadFolder("core/derma")
ow.util:LoadFolder("core/hooks")
ow.util:LoadFolder("core/net")
ow.util:Print("Initialized.")

ow.util:Print("Initializing Modules...")

local files, directories = file.Find("overwatch/modules/*", "LUA")
for k, v in ipairs(directories) do
    if ( file.Exists("overwatch/modules/" .. v .. "/sh_module.lua", "LUA") ) then
        ow.util:LoadFile("overwatch/modules/" .. v .. "/sh_module.lua")
    else
        ow.util:PrintError("Module " .. v .. " is missing a shared module file.")
    end
end

for k, v in ipairs(files) do
    ow.util:LoadFile("overwatch/modules/" .. v, "shared")
end

ow.util:Print("Initializing Modules.")

function GM:Initialize()
    ow.schema:Initialize()

    hook.Run("LoadFonts")
end

ow.reloaded = false
ow.refresh = ow.refresh or {}
ow.refresh.count = ow.refresh.count or 0
ow.refresh.time = SysTime()

function GM:OnReloaded()
    if ( ow.reloaded ) then return end

    ow.reloaded = true

    ow.schema:Initialize()

    hook.Run("LoadFonts")

    ow.refresh.count = ow.refresh.count + 1
    ow.refresh.time = SysTime() - ow.refresh.time

    ow.util:Print("Reloaded Files (Refreshes: " .. ow.refresh.count .. ", Time: " .. ow.refresh.time .. "s)")

    hook.Run("PostReloaded")
end

ow.util:LoadFile("core/sh_chat.lua")
ow.util:LoadFile("core/sh_colors.lua")
ow.util:LoadFile("core/sh_commands.lua")

concommand.Remove("gm_save")
concommand.Add("gm_save", function(ply, command, arguments)
    ow.util:PrintError("This command has been disabled.", ply)
end)

-- concommand.Remove("gm_admin_cleanup")
-- concommand.Add("gm_admin_cleanup", function(ply, command, arguments)
--     ow.util:PrintError("This command has been disabled.", ply)
-- end)