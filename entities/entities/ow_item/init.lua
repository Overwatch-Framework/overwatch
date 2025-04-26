AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_junk/watermelon01.mdl")
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetHealth(50)
    self:PhysWake()
end

function ENT:SetItem(uniqueID)
    local itemData = ow.item:Get(uniqueID)
    if ( !istable(itemData) ) then return false end

    self:SetModel(Model(itemData.Model))

    local iSkin = itemData.Skin or 0
    if ( isfunction(itemData.GetSkin) ) then
        iSkin = itemData:GetSkin(self)
    end

    local cColor = itemData.Color or color_white
    if ( isfunction(itemData.GetColor) ) then
        cColor = itemData:GetColor(self)
    end

    local sMaterial = itemData.Material or ""
    if ( isfunction(itemData.GetMaterial) ) then
        sMaterial = itemData:GetMaterial(self)
    end

    local fScale = itemData.Scale or 1
    if ( isfunction(itemData.GetScale) ) then
        fScale = itemData:GetScale(self)
    end

    self:SetSkin(iSkin)
    self:SetColor(cColor)
    self:SetMaterial(sMaterial)
    self:SetModelScale(fScale)
    -- self:SetCollisionGroup(COLLISION_GROUP_WEAPON) -- TODO: Wondering if we should do this

    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:PhysWake()

    if ( itemData.Bodygroups ) then
        for k, v in pairs(itemData.Bodygroups) do
            if ( isstring(k) ) then
                self:SetBodygroup(self:GetBodygroupByName(k), v)
            elseif ( isnumber(k) ) then
                self:SetBodygroup(k, v)
            end
        end
    end

    if ( itemData.SubMaterials ) then
        for k, v in pairs(itemData.SubMaterials) do
            self:SetSubMaterial(k - 1, v)
        end
    end

    if ( itemData.OnSpawned ) then
        itemData:OnSpawned(self)
    end

    -- TODO: Assign item ID and unique ID
end

function ENT:Use(ply)
    if ( !IsValid(ply) or !ply:IsPlayer() ) then return end
    if ( hook.Run("CanPlayerTakeItem", ply, self) == false ) then return end

    local itemData = ow.item:Get(self:GetItemID())
    if ( !itemData ) then return end

    -- TODO: Should probably move this into some Inventory Action System
    --[[
    if ( itemData.OnTaken ) then
        itemData:OnTaken(ply, self)
    end
    ]]

    SafeRemoveEntity(self)

    hook.Run("PlayerTookItem", ply, self)
end

function ENT:OnRemove()
    local itemData = ow.item:Get(self:GetItemID())
    if ( !itemData ) then return end

    if ( itemData.OnRemoved ) then
        itemData:OnRemoved(self)
    end
end

function ENT:OnTakeDamage(damageInfo)
    local itemData = ow.item:Get(self:GetItemID())
    if ( !itemData ) then return end

    self:SetHealth(self:Health() - damageInfo:GetDamage())

    if ( self:Health() <= 0 and hook.Run("ItemCanBeDestroyed", self, damageInfo) != false ) then
        SafeRemoveEntity(self)
    end
end