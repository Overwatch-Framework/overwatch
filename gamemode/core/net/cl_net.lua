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

    if ( IsValid(ow.gui.mainmenu) ) then
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

net.Receive("ow.entity.setDataVariable", function(len)
    local entity = net.ReadEntity()
    local key = net.ReadString()
    local value = net.ReadType()

    if ( !IsValid(entity) ) then return end

    local entityTable = entity:GetTable()

    entityTable[key] = value
end)

net.Receive("ow.item.add", function()
    local itemID = net.ReadUInt(32)
    local inventoryID = net.ReadUInt(32)
    local uniqueID = net.ReadString()
    local data = util.JSONToTable(util.Decompress(net.ReadData(net.BytesLeft())))

    ow.item:Add(itemID, inventoryID, uniqueID, data)
end)

net.Receive("ow.item.cache", function()
    local characterID = net.ReadUInt(32)
    local items = net.ReadTable()

    for _, itemData in ipairs(items) do
        local uniqueID = itemData.UniqueID
        if ( ow.item.stored[uniqueID] ) then
            ow.item.instances[tonumber(itemData.ID)] = ow.item:CreateObject(itemData)
        end
    end
end)

net.Receive("ow.item.entity", function()
    local itemID = net.ReadUInt(32)
    local entity = net.ReadEntity()
    if ( !IsValid(entity) ) then return end

    local item = ow.item:Get(itemID)
    if ( item ) then
        item:SetEntity(entity)
    end
end)

net.Receive("ow.inventory.cache", function()
    local inventoryData = net.ReadTable()
    if ( !istable(inventoryData) ) then return end

    local inventory = ow.inventory:CreateObject(inventoryData)
    if ( inventory ) then
        ow.inventory.stored[inventory:GetID()] = inventory

        local character = ow.character.stored[inventory.CharacterID]
        if ( character ) then
            local inventories = character:GetInventories()
            print("Inventories: ", inventories)
            if ( !table.HasValue(inventories, inventory) ) then
                table.insert(inventories, inventory)
            end

            character:SetInventories(inventories)
        end
    end
end)

net.Receive("ow.inventory.register", function()
    local inventoryData = net.ReadTable()
    if ( !istable(inventoryData) ) then return end

    local inventory = ow.inventory:CreateObject(inventoryData)
    if ( inventory ) then
        ow.inventory.stored[inventory.ID] = inventory
    end
end)

net.Receive("ow.inventory.item.add", function()
    local inventoryID = net.ReadUInt(32)
    local itemID = net.ReadUInt(32)
    local uniqueID = net.ReadString()
    local data = net.ReadTable()

    local item = ow.item:Add(itemID, inventoryID, uniqueID, data)
    if ( !item ) then return end

    local inventory = ow.inventory:Get(inventoryID)
    if ( inventory ) then
        local items = inventory:GetItems()
        if ( !table.HasValue(items, itemID) ) then
            table.insert(items, itemID)
        end
    end
end)

net.Receive("ow.inventory.item.remove", function()
    local inventoryID = net.ReadUInt(32)
    local itemID = net.ReadUInt(32)

    local inventory = ow.inventory:Get(inventoryID)
    if ( !inventory ) then return end

    local items = inventory:GetItems()
    if ( table.HasValue(items, itemID) ) then
        table.RemoveByValue(items, itemID)
    end

    local item = ow.item:Get(itemID)
    if ( item ) then
        item:SetInventory(0)
    end
end)

net.Receive("ow.inventory.refresh", function()
    local inventoryID = net.ReadUInt(32)

    local panel = ow.gui.inventory
    if ( IsValid(panel) ) then
        panel:SetInventory(inventoryID)
    end
end)

net.Receive("ow.entity.setDataVariable", function()
    local entity = net.ReadEntity()
    local key = net.ReadString()
    local value = net.ReadType()

    if ( IsValid(entity) ) then
        local entTable = entity:GetTable()
        entTable[key] = value
    end
end)