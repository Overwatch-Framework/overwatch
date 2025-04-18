net.Receive("ow.chat.text", function(len)
    local receivedTable = util.JSONToTable(util.Decompress(net.ReadData(len / 8)))

    chat.AddText(unpack(receivedTable))
end)

net.Receive("ow.gesture.play", function(len)
    local ply = net.ReadPlayer()
    local name = net.ReadString()

    if ( !IsValid(ply) ) then return end

    ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, ply:LookupSequence(name), 0, true)
end)

net.Receive("ow.item.add", function(len)
    local uniqueID = net.ReadString()
    local data = util.JSONToTable(util.Decompress(net.ReadData(len / 8)))

    ow.item:Add(uniqueID, data)
end)

net.Receive("ow.config.sync", function(len)
    local compressedTable = util.JSONToTable(util.Decompress(net.ReadData(len / 8)))

    ow.config.stored = compressedTable
end)

net.Receive("ow.config.set", function(len)
    local key = net.ReadString()
    local value = net.ReadType()

    local stored = ow.config.stored[key]
    if ( !istable(stored) ) then return end

    ow.config:Set(key, value)
    print("Config " .. key .. " set to " .. tostring(value))
end)