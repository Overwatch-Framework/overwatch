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

net.Receive("ow.character.load", function(len, ply)
    local characterID = net.ReadUInt(32)
    if ( !characterID ) then return end

    ow.character:Load(ply, characterID)
end)

net.Receive("ow.character.delete", function(len, ply)
    local characterID = net.ReadUInt(32)
    if ( !characterID ) then return end

    local character = ow.character:Get(characterID)
    if ( !character ) then return end

    local bResult = hook.Run("PreCharacterDelete", ply, character)
    if ( bResult == false ) then return end

    ow.character:Delete(characterID)

    hook.Run("PostCharacterDelete", ply, character)
end)

net.Receive("ow.character.create", function(len, ply)
    -- TODO: Make this more secure, validate the payload and check if the player is allowed to create a character and probably check for other stuff and do other cool things later on in the menus
    local payload = util.JSONToTable(util.Decompress(net.ReadData(len / 8)))
    if ( !istable(payload) ) then return end
    PrintTable(payload)

    local bResult = hook.Run("PreCharacterCreate", ply, payload)
    if ( bResult == false ) then return end

    for k, v in pairs(ow.character.variables) do
        if ( v.Editable != true ) then continue end

        -- This is a bit of a hack, but it works for now.
        if ( v.Type == ow.type.string or v.Type == ow.type.text ) then
            payload[k] = string.Trim(payload[k] or "")
        end

        if ( v.OnValidate ) then
            local validate, reason = v:OnValidate(ply, payload, ply)
            if ( !validate ) then
                net.Start("ow.character.create.failed")
                    net.WriteString(reason or "Failed to validate character!")
                net.Send(ply)

                return
            end
        end
    end

    local character, reason = ow.character:Create(ply, payload)
    if ( !character ) then
        net.Start("ow.character.create.failed")
            net.WriteString(reason or "Failed to create character!")
        net.Send(ply)

        return
    end

    ow.character:Load(ply, character:GetID())

    net.Start("ow.character.create")
    net.Send(ply)

    hook.Run("PostCharacterCreate", ply, character, payload)
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

net.Receive("ow.config.reset", function(len, ply)
    if ( !CAMI.PlayerHasAccess(ply, "Overwatch - Manage Config", nil) ) then return end

    local key = net.ReadString()
    local stored = ow.config.stored[key]
    if ( !istable(stored) ) then return end

    local bResult = hook.Run("PrePlayerConfigReset", ply, key)
    if ( bResult == false ) then return end

    ow.config:Reset(key)

    hook.Run("PostPlayerConfigReset", ply, key)
end)

net.Receive("ow.config.set", function(len, ply)
    if ( !CAMI.PlayerHasAccess(ply, "Overwatch - Manage Config", nil) ) then return end

    local key = net.ReadString()
    local stored = ow.config.stored[key]
    if ( !istable(stored) ) then return end

    local value = net.ReadType()
    if ( value == nil ) then return end

    local oldValue = ow.config:Get(key)

    local bResult = hook.Run("PrePlayerConfigChanged", ply, key, value, oldValue)
    if ( bResult == false ) then return end

    ow.config:Set(key, value)

    hook.Run("PostPlayerConfigChanged", ply, key, value, oldValue)
end)

--[[-----------------------------------------------------------------------------
    Option Networking
-----------------------------------------------------------------------------]]--

util.AddNetworkString("ow.option.set")
util.AddNetworkString("ow.option.sync")

net.Receive("ow.option.set", function(len, ply)
    local key = net.ReadString()
    local value = net.ReadType()

    local bResult = hook.Run("PreOptionChanged", ply, key, value)
    if ( bResult == false ) then return false end

    ow.option:Set(ply, key, value)

    hook.Run("PostOptionChanged", ply, key, value)
end)

net.Receive("ow.option.sync", function(len, ply)
    if ( !IsValid(ply) ) then return end

    local data = util.JSONToTable(util.Decompress(net.ReadData(len / 8)))
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

            if ( ow.option.clients[ply] == nil ) then
                ow.option.clients[ply] = {}
            end

            ow.option.clients[ply][k] = data[k]
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

net.Receive("ow.inventory.cache", function(len, ply)
    local inventoryID = net.ReadUInt(32)
    if ( !inventoryID ) then return end

    ow.inventory:Cache(ply, inventoryID)
end)

--[[-----------------------------------------------------------------------------
    Item Networking
-----------------------------------------------------------------------------]]--

util.AddNetworkString("ow.item.add")
util.AddNetworkString("ow.item.cache")
util.AddNetworkString("ow.item.entity")
util.AddNetworkString("ow.item.perform")
util.AddNetworkString("ow.item.spawn")

net.Receive("ow.item.entity", function(len, ply)
    local itemID = net.ReadUInt(32)
    local entity = net.ReadEntity()

    if ( !IsValid(entity) ) then return end

    local item = ow.item:Get(itemID)
    if ( !item ) then return end

    item:SetEntity(entity)
end)

net.Receive("ow.item.perform", function(len, ply)
    local itemID = net.ReadUInt(32)
    local actionName = net.ReadString()

    if ( !itemID or !actionName ) then return end

    local item = ow.item:Get(itemID)
    if ( !item or item:GetOwner() != ply:GetCharacterID() ) then return end

    ow.item:PerformAction(itemID, actionName)
end)

net.Receive("ow.item.spawn", function(len, ply)
    local uniqueID = net.ReadString()
    if ( !uniqueID or !ow.item.stored[uniqueID] ) then return end

    local pos = ply:GetEyeTrace().HitPos + Vector(0, 0, 10)

    ow.item:Spawn(nil, uniqueID, pos, nil, function(entity)
        if ( IsValid(entity) ) then
            ply:Notify("Spawned item: " .. uniqueID)
        else
            ply:Notify("Failed to spawn item.")
        end
    end)
end)

--[[-----------------------------------------------------------------------------
    Miscellaneous Networking
-----------------------------------------------------------------------------]]--

util.AddNetworkString("ow.database.save")
util.AddNetworkString("ow.entity.setDataVariable")
util.AddNetworkString("ow.gesture.play")
util.AddNetworkString("ow.luarun.server.test")
util.AddNetworkString("ow.mainmenu")
util.AddNetworkString("ow.notification.send")

net.Receive("ow.luarun.server.test", function(len, ply)
    ply:Ban(0, false)
    ply:Kick("You have been banned from this server. Thank you taking the bait!")

    ow.util:PrintWarning("Player " .. ply:Name() .. " (" .. ply:SteamID() .. ") has been banned for using the \"ow.luarun.server.test\" network message!")
end)