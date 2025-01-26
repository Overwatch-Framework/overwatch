--- Database library
-- @module ow.database

ow.database = {}
ow.database.config = ow.database.config or {}

--- Sets up the configuration for the database.
-- @realm server
-- @param string host The host of the database.
-- @param string port The port of the database.
-- @param string database The name of the database.
-- @param string username The username of the database.
-- @param string password The password of the database.
-- @param string module The module of the database. (sqlite, mysqloo, etc.)
-- @internal
function ow.database:Setup(host, port, database, username, password, module)
    self.config.host = host
    self.config.port = port
    self.config.database = database
    self.config.username = username
    self.config.password = password
    self.config.module = module
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

    local databaseModule = self.config.module
    if ( databaseModule == "mysqloo" ) then
        require("mysqloo")

        self.db = mysqloo.connect(self.config.host, self.config.username, self.config.password, self.config.database, self.config.port)

        self.db.onConnected = function()
            ow.util:Print(Color(0, 255, 0), "Connected to the database.")
        end

        self.db.onConnectionFailed = function(db, error)
            ow.util:PrintError("Connection to the database failed! Error: " .. error)
        end

        self.db:connect()
    else
        ow.util:PrintError("Database module \"" .. databaseModule .. "\" is not supported!")
        return false
    end
end