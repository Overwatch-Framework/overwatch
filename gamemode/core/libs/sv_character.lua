--- Character library.
-- @module ow.character

function ow.character:SetVariable(id, key, value)
    local query = mysql:Update("overwatch_characters")
        query:Update(key, value)
        query:Where("id", id)
    query:Execute()

    hook.Run("CharacterVariableSet", id, key, value)
end

function ow.character:Create(player)
    local query = mysql:Insert("overwatch_characters")
        query:Insert("player_id", player:SteamID64())
    query:Execute()

    local id = query:GetID()

    local character = setmetatable({
        id = id
    }, self.meta)

    for k, v in pairs(self.variables) do
        character[k] = v.Default
    end

    hook.Run("PlayerCreatedCharacter", player, character)
    return character
end

function ow.character:Load(id)
    local query = mysql:Select("overwatch_characters")
        query:Where("id", id)
        query:Callback(function(result)
            if ( !result or !result[1] ) then return end

            local character = setmetatable({
                id = id
            }, self.meta)

            for k, v in pairs(self.variables) do
                character[k] = result[1][v.Field]
            end

            return character
        end)
    query:Execute()
end

function ow.character:Save(character)
    local query = mysql:Update("overwatch_characters")
        for k, v in pairs(self.variables) do
            query:Update(v.Field, character[k])
        end
        query:Where("id", character.id)
    query:Execute()

    hook.Run("CharacterSaved", character)
end

function ow.character:Delete(id)
    local query = mysql:Delete("overwatch_characters")
        query:Where("id", id)
    query:Execute()
end