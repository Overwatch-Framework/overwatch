--- Database library for Overwatch; handles database connections using sqlite, mysqoo, or tmysql4.
-- This library was taken from Helix and modified to work with Overwatch.
-- @module ow.database

ow.database = ow.database or {
    schema = {},
    schemaQueue = {},
    type = {
        [ow.type.string] = "VARCHAR(255)",
        [ow.type.text] = "TEXT",
        [ow.type.number] = "INT(11)",
        [ow.type.steamid] = "VARCHAR(20)",
        [ow.type.bool] = "TINYINT(1)"
    }
}

ow.database.config = ow.config.server.database or {}

--- Establishes a connection to the database.
-- @realm server
-- @param folder The folder to read configuration from.
function ow.database:Connect(folder)
    ow.config.server = folder and ow.yaml.Read("gamemodes/" .. folder.. "/config.yml") or ow.config.server
    ow.database.config = ow.config.server.database or ow.database.config

    ow.database.config.adapter = ow.database.config.adapter or "sqlite"

    local dbmodule = ow.database.config.adapter
    local hostname = ow.database.config.hostname
    local username = ow.database.config.username
    local password = ow.database.config.password
    local database = ow.database.config.database
    local port = ow.database.config.port

    mysql:SetModule(dbmodule)
    mysql:Connect(hostname, username, password, database, port)
end

--- Adds a new field to the schema.
-- @realm server
-- @param schemaType The type of schema to modify.
-- @param field The field name.
-- @param fieldType The type of the field.
function ow.database:AddToSchema(schemaType, field, fieldType)
    if ( !ow.database.type[fieldType] ) then
        error(string.format("attempted to add field in schema with invalid type '%s'", fieldType))
        return
    end

    if ( !mysql:IsConnected() or !ow.database.schema[schemaType] ) then
        ow.database.schemaQueue[#ow.database.schemaQueue + 1] = {schemaType, field, fieldType}
        return
    end

    ow.database:InsertSchema(schemaType, field, fieldType)
end

--- Inserts a new field into the schema. (Internal use only)
-- @realm server
-- @param schemaType The type of schema to modify.
-- @param field The field name.
-- @param fieldType The type of the field.
function ow.database:InsertSchema(schemaType, field, fieldType)
    local schema = ow.database.schema[schemaType]
    if ( !schema ) then
        error(string.format("attempted to insert into schema with invalid schema type '%s'", schemaType))
        return
    end

    if ( !schema[field] ) then
        schema[field] = true

        local query = mysql:Update("overwatch_schema")
            query:Update("columns", util.TableToJSON(schema))
            query:Where("table", schemaType)
        query:Execute()

        query = mysql:Alter(schemaType)
            query:Add(field, ow.database.type[fieldType])
        query:Execute()
    end
end

--- Loads database tables and schema.
-- @realm server
function ow.database:LoadTables()
    local query

    query = mysql:Create("overwatch_players")
        query:Create("steamid64", "VARCHAR(20) NOT NULL")
        query:Create("steamname", "VARCHAR(255) NOT NULL")
        query:Create("data", "TEXT")
        query:PrimaryKey("steamid64")
    query:Execute()

    query = mysql:Create("overwatch_schema")
        query:Create("table", "VARCHAR(64) NOT NULL")
        query:Create("columns", "TEXT NOT NULL")
        query:PrimaryKey("table")
    query:Execute()

    query = mysql:Create("overwatch_characters")
        query:Create("id", "INT(11) UNSIGNED NOT NULL AUTO_INCREMENT")
        query:Create("player_id", "VARCHAR(20) NOT NULL")
        query:PrimaryKey("id")
    query:Execute()

    query = mysql:Create("overwatch_inventory")
        query:Create("inventory_id", "INT(11) UNSIGNED NOT NULL AUTO_INCREMENT")
        query:Create("character_id", "INT(11) UNSIGNED NOT NULL")
        query:Create("inventory_type", "VARCHAR(150) DEFAULT NULL")
        query:Create("data", "TEXT")
        query:PrimaryKey("inventory_id")
    query:Execute()

    query = mysql:Create("overwatch_items")
        query:Create("owner_id", "INT(11) NOT NULL")
        query:Create("unique_id", "VARCHAR(255) NOT NULL")
        query:Create("item_id", "INT(11) NOT NULL")
        query:Create("data", "TEXT")
        query:PrimaryKey("unique_id")
    query:Execute()

    -- populate schema table if rows don't exist
    query = mysql:InsertIgnore("overwatch_schema")
        query:Insert("table", "overwatch_characters")
        query:Insert("columns", util.TableToJSON({}))
    query:Execute()

    -- load schema from database
    query = mysql:Select("overwatch_schema")
        query:Callback(function(result)
            if ( !istable(result) ) then return end

            for _, v in pairs(result) do
                ow.database.schema[v.table] = util.JSONToTable(v.columns)
            end

            -- update schema if needed
            for i = 1, #ow.database.schemaQueue do
                local entry = ow.database.schemaQueue[i]
                ow.database.InsertSchema(entry[1], entry[2], entry[3])
            end
        end)
    query:Execute()
end

--- Wipes all database tables.
-- @realm server
-- @param callback A function to call after tables are wiped.
function ow.database:WipeTables(callback)
    local query

    query = mysql:Drop("overwatch_schema")
    query:Execute()

    query = mysql:Drop("overwatch_characters")
    query:Execute()

    query = mysql:Drop("overwatch_inventories")
    query:Execute()

    query = mysql:Drop("overwatch_items")
    query:Execute()

    query = mysql:Drop("overwatch_players")
        query:Callback(callback)
    query:Execute()
end

hook.Add("InitPostEntity", "OverwatchDatabaseConnect", function()
    -- Connect to the database using SQLite, mysqoo, or tmysql4.
    ow.database:Connect(Schema.folder)
end)

local resetCalled = 0

--- Console command to wipe the database.
-- Requires confirmation within 3 seconds.
-- @realm server
-- @param ply The player executing the command.
function ow.database:Wipe(ply)
    if ( IsValid(ply) or !IsValid(ply) and !ply:IsListenServerHost() ) then return end

    if ( resetCalled < RealTime() ) then
        resetCalled = RealTime() + 3

        ow.util:PrintWarning("WIPING THE DATABASE WILL PERMANENTLY REMOVE ALL PLAYER, CHARACTER, ITEM, AND INVENTORY DATA.")
        ow.util:PrintWarning("THE SERVER WILL RESTART TO APPLY THESE CHANGES WHEN COMPLETED.")
        ow.util:PrintWarning("TO CONFIRM DATABASE RESET, RUN 'overwatch_database_wipe' AGAIN WITHIN 3 SECONDS.")
    else
        resetCalled = 0
        ow.util:PrintWarning("DATABASE WIPE IN PROGRESS...")

        hook.Run("OnWipeTables")

        ow.database:WipeTables(function()
            ow.util:PrintWarning("DATABASE WIPE COMPLETED!")
            RunConsoleCommand("changelevel", game.GetMap())
        end)
    end
end

concommand.Add("overwatch_database_wipe", ow.database.Wipe)