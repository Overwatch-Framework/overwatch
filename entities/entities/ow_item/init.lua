-- entities/entities/ow_item/init.lua
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_junk/watermelon01.mdl")
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:PhysWake()
end

function ENT:SetItem(itemID, uniqueID)
    local itemDef = ow.item:Get(uniqueID)
    if ( !istable(itemDef) ) then
        print("Item '" .. uniqueID .. "' not found!")
        return
    end

    self:SetModel(Model(itemDef.Model))
    self:SetSkin(isfunction(itemDef.GetSkin) and itemDef:GetSkin(self) or (itemDef.Skin or 0))
    self:SetColor(isfunction(itemDef.GetColor) and itemDef:GetColor(self) or (itemDef.Color or color_white))
    self:SetMaterial(isfunction(itemDef.GetMaterial) and itemDef:GetMaterial(self) or (itemDef.Material or ""))
    self:SetModelScale(isfunction(itemDef.GetScale) and itemDef:GetScale(self) or (itemDef.Scale or 1))
    self:SetHealth(itemDef.Health or 25)

    -- Reinitialize physics due to model change
    self:PhysicsInit(SOLID_VPHYSICS)
    self:PhysWake()

    if ( itemDef.Bodygroups ) then
        for k, v in pairs(itemDef.Bodygroups) do
            local idx = isstring(k) and self:GetBodygroupByName(k) or k
            if ( idx ) then self:SetBodygroup(idx, v) end
        end
    end

    if ( itemDef.SubMaterials ) then
        for k, v in pairs(itemDef.SubMaterials) do
            self:SetSubMaterial(k - 1, v)
        end
    end

    if ( itemDef.OnSpawned ) then
        itemDef:OnSpawned(self)
    end

    self:SetUniqueID(uniqueID)

    if ( !itemID or itemID == 0 ) then
        -- Register world item instance
        ow.item:Add(0, 0, uniqueID, {}, function(newID)
            self:SetItemID(newID)
            local item = ow.item:Get(newID)
            if ( item ) then
                item:SetEntity(self)
                self:SetData(item:GetData() or {})

                -- Notify clients
                net.Start("ow.item.entity")
                    net.WriteUInt(newID, 32)
                    net.WriteEntity(self)
                net.Broadcast()
            end
        end)
    else
        self:SetItemID(itemID)
        local item = ow.item:Get(itemID)
        if ( item ) then
            item:SetEntity(self)
            self:SetData(item:GetData() or {})
        end

        net.Start("ow.item.entity")
            net.WriteUInt(itemID, 32)
            net.WriteEntity(self)
        net.Broadcast()
    end

    local item = ow.item:Get(itemID)
    if ( item ) then
        item:SetEntity(self)
        self:SetData(item:GetData() or {})
    else
        self:SetData({})
    end

    net.Start("ow.item.entity")
        net.WriteUInt(itemID or 0, 32)
        net.WriteEntity(self)
    net.Broadcast()
end

function ENT:GetData()
    return self:GetTable().owItemData or {}
end

function ENT:SetData(data)
    self:GetTable().owItemData = data
end

function ENT:Use(client)
    if ( !IsValid(client) or !client:IsPlayer() ) then return end
    if ( hook.Run("CanPlayerTakeItem", client, self) == false ) then return end

    local itemDef = ow.item:Get(self:GetUniqueID())
    local itemInst = ow.item:Get(self:GetItemID())

    if ( !itemDef or !itemInst ) then return end

    itemInst:SetEntity(self)
    itemInst:SetOwner(client:GetCharacterID())

    self.owPickingUp = CurTime() + 1
    ow.item:PerformAction(itemInst:GetID(), "Take")
end

function ENT:OnRemove()
    local item = ow.item:Get(self:GetItemID())
    if ( item and item.OnRemoved ) then
        item:OnRemoved(self)
    end
end

function ENT:OnTakeDamage(dmg)
    local item = ow.item:Get(self:GetItemID())
    if ( !item ) then return end

    self:SetHealth(self:Health() - dmg:GetDamage())

    if ( self:Health() <= 0 and hook.Run("ItemCanBeDestroyed", self, dmg) != false ) then
        self:EmitSound("physics/cardboard/cardboard_box_break" .. math.random(1, 3) .. ".wav")

        local position = self:LocalToWorld(self:OBBCenter())
        local effect = EffectData()
        effect:SetStart(position)
        effect:SetOrigin(position)
        effect:SetScale(3)
        util.Effect("GlassImpact", effect)

        local itemDef = ow.item:Get(self:GetUniqueID())
        if ( itemDef and itemDef.OnDestroyed ) then
            itemDef:OnDestroyed(self)
        end

        SafeRemoveEntity(self)
    end
end

function ENT:OnRemove()
    if ( self.owPickingUp and self.owPickingUp > CurTime() ) then return end

    local item = ow.item:Get(self:GetItemID())
    if ( item and item.OnRemoved ) then
        item:OnRemoved(self)
    end

    ow.sqlite:Delete("ow_items", string.format("id = %s", sql.SQLStr(self:GetItemID())))
end