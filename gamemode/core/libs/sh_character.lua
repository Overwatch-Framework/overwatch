--- Character library.
-- @module ow.character

ow.character = {}
ow.character.meta = ow.character.meta or {}
ow.character.variables = ow.character.variables or {}
ow.character.fields = ow.character.fields or {}
ow.character.stored = ow.character.stored or {}
ow.character.cache = ow.character.cache or {}

--- Registers a variable for the character.
-- @realm shared
function ow.character:RegisterVariable(key, data)
    data.Index = table.Count(self.variables) + 1

    local upperKey = key:gsub("^%l", string.upper)
    -- TODO, add support for custom OnGet and OnSet methods.

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

    if ( data.Alias != nil ) then
        if ( isstring(data.Alias) ) then
            data.Alias = { data.Alias }
        end

        for k, v in ipairs(data.Alias) do
            self.meta["Get" .. v] = function(this)
                return self:GetVariable(key)
            end

            self.meta["Set" .. v] = function(this, value)
                self:SetVariable(key, value)

                if ( data.OnSet ) then
                    data:OnSet(this, value)
                end
            end
        end
    end

    self.variables[key] = data
end

function ow.character:GetVariable(id, key, callback, bNoCache)
    if ( !istable(self.variables[id]) ) then
        return false, "Variable not found"
    end

    if ( self.cache[key] and !bNoCache ) then
        return self.cache[key]
    end

    local data = self.variables[id]

    if ( SERVER ) then
        local field = data.Field
        if ( field ) then
            local query = string.format("%s = %s", field, sql.SQLStr(key))
            local result = ow.sqlite:Select("characters", nil, query)

            if ( result and result[1] ) then
                self.cache[key] = result[1]
            else
                self.cache[key] = {}
            end

            if ( callback ) then
                callback(self.cache[key])
            end
        else
            callback(self.cache[key])
        end
    else
        callback(self.cache[key])
    end

    return true, nil
end