local MODULE = MODULE

net.Receive("ow.logging.send", function()
    local len = net.ReadUInt(32)
    local payload = net.ReadData(len)
    if ( !payload ) then return end

    ow.util:Print(ow.color:Get("log.message"), "Logging >> ", color_white, unpack(ow.crypto:Unpack(payload)))
end)

function MODULE:SendLog(...)
    ow.util:Print(ow.color:Get("log.message"), "Logging >> ", color_white, ...)
end