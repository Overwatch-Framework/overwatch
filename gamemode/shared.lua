
--- Top-level library containing all Helix libraries. A large majority of the framework is split into respective libraries that
-- reside within `ow`.
-- @module ow

--- A table of variable types that are used throughout the framework. It represents types as a table with the keys being the
-- name of the type, and the values being some number value. **You should never directly use these number values!** Using the
-- values from this table will ensure backwards compatibility if the values in this table change.
--
-- This table also contains the numerical values of the types as keys. This means that if you need to check if a type exists, or
-- if you need to get the name of a type, you can do a table lookup with a numerical value. Note that special types are not
-- included since they are not real types that can be compared with.
-- @table ow.type
-- @realm shared
-- @field string A regular string.
-- @field text A regular string that can contain newlines.
-- @field number Any number.
-- @field player Any player that matches the given query string in `ow.util.FindPlayer`.
-- @field steamid A string that matches the Steam ID format of `STEAM_X:X:XXXXXXXX`.
-- @field character Any player's character that matches the given query string in `ow.util.FindPlayer`.
-- @field bool A string representation of a bool - `false` and `0` will return `false`, anything else will return `true`.
-- @field color A color represented by its red/green/blue/alpha values.
-- @field vector A 3D vector represented by its x/y/z values.
-- @field optional This is a special type that can be bitwise OR'd with any other type to make it optional.
-- @field array This is a special type that can be bitwise OR'd with any other type to make it an array of that type.
-- @usage -- checking if type exists
-- print(ow.type[2] != nil)
-- > true
--
-- -- getting name of type
-- print(ow.type[ow.type.string])
-- > "string"
ow.type = ow.type or {}

GM.Name = "Overwatch"
GM.Author = "Riggs & eon (bloodycop)"
GM.Description = "A roleplaying gamemode for Garry's Mod."
GM.Version = "Foundation"

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

ow.util:Print("Initializing Modules...")

local files, directories = file.Find("overwatch/modules/*", "LUA")
for k, v in ipairs(directories) do
    if ( file.Exists("overwatch/modules/" .. v .. "/sh_module.lua", "LUA") ) then
        MODULE = { UniqueID = v }
            ow.util:LoadFile("overwatch/modules/" .. v .. "/sh_module.lua")
            ow.module.stored[v] = MODULE
        MODULE = nil
    else
        ow.util:PrintError("Module " .. v .. " is missing a shared module file.")
    end
end

for k, v in ipairs(files) do
    local ModuleUniqueID = string.StripExtension(v)
    if ( string.sub(v, 1, 3) == "cl_" or string.sub(v, 1, 3) == "sv_" or string.sub(v, 1, 3) == "sh_" ) then
        ModuleUniqueID = string.gsub(ModuleUniqueID, "cl_", "")
        ModuleUniqueID = string.gsub(ModuleUniqueID, "sv_", "")
        ModuleUniqueID = string.gsub(ModuleUniqueID, "sh_", "")
    end

    MODULE = { UniqueID = ModuleUniqueID }
        hook.Run("PreModuleLoad", ModuleUniqueID, MODULE)
        ow.util:LoadFile("overwatch/modules/" .. v, "shared")
        ow.module.stored[ModuleUniqueID] = MODULE
        hook.Run("PostModuleLoad", ModuleUniqueID, MODULE)
    MODULE = nil
end

ow.util:Print("Initialized Modules.")

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

ow.util:LoadFile("core/sh_cami.lua")
ow.util:LoadFile("core/sh_characters.lua")
ow.util:LoadFile("core/sh_chat.lua")
ow.util:LoadFile("core/sh_colors.lua")
ow.util:LoadFile("core/sh_commands.lua")
ow.util:LoadFile("core/sh_configs.lua")

concommand.Remove("gm_save")
concommand.Add("gm_save", function(ply, command, arguments)
    ow.util:PrintError("This command has been disabled.", ply)
end)

-- concommand.Remove("gm_admin_cleanup")
-- concommand.Add("gm_admin_cleanup", function(ply, command, arguments)
--     ow.util:PrintError("This command has been disabled.", ply)
-- end)

ow.debugMode = CreateConVar("ow_debug", "0", FCVAR_ARCHIVE, "Enable debug mode.", 0, 1)