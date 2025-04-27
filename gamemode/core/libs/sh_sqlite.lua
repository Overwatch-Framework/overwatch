--- SQLite Utility Library for Overwatch
-- Provides dynamic variable registration and row management per table.
-- Designed for frameworks with multiple data tables like `users`, `characters`, etc.
-- @module ow.sqlite

ow.sqlite = ow.sqlite or {}
ow.sqlite.tables = {}

--- Registers a variable for a table to be included in table creation and loading.
-- It will also automatically add the column to the table in the database if it doesn't exist.
-- @realm shared
-- @tparam string tableName The name of the table (e.g. "users", "characters")
-- @tparam string key The name of the variable (e.g. "credits", "xp")
-- @tparam any default The default value for the variable
function ow.sqlite:RegisterVar(tableName, key, default)
    self.tables[tableName] = self.tables[tableName] or {}
    self.tables[tableName][key] = default

    self:AddColumn(tableName, key, type(default) == "number" and "INTEGER" or "TEXT", default)
end

--- Adds a column to an existing table if the column doesn't already exist.
-- @realm shared
-- @tparam string tableName The name of the table (e.g. "users", "characters")
-- @tparam string columnName The name of the column to add
-- @tparam string columnType The type of the column (e.g. "INTEGER", "TEXT")
-- @tparam any defaultValue The default value to set if the column is added
function ow.sqlite:AddColumn(tableName, columnName, columnType, defaultValue)
    local result = sql.Query(string.format("PRAGMA table_info(%s);", tableName))
    if ( result ) then
        local columnExists = false
        for _, column in ipairs(result) do
            if ( column.name == columnName ) then
                columnExists = true
                break
            end
        end

        if ( !columnExists ) then
            local insertQuery = string.format(
                "ALTER TABLE %s ADD COLUMN %s %s DEFAULT %s;",
                tableName,
                columnName,
                columnType,
                sql.SQLStr(defaultValue)
            )
            sql.Query(insertQuery)
        end
    end
end

--- Returns a default row based on registered variables for a table.
-- @realm shared
-- @tparam string query The table name
-- @tparam table[opt] override Optional overrides to apply to default row
-- @treturn table The default row with values
function ow.sqlite:GetDefaultRow(query, override)
    local data = table.Copy(self.tables[query] or {})
    for k, v in pairs(override or {}) do
        data[k] = v
    end

    return data
end

--- Initializes a table by creating it in SQLite with registered and extra schema fields.
-- @realm shared
-- @tparam string query The table name
-- @tparam table[opt] extraSchema Extra schema definitions (e.g. primary key)
function ow.sqlite:InitializeTable(query, extraSchema)
    local schema = {
        steamid = "TEXT PRIMARY KEY"
    }

    for k, v in pairs(self.tables[query] or {}) do
        if ( isnumber(v) ) then
            schema[k] = "INTEGER"
        elseif ( isstring(v) ) then
            schema[k] = "TEXT"
        elseif ( isbool(v) ) then
            schema[k] = "BOOLEAN"
        else
            schema[k] = "TEXT"
        end
    end

    if ( extraSchema ) then
        for k, v in pairs(extraSchema) do
            schema[k] = v
        end
    end

    self:CreateTable(query, schema)
end

