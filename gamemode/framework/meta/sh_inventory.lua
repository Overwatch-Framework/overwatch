local INV = ow.meta.inventory or {}
INV.__index = INV
INV.ID = 0
INV.Items = {}

function INV:__tostring()
    return "inventory[" .. self:GetID().. "]"
end

-- TODO: I believe a sequential table with the value being the item's ID

--- Returns the inventory's ID.
-- @treturn number The inventory's ID.
function INV:GetID()
    return self.ID
end

--- Returns the inventory's name.
-- @treturn string The inventory's name.
function INV:GetName()
    return self.Name or Format("Inventory %s", self:GetID())
end

--- Returns the character that the inventory belongs to.
-- @treturn number The character's ID.
function INV:GetOwner()
    return self.OwnerID -- TODO: Use whatever ow.character table we use to store character IDs | ow.character.cache[self.OwnerID]? Not sure
end

--- Returns the inventory's weight.
-- @treturn number The inventory's weight.
function INV:GetWeight()
    local weight = 0

    --[[ -- This is an example of the Inventory's "Items" table
        [1] = 252,
        [2] = 323,
    ]]
    for k, v in ipairs(self:GetItems()) do
        weight = weight + v:GetWeight()
    end

    return weight
end

function INV:GetItems()
    return self.Items
end

ow.meta.inventory = INV