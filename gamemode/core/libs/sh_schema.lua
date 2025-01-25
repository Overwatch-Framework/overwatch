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

    ow.util:Print("Searching for schema...")

    local bSuccess = file.Exists(path, "LUA")
    if ( !bSuccess ) then
        ow.util:PrintError("Schema not found!")
        return
    else
        SCHEMA.Folder = folder

        ow.util:Print("Schema found, loading \"" .. SCHEMA.Folder .. "\"...")
        ow.util:LoadFile(path)
    end

    hook.Call("PreSchemaLoad", path, SCHEMA)

    for k, v in pairs(default) do
        if ( !SCHEMA[k] ) then
            SCHEMA[k] = v
        end
    end

    ow.hooks:Register("SCHEMA")
    ow.modules:LoadFolder(folder .. "/modules", true)
    //ow.faction:LoadFolder(folder .. "/schema/factions", true)
    //ow.item:LoadFolder(folder .. "/schema/items", true)

    ow.util:Print("Loaded schema " .. SCHEMA.Name)

    hook.Call("PostSchemaLoad", path, SCHEMA)

    return true
end