require("mongo")

local client = MongoDB.Client("mongodb://admin:password@localhost:27017")

ow.database = ow.database or {}
ow.database.database = nil

function ow.database.Initialize()
    if ( !SCHEMA ) then
        ow.util.PrintError("Schema not found!")
        return
    end

    local folder = engine.ActiveGamemode()
    local database = client:Database(folder)

    ow.database.database = database

    ow.util.Print("Connected to database \"" .. folder .. "\".")

    return true
end

function ow.database.GetDatabase()
    return ow.database.database
end

function ow.database.CreateCollection(name)
    local database = ow.database.GetDatabase()
    if ( !database ) then
        ow.util.PrintError("Database not found!")
        return
    end

    if ( !name or name == "" or string.gsub(name, "%s", "") == "" ) then
        ow.util.PrintError("Invalid collection name!")
        return
    end

    local result = database:CreateCollection(name)
    if ( !result ) then
        ow.util.PrintError("Failed to create collection \"" .. name .. "\"!")
        return
    end

    ow.util.Print("Created collection \"" .. name .. "\".")

    return result
end