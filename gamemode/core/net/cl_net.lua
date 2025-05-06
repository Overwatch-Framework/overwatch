--[[-----------------------------------------------------------------------------
    Character Networking
-----------------------------------------------------------------------------]]--

ow.net:Hook("character.cache.all", function(data)
    if ( !istable(data) ) then print("Invalid data!") return end

    local client = ow.localClient
    local clientTable = client:GetTable()

    for k, v in pairs(data) do
        local character = ow.character:CreateObject(v.ID, v, client)
        local characterID = character:GetID()

        ow.character.stored = ow.character.stored or {}
        ow.character.stored[characterID] = character

        clientTable.owCharacters = clientTable.owCharacters or {}
        clientTable.owCharacters[characterID] = character
    end

    ow.localClient:Notify("All characters cached!")
end)

ow.net:Hook("character.cache", function(data)
    if ( !istable(data) ) then return end

    local client = ow.localClient
    local clientTable = client:GetTable()

    local character = ow.character:CreateObject(data.ID, data, client)
    local characterID = character:GetID()

    ow.character.stored = ow.character.stored or {}
    ow.character.stored[characterID] = character

    clientTable.owCharacters = clientTable.owCharacters or {}
    clientTable.owCharacters[characterID] = character
    clientTable.owCharacter = character

    ow.localClient:Notify("Character " .. characterID .. " cached!")
end)

ow.net:Hook("character.create.failed", function(reason)
    if ( !reason ) then return end

    ow.localClient:Notify(reason)
end)

ow.net:Hook("character.create", function()
    -- Do something here...
end)

ow.net:Hook("character.delete", function(characterID)
    if ( !isnumber(characterID) ) then return end

    local character = ow.character.stored[characterID]
    if ( !character ) then return end

    ow.character.stored[characterID] = nil

    local client = ow.localClient
    local clientTable = client:GetTable()
    if ( clientTable.owCharacters ) then
        clientTable.owCharacters[characterID] = nil
    end

    clientTable.owCharacter = nil

    if ( IsValid(ow.gui.mainmenu) ) then
        ow.gui.mainmenu:Populate()
    end

    ow.notification:Add("Character " .. characterID .. " deleted!", 5, ow.color:Get("success"))
end)

ow.net:Hook("character.load.failed", function(reason)
    if ( !reason ) then return end

    ow.localClient:Notify(reason)
end)

ow.net:Hook("character.load", function(characterID)
    if ( characterID == 0 ) then return end

    if ( IsValid(ow.gui.mainmenu) ) then
        ow.gui.mainmenu:Remove()
    end

    local client = ow.localClient

    local character, reason = ow.character:CreateObject(characterID, ow.character.stored[characterID], client)
    if ( !character ) then
        ow.util:PrintError("Failed to load character ", characterID, ", ", reason, "!")
        return
    end

    local clientTable = client:GetTable()

    ow.character.stored = ow.character.stored or {}
    ow.character.stored[characterID] = character

    clientTable.owCharacters = clientTable.owCharacters or {}
    clientTable.owCharacters[characterID] = character
    clientTable.owCharacter = character
end)

ow.net:Hook("character.variable.set", function(characterID, key, value)
    if ( !characterID or !key or !value ) then return end

    local character = ow.character:Get(characterID)
    if ( !character ) then return end

    character[key] = value
end)

--[[-----------------------------------------------------------------------------
    Chat Networking
-----------------------------------------------------------------------------]]--

ow.net:Hook("chat.send", function(data)
    if ( !istable(data) ) then return end

    local speaker = data.Speaker and Entity(data.Speaker) or nil
    local uniqueID = data.UniqueID
    local text = data.Text

    local chatData = ow.chat:Get(uniqueID)
    if ( istable(chatData) ) then
        chatData:OnChatAdd(speaker, text)
    end
end)

ow.net:Hook("chat.text", function(data)
    if ( !istable(data) ) then return end

    chat.AddText(unpack(data))
end)

--[[-----------------------------------------------------------------------------
    Config Networking
-----------------------------------------------------------------------------]]--

