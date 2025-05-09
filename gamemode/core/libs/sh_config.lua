-- Configuration for the gamemode
-- @module ow.config

ow.config = ow.config or {}
ow.config.stored = ow.config.stored or {}

--- Gets the current value of the specified configuration.
-- @realm shared
-- @param key The key of the configuration.
-- @param default The default value of the configuration.
-- @return The value of the configuration.
-- @usage local color = ow.config.Get("color.schema", Color(0, 100, 150))
-- print(color) -- Prints the color of the schema.
function ow.config:Get(key, fallback)
    local configData = self.stored[key]
    if ( !istable(configData) ) then
        ow.util:PrintError("Config \"" .. key .. "\" does not exist!")
        return fallback
    end

    return configData.Value == nil and configData.Default or configData.Value
end

--- Gets the default value of the specified configuration.
-- @realm shared
-- @param key The key of the configuration.
-- @return The default value of the configuration.
-- @usage local defaultColor = ow.config.GetDefault("color.schema")
-- print(defaultColor) -- Prints the default color of the schema.
function ow.config:GetDefault(key)
    local configData = self.stored[key]
    if ( !istable(configData) ) then
        ow.util:PrintError("Config \"" .. key .. "\" does not exist!")
        return nil
    end

    return configData.Default
end

--- Sets the value of the specified configuration.
-- @realm shared
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

    if ( ow.util:DetectType(value) != stored.Type ) then
        ow.util:PrintError("Attempted to set config \"" .. key .. "\" with invalid type!")
        return false
    end

    local oldValue = stored.Value != nil and stored.Value or stored.Default
    local bResult = hook.Run("PreConfigChanged", key, value, oldValue)
    if ( bResult == false ) then return false end

    stored.Value = value

    if ( SERVER and stored.NoNetworking != true ) then
        ow.net:Start(nil, "config.set", key, value)
    end

    if ( isfunction(stored.OnChange) ) then
        stored:OnChange(value, oldValue, client)
    end

    if ( SERVER ) then
        self:Save()
    end

    hook.Run("PostConfigChanged", key, value, oldValue)

    return true
end

--- Sets the default value of the specified configuration.
-- @realm shared
-- @param key The key of the configuration.
-- @param value The default value of the configuration.
-- @treturn boolean Whether the default value of the configuration was successfully set.
-- @usage ow.config.SetDefault("color.schema", Color(0, 100, 150)) -- Sets the default color of the schema.
function ow.config:SetDefault(key, value)
    local stored = self.stored[key]
    if ( !istable(stored) ) then
        ErrorNoHalt("Configuration \"" .. key .. "\" does not exist!\n")
        return false
    end

    stored.Default = value

    return true
end

--- Registers a new configuration.
-- @realm shared
-- @param key The key of the configuration.
-- @param data The data of the configuration.
-- @field Name The display name of the configuration.
-- @field Description The description of the configuration.
-- @field Type The type of the configuration.
-- @field Default The default value of the configuration.
-- @field OnChange The function that is called when the configuration is changed.
-- @treturn boolean Whether the configuration was successfully registered.
-- @usage ow.config:Register("color.schema", {
--     Name = "Schema Color",
--     Description = "The color of the schema.",
--     Type = ow.types.color,
--     Default = Color(0, 100, 150),
--     OnChange = function(oldValue, newValue)
--         print("Schema color changed from " .. tostring(oldValue) .. " to " .. tostring(newValue))
--     end
-- })

local requiredFields = {
    "Name",
    "Description",
    "Default"
}

function ow.config:Register(key, data)
    if ( !isstring(key) or !istable(data) ) then return false end

    local bResult = hook.Run("PreConfigRegistered", key, data)
    if ( bResult == false ) then return false end

    for _, v in pairs(requiredFields) do
        if ( data[v] == nil ) then
            ow.util:PrintError("Configuration \"" .. key .. "\" is missing required field \"" .. v .. "\"!\n")
            return false
        end
    end

    if ( data.Type == nil ) then
        data.Type = ow.util:DetectType(data.Default)

        if ( data.Type == nil ) then
            ow.util:PrintError("Config \"" .. key .. "\" has an invalid type!")
            return false
        end
    end

    if ( !isstring(data.Category) ) then
        data.Category = "misc"
    end

    if ( isstring(data.SubCategory) ) then
        data.SubCategory = "other"
    end

    data.UniqueID = key

    self.stored[key] = data
    hook.Run("PostConfigRegistered", key, data)

    return true
end