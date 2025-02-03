--- Inventory library
-- @module ow.inventory

ow.inventory = {}
ow.inventory.stored = {}
ow.inventory.meta = ow.inventory.meta or {}

function ow.inventory:Get(index)
    return self.stored[index]
end

function ow.inventory:Register(invData)
    hook.Run("PreInventoryRegistered", invData)

    invData.index = #self.stored + 1
    self.stored[invData.index] = invData

    local inventory = setmetatable({
        id = invData.index
    }, self.meta)

    hook.Run("PostInventoryRegistered", inventory)
    return inventory
end

function ow.inventory:CalculateWeight(invID)

end