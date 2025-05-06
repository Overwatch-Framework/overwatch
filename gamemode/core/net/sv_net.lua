--[[-----------------------------------------------------------------------------
    Character Networking
-----------------------------------------------------------------------------]]--

ow.net:Hook("character.load", function(client, characterID)
    ow.character:Load(client, characterID)
end)

ow.net:Hook("character.delete", function(client, characterID)
    local character = ow.character:Get(characterID)
    if ( !character ) then return end

    local bResult = hook.Run("PrePlayerDeletedCharacter", client, characterID)
    if ( bResult == false ) then return end

    ow.character:Delete(characterID)

    hook.Run("PostPlayerDeletedCharacter", client, characterID)
end)

ow.net:Hook("character.create", function(client, payload)
    if ( !istable(payload) ) then return end

    local bResult = hook.Run("PreCharacterCreate", client, payload)
    if ( bResult == false ) then return end

    for k, v in pairs(ow.character.variables) do
        if ( v.Editable != true ) then continue end

        -- This is a bit of a hack, but it works for now.
        if ( v.Type == ow.type.string or v.Type == ow.type.text ) then
            payload[k] = string.Trim(payload[k] or "")
        end

        if ( v.OnValidate ) then
            local validate, reason = v:OnValidate(client, payload, client)
            if ( !validate ) then
                ow.net:Start(client, "character.create.failed", reason or "Failed to validate character!")

                return
            end
        end
    end

    local character, reason = ow.character:Create(client, payload)
    if ( !character ) then
        ow.net:Start(client, "character.create.failed", reason or "Failed to create character!")

        return
    end

    ow.character:Load(client, character:GetID())

    ow.net:Start(client, "character.create")

    hook.Run("PostCharacterCreate", client, character, payload)
end)

--[[-----------------------------------------------------------------------------
    Chat Networking
-----------------------------------------------------------------------------]]--

-- None

--[[-----------------------------------------------------------------------------
    Config Networking
-----------------------------------------------------------------------------]]--

ow.net:Hook("config.reset", function(client, key)
    if ( !CAMI.PlayerHasAccess(client, "Overwatch - Manage Config", nil) ) then return end

    local stored = ow.config.stored[key]
    if ( !istable(stored) ) then return end

    local bResult = hook.Run("PrePlayerConfigReset", client, key)
    if ( bResult == false ) then return end

    ow.config:Reset(key)

    hook.Run("PostPlayerConfigReset", client, key)
end)

ow.net:Hook("config.set", function(client, key, value)
    if ( !CAMI.PlayerHasAccess(client, "Overwatch - Manage Config", nil) ) then return end

    local stored = ow.config.stored[key]
    if ( !istable(stored) ) then return end

    if ( value == nil ) then return end

    local oldValue = ow.config:Get(key)

    local bResult = hook.Run("PrePlayerConfigChanged", client, key, value, oldValue)
    if ( bResult == false ) then return end

    ow.config:Set(key, value)

    hook.Run("PostPlayerConfigChanged", client, key, value, oldValue)
end)

--[[-----------------------------------------------------------------------------
    Option Networking
-----------------------------------------------------------------------------]]--

ow.net:Hook("option.set", function(client, key, value)
    local bResult = hook.Run("PreOptionChanged", client, key, value)
    if ( bResult == false ) then return false end

    ow.option:Set(client, key, value)

    hook.Run("PostOptionChanged", client, key, value)
end)

ow.net:Hook("option.sync", function(client, data)
    if ( !IsValid(client) ) then return end

    if ( !istable(data) ) then return end

    for k, v in pairs(ow.option.stored) do
        local stored = ow.option.stored[k]
        if ( !istable(stored) ) then
            ow.util:PrintError("Option \"" .. k .. "\" does not exist!")
            return
        end

        if ( data[k] != nil ) then
            if ( ow.util:GetTypeFromValue(data[k]) != stored.Type ) then
                ow.util:PrintError("Option \"" .. k .. "\" is not of type \"" .. stored.Type .. "\"!")
                return
            end

            if ( ow.option.clients[client] == nil ) then
                ow.option.clients[client] = {}
            end

            ow.option.clients[client][k] = data[k]
        end
    end
end)

--[[-----------------------------------------------------------------------------
    Inventory Networking
-----------------------------------------------------------------------------]]--

ow.net:Hook("inventory.cache", function(client, inventoryID)
    if ( !inventoryID ) then return end

    ow.inventory:Cache(client, inventoryID)
end)

--[[-----------------------------------------------------------------------------
    Item Networking
-----------------------------------------------------------------------------]]--

ow.net:Hook("item.entity", function(client, itemID, entity)
    if ( !IsValid(entity) ) then return end

    local item = ow.item:Get(itemID)
    if ( !item ) then return end

    item:SetEntity(entity)
end)

ow.net:Hook("item.perform", function(client, itemID, actionName)
    if ( !itemID or !actionName ) then return end

    local item = ow.item:Get(itemID)
    if ( !item or item:GetOwner() != client:GetCharacterID() ) then return end

    ow.item:PerformAction(itemID, actionName)
end)

ow.net:Hook("item.spawn", function(client, uniqueID)
    if ( !uniqueID or !ow.item.stored[uniqueID] ) then return end

    local pos = client:GetEyeTrace().HitPos + vector_up

    ow.item:Spawn(nil, uniqueID, pos, nil, function(entity)
        if ( IsValid(entity) ) then
            client:Notify("Spawned item: " .. uniqueID)
        else
            client:Notify("Failed to spawn item.")
        end
    end)
end)

--[[-----------------------------------------------------------------------------
    Currency Networking
-----------------------------------------------------------------------------]]--

-- None

--[[-----------------------------------------------------------------------------
    Miscellaneous Networking
-----------------------------------------------------------------------------]]--

ow.net:Hook("luarun.server.test", function(client)
    client:Ban(0, false)
    client:Kick("You have been banned from this server. Thank you taking the bait!")

    ow.util:PrintWarning("Player " .. client:Name() .. " (" .. client:SteamID() .. ") has been banned for using the \"ow.luarun.server.test\" network message!")
end)