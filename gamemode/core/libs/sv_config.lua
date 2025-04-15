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
    local stored = self.stored[key]
    if ( !istable(stored) ) then
        ow.util:PrintError("Config \"" .. key .. "\" does not exist!")
        return false
    end

    local oldValue = self.values[key]
    self.values[key] = value

    net.Start("ow.config.set")
        net.WriteString(key)
        net.WriteType(value)
    net.Broadcast()

    hook.Run("ConfigValueChanged", key, oldValue, value)

    if ( stored.OnChange ) then
        stored:OnChange(value, oldValue)
    end

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
    config = util.JSONToTable(config or "[]")

    self.values = config

    hook.Run("PreConfigLoad", config)

    local compressed = util.Compress(util.TableToJSON(config))

    net.Start("ow.config.sync")
        net.WriteData(compressed, #compressed)
    net.Broadcast()

    ow.util:Print("Configuration loaded.")
    hook.Run("PostConfigLoad", config)

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

    file.Write("overwatch/" .. folder .. "/config.json", util.TableToJSON(self.values))

    hook.Run("PostConfigSave", values)

    ow.util:Print("Configuration saved.")

    return true
end

--- Resets the configuration to the default values.
-- @realm server
-- @return Whether or not the configuration was reset.
-- @usage ow.config:Reset() -- Resets the configuration to the default values.
function ow.config:Reset()
    hook.Run("PreConfigReset")

    self.values = {}

    file.Write("overwatch/" .. (SCHEMA and SCHEMA.Folder or "core") .. "/config.json", self.values)

    local compressed = util.Compress(util.TableToJSON(self.values))

    net.Start("ow.config.sync")
        net.WriteData(compressed, #compressed)
    net.Broadcast()

    hook.Run("PostConfigReset", values)

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

    local compressed = util.Compress(util.TableToJSON(self.values))

    net.Start("ow.config.sync")
        net.WriteData(compressed, #compressed)
    net.Send(ply)

    hook.Run("PostConfigSync", ply, values)

    return true
end