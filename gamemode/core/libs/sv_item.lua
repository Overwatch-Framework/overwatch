--- Item library
-- @module ow.item

--- Adds a new item to a character's inventory.
-- @realm server
-- @param number characterID The ID of the character who owns the item.
-- @param number inventoryID The ID of the inventory where the item will be added.
-- @param string uniqueID The uniqueID of the item.
-- @param table data Additional data for the item.
-- @param function callback The callback function.
-- @return boolean True if the item was added successfully, false otherwise.
function ow.item:Add(characterID, inventoryID, uniqueID, data, callback)
    if ( !characterID or !uniqueID or !self.stored[uniqueID] ) then return end

    if ( !data ) then data = {} end

    ow.sqlite:Insert("ow_items", {
        inventory_id = inventoryID,
        character_id = characterID,
        unique_id = uniqueID,
        data = util.Compress(util.TableToJSON(data))
    }, function(result)
        print("ow.item:Add", result)
        if ( !result ) then return end

        local item = self:CreateObject(result, uniqueID, data)
        if ( !item ) then return end

        self.instances[result] = item

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
                net.WriteUInt(result, 32)
                net.WriteUInt(inventoryID, 32)
                net.WriteString(uniqueID)
                net.WriteData(compressed, #compressed)
            net.Send(receiver)
        end

        if ( callback ) then
            callback(result, data)
        end
    end)

    hook.Run("OnItemAdded", item, characterID, uniqueID, data)

    return true
end

concommand.Add("ow_item_add", function(ply, cmd, args)
    if ( !ply:IsAdmin() ) then return end

    local uniqueID = args[1]
    if ( !uniqueID or !ow.item.stored[uniqueID] ) then return end

    local characterID = ply:GetCharacterID()
    local inventories = ow.inventory:GetByCharacterID(characterID)
    if ( #inventories == 0 ) then print("No inventories found for character ID " .. characterID) return end
    local inventoryID = inventories[1]:GetID()

    ow.item:Add(characterID, inventoryID, uniqueID, nil, function(itemID, data)
        ply:Notify("Item " .. uniqueID .. " added to inventory " .. inventoryID .. ".")
    end)
end)

--- Spawns an item entity with the given uniqueID, position and angles.
-- @realm server
-- @param string uniqueID The uniqueID of the item.
-- @param Vector pos The position of the item.
-- @param Angle angles The angles of the item.
-- @param function callback The callback function.
-- @param table data Additional data for the item.
-- @return Entity The spawned item entity.
function ow.item:Spawn(uniqueID, position, angles, callback, data)
    if ( !uniqueID or !position or !self.stored[uniqueID] ) then return end

    local entity = ents.Create("ow_item")
    if ( IsValid(entity) ) then
        entity:SetPos(position)
        entity:SetAngles(angles or Angle(0, 0, 0))
        entity:Spawn()
        entity:Activate()
        entity:SetItem(uniqueID)
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

    ow.item:Spawn(uniqueID, position, nil, function(entity)
        if ( IsValid(entity) ) then
            ply:ChatPrint("Item " .. uniqueID .. " spawned.")
        else
            ply:ChatPrint("Failed to spawn item " .. uniqueID .. ".")
        end
    end)
end)