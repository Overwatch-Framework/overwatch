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
    query:Execute(function(data)
        local receiver = ow.character:GetPlayerByCharacter(ownerID)
        if ( IsValid(receiver) ) then
            net.Start("ow.item.add")
                net.WriteString(uniqueID)
                net.WriteTable(data)
            net.Send(receiver)
        end

        if ( callback ) then
            callback(item)
        end
    end)

    return item
end