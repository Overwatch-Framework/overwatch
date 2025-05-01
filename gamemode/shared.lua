
--- Top-level library containing all Overwatch libraries. A large majority of the framework is split into respective libraries that
-- reside within `ow`.
-- @module ow
-- @author riggs9162 & bloodycop6385

GM.Name = "Overwatch"
GM.Author = "Riggs & bloodycop"
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
				hook.Run("PreModuleLoad", v, MODULE)
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
			ModuleUniqueID = string.sub(v, 4)
		end

		MODULE = { UniqueID = ModuleUniqueID }
			hook.Run("PreModuleLoad", ModuleUniqueID, MODULE)
			ow.util:LoadFile("overwatch/modules/" .. v, "shared")
			ow.module.stored[ModuleUniqueID] = MODULE
			hook.Run("PostModuleLoad", ModuleUniqueID, MODULE)
		MODULE = nil
	end
ow.util:Print("Initialized Modules.")
hook.Run("ModulesInitialized")

ow.reloaded = false
ow.refresh = ow.refresh or {}
ow.refresh.count = ow.refresh.count or 0
ow.refresh.time = SysTime()

function GM:OnReloaded()
	if ( ow.reloaded ) then return end

	ow.reloaded = true

	ow.schema:Initialize()

	if ( CLIENT ) then
		ow.option:Load()
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

concommand.Remove("gm_save")
concommand.Add("gm_save", function(ply, command, arguments)
	ply:Notify("This command has been disabled!")
end)

-- concommand.Remove("gm_admin_cleanup")
-- concommand.Add("gm_admin_cleanup", function(ply, command, arguments)
--     ow.util:PrintError("This command has been disabled.", ply)
-- end)