--- Item library
-- @module ow.item

function ow.item:Instance(uniqueID, data)
    local item = table.Copy(self.stored[uniqueID])

    if ( !item ) then return end

    item.ID = #ents.FindByClass("overwatch_item") + 1
    item.Data = data.Data

    local query = mysql:Create("overwatch_items")
        query:Insert("id", item.ID)
        query:Insert("unique_id", uniqueID)
        query:Insert("data", util.TableToJSON(data or {}))
    query:Execute()

    return item
end