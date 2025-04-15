local MODULE = MODULE

net.Receive("ow.logging.send", function(len)
    local compressed = util.JSONToTable(util.Decompress(net.ReadData(len / 8)))

    MODULE:SendLog(unpack(compressed))
end)

function MODULE:SendLog(...)
    ow.util:Print(ow.color:Get("ow.log.message"), "Logging >> ", color_white, ...)
end