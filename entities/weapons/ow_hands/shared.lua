SWEP.PrintName = "Hands"
SWEP.Author = "Overwatch"
SWEP.Contact = ""
SWEP.Purpose = "Grab and throw things"
SWEP.Instructions = ""

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModel = Model("models/weapons/c_arms.mdl")
SWEP.WorldModel = ""

util.PrecacheModel(SWEP.ViewModel)
util.PrecacheModel(SWEP.WorldModel)

SWEP.UseHands = true
SWEP.Spawnable = true

SWEP.ViewModelFOV = 45
SWEP.ViewModelFlip = false
SWEP.AnimPrefix = "rpg"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Primary.Damage = 5
SWEP.Primary.Delay = 0.75

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""
SWEP.Secondary.Delay = 0.5

SWEP.HoldType = "fist"

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
    if ( !IsFirstTimePredicted() ) then return end
    if ( self:GetNextPrimaryFire() > CurTime() ) then return end
end

function SWEP:GetMaxMassHold()
    return hook.Run("OW.GetMaxHandsMass", self:GetOwner()) or 64
end

function SWEP:GetReachDistance()
    return hook.Run("OW.GetHandsReachDistance", self:GetOwner()) or 96
end

function SWEP:GetPushForce()
    return hook.Run("OW.GetHandsPushForce", self:GetOwner()) or 128
end

function SWEP:CanPush(ent)
    return hook.Run("OW.CanHandsPush", self:GetOwner(), ent) or true
end

function SWEP:CanPickup(ent)
    return hook.Run("OW.CanHandsPickup", self:GetOwner(), ent) or true
end

function SWEP:SecondaryAttack()
    if ( !IsFirstTimePredicted() ) then return end
    if ( self:GetNextSecondaryFire() > CurTime() ) then return end

    local ply = self:GetOwner()

    local traceData = util.TraceLine({
        start = ply:GetShootPos(),
        endpos = ply:GetShootPos() + ply:GetAimVector() * self:GetReachDistance(),
        filter = ply
    })

    local ent = traceData.Entity
    if ( !IsValid(ent) ) then return end

    if ( ( ent:IsPlayer() or ent:IsNPC() ) and self:CanPush() ) then
        if ( CLIENT ) then
            ply:EmitSound("physics/flesh/flesh_impact_hard" .. math.random(3, 4) .. ".wav")
        end

        ply:ViewPunch(Angle(-4, 0, 0))
        
        if ( ent:IsPlayer() ) then
            ent:ViewPunch(Angle(4, 0, 0))
        end

        ent:SetVelocity(ply:GetAimVector() * self:GetPushForce())

        hook.Run("OW.HandsPush", ply, ent)
    elseif ( ent:GetClass():find("door") ) then
        if ( CLIENT ) then
            ply:EmitSound("physics/wood/wood_crate_impact_hard" .. math.random(1, 5) .. ".wav")
        end

        ply:ViewPunch(Angle(2, 0, 0))

        hook.Run("OW.HandsKnock", ply, ent)
    elseif ( SERVER and IsValid(ent:GetPhysicsObject()) and self:CanPickup() ) then
        if ( ent:GetPhysicsObject():GetMass() > self:GetMaxMassHold() ) then return end

        if ( ent:IsPlayerHolding() ) then
            ply:DropObject()
        else
            timer.Simple(0.1, function()
                if ( !IsValid(ent) ) then return end

                ply:PickupObject(ent)

                hook.Run("OW.HandsPickup", ply, ent)
            end)
        end
    end

    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
end