ow.net:Hook("config.sync", function(data)
    if ( !istable(data) ) then return end

    for k, v in pairs(data) do
        local stored = ow.config.stored[k]
        if ( !istable(stored) ) then continue end

        stored.Value = v
    end
end)

ow.net:Hook("config.set", function(key, value)
    ow.config:Set(key, value)
end)

--[[-----------------------------------------------------------------------------
    Option Networking
-----------------------------------------------------------------------------]]--

ow.net:Hook("option.set", function(key, value)
    local stored = ow.option.stored[key]
    if ( !istable(stored) ) then return end

    ow.option:Set(key, value)
end)

--[[-----------------------------------------------------------------------------
    Inventory Networking
-----------------------------------------------------------------------------]]--

ow.net:Hook("inventory.cache", function(data)
    if ( !istable(data) ) then return end

    local inventory = ow.inventory:CreateObject(data)
    if ( inventory ) then
        ow.inventory.stored[inventory:GetID()] = inventory

        local character = ow.character.stored[inventory.CharacterID]
        if ( character ) then
            local inventories = character:GetInventories()
            if ( !table.HasValue(inventories, inventory) ) then
                table.insert(inventories, inventory)
            end

            character:SetInventories(inventories)
        end
    end
end)

ow.net:Hook("inventory.item.add", function(inventoryID, itemID, uniqueID, data)
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

ow.net:Hook("inventory.item.remove", function(inventoryID, itemID)
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

ow.net:Hook("inventory.refresh", function(inventoryID)
    local panel = ow.gui.inventory
    if ( IsValid(panel) ) then
        panel:SetInventory(inventoryID)
    end
end)

ow.net:Hook("inventory.register", function(data)
    if ( !istable(data) ) then return end

    local inventory = ow.inventory:CreateObject(data)
    if ( inventory ) then
        ow.inventory.stored[inventory.ID] = inventory
    end
end)

--[[-----------------------------------------------------------------------------
    Item Networking
-----------------------------------------------------------------------------]]--

ow.net:Hook("item.add", function(itemID, inventoryID, uniqueID, data)
    ow.item:Add(itemID, inventoryID, uniqueID, data)
end)

ow.net:Hook("item.cache", function(data)
    if ( !istable(data) ) then return end

    for k, v in pairs(data) do
        local item = ow.item:CreateObject(v)
        if ( item ) then
            ow.item.instances[item.ID] = item

            if ( item.OnCache ) then
                item:OnCache()
            end
        end
    end
end)

ow.net:Hook("item.data", function(itemID, key, value)
    local item = ow.item:Get(itemID)
    if ( !item ) then return end

    item:SetData(key, value)
end)

ow.net:Hook("item.entity", function(entity, itemID)
    if ( !IsValid(entity) ) then return end

    local item = ow.item:Get(itemID)
    if ( !item ) then return end

    item:SetEntity(entity)
end)

--[[-----------------------------------------------------------------------------
    Currency Networking
-----------------------------------------------------------------------------]]--

ow.net:Hook("currency.give", function(entity, amount)
    if ( !IsValid(entity) ) then return end

    local phrase = ow.localization:GetPhrase("currency.pickup")
    phrase = string.format(phrase, amount .. ow.currency:GetSymbol())

    ow.localClient:Notify(phrase)
end)

--[[-----------------------------------------------------------------------------
    Miscellaneous Networking
-----------------------------------------------------------------------------]]--

ow.net:Hook("database.save", function(data)
    ow.localClient:GetTable().owDatabase = data
end)

ow.net:Hook("entity.setDataVariable", function(entity, key, value)
    if ( !IsValid(entity) ) then return end

    entity:GetTable()[key] = value
end)

ow.net:Hook("gesture.play", function(client, name)
    if ( !IsValid(client) ) then return end

    client:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, client:LookupSequence(name), 0, true)
end)

ow.net:Hook("mainmenu", function()
    ow.gui.mainmenu = vgui.Create("ow.mainmenu")
end)

ow.net:Hook("notification.send", function(text, type, duration)
    if ( !text ) then return end

    notification.AddLegacy(text, type, duration)
end)