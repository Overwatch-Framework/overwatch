--- Schema library.
-- @module ow.schema

ow.schema = {}

local default = {
    Name = "Unknown",
    Description = "No description available.",
    Author = "Unknown"
}

--- Initializes the schema.
-- @realm shared
-- @return boolean Returns true if the schema was successfully initialized, false otherwise.
-- @internal
function ow.schema:Initialize()
    SCHEMA = {}

    local folder = engine.ActiveGamemode()
    local path = folder .. "/schema/sh_schema.lua"

    file.CreateDir("overwatch/" .. folder)

    ow.util:Print("Searching for schema...")

    local bSuccess = file.Exists(path, "LUA")
    if ( !bSuccess ) then
        ow.util:PrintError("Schema not found!")
        return false
    else
        SCHEMA.Folder = folder

        ow.util:Print("Schema found, loading \"" .. SCHEMA.Folder .. "\"...")
        ow.util:LoadFile(path)
    end

    hook.Run("PreInitializeSchema", SCHEMA, path)

    for k, v in pairs(default) do
        if ( !SCHEMA[k] ) then
            SCHEMA[k] = v
        end
    end

    ow.hooks:Register("SCHEMA")
    ow.util:LoadFolder(folder .. "/schema/factions", true)
    ow.item:LoadFolder(folder .. "/schema/items")
    ow.util:LoadFolder(folder .. "/schema/config", true)

    -- Load the current map config if it exists
    local map = game.GetMap()
    path = folder .. "/schema/config/maps/" .. map .. ".lua"
    if ( file.Exists(path, "LUA") ) then
        hook.Run("PreInitializeMapConfig", SCHEMA, path, map)
        ow.util:Print("Loading map config for \"" .. map .. "\"...")
        ow.util:LoadFile(path, "shared")
        ow.util:Print("Loaded map config for \"" .. map .. "\".")
        hook.Run("PostInitializeMapConfig", SCHEMA, path, map)
    else
        ow.util:PrintError("Failed to find map config for \"" .. map .. "\".")
    end

    if ( SERVER ) then
        ow.config:Load()
    end

    ow.module:LoadFolder(folder .. "/modules")

    ow.util:Print("Loaded schema " .. SCHEMA.Name)

    hook.Run("PostInitializeSchema", SCHEMA, path)

    return true
end