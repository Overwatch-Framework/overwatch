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
    local compressedTable = util.JSONToTable(util.Decompress(net.ReadData(len / 8)))
    LocalPlayer():GetTable().owDatabase = compressedTable
end)

net.Receive("ow.character.create", function(len)
    print("Character created!")
end)

net.Receive("ow.character.create.failed", function(len)
    local reason = net.ReadString()
    if ( !reason ) then return end

    notification.AddLegacy(reason, NOTIFY_ERROR, 5)
end)

net.Receive("ow.character.cache", function(len)
    local data = util.JSONToTable(util.Decompress(net.ReadData(len / 8)))
    if ( !istable(data) ) then return end

    local ply = LocalPlayer()
    local plyTable = ply:GetTable()

    local character = ow.character:CreateObject(data.id, data, ply)
    local id = character:GetID()

    ow.character.stored = ow.character.stored or {}
    ow.character.stored[id] = character

    plyTable.owCharacters = plyTable.owCharacters or {}
    plyTable.owCharacters[id] = character
    plyTable.owCharacter = character

    notification.AddLegacy("Character " .. id .. " cached!", NOTIFY_GENERIC, 5)
end)

net.Receive("ow.character.cache.all", function(len)
    local data = util.JSONToTable(util.Decompress(net.ReadData(len / 8)))
    if ( !istable(data) ) then return end

    local ply = LocalPlayer()
    local plyTable = ply:GetTable()

    for k, v in pairs(data) do
        local character = ow.character:CreateObject(v.id, v, ply)
        local id = character:GetID()

        ow.character.stored = ow.character.stored or {}
        ow.character.stored[id] = character

        plyTable.owCharacters = plyTable.owCharacters or {}
        plyTable.owCharacters[id] = character
    end

    notification.AddLegacy("Characters cached!", NOTIFY_GENERIC, 5)
end)

net.Receive("ow.character.load", function(len)
    local characterID = net.ReadUInt(32)
    if ( !characterID ) then return end

    if ( ow.gui.mainmenu ) then
        ow.gui.mainmenu:Remove()
    end

    local character, reason = ow.character:CreateObject(characterID, ow.character.stored[characterID], LocalPlayer())
    if ( !character ) then print("Failed to load character " .. characterID .. "!", reason) return end
    print("Character " .. characterID .. " loaded.", character)

    local ply = LocalPlayer()
    local plyTable = ply:GetTable()

    ow.character.stored = ow.character.stored or {}
    ow.character.stored[characterID] = character

    plyTable.owCharacters = plyTable.owCharacters or {}
    plyTable.owCharacters[characterID] = character
    plyTable.owCharacter = character
end)

net.Receive("ow.mainmenu", function(len)
    ow.gui.mainmenu = vgui.Create("ow.mainmenu")
end)

net.Receive("ow.character.delete", function(len)
    local characterID = net.ReadUInt(32)
    if ( !isnumber(characterID) ) then return end

    local character = ow.character.stored[characterID]
    if ( !character ) then return end

    ow.character.stored[characterID] = nil

    local ply = LocalPlayer()
    local plyTable = ply:GetTable()
    if ( plyTable.owCharacters ) then
        plyTable.owCharacters[characterID] = nil
    end

    plyTable.owCharacter = nil

    ow.notification:Add("Character " .. characterID .. " deleted!", 5, ow.colour:Get("ui.success"))
end)

net.Receive("ow.notification.send", function(len)
    local text = net.ReadString()
    local type = net.ReadUInt(8)
    local duration = net.ReadUInt(16)

    if ( !text ) then return end

    notification.AddLegacy(text, type, duration)
end)