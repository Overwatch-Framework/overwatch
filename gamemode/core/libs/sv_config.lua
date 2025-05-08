-- Configuration for the gamemode
-- @module ow.config

ow.config = ow.config or {}
ow.config.stored = ow.config.stored or {}

--- Loads the configuration from the file.
-- @realm shared
-- @return Whether or not the configuration was loaded.
-- @usage ow.config:Load()
-- @internal
function ow.config:Load()
    local config = ow.data:Get("config", {}, true, false)

    for k, v in pairs(config) do
        local storedData = self.stored[k]
        if ( !istable(storedData) ) then continue end

        storedData.Value = v
    end

    local tableToSend =  self:GetNetworkData()
    ow.net:Start(nil, "config.sync", tableToSend)

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

function ow.config:GetNetworkData()
    local saveData = self:GetSaveData()
    for k, v in pairs(self.stored) do
        if ( v.NoNetworking ) then
            saveData[k] = nil
            continue
        end

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

    for k, v in pairs(self.stored) do
        self:Reset(k)
    end

    ow.net:Start(nil, "config.sync", self:GetNetworkData())

    self:Save()
    hook.Run("PostConfigReset")

    return true
end

--- Synchronizes the configuration with the player.
-- @realm server
-- @param client The player to synchronize the configuration with.
-- @return Whether or not the configuration was synchronized with the player.
-- @usage ow.config:Synchronize(Entity(1)) -- Synchronizes the configuration with the first player.
function ow.config:Synchronize(client)
    if ( !IsValid(client) ) then return false end

    local tableToSend = self:GetNetworkData()
    local shouldSend = hook.Run("PreConfigSync", client, tableToSend)
    if ( shouldSend == false ) then return false end

    ow.net:Start(client, "config.sync", tableToSend)

    hook.Run("PostConfigSync", client)

    return true
end