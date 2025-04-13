--- Inventory library
-- @module ow.inventory

function ow.inventory:Register(invData)
    local bResult = hook.Run("PreInventoryRegistered", invData)
    if ( bResult == false ) then return false end

    invData.index = #self.stored + 1
    self.stored[invData.index] = invData

    ow.sqlite:Insert("inventories", {
        inventory_id = invData.index,
        character_id = invData.charID,
        inventory_type = invData.type,
        data = util.TableToJSON(invData.data or {})
    })

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