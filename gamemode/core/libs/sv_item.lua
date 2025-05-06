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
            local encoded, err = sfs.encode(data)
            if ( err ) then
                ow.util:PrintError("Failed to encode item data: " .. err)
                return
            end

            net.Start("ow.item.add")
                net.WriteUInt(itemID, 32)
                net.WriteUInt(inventoryID, 32)
                net.WriteString(uniqueID)
                net.WriteData(encoded, #encoded)
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

    if ( toInventory and !toInventory:HasSpaceFor(item:GetWeight()) ) then
        local receiver = ow.character:GetPlayerByCharacter(item:GetOwner())
        if ( IsValid(receiver) ) then
            receiver:Notify("Inventory is too full to transfer this item.")
        end

        return false
    end

    local prevent = hook.Run("PreItemTransferred", item, fromInventoryID, toInventoryID)
    if ( prevent == false ) then
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

    hook.Run("PostItemTransferred", item, fromInventoryID, toInventoryID)

    return true
end

function ow.item:PerformAction(itemID, actionName, callback)
    local item = self.instances[itemID]
    if ( !item or !actionName ) then return false end

    local base = self.stored[item:GetUniqueID()]
    if ( !base or !base.Actions ) then return false end

    local action = base.Actions[actionName]
    if ( !action ) then return false end

    local ply = ow.character:GetPlayerByCharacter(item:GetOwner())
    if ( !IsValid(ply) ) then return false end

    if ( action.OnCanRun and !action:OnCanRun(item, ply) ) then
        return false
    end

    local prevent = hook.Run("PrePlayerItemAction", ply, actionName, item)
    if ( prevent == false ) then
        return false
    end

    if ( action.OnRun ) then
        action:OnRun(item, ply)
    end

    if ( callback ) then
        callback()
    end

    local hooks = base.Hooks or {}
    if ( hooks[actionName] ) then
        for _, hookFunc in pairs(hooks[actionName]) do
            if ( hookFunc ) then
                hookFunc(item, ply)
            end
        end
    end

    net.Start("ow.inventory.refresh")
        net.WriteUInt(item:GetInventory(), 32)
    net.Send(ply)

    hook.Run("PostPlayerItemAction", ply, actionName, item)

    return true
end

function ow.item:Cache(characterID)
    if ( !ow.character:Get(characterID) ) then return false end

    local items = ow.sqlite:Select("ow_items", nil, "character_id = " .. characterID .. " OR character_id = 0")
    if ( !items ) then return false end

    for _, row in pairs(items) do
        local itemID = tonumber(row.id)
        local uniqueID = row.unique_id

        if ( self.stored[uniqueID] ) then
            local item = self:CreateObject(row)
            if ( !item ) then
                ow.util:PrintError("Failed to create object for item #" .. itemID .. ", skipping")
                continue
            end

            if ( item:GetOwner() == 0 ) then
                local inv = ow.inventory:Get(item:GetInventory())
                if ( inv ) then
                    local newCharID = inv:GetOwner()
                    item:SetOwner(newCharID)

                    ow.sqlite:Update("ow_items", {
                        character_id = newCharID
                    }, "id = " .. itemID)
                else
                    ow.util:PrintError("Invalid orphaned item #" .. itemID .. " (no inventory)")
                    ow.sqlite:Delete("ow_items", "id = " .. itemID)
                    continue
                end
            end

            self.instances[itemID] = item

            if ( item.OnCache ) then
                item:OnCache()
            end
        else
            ow.util:PrintError("Unknown item unique ID '" .. tostring(uniqueID) .. "' in DB, skipping")
        end
    end

    local instanceList = {}
    for _, item in pairs(self.instances) do
        if ( item:GetOwner() == characterID ) then
            table.insert(instanceList, {
                ID = item:GetID(),
                UniqueID = item:GetUniqueID(),
                Data = item:GetData(),
                InventoryID = item:GetInventory()
            })
        end
    end

    local ply = ow.character:GetPlayerByCharacter(characterID)
    if ( IsValid(ply) ) then
        net.Start("ow.item.cache")
            net.WriteTable(instanceList)
        net.Send(ply)
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

    local pos = ply:GetEyeTrace().HitPos + vector_up * 10

    ow.item:Spawn(nil, uniqueID, pos, nil, function(ent)
        if ( IsValid(ent) ) then
            ply:Notify("Item " .. uniqueID .. " spawned.")
        else
            ply:Notify("Failed to spawn item " .. uniqueID .. ".")
        end
    end)
end)