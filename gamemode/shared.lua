
--- Top-level library containing all Overwatch libraries. A large majority of the framework is split into respective libraries that
-- reside within `ow`.
-- @module ow
-- @author riggs9162 & bloodycop6385

GM.Name = "Overwatch"
GM.Author = "Riggs & bloodycop"
GM.Description = "A roleplaying gamemode for Garry's Mod."
GM.Version = "alpha-0.1.0"

function widgets.PlayerTick()
end

hook.Remove("PlayerTick", "TickWidgets")

ow.util:Print("Initializing...")
ow.util:LoadFolder("core/libs")
ow.util:LoadFolder("core/thirdparty")
ow.util:LoadFolder("core/thirdparty/paint")
ow.util:LoadFolder("core/meta")
ow.util:LoadFolder("core/derma")
ow.util:LoadFolder("core/hooks")
ow.util:LoadFolder("core/net")
ow.util:LoadFolder("core/languages")
ow.util:Print("Initialized.")

ow.reloaded = false
ow.refresh = ow.refresh or {}
ow.refresh.count = ow.refresh.count or 0
ow.refresh.time = SysTime()

function GM:OnReloaded()
    if ( ow.reloaded ) then return end

    ow.reloaded = true

    ow.module:LoadFolder("overwatch/modules")
    ow.item:LoadFolder("overwatch/gamemode/items")
    ow.schema:Initialize()

    if ( CLIENT ) then
        ow.option:Load()
    else
        ow.config:Load()
    end

    hook.Run("LoadFonts")

    ow.refresh.count = ow.refresh.count + 1
    ow.refresh.time = SysTime() - ow.refresh.time

    ow.util:Print("Reloaded Files (Refreshes: " .. ow.refresh.count .. ", Time: " .. ow.refresh.time .. "s)")

    hook.Run("PostReloaded")
end

ow.util:LoadFile("core/sh_cami.lua")
ow.util:LoadFile("core/sh_characters.lua")
ow.util:LoadFile("core/sh_chat.lua")
ow.util:LoadFile("core/sh_colors.lua")
ow.util:LoadFile("core/sh_commands.lua")
ow.util:LoadFile("core/sh_configs.lua")
ow.util:LoadFile("core/sh_options.lua")
ow.util:LoadFile("core/cl_debug.lua")

concommand.Remove("gm_save")
concommand.Add("gm_save", function(client, command, arguments)
    client:Notify("This command has been disabled!")
end)

-- concommand.Remove("gm_admin_cleanup")
-- concommand.Add("gm_admin_cleanup", function(client, command, arguments)
--     ow.util:PrintError("This command has been disabled.", client)
-- end)