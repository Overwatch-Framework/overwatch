local ITEM = ow.item.meta or {}
ITEM.__index = ITEM
ITEM.Name = "Undefined"
ITEM.Description = ITEM.Description or "An item that is undefined."
ITEM.ID = ITEM.ID or 0

function ITEM:__tostring()
    return "item[" .. self:GetUniqueID() .. "][" .. self:GetID() .. "]"
end

function ITEM:__eq(other)
    if ( isstring(other) ) then
        return self.Name == other
    elseif ( isnumber(other) ) then
        return tonumber(self.ID) == other
    end

    return false
end

function ITEM:GetID()
    return tonumber(self.ID) or 0
end

function ITEM:GetUniqueID()
    return self.UniqueID or "undefined"
end

function ITEM:GetName()
    return self.Name or "Undefined"
end

function ITEM:GetDescription()
    return self.Description or "An item that is undefined."
end

function ITEM:GetWeight()
    return tonumber(self.Weight) or 0
end

function ITEM:GetCategory()
    return self.Category or "Miscellaneous"
end

function ITEM:GetModel()
    return self.Model or "models/props_c17/oildrum001.mdl"
end

function ITEM:GetMaterial()
    return self.Material or ""
end

function ITEM:GetSkin()
    return tonumber(self.Skin) or 0
end

function ITEM:GetInventory()
    return tonumber(self.InventoryID) or 0
end

function ITEM:GetOwner()
    return tonumber(self.CharacterID) or 0
end

function ITEM:GetData(key, default)
    if ( !key ) then return end

    if ( self.Data and self.Data[key] ) then
        return self.Data[key]
    end

    return default or nil
end

function ITEM:SetInventory(InventoryID)
    if ( !InventoryID ) then return end

    local inventory = ow.inventory:Get(InventoryID)
    if ( !inventory ) then return end

    self.InventoryID = InventoryID
end

function ITEM:Add(uniqueID, data)
    if ( !uniqueID or !self.stored[uniqueID] ) then return end

    if ( !data ) then data = {} end

    local item = self:CreateObject(self.ID, uniqueID, data)
    if ( !item ) then return end

    item.InventoryID = self.InventoryID
    item.CharacterID = self.CharacterID or 0

    self.instances[self.ID] = item

    local inventory = ow.inventory:Get(self.InventoryID)
    if ( IsValid(inventory) ) then
        local items = inventory:GetItems()
        if ( items and !table.HasValue(items, item.ID) ) then
            table.insert(items, item.ID)
        end
    end

    return item
end

function ITEM:Spawn(position, angles)
    if (ow.item.instances[self.id]) then
        local ply

        local entity = ents.Create("ow_item")
        entity:Spawn()
        entity:SetAngles(angles or angle_zero)
        entity:SetItemID(self.id)

        -- If the first argument is a player, then we will find a position to drop
        -- the item based off their aim.
        if (type(position) == "Player") then
            ply = position
            position = position:GetItemDropPos(entity)
        end

        entity:SetPos(position)

        if ( IsValid(ply) and ply:GetCharacter() ) then
            entity:GetTable().owCharID = ply:GetCharacter():GetID()
        end

        hook.Run("OnItemSpawned", entity)
        return entity
    end
end