local MODULE = MODULE

net.Receive("ow.logging.send", function()
    MODULE:SendLog(unpack(net.ReadTable()))
end)

function MODULE:SendLog(...)
    ow.util:Print(ow.color:Get("ow.log.message"), "Logging | ", color_white, ...)
end