--- Character library.
-- @module ow.character

ow.character = {}
ow.character.variables = ow.character.variables or {}
ow.character.meta = ow.character.meta or {}
ow.character.fields = ow.character.fields or {}

local typeTranslator = {
    ["string"] = "VARCHAR(255)",
    ["text"] = "TEXT",
    ["number"] = "INT(11)",
    ["boolean"] = "TINYINT(1)"
}

--- Registers a variable for the character.
-- @realm shared
function ow.character:RegisterVariable(key, data)
    data.Index = table.Count(self.variables) + 1

    local upperKey = key:gsub("^%l", string.upper)

    if ( SERVER ) then
        if ( data.OnSet ) then
            self.meta["Set" .. upperKey] = function(self, value)
                self:SetVariable(key, value)
                data:OnSet(self, value)
            end
        else
            self.meta["Set" .. upperKey] = function(self, value)
                self:SetVariable(key, value)
            end
        end

        self.meta["Get" .. upperKey] = function(self)
            return self:GetVariable(key)
        end

        local field = data.Field
        if ( field ) then
            ow.database:Alter("overwatch_characters", field, typeTranslator[data.Type] or "TEXT")
        end
    end

    self.variables[key] = data
end

function ow.character:SetVariable(id, key, value)
    local query = mysql:Update("overwatch_characters")
        query:Update(key, value)
        query:Where("id", id)
    query:Execute()
end

function ow.character:GetVariable(id, key)
    local query = mysql:Select("overwatch_characters")
        query:Select(key)
        query:Where("id", id)
        query:Callback(function(result)
            return result[1][key]
        end)
    query:Execute()
end

function ow.character:Create()
    local query = mysql:Insert("overwatch_characters")
        query:Insert("id", 0)
    query:Execute()

    local id = query:GetID()

    local character = setmetatable({
        id = id
    }, self.meta)

    for k, v in pairs(self.variables) do
        character[k] = v.Default
    end

    return character
end