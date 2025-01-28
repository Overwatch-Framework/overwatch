net.Receive("ow.chat.text", function(len)
    chat.AddText(unpack(net.ReadTable()))
end)

net.Receive("ow.gesture.play", function(len)
    local ply = net.ReadPlayer()
    local name = net.ReadString()

    if ( !IsValid(ply) ) then return end

    ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, ply:LookupSequence(name), 0, true)
end)

net.Receive("ow.item.add", function(len)
    local uniqueID = net.ReadString()
    local data = net.ReadTable()

    ow.item:Add(uniqueID, data)
end)

net.Receive("ow.config.sync", function(len)
    local values = net.ReadTable()
    for key, value in pairs(values) do
        if ( ow.config.stored[key] ) then
            ow.config.stored[key].Value = value or ow.config.stored[key].Default
        end
    end
end)

net.Receive("ow.config.set", function(len)
    local key = net.ReadString()
    local value = net.ReadType()

    if ( !ow.config.stored[key] ) then return end
    ow.config.stored[key].Value = value
end)

net.Receive("ixDataSync", function()
    ow.localData = net.ReadTable()
    ow.playTime = net.ReadUInt(32)
end)

net.Receive("ixData", function()
    ow.localData = ix.localData or {}
    ow.localData[net.ReadString()] = net.ReadType()
end)