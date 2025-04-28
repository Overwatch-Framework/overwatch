util.AddNetworkString("ow.character.cache")
util.AddNetworkString("ow.character.cache.all")
util.AddNetworkString("ow.character.create")
util.AddNetworkString("ow.character.create.failed")
util.AddNetworkString("ow.character.delete")
util.AddNetworkString("ow.character.load")
util.AddNetworkString("ow.character.load.failed")
util.AddNetworkString("ow.chat.text")
util.AddNetworkString("ow.config.set")
util.AddNetworkString("ow.config.sync")
util.AddNetworkString("ow.database.save")
util.AddNetworkString("ow.gesture.play")
util.AddNetworkString("ow.item.add")
util.AddNetworkString("ow.mainmenu")

net.Receive("ow.config.set", function(len, ply)
    if ( !CAMI.PlayerHasAccess(ply, "Overwatch - Manage Config", nil) ) then return end

    local key = net.ReadString()
    local stored = ow.config.stored[key]
    if ( !istable(stored) ) then return end

    local value = net.ReadType()
    if ( value == nil ) then return end

    local oldValue = ow.config:Get(key)

    local bResult = hook.Run("PreConfigChanged", key, value, oldValue, ply)
    if ( tobool(bResult) == false ) then return end

    ow.config:Set(key, value, ply)

    hook.Run("PostConfigChanged", key, value, oldValue, ply)
end)

util.AddNetworkString("ow.character.create")
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

util.AddNetworkString("ow.option.set")
net.Receive("ow.option.set", function(len, ply)
    local key = net.ReadString()
    local value = net.ReadType()

    local bResult = hook.Run("PreOptionChanged", ply, key, value)
    if ( bResult == false ) then return false end

    ow.option:Set(ply, key, value)

    hook.Run("PostOptionChanged", ply, key, value)
end)

util.AddNetworkString("ow.option.syncServer")
net.Receive("ow.option.syncServer", function(len, ply)
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