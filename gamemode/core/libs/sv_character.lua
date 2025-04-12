--- Character library.
-- @module ow.character

function ow.character:SetVariable(id, key, value)
    hook.Run("CharacterVariableSet", id, key, value)
end

function ow.character:Create(ply, query)
    if ( !IsValid(ply) or !ply:IsPlayer() ) then
        ErrorNoHalt("Attempted to create character for invalid player (" .. tostring(ply) .. ")")
        return
    end

    if ( !query or !istable(query) ) then
        ErrorNoHalt("Attempted to create character with invalid query (" .. tostring(query) .. ")")
        return
    end

    print("Creating character for player (" .. tostring(ply) .. ")")
    print("Query: " .. util.TableToJSON(query))

    local insertQuery = {}
    for k, v in pairs(self.variables) do
        if ( query[k] ) then
            insertQuery[k] = query[k]
        elseif ( v.Default ) then
            insertQuery[k] = v.Default
        end
    end

    local id = ow.sqlite:Count("characters") + 1
    if ( !id ) then
        print("Failed to get new character ID")
        return
    end

    insertQuery.id = id
    insertQuery.steamid = ply:SteamID64()
    insertQuery.schema = SCHEMA.Folder

    ow.sqlite:Insert("characters", insertQuery)

    print("Created character with ID " .. id .. " for player " .. ply:Nick())

    local character = setmetatable({
        id = id
    }, self.meta)

    for k, v in pairs(self.variables) do
        character[k] = v.Default
    end

    hook.Run("PlayerCreatedCharacter", ply, character, query)

    return character
end

concommand.Add("ow_character_test_create", function(ply, cmd, args)
    ow.character:Create(ply, {
        name = "Test Character"
    })
end)

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