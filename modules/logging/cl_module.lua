local MODULE = MODULE

net.Receive("ow.logging.send", function(len)
    local payload = sfs.decode(net.ReadData(len / 8))
    if ( !payload ) then return end

    ow.util:Print(ow.color:Get("log.message"), "Logging >> ", color_white, unpack(payload))
end)

function MODULE:Send(...)
    ow.util:Print(ow.color:Get("log.message"), "Logging >> ", color_white, ...)
end