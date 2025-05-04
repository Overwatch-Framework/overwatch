local ITEM = ow.item.meta or {}
ITEM.Name = "Undefined"
ITEM.Description = ITEM.Description or "An item that is undefined."
ITEM.ID = ITEM.ID or 0

ITEM.__index = ITEM

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

function ITEM:SetOwner(characterID)
    characterID = tonumber(characterID) or 0

    if ( !characterID ) then return end

    self.CharacterID = characterID
end

function ITEM:GetData(key, default)
    if ( !key ) then return end

    if ( self.Data and self.Data[key] ) then
        return self.Data[key]
    end

    return default or nil
end

function ITEM:SetData(key, value)
    if ( !key ) then return end

    if ( !self.Data ) then
        self.Data = {}
    end

    if ( value == nil ) then
        self.Data[key] = nil
    else
        self.Data[key] = value
    end

    if ( SERVER ) then
        self:SendData(key, value)
    end
end

if ( SERVER ) then
    function ITEM:SendData(key, value)
        local ply = ow.character:GetPlayerByCharacter(self:GetOwner())
        if ( !IsValid(ply) ) then return end

        net.Start("ow.item.data")
            net.WriteUInt(self:GetID(), 32)
            net.WriteString(key)
            net.WriteType(value)
        net.Send(ply)
    end
end

function ITEM:SetInventory(InventoryID)
    if ( !InventoryID ) then return end

    local inventory = ow.inventory:Get(InventoryID)
    if ( !inventory ) then return end

    self.InventoryID = InventoryID
end

function ITEM:GetEntity()
    return self.Entity or nil
end

function ITEM:SetEntity(entity)
    if ( !entity ) then return end

    self.Entity = entity
end

function ITEM:Spawn(position, angles)
    local ply = ow.character:GetPlayerByCharacter(self:GetOwner())
    if ( !IsValid(ply) ) then return end

    position = position or ply:GetDropPosition()
    if ( !position ) then return end

    local item = ow.item:Spawn(nil, uniqueID, position, angles, function()
        if ( self.OnSpawned ) then
            self:OnSpawned(item)
        end

        item:SetUniqueID(self:GetUniqueID())
        item:SetData(self:GetData())
        item:SetEntity(self:GetEntity())

        if ( self.OnSpawned ) then
            self:OnSpawned(item)
        end

        return item
    end)
end

function ITEM:Hook(name, func)
    if ( !name or !func ) then return end

    if ( !self.Hooks ) then
        self.Hooks = {}
    end

    if ( !self.Hooks[name] ) then
        self.Hooks[name] = {}
    end

    table.insert(self.Hooks[name], func)
end

ow.item.meta = ITEM