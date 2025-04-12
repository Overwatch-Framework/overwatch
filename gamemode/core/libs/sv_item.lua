--- Item library
-- @module ow.item

--- Adds a new item to a character's inventory.
-- @realm server
-- @param string ownerID The owner's character ID.
-- @param string uniqueID The uniqueID of the item.
-- @param table data The data to save with the item.
-- @param function callback The callback function.
-- @return table The item table.
function ow.item:Add(ownerID, uniqueID, data, callback)
    if ( !ownerID or !uniqueID ) then return end
    if ( !self.stored[uniqueID] ) then return end

    local item = table.Copy(self.stored[uniqueID])
    if ( !item ) then return end

    item.Data = data.Data

    local query = mysql:Insert("overwatch_items")
        query:Insert("owner_id", ownerID)
        query:Insert("unique_id", uniqueID)
        query:Insert("data", util.TableToJSON(data or {}))
    query:Execute(function(dataReceived)
        local receiver = ow.character:GetPlayerByCharacter(ownerID)
        if ( IsValid(receiver) ) then
            net.Start("ow.item.add")
                net.WriteString(uniqueID)
                net.WriteTable(dataReceived)
            net.Send(receiver)
        end

        if ( callback ) then
            callback(item)
        end
    end)

    hook.Run("OnItemAdded", item, ownerID, uniqueID, data)

    return item
end

--- Spawns an item entity with the given uniqueID, position and angles.
-- @realm server
-- @param string uniqueID The uniqueID of the item.
-- @param Vector pos The position of the item.
-- @param Angle angles The angles of the item.
-- @param function callback The callback function.
function ow.item:Spawn(uniqueID, pos, angles, callback)
    local item = ents.Create("ow_item")
    item:SetPos(pos)
    item:SetAngles(angles or angle_zero)
    item:Spawn()
    item:SetItem(uniqueID)
    item:Activate()

    self.instances[#self.instances + 1] = item

    if ( callback ) then
        callback(item)
    end

    return item
end