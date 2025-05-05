local MODULE = MODULE

net.Receive("ow.logging.send", function()
    local payload = sfs.decode(net.ReadString())
    if ( !payload ) then return end

    ow.util:Print(ow.color:Get("log.message"), "Logging >> ", color_white, unpack(payload))
end)

function MODULE:SendLog(...)
    ow.util:Print(ow.color:Get("log.message"), "Logging >> ", color_white, ...)
end