--- Item library
-- @module ow.item

ow.item = ow.item or {}
ow.item.stored = ow.item.stored or {}
ow.item.instances = ow.item.instances or {}

function ow.item:Add(ownerID, uniqueID, data, callback)
    if ( !ownerID or !uniqueID ) then return end
    if ( !self.stored[uniqueID] ) then return end

    local item = table.Copy(self.stored[uniqueID])
    if ( !item ) then return end

    item.Data = data.Data

    local query = mysql:Create("overwatch_items")
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

function ow.item:Spawn(uniqueID, pos, angles)
    local item = ents.Create("ow_item")
    item:SetPos(pos)
    item:SetAngles(angles or angle_zero)
    item:SetItem(uniqueID)
    item:Spawn()
    item:Activate()

    return item
end