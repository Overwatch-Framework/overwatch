--- Inventory library
-- @module ow.inventory

ow.inventory = {}
ow.inventory.stored = {}

function ow.inventory:Get(index)
    return self.stored[index]
end