local MODULE = MODULE

util.AddNetworkString("ow.logging.send")

function MODULE:SendLog(...)
    if ( !ow.config:Get("logging", true) ) then return end

    local receivers = {}
    for k, v in player.Iterator() do
        if ( !CAMI.PlayerHasAccess(v, "Overwatch - Logging") ) then continue end

        table.insert(receivers, v)
    end

    -- Send to the remote console if we are in a dedicated server
    if ( game.IsDedicated() ) then
        ow.util:Print(ow.color:Get("log.message"), "Logging >> ", color_white, ...)
    end

    -- Send to clients who are permitted to see the log
    local encoded, err = sfs.encode({...})
    if ( err ) then
        ow.util:PrintError("Failed to encode log message: " .. err)
        return false
    end

    net.Start("ow.logging.send")
        net.WriteData(encoded, #encoded)
    net.Send(receivers)
end