--- A library for managing modules in the gamemode.
-- @module ow.modules

ow.modules = {}
ow.modules.stored = {}

--- Registers a module.
-- @realm shared
-- @param table info The module information.
-- @return string The unique identifier of the module.
function ow.modules:Register(info)
    if ( !info ) then
        ow.util:PrintError("Attempted to register an invalid module!")
        return
    end

    if ( !info.Name ) then
        info.Name = "Unknown"
    end

    if ( !info.Description ) then
        info.Description = "No description provided."
    end

    if ( !info.Author ) then
        info.Author = "Unknown"
    end

    local uniqueID = string.lower(string.gsub(info.Name, "%s", "_")) 
    info.UniqueID = uniqueID

    self.stored[uniqueID] = info

    return uniqueID
end

--- Returns a module by its unique identifier or name.
-- @realm shared
-- @param string identifier The unique identifier or name of the module.
-- @return table The module.
function ow.modules:Get(identifier)
    if ( !identifier ) then
        ow.util:PrintError("Attempted to get an invalid module!")
        return
    end

    if ( self.stored[identifier] ) then
        return self.stored[identifier]
    end

    for k, v in pairs(self.stored) do
        if ( ow.util:FindString(v.Name, identifier) ) then
            return v
        elseif ( ow.util:FindString(v.UniqueID, identifier) ) then
            return v
        end
    end
end

--- Loads a module from a file.
-- @realm shared
-- @param string path The path to the module file.
-- @param boolean bFromLua Whether the file is being loaded from Lua or not.
-- @return boolean Returns true if the module was successfully loaded, false otherwise.
function ow.modules:LoadFolder(path, bFromLua)
    local baseDir = engine.ActiveGamemode()
    baseDir = baseDir .. "/"

    if ( SCHEMA and SCHEMA.Folder ) then
        baseDir = SCHEMA.Folder .. "/schema/"
    else
        baseDir = baseDir .. "/gamemode/"
    end

    if ( bFromLua ) then
        baseDir = ""
    end

    -- Load modules from the main folder
    for k, v in ipairs(file.Find(baseDir .. path .. "/*.lua", "LUA")) do
        ow.util:LoadFile(path .. "/" .. v)
    end

    -- Load modules from subfolders
    local files, folders = file.Find(baseDir .. path .. "/*", "LUA")
    for k, v in ipairs(folders) do
        local modulePath = baseDir .. path .. "/" .. v .. "/sh_module.lua"

        if ( file.Exists(modulePath, "LUA") ) then
            ow.util:LoadFile(modulePath, true)
        end
    end

    return true
end