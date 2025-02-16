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
    if ( !itemData ) then return false end

    self:SetModel(Model(itemData.Model))
    self:SetSkin(itemData.Skin or 0)
    self:SetColor(itemData.Color or color_white)
    self:SetMaterial(itemData.Material or "")
    self:SetModelScale(itemData.Scale or 1)
    -- self:SetCollisionGroup(COLLISION_GROUP_WEAPON) bloodycop: Wondering if we should do this

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

    -- bloodycop: Might need an overhaul in the future lol
    self:SetItemID(math.random(1, 9999))
end