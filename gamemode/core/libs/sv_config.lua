-- Configuration for the gamemode
-- @module ow.config

ow.config = ow.config or {}
ow.config.stored = ow.config.stored or {}

--- Sets the value of the specified configuration.
-- @realm server
-- @param key The key of the configuration.
-- @param value The value of the configuration.
-- @treturn boolean Whether the configuration was successfully set.
-- @usage ow.config.Set("schemaColor", Color(0, 100, 150)) -- Sets the color of the schema.
function ow.config:Set(key, value)
    if ( !self.stored[key] ) then return false end

    local oldValue = self.stored[key]
    self.stored[key].Value = value

    net.Start("ow.config.set")
        net.WriteString(key)
        net.WriteType(value)
    net.Broadcast()

    hook.Run("ConfigValueChanged", key, oldValue, value)

    return true
end

--- Loads the configuration from the file.
-- @realm shared
-- @return Whether or not the configuration was loaded.
-- @usage ow.config:Load()
-- @internal
function ow.config:Load()
    if ( !file.Exists("overwatch", "DATA") ) then
        file.CreateDir("overwatch")
    end

    local folder = SCHEMA and SCHEMA.Folder or "core"
    if ( !file.Exists("overwatch/" .. folder, "DATA") ) then
        file.CreateDir("overwatch/" .. folder)
    end

    local config = file.Read("overwatch/" .. folder .. "/config.json", "DATA")
    config = util.JSONToTable(config) or {}
    
    hook.Run("PreConfigLoad")

    local values = {}
    for key, data in pairs(self.stored) do
        self.stored[key].Value = config[key] or data.Default
        values[key] = self.stored[key].Value
    end

    net.Start("ow.config.sync")
        net.WriteTable(values)
    net.Broadcast()

    hook.Run("PostConfigLoad")

    ow.util:Print("Configuration loaded.")

    return true
end

--- Saves the configuration to the file.
-- @realm server
-- @return Whether or not the configuration was saved.
-- @usage ow.config:Save() -- Saves the configuration to the file.
-- @internal
function ow.config:Save()
    hook.Run("PreConfigSave")

    local folder = SCHEMA and SCHEMA.Folder or "core"
    local values = {}
    for key, data in pairs(self.stored) do
        values[key] = data.Value or data.Default
    end

    file.Write("overwatch/" .. folder .. "/config.json", util.TableToJSON(values))

    hook.Run("PostConfigSave")

    ow.util:Print("Configuration saved.")

    return true
end

--- Resets the configuration to the default values.
-- @realm server
-- @return Whether or not the configuration was reset.
-- @usage ow.config:Reset() -- Resets the configuration to the default values.
function ow.config:Reset()
    hook.Run("PreConfigReset")

    file.Write("overwatch/" .. (SCHEMA and SCHEMA.Folder or "core") .. "/config.json", "")

    for key, data in pairs(self.stored) do
        self.stored[key].Value = data.Default
    end

    local values = {}
    for key, data in pairs(self.stored) do
        values[key] = data.Value or data.Default
    end

    file.Write("overwatch/" .. (SCHEMA and SCHEMA.Folder or "core") .. "/config.json", util.TableToJSON(values))

    net.Start("ow.config.sync")
        net.WriteTable(values)
    net.Broadcast()

    hook.Run("PostConfigReset")

    return true
end

--- Synchronizes the configuration with the player.
-- @realm server
-- @param ply The player to synchronize the configuration with.
-- @return Whether or not the configuration was synchronized with the player.
-- @usage ow.config:Synchronize(player.GetHumans()[1]) -- Synchronizes the configuration with the first player.
function ow.config:Synchronize(ply)
    if ( !IsValid(ply) ) then return false end

    hook.Run("PreConfigSync", ply)

    local values = {}
    for key, data in pairs(self.stored) do
        values[key] = data.Value or data.Default
    end

    net.Start("ow.config.sync")
        net.WriteTable(values)
    net.Send(ply)

    hook.Run("PostConfigSync", ply)

    return true
end