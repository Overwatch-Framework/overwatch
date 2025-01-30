--- Inventory library
-- @module ow.inventory

ow.inventory = {}
ow.inventory.stored = {}

function ow.inventory:Get(index)
    return self.stored[index] 
end

function ow.inventory:Register(invData)
    hook.Run("PreInventoryRegistered", invData)

    invData.index = #self.stored + 1
    self.stored[invData.index] = invData

    hook.Run("PostInventoryRegistered", invData)

    return invData.index
end