util.AddNetworkString("ow.chat.text")
util.AddNetworkString("ow.gesture.play")
util.AddNetworkString("ow.item.add")
util.AddNetworkString("ow.config.sync")
util.AddNetworkString("ow.config.set")
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
end)