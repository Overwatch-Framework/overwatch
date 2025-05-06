local MODULE = MODULE

function MODULE:Send(...)
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

    ow.net:Start(receivers, "logging.send", {...})
end