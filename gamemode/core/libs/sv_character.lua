--- Character library.
-- @module ow.character

function ow.character:SetVariable(id, key, value)
    hook.Run("CharacterVariableSet", id, key, value)
end

function ow.character:Create(player, query)
    if not player or not IsValid(player) then return end
    if not query or not istable(query) then return end

    print("Creating character for player: " .. player:Nick())

    local insertQuery = {
        steamid = player:SteamID(),
        name = player:Nick()
    }

    for k, v in pairs(self.variables) do
        if v.Default then
            insertQuery[k] = v.Default
        end
    end
    
    local id = ow.sqlite:Insert("characters", insertQuery)
    if not id then
        print("Failed to create character for player: " .. player:Nick())
        return
    end

    local character = setmetatable({
        id = id
    }, self.meta)

    for k, v in pairs(self.variables) do
        character[k] = v.Default
    end

    hook.Run("PlayerCreatedCharacter", player, character, query)

    return character
end

function ow.character:Load(id)
    print("Loading character with ID: " .. id)
end

function ow.character:Save(character)
    print("Saving character with ID: " .. character.id)
end

function ow.character:Delete(id)
    print("Deleting character with ID: " .. id)
end

hook.Add("Initialize", "ow.character", function()
    
end)