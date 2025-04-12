--- Character library.
-- @module ow.character

ow.character = {}
ow.character.variables = ow.character.variables or {}
ow.character.fields = ow.character.fields or {}
ow.character.stored = ow.character.stored or {}
ow.character.cache = ow.character.cache or {}

--- Registers a variable for the character.
-- @realm shared
function ow.character:RegisterVariable(key, data)
    data.Index = table.Count(self.variables) + 1

    local upperKey = key:gsub("^%l", string.upper)

    if ( SERVER ) then
        self.meta["Set" .. upperKey] = function(this, value)
            self:SetVariable(key, value)

            if ( data.OnSet ) then
                data:OnSet(this, value)
            end
        end

        local field = data.Field
        if ( field ) then
            ow.sqlite:RegisterVar("characters", key, data.Default or nil)
            self.fields[key] = field
        end
    end

    self.meta["Get" .. upperKey] = function(this)
        return self:GetVariable(key)
    end

    self.variables[key] = data
end

function ow.character:GetVariable(id, key, callback, bNoCache)
    if ( !self.variables[id] ) then
        return false, "Variable not found"
    end

    if ( self.cache[key] and !bNoCache ) then
        return self.cache[key]
    end

    local data = self.variables[id]

    if ( SERVER ) then
        local field = data.Field
        if ( field ) then
            -- Get the field from the database table

        else
            callback(self.cache[key])
        end
    else
        callback(self.cache[key])
    end

    return true, nil
end