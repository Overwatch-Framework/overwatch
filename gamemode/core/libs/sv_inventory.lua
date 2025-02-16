--- Inventory library
-- @module ow.inventory

function ow.inventory:Register(invData)
    hook.Run("PreInventoryRegistered", invData)

    invData.index = #self.stored + 1
    self.stored[invData.index] = invData

    local query = mysql:Insert("overwatch_inventories")
        query:Insert("inventory_id", invData.index)
        query:Insert("character_id", invData.charID)
        query:Insert("inventory_type", invData.type)
        query:Insert("data", util.TableToJSON(invData.data or {}))
    query:Execute()

    local inventory = setmetatable({
        id = invData.index
    }, self.meta)

    hook.Run("PostInventoryRegistered", inventory)
    return inventory
end

function ow.inventory:PerformAction(item, action) -- prob needs more args
    if ( item == nil ) then return end

    -- TODO: Implement
end