--- Inventory library
-- @module ow.inventory

ow.inventory = {}
ow.inventory.stored = {}
ow.inventory.meta = ow.inventory.meta or {}

function ow.inventory:Get(index)
    return self.stored[index]
end

function ow.inventory:CalculateWeight(invID)
    -- TODO: Implement weight calculation
    return 0
end