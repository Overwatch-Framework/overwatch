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
    local itemID = net.ReadUInt(32)
    local inventoryID = net.ReadUInt(32)
    local uniqueID = net.ReadString()
    local data = util.JSONToTable(util.Decompress(net.ReadData(len / 8)))

    ow.item:Add(itemID, inventoryID, uniqueID, data)

    print("Item " .. uniqueID .. " received with ID " .. itemID .. ".")
end)

net.Receive("ow.config.sync", function(len)
    local compressedTable = util.JSONToTable(util.Decompress(net.ReadData(len / 8)))

    ow.config.stored = compressedTable
end)

net.Receive("ow.config.set", function(len)
    local key = net.ReadString()
    local value = net.ReadType()

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
    ow.localClient:GetTable().owDatabase = compressedTable
end)

net.Receive("ow.character.create", function(len)
    print("Character created!")
end)

net.Receive("ow.character.create.failed", function(len)
    local reason = net.ReadString()
    if ( !reason ) then return end

    ow.localClient:Notify(reason)
end)

net.Receive("ow.character.cache", function(len)
    local data = util.JSONToTable(util.Decompress(net.ReadData(len / 8)))
    if ( !istable(data) ) then return end

    local ply = ow.localClient
    local plyTable = ply:GetTable()

    local character = ow.character:CreateObject(data.ID, data, ply)
    local characterID = character:GetID()

    ow.character.stored = ow.character.stored or {}
    ow.character.stored[characterID] = character

    plyTable.owCharacters = plyTable.owCharacters or {}
    plyTable.owCharacters[characterID] = character
    plyTable.owCharacter = character

    ow.localClient:Notify("Character " .. characterID .. " cached!")
end)

net.Receive("ow.character.cache.all", function(len)
    local data = util.JSONToTable(util.Decompress(net.ReadData(len / 8)))
    if ( !istable(data) ) then return end

    local ply = ow.localClient
    local plyTable = ply:GetTable()

    for k, v in pairs(data) do
        local character = ow.character:CreateObject(v.ID, v, ply)
        local characterID = character:GetID()

        ow.character.stored = ow.character.stored or {}
        ow.character.stored[characterID] = character

        plyTable.owCharacters = plyTable.owCharacters or {}
        plyTable.owCharacters[characterID] = character
    end

    ow.localClient:Notify("All characters cached!")
end)

net.Receive("ow.character.load", function(len)
    local characterID = net.ReadUInt(32)
    if ( !characterID ) then return end

    if ( ow.gui.mainmenu ) then
        ow.gui.mainmenu:Remove()
    end

    local ply = ow.localClient

    local character, reason = ow.character:CreateObject(characterID, ow.character.stored[characterID], ply)
    if ( !character ) then print("Failed to load character " .. characterID .. "!", reason) return end
    print("Character " .. characterID .. " loaded.", character)

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
    if ( !isnumber(characterID) ) then print("Failed to delete character " .. characterID .. "!") return end

    local character = ow.character.stored[characterID]
    if ( !character ) then print("Failed to delete character " .. characterID .. "!") return end

    ow.character.stored[characterID] = nil

    local ply = ow.localClient
    local plyTable = ply:GetTable()
    if ( plyTable.owCharacters ) then
        plyTable.owCharacters[characterID] = nil
    end

    plyTable.owCharacter = nil

    if ( IsValid(ow.gui.mainmenu) ) then
        ow.gui.mainmenu:Populate()
    end

    ow.notification:Add("Character " .. characterID .. " deleted!", 5, ow.color:Get("ui.success"))
end)

net.Receive("ow.notification.send", function(len)
    local text = net.ReadString()
    local type = net.ReadUInt(8)
    local duration = net.ReadUInt(16)

    if ( !text ) then return end

    notification.AddLegacy(text, type, duration)
end)

net.Receive("ow.inventory.register", function(len, ply)
    local inventoryData = net.ReadTable()
    if ( !istable(inventoryData) ) then return end

    local bResult = hook.Run("PreInventoryRegistered", inventoryData)
    if ( bResult == false ) then return end

    local inventoryID = inventoryData.ID
    if ( !inventoryID ) then return end

    local inventory = ow.inventory:CreateObject(inventoryID, inventoryData, ply)
    if ( !inventory ) then return end

    print("Inventory " .. inventoryID .. " registered!")
end)

net.Receive("ow.inventory.cache", function(len)
    local inventoryData = net.ReadTable()
    if ( !istable(inventoryData) ) then return end

    local bResult = hook.Run("PreInventoryCached", inventoryData)
    if ( bResult == false ) then return end

    local inventoryID = inventoryData.ID
    if ( !inventoryID ) then return end

    local inventory = ow.inventory:CreateObject(inventoryID, inventoryData)
    if ( !inventory ) then return end

    ow.inventory.stored = ow.inventory.stored or {}
    ow.inventory.stored[inventoryID] = inventory

    -- if the character object exists, add the inventory to it
    local character = ow.character.stored[inventoryData.characterID]
    if ( character ) then
        local inventories = character:GetInventories()
        if ( !table.HasValue(inventories, inventory) ) then
            table.insert(inventories, inventory)
        end

        character:SetInventories(inventories)
        print("Inventory " .. inventoryID .. " added to character " .. inventoryData.characterID .. "!")
    end

    print(inventory)
    PrintTable(inventory)

    print("Inventory " .. inventoryID .. " cached!")
end)

net.Receive("ow.entity.setDataVariable", function(len)
    local entity = net.ReadEntity()
    local key = net.ReadString()
    local value = net.ReadType()

    if ( !IsValid(entity) ) then return end

    local entityTable = entity:GetTable()

    entityTable[key] = value
end)