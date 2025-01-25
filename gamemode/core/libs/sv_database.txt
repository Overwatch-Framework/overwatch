--- Database library
-- @module ow.database

require("mongo")

ow.database = {}
ow.database.database = nil

local client = MongoDB.Client("mongodb://admin:password@localhost:27017")

--- Initializes the database.
-- @realm server
-- @return boolean Returns true if the database was successfully initialized, false otherwise.
-- @internal
function ow.database:Initialize()
    if ( !SCHEMA ) then
        ow.util:PrintError("Schema not found!")
        return
    end

    local folder = engine.ActiveGamemode()
    local database = client:Database(folder)

    self.database = database

    ow.util:Print("Connected to database \"" .. folder .. "\".")

    return true
end

--- Returns the active database.
-- @realm server
function ow.database:GetDatabase()
    return ow.database.database
end

--- Creates a collection.
-- @realm server
-- @param string name The name of the collection.
-- @return table The collection object.
function ow.database:CreateCollection(name)
    local database = self:GetDatabase()
    if ( !database ) then
        ow.util:PrintError("Database not found!")
        return
    end

    if ( !name or name == "" or string.gsub(name, "%s", "") == "" ) then
        ow.util:PrintError("Invalid collection name!")
        return
    end

    local result = database:CreateCollection(name)
    if ( !result ) then
        ow.util:PrintError("Failed to create collection \"" .. name .. "\"!")
        return
    end

    ow.util:Print("Created collection \"" .. name .. "\".")

    return result
end