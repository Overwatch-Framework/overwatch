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

    if ( ow.util:SanitizeType(value) != stored.Type ) then
        ow.util:PrintError("Attempted to set config \"" .. key .. "\" with invalid type!")
        return
    end

    local bResult = hook.Run9("PreConfigChanged", ply, key, value)
    if ( tobool(bResult) == false ) then return end

    stored.Value = value

    net.Start("ow.config.set")
        net.WriteString(key)
        net.WriteType(value)
    net.Broadcast()

    if ( isfunction(stored.OnChange) ) then
        stored:OnChange(value, ply)
    end

    hook.Run("PostConfigChanged", ply, key, value)
end)