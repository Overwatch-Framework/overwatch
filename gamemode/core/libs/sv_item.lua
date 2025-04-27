--- Item library
-- @module ow.item

--- Adds a new item to a character's inventory.
-- @realm server
-- @param number ownerID The ID of the character who owns the item.
-- @param string uniqueID The uniqueID of the item.
-- @param table data Additional data for the item.
-- @param function callback The callback function.
-- @return boolean True if the item was added successfully, false otherwise.
function ow.item:Add(ownerID, uniqueID, data, callback)
    if ( !ownerID or !uniqueID or !self.stored[uniqueID] ) then return end

    if ( !data ) then data = {} end

    ow.sqlite:Insert("ow_items", {
        owner_id = ownerID,
        unique_id = uniqueID,
        inv_id = 1,
        data = util.Compress(util.TableToJSON(data))
    }, function(id)
        if ( !id ) then return end
        print("Item " .. uniqueID .. " added to character " .. ownerID .. ".")
        local receiver = ow.character:GetPlayerByCharacter(ownerID)
        if ( IsValid(receiver) ) then
            print("Sending item " .. uniqueID .. " to player " .. receiver:Name() .. ".")
            local compressed = util.Compress(util.TableToJSON(data))

            net.Start("ow.item.add")
                net.WriteString(uniqueID)
                net.WriteUInt(id, 32)
                net.WriteData(compressed, #compressed)
            net.Send(receiver)
        else
            print("Player not found for character " .. ownerID .. ".")
        end

        if ( callback ) then
            callback(id, data)
        end
    end)

    hook.Run("OnItemAdded", item, ownerID, uniqueID, data)

    return true
end

concommand.Add("ow_item_add", function(ply, cmd, args)
    if ( !ply:IsAdmin() ) then return end

    local uniqueID = args[1]

    ow.item:Add(1, uniqueID, nil, function(itemID, data)
        if ( !itemID ) then return end

        ply:ChatPrint("Item " .. uniqueID .. " added with ID " .. itemID .. ".")
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