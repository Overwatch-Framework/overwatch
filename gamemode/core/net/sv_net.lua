--[[-----------------------------------------------------------------------------
    Character Networking
-----------------------------------------------------------------------------]]--

util.AddNetworkString("ow.character.cache.all")
util.AddNetworkString("ow.character.cache")
util.AddNetworkString("ow.character.create.failed")
util.AddNetworkString("ow.character.create")
util.AddNetworkString("ow.character.delete")
util.AddNetworkString("ow.character.load.failed")
util.AddNetworkString("ow.character.load")
util.AddNetworkString("ow.character.variable.set")

net.Receive("ow.character.load", function(len, client)
    local characterID = net.ReadUInt(32)
    ow.character:Load(client, characterID)
end)

net.Receive("ow.character.delete", function(len, client)
    local characterID = net.ReadUInt(32)
    local character = ow.character:Get(characterID)
    if ( !character ) then return end

    local bResult = hook.Run("PreCharacterDelete", client, character)
    if ( bResult == false ) then return end

    ow.character:Delete(characterID)

    hook.Run("PostCharacterDelete", client, character)
end)

net.Receive("ow.character.create", function(len, client)
    -- TODO: Make this more secure, validate the payload and check if the player is allowed to create a character and probably check for other stuff and do other cool things later on in the menus
    local payload = sfs.decode(net.ReadData(len / 8))
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
                net.Start("ow.character.create.failed")
                    net.WriteString(reason or "Failed to validate character!")
                net.Send(client)

                return
            end
        end
    end

    local character, reason = ow.character:Create(client, payload)
    if ( !character ) then
        net.Start("ow.character.create.failed")
            net.WriteString(reason or "Failed to create character!")
        net.Send(client)

        return
    end

    ow.character:Load(client, character:GetID())

    net.Start("ow.character.create")
    net.Send(client)

    hook.Run("PostCharacterCreate", client, character, payload)
end)

--[[-----------------------------------------------------------------------------
    Chat Networking
-----------------------------------------------------------------------------]]--

util.AddNetworkString("ow.chat.send")
util.AddNetworkString("ow.chat.text")

--[[-----------------------------------------------------------------------------
    Config Networking
-----------------------------------------------------------------------------]]--

util.AddNetworkString("ow.config.reset")
util.AddNetworkString("ow.config.set")
util.AddNetworkString("ow.config.sync")

net.Receive("ow.config.reset", function(len, client)
    if ( !CAMI.PlayerHasAccess(client, "Overwatch - Manage Config", nil) ) then return end

    local key = net.ReadString()
    local stored = ow.config.stored[key]
    if ( !istable(stored) ) then return end

    local bResult = hook.Run("PrePlayerConfigReset", client, key)
    if ( bResult == false ) then return end

    ow.config:Reset(key)

    hook.Run("PostPlayerConfigReset", client, key)
end)

net.Receive("ow.config.set", function(len, client)
    if ( !CAMI.PlayerHasAccess(client, "Overwatch - Manage Config", nil) ) then return end

    local key = net.ReadString()
    local stored = ow.config.stored[key]
    if ( !istable(stored) ) then return end

    local value = net.ReadType()
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

util.AddNetworkString("ow.option.set")
util.AddNetworkString("ow.option.sync")

net.Receive("ow.option.set", function(len, client)
    local key = net.ReadString()
    local value = net.ReadType()

    local bResult = hook.Run("PreOptionChanged", client, key, value)
    if ( bResult == false ) then return false end

    ow.option:Set(client, key, value)

    hook.Run("PostOptionChanged", client, key, value)
end)

net.Receive("ow.option.sync", function(len, client)
    if ( !IsValid(client) ) then return end

    local data = sfs.decode(net.ReadData(len / 8))
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

util.AddNetworkString("ow.inventory.cache")
util.AddNetworkString("ow.inventory.item.add")
util.AddNetworkString("ow.inventory.item.remove")
util.AddNetworkString("ow.inventory.refresh")
util.AddNetworkString("ow.inventory.register")

net.Receive("ow.inventory.cache", function(len, client)
    local inventoryID = net.ReadUInt(32)
    if ( !inventoryID ) then return end

    ow.inventory:Cache(client, inventoryID)
end)

--[[-----------------------------------------------------------------------------
    Item Networking
-----------------------------------------------------------------------------]]--

util.AddNetworkString("ow.item.add")
util.AddNetworkString("ow.item.cache")
util.AddNetworkString("ow.item.data")
util.AddNetworkString("ow.item.entity")
util.AddNetworkString("ow.item.perform")
util.AddNetworkString("ow.item.spawn")

net.Receive("ow.item.entity", function(len, client)
    local itemID = net.ReadUInt(32)
    local entity = net.ReadEntity()

    if ( !IsValid(entity) ) then return end

    local item = ow.item:Get(itemID)
    if ( !item ) then return end

    item:SetEntity(entity)
end)

net.Receive("ow.item.perform", function(len, client)
    local itemID = net.ReadUInt(32)
    local actionName = net.ReadString()

    if ( !itemID or !actionName ) then return end

    local item = ow.item:Get(itemID)
    if ( !item or item:GetOwner() != client:GetCharacterID() ) then return end

    ow.item:PerformAction(itemID, actionName)
end)

net.Receive("ow.item.spawn", function(len, client)
    local uniqueID = net.ReadString()
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

util.AddNetworkString("ow.currency.give")

--[[-----------------------------------------------------------------------------
    Miscellaneous Networking
-----------------------------------------------------------------------------]]--

util.AddNetworkString("ow.database.save")
util.AddNetworkString("ow.entity.setDataVariable")
util.AddNetworkString("ow.gesture.play")
util.AddNetworkString("ow.luarun.server.test")
util.AddNetworkString("ow.mainmenu")
util.AddNetworkString("ow.notification.send")

net.Receive("ow.luarun.server.test", function(len, client)
    client:Ban(0, false)
    client:Kick("You have been banned from this server. Thank you taking the bait!")

    ow.util:PrintWarning("Player " .. client:Name() .. " (" .. client:SteamID() .. ") has been banned for using the \"ow.luarun.server.test\" network message!")
end)