-- entities/entities/ow_item/init.lua
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(Model(ow.config:Get("currency.model")))
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetAmount(0)
    self:PhysWake()
end

function ENT:Use(ply)
    if ( !IsValid(ply) or !ply:IsPlayer() ) then return end
    if ( hook.Run("CanPlayerTakeMoney", ply, self) == false ) then return end

    local amount = self:GetAmount()
    if ( amount <= 0 ) then
        SafeRemoveEntity(self)
        return
    end

    local character = ply:GetCharacter()
    if ( !character ) then return end

    local prevent = hook.Run("PrePlayerTakeMoney", ply, self, amount)
    if ( prevent == false ) then return end

    character:GiveMoney(amount)
    net.Start("ow.currency.give")
        net.WriteFloat(amount, 32)
        net.WriteEntity(self)
    net.Send(ply)
    hook.Run("PostPlayerTakeMoney", ply, self, amount)

    SafeRemoveEntity(self)
end