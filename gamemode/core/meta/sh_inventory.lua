local INV = ow.inventory.meta or {}
INV.__index = INV
INV.ID = 0
INV.Items = {}

function INV:__tostring()
    return "inventory[" .. self:GetID() .. "]"
end

function INV:__eq(other)
    return self.ID == other.ID
end

--- Returns the inventory's ID.
-- @realm shared
-- @treturn number The inventory's ID.
function INV:GetID()
    return self.ID
end

--- Returns the inventory's name.
-- @realm shared
-- @treturn string The inventory's name.
function INV:GetName()
    return self.Name or "Inventory"
end

--- Returns the character that the inventory belongs to.
-- @realm shared
-- @treturn number The character's ID.
function INV:GetOwner()
    return self.CharacterID
end

--- Returns the inventory's maximum weight.
-- @realm shared
-- @treturn number The inventory's maximum weight.
function INV:GetMaxWeight()
    return self.MaxWeight or ow.config:Get("inventory.maxweight", 20)
end

--- Returns the inventory's data.
-- @realm shared
-- @treturn table The inventory's data.
function INV:GetData()
    return self.Data or {}
end

--- Returns the inventory's weight.
-- @realm shared
-- @treturn number The inventory's weight.
function INV:GetWeight()
    local weight = 0

    for _, itemID in ipairs(self:GetItems()) do
        local item = ow.item:Get(itemID)
        if ( !item ) then continue end

        local itemWeight = item:GetWeight() or 0
        if ( itemWeight < 0 ) then continue end

        weight = weight + itemWeight
    end

    return weight
end

--- Returns the inventory's items.
-- @realm shared
-- @treturn table A sequential table of items in the inventory.
-- @usage local items = inventory:GetItems()
-- for k, v in ipairs(items) do print(v:GetID()) end
-- > [1] = 252, [2] = 323
function INV:GetItems()
    return self.Items
end

function INV:AddItem(itemID, itemData)
    if ( !itemID or !itemData ) then return end

    local item = ow.item:Get(itemID)
    if ( !item ) then return end

    table.insert(self.Items, itemID)

    if ( item.OnAdded ) then
        item:OnAdded(self, itemData)
    end
end

function INV:RemoveItem(itemID)
    if ( !itemID ) then return end

    local item = ow.item:Get(itemID)
    if ( !item ) then return end

    table.RemoveByValue(self.Items, itemID)

    if ( item.OnRemoved ) then
        item:OnRemoved(self)
    end
end

function INV:GetReceivers()
    local receivers = {}
    table.insert(receivers, ow.character:GetPlayerByCharacter(self.CharacterID))

    if ( self.Receivers ) then
        for _, receiver in ipairs(self.Receivers) do
            if ( IsValid(receiver) and receiver:IsPlayer() ) then
                table.insert(receivers, receiver)
            end
        end
    end

    return receivers
end

function INV:AddReceiver(receiver)
    if ( !IsValid(receiver) or !receiver:IsPlayer() ) then return end

    if ( !self.Receivers ) then self.Receivers = {} end

    table.insert(self.Receivers, receiver)
end

function INV:RemoveReceiver(receiver)
    if ( !IsValid(receiver) or !receiver:IsPlayer() ) then return end

    if ( !self.Receivers ) then return end

    table.RemoveByValue(self.Receivers, receiver)
end

function INV:ClearReceivers()
    local receivers = {}
    table.insert(receivers, ow.character:GetPlayerByCharacter(self.CharacterID))

    self.Receivers = receivers
end