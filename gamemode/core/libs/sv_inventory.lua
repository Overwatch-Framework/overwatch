-- Inventory management library.
-- @module ow.inventory

function ow.inventory:Register(data)
    if ( !istable(data) or !data.characterID ) then return false end

    local bResult = hook.Run("PreInventoryRegistered", data)
    if ( bResult == false ) then return false end

    local inventoryID
    ow.sqlite:Insert("ow_inventories", {
        character_id = data.characterID,
        name = data.name or "Main",
        max_weight = data.maxWeight or ow.config:Get("inventory.maxweight", 20),
        data = util.TableToJSON(data.data or {})
    }, function(result)
        if ( result ) then
            inventoryID = tonumber(result)
        else
            ErrorNoHalt("Failed to insert inventory into database for character " .. data.characterID .. "\n")
        end
    end)

    if ( !inventoryID ) then
        return false
    end

    data.ID = inventoryID
    local inventory = self:CreateObject(data)
    if ( !inventory ) then
        ErrorNoHalt("Failed to create inventory object for ID " .. inventoryID .. "\n")
        return false
    end

    self.stored[inventoryID] = inventory
    self:AssignToCharacter(data.characterID, inventoryID)
    self:Broadcast(inventory)

    hook.Run("PostInventoryRegistered", inventory)

    return inventory
end

function ow.inventory:AssignToCharacter(characterID, inventoryID)
    if ( !characterID or !inventoryID ) then return end

    local result = ow.sqlite:Select("ow_characters", nil, "id = " .. characterID)
    if ( !result or !result[1] ) then return end

    local inventories = util.JSONToTable(result[1].inventories or "[]") or {}

    if ( !table.HasValue(inventories, inventoryID) ) then
        table.insert(inventories, inventoryID)
    end

    ow.sqlite:Update("ow_characters", {
        inventories = util.TableToJSON(inventories)
    }, "id = " .. characterID)

    local character = ow.character:Get(characterID)
    if ( character ) then
        character:SetInventories(inventories)
    end
end

function ow.inventory:Broadcast(inventory)
    if ( !inventory ) then return end

    local receivers = inventory:GetReceivers()
    if ( !istable(receivers) ) then return end

    net.Start("ow.inventory.register")
        net.WriteTable({
            ID = inventory:GetID(),
            CharacterID = inventory:GetOwner(),
            Name = inventory:GetName(),
            MaxWeight = inventory:GetMaxWeight(),
            Items = inventory:GetItems(),
            Data = inventory:GetData(),
            Receivers = inventory.Receivers
        })
    net.Send(receivers)
end

function ow.inventory:Cache(client, inventoryID)
    if ( !IsValid(client) or !inventoryID ) then return false end

    local result = ow.sqlite:Select("ow_inventories", nil, "id = " .. inventoryID)
    if ( !result or !result[1] ) then return false end

    local inventory = self:CreateObject(result[1])
    if ( !inventory ) then return false end

    self.stored[inventoryID] = inventory
    self:AssignToCharacter(inventory:GetOwner(), inventoryID)
    ow.item:Cache(inventory:GetOwner())

    local itemIDs = {}
    for _, item in pairs(ow.item.instances) do
        if ( item:GetOwner() == inventory:GetOwner() ) then
            table.insert(itemIDs, item:GetID())
        end
    end

    inventory.Items = itemIDs

    net.Start("ow.inventory.cache")
        net.WriteTable({
            ID = inventory:GetID(),
            CharacterID = inventory:GetOwner(),
            Name = inventory:GetName(),
            MaxWeight = inventory:GetMaxWeight(),
            Items = inventory:GetItems(),
            Data = inventory:GetData(),
            Receivers = inventory.Receivers
        })
    net.Send(client)

    return true
end

function ow.inventory:CacheAll(characterID)
    if ( !characterID ) then return end

    local result = ow.sqlite:Select("ow_characters", nil, "id = " .. characterID)
    if ( !result or !result[1] ) then return end

    local inventories = util.JSONToTable(result[1].inventories or "[]") or {}

    for _, invID in ipairs(inventories) do
        local client = ow.character:GetPlayerByCharacter(characterID)
        self:Cache(client, invID)
    end
end