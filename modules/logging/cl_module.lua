local MODULE = MODULE

net.Receive("ow.logging.send", function()
    MODULE:SendLog(unpack(net.ReadTable()))
end)

function MODULE:SendLog(...)
    ow.util:Print(Color(250, 200, 25), "Logging | ", color_white, ...)
end