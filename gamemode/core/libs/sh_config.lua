-- Configuration for the gamemode
-- @module ow.config

ow.config = ow.config or {}
ow.config.stored = ow.config.stored or {}

--- Gets the current value of the specified configuration.
-- @realm shared
-- @param key The key of the configuration.
-- @param default The default value of the configuration.
-- @return The value of the configuration.
-- @usage local color = ow.config.Get("schemaColor", Color(0, 100, 150))
-- print(color) -- Prints the color of the schema.
function ow.config:Get(key, fallback)
    local stored = self.stored[key]
    if ( !istable(stored) ) then
        ow.util:PrintError("Config \"" .. key .. "\" does not exist!")
        return fallback or nil
    end

    local value = stored.Value

    local defaultValue = stored.Default
    if ( defaultValue == nil ) then
        return fallback
    end

    return value != nil and value or defaultValue
end

--- Sets the default value of the specified configuration.
-- @realm shared
-- @param key The key of the configuration.
-- @param value The default value of the configuration.
-- @treturn boolean Whether the default value of the configuration was successfully set.
-- @usage ow.config.SetDefault("schemaColor", Color(0, 100, 150)) -- Sets the default color of the schema.
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
-- @field DisplayName The display name of the configuration.
-- @field Description The description of the configuration.
-- @field Type The type of the configuration.
-- @field Default The default value of the configuration.
-- @field OnChange The function that is called when the configuration is changed.
-- @treturn boolean Whether the configuration was successfully registered.
-- @usage ow.config:Register("schemaColor", {
--     DisplayName = "Schema Color",
--     Description = "The color of the schema.",
--     Type = "Color",
--     Default = Color(0, 100, 150),
--     OnChange = function(oldValue, newValue)
--         print("Schema color changed from " .. tostring(oldValue) .. " to " .. tostring(newValue))
--     end
-- })

local requiredFields = {
    "DisplayName",
    "Description",
    "Type",
    "Default"
}

function ow.config:Register(key, data)
    if ( key == nil or data == nil or !isstring(key) or !istable(data) ) then return false end

    local bResult = hook.Run("PreConfigRegistered", key, data)
    if ( bResult == false ) then return false end

    local CONFIG = table.Copy(data)
    for _, v in pairs(requiredFields) do
        if ( data[v] == nil ) then
            ow.util:PrintError("Configuration \"" .. key .. "\" is missing required field \"" .. v .. "\"!\n")
            return false
        end
    end

    self.stored[key] = CONFIG
    hook.Run("PostConfigRegistered", key, data, CONFIG)

    return true
end

if CAMI != nil then
    CAMI.RegisterPrivilege({
        Name = "Overwatch - Manage Config",
        MinAccess = "superadmin",
        Description = "Allows the user to manage the configuration of the gamemode."
    })
end