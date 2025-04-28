--- Character library.
-- @module ow.character

function ow.character:Create(ply, query)
    if ( !IsValid(ply) or !ply:IsPlayer() ) then
        ErrorNoHalt("Attempted to create character for invalid player (" .. tostring(ply) .. ")")
        return false
    end

    if ( !istable(query) ) then
        ErrorNoHalt("Attempted to create character with invalid query (" .. tostring(query) .. ")")
        return false
    end

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
        ErrorNoHalt("Failed to get character ID for player " .. tostring(ply) .. "\n")
        return false
    end

    insertQuery.id = id
    insertQuery.steamid = ply:SteamID64()
    insertQuery.schema = SCHEMA.Folder

    ow.sqlite:Insert("ow_characters", insertQuery)

    local character = self:CreateObject(id, insertQuery, ply)
    if ( !character ) then
        ErrorNoHalt("Failed to create character object for ID " .. id .. " for player " .. tostring(ply) .. "\n")
        return false
    end

    ply.owCharacters = ply.owCharacters or {}
    ply.owCharacters[id] = character
    self.stored[id] = character

    net.Start("ow.character.cache")
        net.WriteTable(character)
    net.Send(ply)

    hook.Run("PlayerCreatedCharacter", ply, character, query)

    return character
end

function ow.character:Load(ply, id)
    if ( !IsValid(ply) or !ply:IsPlayer() ) then
        ErrorNoHalt("Attempted to load character for invalid player (" .. tostring(ply) .. ")\n")
        return false
    end

    if ( !id ) then
        ErrorNoHalt("Attempted to load character with invalid ID (" .. tostring(id) .. ")\n")
        return false
    end

    local currentCharacter = ply:GetCharacter()
    if ( currentCharacter and currentCharacter.id == id ) then
        ErrorNoHalt("Attempted to load the same character (" .. id .. ") for player " .. tostring(ply) .. "\n")
        return false
    end

    local steamID = ply:SteamID64()
    local condition = string.format("steamid = %s AND id = %s", sql.SQLStr(steamID), sql.SQLStr(id))
    local result = ow.sqlite:Select("ow_characters", nil, condition)

    if ( result and result[1] ) then
        local row = result[1]
        local character = self:CreateObject(id, row, ply)
        if ( !character ) then
            ErrorNoHalt("Failed to create character object for ID " .. id .. " for player " .. tostring(ply) .. "\n")
            return false
        end

        self.stored[id] = character

        hook.Run("PrePlayerLoadedCharacter", ply, character, currentCharacter)

        net.Start("ow.character.load")
            net.WriteUInt(character:GetID(), 32)
        net.Send(ply)

        ply.owCharacters = ply.owCharacters or {}
        ply.owCharacters[id] = character
        ply.owCharacter = character

        ply:SetModel(character:GetModel())
        ply:Spawn()

        hook.Run("PlayerLoadedCharacter", ply, character, currentCharacter)

        return character
    else
        ErrorNoHalt("Failed to load character with ID " .. id .. " for player " .. tostring(ply) .. "\n")
        return false
    end
end

function ow.character:Cache(ply, id)
    if ( !IsValid(ply) or !ply:IsPlayer() ) then
        ErrorNoHalt("Attempted to cache character for invalid player (" .. tostring(ply) .. ")\n")
        return false
    end

    local steamID = ply:SteamID64()
    local condition = string.format("steamid = %s AND id = %s", sql.SQLStr(steamID), sql.SQLStr(id))
    local result = ow.sqlite:Select("ow_characters", nil, condition)
    if ( !result or !result[1] ) then
        ErrorNoHalt("Failed to cache character with ID " .. id .. " for player " .. tostring(ply) .. "\n")
        return false
    end

    id = tonumber(id)
    if ( !id ) then
        ErrorNoHalt("Failed to convert character ID " .. id .. " to number for player " .. tostring(ply) .. "\n")
        return false
    end

    ply.owCharacters = ply.owCharacters or {}
    ply.owCharacters[id] = result[1]
    self.stored[id] = result[1]

    net.Start("ow.character.cache")
        net.WriteTable(result[1])
    net.Send(ply)

    return true
end

function ow.character:CacheAll(ply)
    if ( !IsValid(ply) or !ply:IsPlayer() ) then
        ErrorNoHalt("Attempted to load characters for invalid player (" .. tostring(ply) .. ")\n")
        return false
    end

    local steamID = ply:SteamID64()

    local condition = string.format("steamid = %s", sql.SQLStr(steamID))
    local result = ow.sqlite:Select("ow_characters", nil, condition)

    -- Ensure the player has a table to store characters
    ply.owCharacters = {}

    if ( result ) then
        for _, row in ipairs(result) do
            local id = tonumber(row.id)
            if ( !id ) then
                ErrorNoHalt("Failed to convert character ID " .. row.id .. " to number for player " .. tostring(ply) .. "\n")
                continue
            end

            local character = self:CreateObject(id, row, ply)
            self.stored[id] = character
            ply.owCharacters[id] = character
        end
    end

    net.Start("ow.character.cache.all")
        net.WriteTable(ply.owCharacters)
    net.Send(ply)

    hook.Run("PlayerLoadedAllCharacters", ply, ply.owCharacters)

    return ply.owCharacters
end

concommand.Add("ow_character_test_create", function(ply, cmd, args)
    ow.character:Create(ply, {
        name = "Test Character"
    })
end)