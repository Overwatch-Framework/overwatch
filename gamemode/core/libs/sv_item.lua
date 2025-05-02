--- Item library
-- @module ow.item

--- Adds a new item to a character's inventory.
-- @realm server
-- @param number characterID The ID of the character who owns the item.
-- @param number inventoryID The ID of the inventory where the item will be added.
-- @param string uniqueID The uniqueID of the item.
-- @param table data Additional data for the item.
-- @param function callback The callback function.
-- @return number The ID of the added item.
function ow.item:Add(characterID, inventoryID, uniqueID, data, callback)
    if ( !characterID or !uniqueID or !self.stored[uniqueID] ) then return end

    if ( !data ) then data = {} end

    local itemID
    ow.sqlite:Insert("ow_items", {
        inventory_id = inventoryID,
        character_id = characterID,
        unique_id = uniqueID,
        data = util.TableToJSON(data)
    }, function(result)
        if ( !result ) then return end

        itemID = tonumber(result) or 0

        local item = self:CreateObject({
            ID = itemID,
            UniqueID = uniqueID,
            Data = data,
            InventoryID = inventoryID,
        })

        if ( !item ) then return end

        self.instances[itemID] = item

        local inventory = ow.inventory:Get(inventoryID)
        if ( inventory ) then
            local items = inventory:GetItems()
            if ( items and !table.HasValue(items, item.ID) ) then
                table.insert(items, item.ID)
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
    end)

    hook.Run("OnItemAdded", item, characterID, uniqueID, data)

    return itemID
end

--- Transfers an item from one inventory to another.
-- @realm server
-- @param number itemID The ID of the item to transfer.
-- @param number fromInventoryID The ID of the inventory to transfer the item from.
-- @param number toInventoryID The ID of the inventory to transfer the item to.
-- @param function callback The callback function.
-- @return boolean True if the item was transferred successfully, false otherwise.
function ow.item:Transfer(itemID, fromInventoryID, toInventoryID, callback)
    if ( !itemID or !fromInventoryID or !toInventoryID ) then return end

    local item = self.instances[itemID]
    if ( !item ) then return end

    local fromInventory = ow.inventory:Get(fromInventoryID)
    local toInventory = ow.inventory:Get(toInventoryID)

    if ( fromInventory ) then
        fromInventory:RemoveItem(itemID)
    end

    if ( toInventory ) then
        toInventory:AddItem(itemID, item:GetUniqueID(), item:GetData())
    end

    -- Update the item's inventory ID in the database
    ow.sqlite:Update("ow_items", {
        inventory_id = toInventoryID
    }, "id = " .. itemID)

    if ( callback ) then
        callback()
    end

    return true
end

--- Performs an action on an item.
-- @realm server
-- @param number itemID The ID of the item.
-- @param string action The action to perform on the item.
-- @param function callback The callback function.
-- @return boolean True if the action was performed successfully, false otherwise.
function ow.item:PerformAction(itemID, action, callback)
    if ( !itemID or !action ) then return end

    local item = self.instances[itemID]
    if ( !item ) then return end

    local itemData = self.stored[item:GetUniqueID()]
    if ( !itemData or !itemData.Actions or !itemData.Actions[action] ) then return end

    -- Perform the action
    local actionData = itemData.Actions[action]
    if ( !actionData ) then return end
    if ( actionData.OnCanRun ) then
        local canRun = actionData:OnCanRun(item)
        if ( !canRun ) then return false end
    end

    if ( actionData.OnRun ) then
        actionData:OnRun(item)
    end

    -- Call the callback function if provided
    if ( callback ) then
        callback()
    end

    return true
end

--- Cache all the items from a character's inventory.
-- @realm server
-- @param number characterID The ID of the character.
-- @return boolean True if the items were cached successfully, false otherwise.
function ow.item:Cache(characterID)
    if ( !ow.character:Get(characterID) ) then return false end

    local items = ow.sqlite:Select("ow_items", nil, "character_id = " .. characterID)
    if ( !items ) then return false end

    for k, v in pairs(items) do
        local uniqueID = v.unique_id
        if ( self.stored[uniqueID] ) then
            self.instances[tonumber(v.id)] = self:CreateObject(v)
        end
    end

    -- All instances for this characterID
    local instances = {}
    for k, v in pairs(self.instances) do
        if ( tonumber(v:GetOwner()) == characterID ) then
            table.insert(instances, v)
        end
    end

    net.Start("ow.item.cache")
        net.WriteUInt(characterID, 32)
        net.WriteTable(instances)
    net.Send(ow.character:GetPlayerByCharacter(characterID))

    return true
end

concommand.Add("ow_item_add", function(ply, cmd, args)
    if ( !ply:IsAdmin() ) then return end

    local uniqueID = args[1]
    if ( !uniqueID or !ow.item.stored[uniqueID] ) then return end

    local characterID = ply:GetCharacterID()
    local inventories = ow.inventory:GetByCharacterID(characterID)
    if ( #inventories == 0 ) then return end
    local inventoryID = inventories[1]:GetID()

    ow.item:Add(characterID, inventoryID, uniqueID, nil, function(itemID, data)
        ply:Notify("Item " .. uniqueID .. " added to inventory " .. inventoryID .. ".")
    end)
end)

--- Spawns an item entity with the given uniqueID, position and angles.
-- @realm server
-- @param number itemID The ID of the item.
-- @param string uniqueID The uniqueID of the item.
-- @param Vector pos The position of the item.
-- @param Angle angles The angles of the item.
-- @param function callback The callback function.
-- @param table data Additional data for the item.
-- @return Entity The spawned item entity.
function ow.item:Spawn(itemID, uniqueID, position, angles, callback, data)
    if ( !uniqueID or !position or !self.stored[uniqueID] ) then return end

    local entity = ents.Create("ow_item")
    if ( IsValid(entity) ) then
        entity:SetPos(position)
        entity:SetAngles(angles or Angle(0, 0, 0))
        entity:Spawn()
        entity:Activate()
        entity:SetItem(itemID, uniqueID)
        entity:SetData(data or {})

        if ( callback ) then
            callback(entity)
        end

        return entity
    end

    return nil
end

concommand.Add("ow_item_spawn", function(ply, cmd, args)
    if ( !ply:IsAdmin() ) then return end

    local uniqueID = args[1]
    local position = ply:GetEyeTrace().HitPos + Vector(0, 0, 10)

    ow.item:Spawn(nil, uniqueID, position, nil, function(entity)
        if ( IsValid(entity) ) then
            ply:ChatPrint("Item " .. uniqueID .. " spawned.")
        else
            ply:ChatPrint("Failed to spawn item " .. uniqueID .. ".")
        end
    end)
end)