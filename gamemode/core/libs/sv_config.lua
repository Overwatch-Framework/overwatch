-- Configuration for the gamemode
-- @module ow.config

ow.config = ow.config or {}
ow.config.stored = ow.config.stored or {}

--- Sets the value of the specified configuration.
-- @realm server
-- @param key The key of the configuration.
-- @param value The value of the configuration.
-- @treturn boolean Whether the configuration was successfully set.
-- @usage ow.config.Set("color.schema", Color(0, 100, 150)) -- Sets the color of the schema.
function ow.config:Set(key, value)
    local stored = self.stored[key]
    if ( !istable(stored) ) then
        ow.util:PrintError("Config \"" .. key .. "\" does not exist!")
        return false
    end

    if ( value == nil ) then
        value = stored.Default
    end

    if ( ow.util:GetTypeFromValue(value) != stored.Type ) then
        ow.util:PrintError("Attempted to set config \"" .. key .. "\" with invalid type!")
        return false
    end

    local oldValue = stored.Value != nil and stored.Value or stored.Default
    local bResult = hook.Run("PreConfigChanged", key, value, oldValue)
    if ( bResult == false ) then return false end

    stored.Value = value

    if ( stored.bNoNetworking != true ) then
        net.Start("ow.config.set")
            net.WriteString(key)
            net.WriteType(value)
        net.Broadcast()
    end

    if ( isfunction(stored.OnChange) ) then
        stored:OnChange(value, oldValue, ply)
    end

    self:Save()

    hook.Run("PostConfigChanged", key, value, oldValue)

    return true
end

--- Loads the configuration from the file.
-- @realm shared
-- @return Whether or not the configuration was loaded.
-- @usage ow.config:Load()
-- @internal
function ow.config:Load()
    local config = ow.data:Get("config", {}, true, false)

    hook.Run("PreConfigLoad", config)

    local tableToSend =  self.stored
    for k, v in pairs(tableToSend) do
        if ( v.bNoNetworking ) then
            tableToSend[k] = nil
            continue
        end

        if ( config[k] != nil ) then
            v.Value = config[k]
        end
    end

    local compressed = util.Compress(util.TableToJSON(tableToSend))

    net.Start("ow.config.sync")
        net.WriteData(compressed, #compressed)
    net.Broadcast()

    ow.util:Print("Configuration loaded.")
    hook.Run("PostConfigLoad", config, tableToSend)

    return true
end

function ow.config:GetSaveData()
    local saveData = {}
    for k, v in pairs(self.stored) do
        if ( v.Value != nil and v.Value != v.Default ) then
            saveData[k] = v.Value
        end
    end

    return saveData
end

--- Saves the configuration to the file.
-- @realm server
-- @return Whether or not the configuration was saved.
-- @usage ow.config:Save() -- Saves the configuration to the file.
-- @internal
function ow.config:Save()
    hook.Run("PreConfigSave")

    local values = self:GetSaveData()

    ow.data:Set("config", values, true, false)

    hook.Run("PostConfigSave", values)
    ow.util:Print("Configuration saved.")

    return true
end

--- Set the config to the default value
-- @realm server
-- @string key The config key to reset
-- @return boolean Returns true if the config was reset successfully, false otherwise
-- @usage ow.config:Reset(key) -- Resets the config to the default value.
function ow.config:Reset(key)
    local configData = self.stored[key]
    if ( !istable(configData) ) then
        ow.util:PrintError("Config \"" .. key .. "\" does not exist!")
        return false
    end

    self:Set(key, configData.Default)

    return true
end

--- Resets the configuration to the default values.
-- @realm server
-- @return Whether or not the configuration was reset.
-- @usage ow.config:ResetAll() -- Resets the configuration to the default values.
function ow.config:ResetAll()
    hook.Run("PreConfigReset")

    local tableToSend =  self.stored
    for k, v in pairs(tableToSend) do
        if ( v.bNoNetworking ) then
            tableToSend[k] = nil
            continue
        end

        if ( config[k] != nil ) then
            v.Value = config[k]
        end
    end

    local compressed = util.Compress(util.TableToJSON(tableToSend))

    net.Start("ow.config.sync")
        net.WriteData(compressed, #compressed)
    net.Broadcast()

    self:Save()

    hook.Run("PostConfigReset")

    return true
end

--- Synchronizes the configuration with the player.
-- @realm server
-- @param ply The player to synchronize the configuration with.
-- @return Whether or not the configuration was synchronized with the player.
-- @usage ow.config:Synchronize(Entity(1)) -- Synchronizes the configuration with the first player.
function ow.config:Synchronize(ply)
    if ( !IsValid(ply) ) then return false end

    local tableToSend =  self.stored
    for k, v in pairs(tableToSend) do
        if ( v.bNoNetworking ) then
            tableToSend[k] = nil
        end
    end

    local compressed = util.Compress(util.TableToJSON(tableToSend))
    hook.Run("PreConfigSync", ply, compressed)

    net.Start("ow.config.sync")
        net.WriteData(compressed, #compressed)
    net.Send(ply)

    hook.Run("PostConfigSync", ply, self.stored, tableToSend)

    return true
end