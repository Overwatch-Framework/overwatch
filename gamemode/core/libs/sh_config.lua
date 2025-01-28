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
function ow.config:Get(key, default)
    if ( self.stored[key] ) then
        return self.stored[key].Value
    else
        return default
    end
end

--- Sets the default value of the specified configuration.
-- @realm shared
-- @param key The key of the configuration.
-- @param value The default value of the configuration.
-- @treturn boolean Whether the default value of the configuration was successfully set.
-- @usage ow.config.SetDefault("schemaColor", Color(0, 100, 150)) -- Sets the default color of the schema.
function ow.config:SetDefault(key, value)
    if ( !self.stored[key] ) then
        ErrorNoHalt("Configuration \"" .. key .. "\" does not exist!\n")
        return false
    end

    self.stored[key].Default = value

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
function ow.config:Register(key, data)
    if ( !key or !data ) then return false end

    self.stored[key] = {
        DisplayName = data.DisplayName,
        Description = data.Description,
        Type = data.Type,
        Default = data.Default,
        Value = self.stored[key] and self.stored[key].Value or data.Default
    }

    if ( data.OnChange ) then
        hook.Add("ConfigValueChanged", "ow.config." .. key, function(k, oldValue, newValue)
            if ( k == key ) then
                data.OnChange(oldValue, newValue)
            end
        end)
    end

    return true
end