--- Character library.
-- @module ow.character

ow.character = {}
ow.character.variables = ow.character.variables or {}
ow.character.meta = ow.character.meta or {}
ow.character.fields = ow.character.fields or {}

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

        self.meta["Get" .. upperKey] = function(this)
            return self:GetVariable(key)
        end

        local field = data.Field
        if ( field ) then
            ow.database:AddToSchema("overwatch_characters", field, data.Type)
        end
    end

    self.variables[key] = data
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

function ow.character:GetPlayerByCharacter(id)
    local query = mysql:Select("overwatch_characters")
        query:Select("player_id")
        query:Where("id", id)
        query:Callback(function(result)
            return player.GetBySteamID64(result[1].player_id)
        end)
    query:Execute()
end