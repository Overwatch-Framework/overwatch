local INV = ow.inventory.meta
INV.__index = INV
INV.ID = 0
INV.Items = {}

function INV:__tostring()
    return "inventory[" .. self:GetID() .. "]"
end

function INV:__eq(other)
    return self.ID == other.ID
end

function INV:GetID()
    return self.ID
end

function INV:GetName()
    return self.Name or "Inventory"
end

function INV:GetOwner()
    return self.CharacterID
end

function INV:GetData()
    return self.Data or {}
end

function INV:GetMaxWeight()
    local override = hook.Run("GetInventoryMaxWeight", self)
    if ( isnumber(override) ) then return override end

    return self.MaxWeight or ow.config:Get("inventory.maxweight", 20)
end

function INV:GetWeight()
    local weight = 0

    for _, itemID in ipairs(self:GetItems()) do
        local item = ow.item:Get(itemID)
        if ( item ) then
            local itemWeight = item:GetWeight() or 0
            if ( itemWeight >= 0 ) then
                weight = weight + itemWeight
            end
        end
    end

    return weight
end
function INV:HasSpaceFor(weight)
    return (self:GetWeight() + weight) <= self:GetMaxWeight()
end

function INV:GetItems()
    return self.Items or {}
end

function INV:AddItem(itemID, uniqueID, data)
    ow.inventory:AddItem(self:GetID(), itemID, uniqueID, data)
end

function INV:RemoveItem(itemID)
    ow.inventory:RemoveItem(self:GetID(), itemID)
end

function INV:GetReceivers()
    local receivers = {}
    local owner = ow.character:GetPlayerByCharacter(self.CharacterID)

    if ( IsValid(owner) ) then
        table.insert(receivers, owner)
    end

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

    self.Receivers = self.Receivers or {}

    if ( !table.HasValue(self.Receivers, receiver) ) then
        table.insert(self.Receivers, receiver)
    end
end

function INV:RemoveReceiver(receiver)
    if ( !IsValid(receiver) or !receiver:IsPlayer() ) then return end

    if ( self.Receivers ) then
        table.RemoveByValue(self.Receivers, receiver)
    end
end

function INV:ClearReceivers()
    self.Receivers = {}
    local owner = ow.character:GetPlayerByCharacter(self.CharacterID)

    if ( IsValid(owner) ) then
        table.insert(self.Receivers, owner)
    end
end

function INV:HasItem(itemUniqueID)
    if ( !isstring(itemUniqueID) ) then return false end

    for _, itemID in ipairs(self:GetItems()) do
        local item = ow.item:Get(itemID)
        if ( item and item:GetUniqueID() == itemUniqueID ) then
            return item
        end
    end

    return nil
end

function INV:HasItemQuantity(itemUniqueID, quantity)
    if ( !isstring(itemUniqueID) or !isnumber(quantity) ) then return false end

    local count = 0

    for _, itemID in ipairs(self:GetItems()) do
        local item = ow.item:Get(itemID)
        if ( item and item:GetUniqueID() == itemUniqueID ) then
            count = count + 1
        end
    end

    return count >= quantity
end