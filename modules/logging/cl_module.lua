local MODULE = MODULE

ow.net:Hook("logging.send", function(payload)
    if ( !payload ) then return end

    ow.util:Print(ow.color:Get("log.message"), "Logging >> ", color_white, unpack(payload))
end)

function MODULE:Send(...)
    ow.util:Print(ow.color:Get("log.message"), "Logging >> ", color_white, ...)
end