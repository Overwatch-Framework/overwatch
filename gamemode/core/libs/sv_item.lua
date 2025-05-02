-- server-side item logic
-- @module ow.item

function ow.item:Add(characterID, inventoryID, uniqueID, data, callback)
    if ( !characterID or !uniqueID or !self.stored[uniqueID] ) then return end

    data = data or {}

    ow.sqlite:Insert("ow_items", {
        inventory_id = inventoryID,
        character_id = characterID,
        unique_id = uniqueID,
        data = util.TableToJSON(data)
    }, function(result)
        if ( !result ) then return end

        local itemID = tonumber(result)
        if ( !itemID ) then return end

        local item = self:CreateObject({
            ID = itemID,
            UniqueID = uniqueID,
            Data = data,
            InventoryID = inventoryID,
            CharacterID = characterID
        })

        if ( !item ) then return end

        self.instances[itemID] = item

        local inventory = ow.inventory:Get(inventoryID)
        if ( inventory ) then
            local items = inventory:GetItems()
            if ( !table.HasValue(items, itemID) ) then
                table.insert(items, itemID)
            end
        end

        local receiver = ow.character:GetPlayerByCharacter(characterID)
        if ( IsValid(receiver) ) then
            local compressed = util.Compress(util.TableToJSON(data))

            net.Start("ow.item.add")
                net.WriteUInt(itemID, 32)
                net.WriteUInt(inventoryID, 32)
                net.WriteString(uniqueID)
                net.WriteData(compressed, #compressed)
            net.Send(receiver)
        end

        if ( callback ) then
            callback(itemID, data)
        end

        hook.Run("OnItemAdded", item, characterID, uniqueID, data)
    end)
end

function ow.item:Transfer(itemID, fromInventoryID, toInventoryID, callback)
    if ( !itemID or !fromInventoryID or !toInventoryID ) then return false end

    local item = self.instances[itemID]
    if ( !item ) then return false end

    local fromInventory = ow.inventory:Get(fromInventoryID)
    local toInventory = ow.inventory:Get(toInventoryID)

    print("[Transfer] itemID:", itemID)
    print(" -> fromInventory:", fromInventoryID)
    print(" -> toInventory:", toInventoryID)
    print(" -> item weight:", item:GetWeight())
    print(" -> toInventory object:", toInventory)
    print(" -> toInventory weight:", toInventory and toInventory:GetWeight())
    print(" -> max weight:", toInventory and toInventory:GetMaxWeight())
    print(" -> item owner:", item:GetOwner())

    if ( toInventory and !toInventory:HasSpaceFor(item:GetWeight()) ) then
        local receiver = ow.character:GetPlayerByCharacter(item:GetOwner())
        if ( IsValid(receiver) ) then
            receiver:Notify("Inventory is too full to transfer this item.")
        end
        return false
    end

    if ( fromInventory ) then
        fromInventory:RemoveItem(itemID)
    end

    if ( toInventory ) then
        toInventory:AddItem(itemID, item:GetUniqueID(), item:GetData())
    end

    item:SetInventory(toInventoryID)

    ow.sqlite:Update("ow_items", {
        inventory_id = toInventoryID
    }, "id = " .. itemID)

    if ( callback ) then
        callback(true)
    end

    return true
end

function ow.item:PerformAction(itemID, actionName, callback)
    local item = self.instances[itemID]
    if ( !item or !actionName ) then return false end

    local base = self.stored[item:GetUniqueID()]
    if ( !base or !base.Actions ) then return false end

    local action = base.Actions[actionName]
    if ( !action ) then return false end

    if ( action.OnCanRun and !action:OnCanRun(item) ) then
        return false
    end

    if ( action.OnRun ) then
        action:OnRun(item)
    end

    if ( callback ) then
        callback()
    end

    return true
end

function ow.item:Cache(characterID)
    if ( !characterID or !ow.character:Get(characterID) ) then return false end

    local results = ow.sqlite:Select("ow_items", nil, "character_id = " .. characterID)
    if ( !results ) then return false end

    for _, row in pairs(results) do
        local uniqueID = row.unique_id
        if ( self.stored[uniqueID] ) then
            self.instances[tonumber(row.id)] = self:CreateObject(row)
        end
    end

    local instances = {}
    for _, item in pairs(self.instances) do
        if ( item:GetOwner() == characterID ) then
            table.insert(instances, item)
        end
    end

    local receiver = ow.character:GetPlayerByCharacter(characterID)
    if ( IsValid(receiver) ) then
        net.Start("ow.item.cache")
            net.WriteUInt(characterID, 32)
            net.WriteTable(instances)
        net.Send(receiver)
    end

    return true
end

function ow.inventory:AddItem(inventoryID, itemID, uniqueID, data)
    if ( !inventoryID or !itemID or !uniqueID ) then return end

    local item = ow.item:Get(itemID)
    if ( !item ) then return end

    local inventory = self:Get(inventoryID)
    if ( !inventory ) then return end

    local receivers = inventory:GetReceivers()
    if ( !receivers or !istable(receivers) ) then receivers = {} end

    local items = inventory:GetItems()
    if ( !items or !istable(items) ) then items = {} end

    if ( !table.HasValue(items, itemID) ) then
        table.insert(items, itemID)
    end

    item:SetInventory(inventoryID)

    if ( SERVER ) then
        data = data or {}

        ow.sqlite:Update("ow_items", {
            inventory_id = inventoryID,
            data = util.TableToJSON(data)
        }, "id = " .. itemID)

        net.Start("ow.inventory.item.add")
            net.WriteUInt(inventoryID, 32)
            net.WriteUInt(itemID, 32)
            net.WriteString(uniqueID)
            net.WriteTable(data)
        net.Send(receivers or {})
    end
end

function ow.inventory:RemoveItem(inventoryID, itemID)
    if ( !inventoryID or !itemID ) then return end

    local item = ow.item:Get(itemID)
    if ( !item ) then return end

    local inventory = self:Get(inventoryID)
    if ( !inventory ) then return end

    local items = inventory:GetItems()
    if ( table.HasValue(items, itemID) ) then
        table.RemoveByValue(items, itemID)
    end

    item:SetInventory(0)

    if ( SERVER ) then
        ow.sqlite:Update("ow_items", {
            inventory_id = 0
        }, "id = " .. itemID)

        local receivers = inventory:GetReceivers()
        if ( istable(receivers) ) then
            net.Start("ow.inventory.item.remove")
                net.WriteUInt(inventoryID, 32)
                net.WriteUInt(itemID, 32)
            net.Send(receivers)
        end
    end
end

function ow.item:Spawn(itemID, uniqueID, position, angles, callback, data)
    if ( !uniqueID or !position or !self.stored[uniqueID] ) then return nil end

    local entity = ents.Create("ow_item")
    if ( !IsValid(entity) ) then return nil end

    entity:SetPos(position)
    entity:SetAngles(angles or angle_zero)
    entity:Spawn()
    entity:Activate()
    entity:SetItem(itemID, uniqueID)
    entity:SetData(data or {})

    if ( callback ) then
        callback(entity)
    end

    return entity
end

concommand.Add("ow_item_add", function(ply, cmd, args)
    if ( !ply:IsAdmin() ) then return end

    local uniqueID = args[1]
    if ( !uniqueID or !ow.item.stored[uniqueID] ) then return end

    local characterID = ply:GetCharacterID()
    local inventories = ow.inventory:GetByCharacterID(characterID)
    if ( #inventories == 0 ) then return end

    local inventoryID = inventories[1]:GetID()

    ow.item:Add(characterID, inventoryID, uniqueID, nil, function(itemID)
        ply:Notify("Item " .. uniqueID .. " added to inventory " .. inventoryID .. ".")
    end)
end)

concommand.Add("ow_item_spawn", function(ply, cmd, args)
    if ( !ply:IsAdmin() ) then return end

    local uniqueID = args[1]
    if ( !uniqueID ) then return end

    local pos = ply:GetEyeTrace().HitPos + Vector(0, 0, 10)

    ow.item:Spawn(nil, uniqueID, pos, nil, function(ent)
        if ( IsValid(ent) ) then
            ply:Notify("Item " .. uniqueID .. " spawned.")
        else
            ply:Notify("Failed to spawn item " .. uniqueID .. ".")
        end
    end)
end)