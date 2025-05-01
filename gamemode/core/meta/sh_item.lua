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

function ITEM:Spawn(position, angles)
    if ( !position ) then return end
    if ( !angles ) then angles = angle_zero end

    local entity = ents.Create("ow_item")
    entity:Spawn()
    entity:SetAngles(angles or angle_zero)
    entity:SetItemID(self:GetID())

    if ( type(position) == "Player" ) then
        position = position:GetItemDropPos(entity)
    end

    entity:SetPos(position)

    hook.Run("OnItemSpawned", entity)

    return entity
end