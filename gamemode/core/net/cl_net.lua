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
    local itemID = net.ReadUInt(32)
    local data = util.JSONToTable(util.Decompress(net.ReadData(len / 8)))

    ow.item:Add(itemID, uniqueID, data)

    print("Item " .. uniqueID .. " received with ID " .. itemID .. ".")
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
end)

net.Receive("ow.chat.send", function(len)
    local speaker = net.ReadPlayer()
    local uniqueID = net.ReadString()
    local text = net.ReadString()

    local chatData = ow.chat:Get(uniqueID)
    if ( istable(chatData) ) then
        chatData:OnChatAdd(speaker, text)
    end
end)

net.Receive("ow.option.set", function(len)
    local key = net.ReadString()
    local value = net.ReadType()

    local stored = ow.option.stored[key]
    if ( !istable(stored) ) then return end

    ow.option:Set(key, value)
end)

net.Receive("ow.database.save", function(len)
    LocalPlayer().owDatabase = net.ReadTable()
end)

net.Receive("ow.character.load", function(len)
    local data = net.ReadTable()
    if ( !istable(data) ) then return end

    local character = ow.character:CreateObject(data.id, data, LocalPlayer())
    local id = character:GetID()

    LocalPlayer().owCharacters = LocalPlayer().owCharacters or {}
    LocalPlayer().owCharacters[id] = character
    LocalPlayer().owCharacter = character

    notification.AddLegacy("Character " .. id .. " loaded!", NOTIFY_GENERIC, 5)
end)

net.Receive("ow.character.load.all", function(len)
    LocalPlayer().owCharacters = net.ReadTable()
    notification.AddLegacy("Characters loaded!", NOTIFY_GENERIC, 5)
end)