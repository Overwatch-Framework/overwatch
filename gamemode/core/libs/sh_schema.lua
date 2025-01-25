--- Schema library.
-- @module ow.schema

ow.schema = ow.schema or {}

local default = {
    Name = "Unknown",
    Description = "No description available.",
    Author = "Unknown"
}

--- Initializes the schema.
-- @realm shared
-- @return boolean Returns true if the schema was successfully initialized, false otherwise.
-- @internal
function ow.schema.Initialize()
    SCHEMA = {}

    local folder = engine.ActiveGamemode()
    local path = folder .. "/schema/sh_schema.lua"

    ow.util.Print("Searching for schema...")

    local bSuccess = file.Exists(path, "LUA")
    if ( !bSuccess ) then
        ow.util.PrintError("Schema not found!")
        return
    else
        SCHEMA.Folder = folder

        ow.util.Print("Schema found, loading \"" .. SCHEMA.Folder .. "\"...")
        ow.util.LoadFile(path)
    end

    hook.Run("PreSchemaLoad", path, SCHEMA)

    for k, v in pairs(default) do
        if ( !SCHEMA[k] ) then
            SCHEMA[k] = v
        end
    end

    ow.hooks.Register("SCHEMA")
    ow.modules.LoadFolder(folder .. "/modules", true)

    ow.util.Print("Loaded schema " .. SCHEMA.Name)

    hook.Run("PostSchemaLoad", path, SCHEMA)

    return true
end