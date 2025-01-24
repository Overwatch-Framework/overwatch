--[[-------------------------------------------------------------------------
    Clientsided networking
---------------------------------------------------------------------------]]

net.Receive("ow.chat.text", function(len)
    chat.AddText(unpack(net.ReadTable()))
end)

net.Receive("ow.gesture.play", function(len)
    local ply = net.ReadPlayer()
    local name = net.ReadString()

    if ( !IsValid(ply) ) then return end

    ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, ply:LookupSequence(name), 0, true)
end)