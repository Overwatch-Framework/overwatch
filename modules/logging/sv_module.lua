local MODULE = MODULE

util.AddNetworkString("ow.logging.send")

function MODULE:SendLog(...)
    local receivers = {}
    for k, v in player.Iterator() do
        if ( !CAMI.PlayerHasAccess(v, "Overwatch - Logging") ) then continue end

        table.insert(receivers, v)
    end

    -- Send to the remote console if we are in a dedicated server
    if ( game.IsDedicated() ) then
        ow.util:Print(ow.color:Get("ow.log.message") "Logging | ", color_white, ...)
    end

    -- Send to clients who are permitted to see the log
    net.Start("ow.logging.send")
        net.WriteTable({...})
    net.Send(receivers)
end