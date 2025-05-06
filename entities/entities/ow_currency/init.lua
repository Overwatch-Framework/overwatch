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

function ENT:Use(client)
    if ( !IsValid(client) or !client:IsPlayer() ) then return end

    local amount = self:GetAmount()
    if ( amount <= 0 ) then
        SafeRemoveEntity(self)
        client:Notify("0")
        return
    end

    local character = client:GetCharacter()
    if ( !character ) then return end

    local prevent = hook.Run("PrePlayerTakeMoney", client, self, amount)
    if ( prevent == false ) then return end

    character:GiveMoney(amount)

    ow.net:Start(client, "currency.give", self, amount)
    hook.Run("PostPlayerTakeMoney", client, self, amount)

    SafeRemoveEntity(self)
end