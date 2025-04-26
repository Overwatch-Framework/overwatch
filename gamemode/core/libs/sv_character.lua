--- Character library.
-- @module ow.character

function ow.character:SetVariable(id, key, value)
    if ( !istable(self.variables[id]) ) then
        return false, "Variable not found"
    end

    local data = self.variables[id]

    if ( SERVER ) then
        local field = data.Field
        if ( field ) then
            local query = string.format("%s = %s", field, sql.SQLStr(key))
            ow.sqlite:Update("ow_characters", { [field] = value }, query)
        end

        self.cache[key] = value
    else
        self.cache[key] = value
    end

    hook.Run("CharacterVariableSet", id, key, value)

    return true, nil
end

function ow.character:Create(ply, query)
    if ( !IsValid(ply) or !ply:IsPlayer() ) then
        ErrorNoHalt("Attempted to create character for invalid player (" .. tostring(ply) .. ")")
        return false
    end

    if ( !query or !istable(query) ) then
        ErrorNoHalt("Attempted to create character with invalid query (" .. tostring(query) .. ")")
        return false
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

    local id = ow.sqlite:Count("ow_characters") + 1
    if ( !id ) then
        print("Failed to get new character ID")
        return false
    end

    insertQuery.id = id
    insertQuery.steamid = ply:SteamID64()
    insertQuery.schema = SCHEMA.Folder

    ow.sqlite:Insert("ow_characters", insertQuery)

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