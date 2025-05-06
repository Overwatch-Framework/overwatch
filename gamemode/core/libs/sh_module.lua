--- A library for managing modules in the gamemode.
-- @module ow.module

ow.module = {}
ow.module.stored = {}
ow.module.disabled = {}

--- Returns a module by its unique identifier or name.
-- @realm shared
-- @string identifier The unique identifier or name of the module.
-- @return table The module.
function ow.module:Get(identifier)
    if ( identifier == nil or !isstring(identifier) ) then
        ow.util:PrintError("Attempted to get an invalid module!")
        return false
    end

    if ( self.stored[identifier] ) then
        return self.stored[identifier]
    end

    for k, v in pairs(self.stored) do
        if ( ow.util:FindString(v.Name, identifier) ) then
            return v
        end
    end

    return false
end

function ow.module:LoadEntities(path)
    local bLoadedTools
    local files, folders

    local function IncludeFiles(path2, bClientOnly)
        if ( SERVER and !bClientOnly ) then
            if ( file.Exists(path2 .. "init.lua", "LUA") ) then
                ow.util:LoadFile(path2 .. "init.lua", "server")
            elseif ( file.Exists(path2 .. "shared.lua", "LUA") ) then
                ow.util:LoadFile(path2 .. "shared.lua")
            end

            if ( file.Exists(path2 .. "cl_init.lua", "LUA") ) then
                ow.util:LoadFile(path2 .. "cl_init.lua", "client")
            end
        elseif ( file.Exists(path2 .. "cl_init.lua", "LUA") ) then
            ow.util:LoadFile(path2 .. "cl_init.lua", "client")
        elseif ( file.Exists(path2 .. "shared.lua", "LUA") ) then
            ow.util:LoadFile(path2 .. "shared.lua")
        end
    end

    local function HandleEntityInclusion(folder, variable, register, default, clientOnly, create, complete)
        files, folders = file.Find(path .. "/" .. folder .. "/*", "LUA")
        default = default or {}

        for _, v in ipairs(folders) do
            local path2 = path .. "/" .. folder .. "/" .. v .. "/"
            if ( string.sub(v, 1, 3) == "cl_" or string.sub(v, 1, 3) == "sh_" or string.sub(v, 1, 3) == "sv_" ) then
                v = string.sub(v, 4)
            end

            _G[variable] = table.Copy(default)

            if ( !isfunction(create) ) then
                _G[variable].ClassName = v
            else
                create(v)
            end

            IncludeFiles(path2, clientOnly)

            if ( clientOnly ) then
                if ( CLIENT ) then
                    register(_G[variable], v)
                end
            else
                register(_G[variable], v)
            end

            if ( isfunction(complete) ) then
                complete(_G[variable])
            end

            _G[variable] = nil
        end

        for _, v in ipairs(files) do
            local niceName = string.sub(v, 4, -5)
            niceName = string.StripExtension(niceName)

            _G[variable] = table.Copy(default)

            if ( !isfunction(create) ) then
                _G[variable].ClassName = niceName
            else
                create(niceName)
            end

            ow.util:LoadFile(path .. "/" .. folder .. "/" .. v, clientOnly and "client" or "shared")

            if ( clientOnly ) then
                if ( CLIENT ) then
                    register(_G[variable], niceName)
                end
            else
                register(_G[variable], niceName)
            end

            if ( isfunction(complete) ) then
                complete(_G[variable])
            end

            _G[variable] = nil
        end
    end

    local function RegisterTool(tool, className)
        local gmodTool = weapons.GetStored("gmod_tool")

        if ( className:sub(1, 3) == "sh_" ) then
            className = className:sub(4)
        end

        if ( gmodTool ) then
            gmodTool.Tool[className] = tool
        else
            ErrorNoHalt(string.format("attempted to register tool '%s' with invalid gmod_tool weapon", className))
        end

        bLoadedTools = true
    end

    HandleEntityInclusion("entities", "ENT", scripted_ents.Register, {
        Type = "anim",
        Base = "base_gmodentity",
        Spawnable = true
    }, false)

    HandleEntityInclusion("weapons", "SWEP", weapons.Register, {
        Primary = {},
        Secondary = {},
        Base = "weapon_base"
    })

    HandleEntityInclusion("tools", "TOOL", RegisterTool, {}, false, function(className)
        if (className:sub(1, 3) == "sh_") then
            className = className:sub(4)
        end

        TOOL = ow.tool:Create()
        TOOL.Mode = className
        TOOL:CreateConVars()
    end)

    HandleEntityInclusion("effects", "EFFECT", effects and effects.Register, nil, true)

    if ( CLIENT and bLoadedTools ) then
        RunConsoleCommand("spawnmenu_reload")
    end
end

function ow.module:LoadFolder(path)
    if ( !path or path == "" ) then
        ow.util:PrintError("Attempted to load an invalid module folder!")
        return false
    end

    hook.Run("PreInitializeModules")

    ow.util:Print("Loading modules from \"" .. path .. "\"...")

    local files, folders = file.Find(path .. "/*", "LUA")
    for k, v in ipairs(folders) do
        if ( file.Exists(path .. "/" .. v .. "/sh_module.lua", "LUA") ) then
            MODULE = { UniqueID = v }
                hook.Run("PreInitializeModule", MODULE)
                ow.util:LoadFile(path .. "/" .. v .. "/sh_module.lua", "shared")
                ow.util:LoadFolder(path .. "/" .. v .. "/derma", true)
                self:LoadEntities(path .. "/" .. v .. "/entities")
                self.stored[v] = MODULE
                hook.Run("PostInitializeModule", MODULE)
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

        local realm = "shared"
        if ( string.sub(v, 1, 3) == "cl_" ) then
            realm = "client"
        elseif ( string.sub(v, 1, 3) == "sv_" ) then
            realm = "server"
        end

        MODULE = { UniqueID = ModuleUniqueID }
            hook.Run("PreInitializeModule", MODULE)
            ow.util:LoadFile(path .. "/" .. v, realm)
            self.stored[ModuleUniqueID] = MODULE
            hook.Run("PostInitializeModule", MODULE)
        MODULE = nil
    end

    ow.util:Print("Loaded " .. #files .. " files and " .. #folders .. " folders from \"" .. path .. "\", total " .. (#files + #folders) .. " modules.")

    hook.Run("PostInitializeModules")
end