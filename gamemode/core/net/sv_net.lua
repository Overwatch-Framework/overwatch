util.AddNetworkString("ow.chat.text")
util.AddNetworkString("ow.gesture.play")
util.AddNetworkString("ow.item.add")
util.AddNetworkString("ow.config.sync")
util.AddNetworkString("ow.config.set")
util.AddNetworkString("ow.database.save")

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
    local payload = net.ReadTable()

    local bResult = hook.Run("PreCharacterCreate", ply, payload)
    if ( bResult == false ) then return end

    local character = ow.character:Create(ply, payload)
    if ( !character ) then
        ply:ChatPrint("Failed to create character.")
        return
    end

    ply:ChatPrint("Character created successfully!")
end)

util.AddNetworkString("ow.option.set")
net.Receive("ow.option.set", function(len, ply)
    local key = net.ReadString()
    local value = net.ReadType()

    local stored = ow.option.stored[key]
    if ( !istable(stored) ) then
        ow.util:PrintError("Option \"" .. key .. "\" does not exist!")
        return
    end

    if ( ow.util:GetTypeFromValue(value) != stored.Type ) then
        ow.util:PrintError("Option \"" .. key .. "\" is not of type \"" .. stored.Type .. "\"!")
        return
    end

    local bResult = hook.Run("PreOptionChanged", ply, key, value)
    if ( bResult == false ) then return false end

    if ( !stored.bNoNetworking ) then
        ow.option.clients[ply] = ow.option.clients[ply] or {}
        ow.option.clients[ply][key] = value
    end

    if ( stored.OnChange ) then
        stored:OnChange(value, ply)
    end

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

util.AddNetworkString("ow.character.delete")
util.AddNetworkString("ow.character.load")