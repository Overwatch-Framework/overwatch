local INV = ow.inventory.meta or {}
INV.__index = INV
INV.id = 0

--- Returns the inventory's ID.
-- @treturn number The inventory's ID.
function INV:GetID()
    return self.id
end

--- Returns the inventory's name.
-- @treturn string The inventory's name.
function INV:GetName()
    return self.name
end

--- Returns the inventory's owner.
-- @treturn number The inventory's owner.
function INV:GetOwner()
    return self.owner
end

--- Returns the inventory's weight.
-- @treturn number The inventory's weight.
function INV:GetWeight()
    for k, v in pairs(self.items) do
        self.weight = self.weight + v.Weight
    end
end

function INV:GetItems()
    return self.items
end