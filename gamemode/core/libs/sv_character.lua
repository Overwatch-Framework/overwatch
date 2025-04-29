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
        if ( query[k] != nil ) then
            insertQuery[k] = query[k]
        elseif ( v.Default ) then
            insertQuery[k] = v.Default
        end
    end

    insertQuery.steamid = ply:SteamID64()
    insertQuery.schema = SCHEMA.Folder

    local id
    ow.sqlite:Insert("ow_characters", insertQuery, function(result)
        if ( !result ) then
            ErrorNoHalt("Failed to insert character into database for player " .. tostring(ply) .. "\n")
            return false
        end

        id = result
    end)

    if ( !id ) then
        ErrorNoHalt("Failed to create character: " .. query.name .. "\n")
        return false
    end

    local character = self:CreateObject(id, insertQuery, ply)
    if ( !character ) then
        ErrorNoHalt("Failed to create character object for ID " .. id .. " for player " .. tostring(ply) .. "\n")
        return false
    end

    local plyTable = ply:GetTable()
    plyTable.owCharacters = plyTable.owCharacters or {}
    plyTable.owCharacters[id] = character

    self.stored[id] = character

    local compressed = util.Compress(util.TableToJSON(character))

    net.Start("ow.character.cache")
        net.WriteData(compressed, #compressed)
    net.Send(ply)

    hook.Run("PlayerCreatedCharacter", ply, character, query)

    return character
end

function ow.character:Load(ply, characterID)
    if ( !IsValid(ply) or !ply:IsPlayer() ) then
        ErrorNoHalt("Attempted to load character for invalid player (" .. tostring(ply) .. ")\n")
        return false
    end

    if ( !characterID ) then
        ErrorNoHalt("Attempted to load character with invalid ID (" .. tostring(characterID) .. ")\n")
        return false
    end

    local currentCharacter = ply:GetCharacter()
    if ( currentCharacter ) then
        currentCharacter.Player = NULL
        --currentCharacter:Save()

        if ( currentCharacter:GetID() == characterID ) then
            ErrorNoHalt("Attempted to load the same character (" .. characterID .. ") for player " .. tostring(ply) .. "\n")
            return false
        end
    end

    local steamID = ply:SteamID64()
    local condition = string.format("steamid = %s AND id = %s", sql.SQLStr(steamID), sql.SQLStr(characterID))
    local result = ow.sqlite:Select("ow_characters", nil, condition)

    if ( result and result[1] ) then
        local row = result[1]
        local character = self:CreateObject(characterID, row, ply)
        if ( !character ) then
            ErrorNoHalt("Failed to create character object for ID " .. characterID .. " for player " .. tostring(ply) .. "\n")
            return false
        end

        self.stored[characterID] = character

        hook.Run("PrePlayerLoadedCharacter", ply, character, currentCharacter)

        net.Start("ow.character.load")
            net.WriteUInt(character:GetID(), 32)
        net.Send(ply)

        local plyTable = ply:GetTable()
        plyTable.owCharacters = plyTable.owCharacters or {}
        plyTable.owCharacters[characterID] = character
        plyTable.owCharacter = character

        ply:SetModel(character:GetModel())
        ply:SetTeam(character:GetFaction())
        ply:Spawn()

        -- Cache the characters' inventories
        for _, inventory in ipairs(character:GetInventories()) do
            ow.inventory:Cache(ply, inventory.ID)
        end

        hook.Run("PlayerLoadedCharacter", ply, character, currentCharacter)

        return character
    else
        ErrorNoHalt("Failed to load character with ID " .. characterID .. " for player " .. tostring(ply) .. "\n")
        return false
    end
end

function ow.character:Delete(characterID)
    if ( !isnumber(characterID) ) then
        ErrorNoHalt("Attempted to delete character with invalid ID (" .. tostring(characterID) .. ")")
        return false
    end

    local character = self.stored[characterID]
    if ( !character ) then
        ow.util:PrintError("Attempted to delete character that does not exist (" .. characterID .. ")")
        return false
    end

    local ply = character:GetPlayer()
    if ( IsValid(ply) ) then
        local plyTable = ply:GetTable()
        plyTable.owCharacters[characterID] = nil
        plyTable.owCharacter = nil

        -- TODO: Uh? Silent Kill? Open Main Menu? What do we do here?

        net.Start("ow.character.delete")
            net.WriteUInt(characterID, 32)
        net.Send(ply)
    end

    ow.sqlite:Delete("ow_characters", string.format("id = %s", sql.SQLStr(characterID)))
    self.stored[characterID] = nil

    return true
end

function ow.character:Cache(ply, characterID)
    if ( !IsValid(ply) or !ply:IsPlayer() ) then
        ErrorNoHalt("Attempted to cache character for invalid player (" .. tostring(ply) .. ")\n")
        return false
    end

    local steamID = ply:SteamID64()
    local condition = string.format("steamid = %s AND id = %s", sql.SQLStr(steamID), sql.SQLStr(characterID))
    local result = ow.sqlite:Select("ow_characters", nil, condition)
    if ( !result or !result[1] ) then
        ErrorNoHalt("Failed to cache character with ID " .. characterID .. " for player " .. tostring(ply) .. "\n")
        return false
    end

    characterID = tonumber(characterID)
    if ( !characterID ) then
        ErrorNoHalt("Failed to convert character ID " .. characterID .. " to number for player " .. tostring(ply) .. "\n")
        return false
    end

    local plyTable = ply:GetTable()
    plyTable.owCharacters = plyTable.owCharacters or {}
    plyTable.owCharacters[characterID] = result[1]
    self.stored[characterID] = result[1]

    local compressed = util.Compress(util.TableToJSON(result[1]))

    net.Start("ow.character.cache")
        net.WriteData(compressed, #compressed)
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
    local plyTable = ply:GetTable()
    plyTable.owCharacters = {}

    if ( result ) then
        for _, row in ipairs(result) do
            local id = tonumber(row.id)
            if ( !id ) then
                ErrorNoHalt("Failed to convert character ID " .. row.id .. " to number for player " .. tostring(ply) .. "\n")
                continue
            end

            local character = self:CreateObject(id, row, ply)
            self.stored[id] = character
            plyTable.owCharacters[id] = character
        end
    end

    local compressed = util.Compress(util.TableToJSON(plyTable.owCharacters))

    net.Start("ow.character.cache.all")
        net.WriteData(compressed, #compressed)
    net.Send(ply)

    hook.Run("PlayerLoadedAllCharacters", ply, plyTable.owCharacters)

    return plyTable.owCharacters
end

concommand.Add("ow_character_test_create", function(ply, cmd, args)
    ow.character:Create(ply, {
        name = "Test Character"
    })
end)