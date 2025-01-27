--- Database library
-- @module ow.database

ow.database = ow.database or {}
ow.database.config = ow.database.config or {}
ow.database.altered = ow.database.altered or {}

--- Sets up the configuration for the database.
-- @realm server
-- @param string host The host of the database.
-- @param string port The port of the database.
-- @param string database The name of the database.
-- @param string username The username of the database.
-- @param string password The password of the database.
-- @param string adapter The adapter of the database. (sqlite, mysqloo, etc.)
-- @internal
function ow.database:Setup(host, port, database, username, password, adapter)
    self.config.host = host
    self.config.port = port
    self.config.database = database
    self.config.username = username
    self.config.password = password
    self.config.adapter = adapter
end

--- Initializes the database.
-- @realm server
-- @return boolean Returns true if the database was successfully initialized, false otherwise.
-- @internal
function ow.database:Initialize()
    for k, v in pairs(self.config) do
        if ( !v or v == "" ) then
            ow.util:PrintError("Database configuration for \"" .. k .. "\" is missing or invalid, please check your configuration!")
            return false
        end
    end

    if ( !SCHEMA ) then
        ow.util:PrintError("Schema not found!")
        return
    end

    local query
    query = mysql:Create("overwatch_players")
        query:Create("steamid64", "VARCHAR(20) NOT NULL")
        query:Create("steamname", "VARCHAR(255) NOT NULL")
        query:Create("data", "TEXT")
        query:PrimaryKey("steamid64")
    query:Execute()

    -- ow.characters.RegisterVariable will take care of the rest of the character data
    query = mysql:Create("overwatch_characters")
        query:Create("id", "INT(11) NOT NULL AUTO_INCREMENT")
        query:Create("player_id", "VARCHAR(20) NOT NULL")
        query:PrimaryKey("id")
    query:Execute()

    query = mysql:Create("overwatch_inventory")
        query:Create("id", "INT(11) NOT NULL AUTO_INCREMENT")
        query:Create("character_id", "INT(11) NOT NULL")
        query:Create("data", "TEXT")
        query:PrimaryKey("id")
    query:Execute()

    query = mysql:Create("overwatch_items")
        query:Create("owner_id", "INT(11) NOT NULL")
        query:Create("unique_id", "VARCHAR(255) NOT NULL")
        query:Create("data", "TEXT")
    query:Execute()
end

function ow.database:Alter(base, field, fieldType)
    if ( !base or !field or !fieldType ) then return end

    if ( self.altered[field] ) then
        ow.util:PrintWarning("Field \"" .. field .. "\" has already been altered in the " .. base .. " table.")
        return
    end

    self.altered[field] = true

    local query = mysql:Alter(base)
        query:Add(field, fieldType)
    query:Execute()
end

--- Connects to the database.
-- @realm server
-- @internal
function ow.database:Connect()
    mysql:SetModule(self.config.adapter)
    mysql:Connect(self.config.host, self.config.username, self.config.password, self.config.database, tonumber(self.config.port))
end