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
function ow.config:Set(key, value, ply)
    local stored = self.stored[key]
    if ( !istable(stored) ) then
        ow.util:PrintError("Config \"" .. key .. "\" does not exist!")
        return false
    end

    if ( ow.util:SanitizeType(value) != stored.Type ) then
        ow.util:PrintError("Attempted to set config \"" .. key .. "\" with invalid type!")
        return false
    end

    local oldValue = stored.Value or stored.Default
    stored.Value = value

    net.Start("ow.config.set")
        net.WriteString(key)
        net.WriteType(value)
    net.Broadcast()

    if ( isfunction(stored.OnChange) ) then
        stored:OnChange(value, oldValue, ply)
    end

    hook.Run("PostConfigChanged", key, value, oldValue, ply)
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

    for k, v in pairs(self.stored) do
        if ( config[k] != nil ) then
            v.Value = config[k]
        end
    end

    local compressed = util.Compress(util.TableToJSON(self.stored))

    net.Start("ow.config.sync")
        net.WriteData(compressed, #compressed)
    net.Broadcast()

    ow.util:Print("Configuration loaded.")
    hook.Run("PostConfigLoad", config)

    return true
end

function ow.config:GetSaveData()
    local saveData = {}
    for k, v in pairs(self.stored) do
        if ( v.Value and v.Value != v.Default ) then
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

--- Resets the configuration to the default values.
-- @realm server
-- @return Whether or not the configuration was reset.
-- @usage ow.config:Reset() -- Resets the configuration to the default values.
function ow.config:Reset()
    hook.Run("PreConfigReset")

    for k, v in pairs(self.stored) do
        if ( v.Default != nil ) then
            v.Value = v.Default
        end
    end

    local compressed = util.Compress(util.TableToJSON(self.stored))

    net.Start("ow.config.sync")
        net.WriteData(compressed, #compressed)
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

    local compressed = util.Compress(util.TableToJSON(self.stored))

    net.Start("ow.config.sync")
        net.WriteData(compressed, #compressed)
    net.Send(ply)

    hook.Run("PostConfigSync", ply, values)

    return true
end