--- Loads a row from a table, or inserts a default if not found.
-- @realm shared
-- @tparam string query Table name
-- @tparam string key Column to match (e.g. "steamid")
-- @tparam any value Value to match (e.g. player's SteamID)
-- @tparam function callback Function to run with resulting data row
function ow.sqlite:LoadRow(query, key, value, callback)
    local condition = string.format("%s = %s", key, sql.SQLStr(value))
    local result = self:Select(query, nil, condition)

    local row = result and result[1]
    if ( !row ) then
        row = self:GetDefaultRow(query)
        row[key] = value

        self:Insert(query, row)

        if ( callback ) then
            if ( isfunction(callback) ) then
                print("Row not found, inserting default row")
                PrintTable(row)
                callback(row)
            else
                error("Callback must be a function")
            end
        end

        return
    else
        for k, v in pairs(row) do
            if ( v == nil ) then
                row[k] = self.tables[query][k]
            end
        end
    end

    if ( callback ) then
        if ( isfunction(callback) ) then
            callback(row)
        else
            error("Callback must be a function")
        end
    end
end

--- Saves a full data row back into the table using a key match.
-- @realm shared
-- @tparam string query Table name
-- @tparam table data The row data to save
-- @tparam string key Column name to use for matching
function ow.sqlite:SaveRow(query, data, key)
    print("Saving row", query, key, data[key])
    PrintTable(data)
    local condition = string.format("%s = %s", key, sql.SQLStr(data[key]))
    self:Update(query, data, condition)
end

--- Creates a table with a given schema if it doesn't already exist.
-- @realm shared
-- @tparam string query Table name
-- @tparam table schema Column definitions
function ow.sqlite:CreateTable(query, schema)
    local parts = {}
    for column, columnType in pairs(schema) do
        parts[#parts + 1] = string.format("%s %s", column, columnType)
    end

    local insertQuery = string.format("CREATE TABLE IF NOT EXISTS %s (%s);", query, table.concat(parts, ", "))
    sql.Query(insertQuery)
end

--- Inserts a row into a table.
-- @realm shared
-- @tparam string query Table name
-- @tparam table data Row data
-- @tparam function[opt] callback Optional callback function to run after insertion
function ow.sqlite:Insert(query, data, callback)
    local keys, values = {}, {}

    for k, v in pairs(data) do
        keys[#keys + 1] = k
        values[#values + 1] = sql.SQLStr(v)
    end

    local insertQuery = string.format("INSERT INTO %s (%s) VALUES (%s);", query, table.concat(keys, ", "), table.concat(values, ", "))
    sql.Query(insertQuery)
    print(insertQuery)

    if ( callback ) then
        local result = sql.QueryRow("SELECT last_insert_rowid();")
        if ( result ) then
            callback(result["last_insert_rowid()"])
        end
    end
end

--- Updates a row in a table based on a condition.
-- @realm shared
-- @tparam string query Table name
-- @tparam table data Row data to update
-- @tparam string condition WHERE clause condition
function ow.sqlite:Update(query, data, condition)
    local updates = {}
    for k, v in pairs(data) do
        updates[#updates + 1] = string.format("%s = %s", k, sql.SQLStr(v))
    end

    local insertQuery = string.format("UPDATE %s SET %s WHERE %s;", query, table.concat(updates, ", "), condition)
    sql.Query(insertQuery)
    print(insertQuery)
end

--- Selects rows from a table matching a condition.
-- @realm shared
-- @tparam string query Table name
-- @tparam table[opt] columns Array of column names or nil for all
-- @tparam string[opt] condition WHERE clause
-- @treturn table|nil Resulting rows or nil
function ow.sqlite:Select(query, columns, condition)
    local cols = columns and table.concat(columns, ", ") or "*"
    local insertQuery = string.format("SELECT %s FROM %s", cols, query)

    if ( condition ) then
        insertQuery = insertQuery .. " WHERE " .. condition
    end

    return sql.Query(insertQuery)
end

--- Returns the number of rows in a table.
-- @realm shared
-- @tparam string query Table name
-- @tparam string[opt] condition WHERE clause
-- @treturn number Number of rows
function ow.sqlite:Count(query, condition)
    local insertQuery = string.format("SELECT COUNT(*) FROM %s", query)

    if ( condition ) then
        insertQuery = insertQuery .. " WHERE " .. condition
    end

    local result = sql.Query(insertQuery)
    return result and result[1]["COUNT(*)"] or 0
end

if ( CLIENT ) then return end

ow.sqlite:CreateTable("ow_characters", {
    id = "INTEGER PRIMARY KEY AUTOINCREMENT",
    steamid = "TEXT",
    name = "TEXT",
    data = "TEXT",
})

ow.sqlite:CreateTable("ow_players", {
    steamid = "TEXT PRIMARY KEY",
    name = "TEXT",
    ip = "TEXT",
    play_time = "INTEGER",
    last_played = "INTEGER",
    data = "TEXT",
})

ow.sqlite:CreateTable("ow_inventories", {
    inventory_id = "INTEGER PRIMARY KEY AUTOINCREMENT",
    character_id = "INTEGER",
    inventory_type = "TEXT",
    data = "TEXT"
})

ow.sqlite:CreateTable("ow_items", {
    id = "INTEGER PRIMARY KEY AUTOINCREMENT",
    owner_id = "INTEGER",
    unique_id = "TEXT",
    data = "TEXT",
    inv_id = "INTEGER",
})