-- entities/entities/ow_item/init.lua
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(Model(ow.config:Get("currency.model")))
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
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

    local bPlural = amount > 1

    character:GiveMoney(amount)
    SafeRemoveEntity(self)
    -- can't add localization, serverside ;9
    ply:Notify(Format("You have taken %s %s.", ow.currency:Format(amount, false, true), bPlural and ow.currency:GetPlural() or ow.currency:GetSingular()))
end