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

function ow.module:LoadFolder(path)
    if ( !path or path == "" ) then
        ow.util:PrintError("Attempted to load an invalid module folder!")
        return false
    end

    ow.util:Print("Loading modules from \"" .. path .. "\"...")

    local files, folders = file.Find(path .. "/*", "LUA")
    for k, v in ipairs(folders) do
        if ( file.Exists(path .. "/" .. v .. "/sh_module.lua", "LUA") ) then
            MODULE = { UniqueID = v }
                hook.Run("PreModuleLoad", v, MODULE)
                ow.util:LoadFile(path .. "/" .. v .. "/sh_module.lua", "shared")
                self.stored[v] = MODULE
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
            hook.Run("PreModuleLoad", ModuleUniqueID, MODULE)
            ow.util:LoadFile(path .. "/" .. v, realm)
            self.stored[ModuleUniqueID] = MODULE
            hook.Run("PostModuleLoad", ModuleUniqueID, MODULE)
        MODULE = nil
    end

    ow.util:Print("Loaded " .. #files .. " files and " .. #folders .. " folders from \"" .. path .. "\", total " .. (#files + #folders) .. " modules.")

    hook.Run("ModulesInitialized")
end