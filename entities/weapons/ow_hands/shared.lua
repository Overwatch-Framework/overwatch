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
SWEP.Primary.Delay = 0.25

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""
SWEP.Secondary.Delay = 0.5

SWEP.HoldType = "normal"

function SWEP:Precache()
    util.PrecacheModel(SWEP.ViewModel)
    util.PrecacheModel(SWEP.WorldModel)

    util.PrecacheSound("npc/vort/claw_swing1.wav")
    util.PrecacheSound("npc/vort/claw_swing2.wav")
    util.PrecacheSound("physics/plastic/plastic_box_impact_hard1.wav")
    util.PrecacheSound("physics/plastic/plastic_box_impact_hard2.wav")
    util.PrecacheSound("physics/plastic/plastic_box_impact_hard3.wav")
    util.PrecacheSound("physics/plastic/plastic_box_impact_hard4.wav")
    util.PrecacheSound("physics/wood/wood_crate_impact_hard2.wav")
    util.PrecacheSound("physics/wood/wood_crate_impact_hard3.wav")
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
end

function SWEP:Deploy()
    if ( !IsValid(self:GetOwner()) ) then return end

    self:Reset()

    return true
end

function SWEP:Holster()
    if ( !IsValid(self:GetOwner()) ) then return end

    self:Reset()

    return true
end

function SWEP:OnRemove()
    self:Reset()
end

function SWEP:Reload()
    return false
end

local function SetSubPhysMotionEnabled(entity, enable)
    if ( !IsValid(entity) ) then return end

    for i = 0, entity:GetPhysicsObjectCount() - 1 do
        local subphys = entity:GetPhysicsObjectNum(i)

        if ( IsValid(subphys) ) then
            subphys:EnableMotion(enable)

            if ( enable ) then
                subphys:Wake()
            end
        end
    end
end

local function VelocityRemove(entity, normalize)
    if ( normalize ) then
        local physicsObject = entity:GetPhysicsObject()
        if ( IsValid(physicsObject) ) then
            physicsObject:SetVelocity(Vector(0, 0, 0))
        end

        entity:SetVelocity(vector_origin)

        SetSubPhysMotionEnabled(entity, false)
        timer.Simple(0, function() SetSubPhysMotionEnabled(entity, true) end)
    else
        local physicsObject = entity:GetPhysicsObject()
        local vel = IsValid(physicsObject) and physicsObject:GetVelocity() or entity:GetVelocity()
        local len = math.min(ow.config:Get("hands.max.throw", 150), vel:Length2D())

        vel:Normalize()
        vel = vel * len

        SetSubPhysMotionEnabled(entity, false)
        timer.Simple(0, function()
            SetSubPhysMotionEnabled(entity, true)

            if ( IsValid(physicsObject) ) then
                physicsObject:SetVelocity(vel)
            end

            entity:SetVelocity(vel)
            entity:SetLocalAngularVelocity(Angle())
        end)
    end
end

local function VelocityThrow(entity, ply, power)
    local physicsObject = entity:GetPhysicsObject()
    local vel = ply:GetAimVector()
    vel = vel * power

    SetSubPhysMotionEnabled(entity, false)
    timer.Simple(0, function()
        if ( IsValid(entity) ) then
            SetSubPhysMotionEnabled(entity, true)

            if ( IsValid(physicsObject) ) then
                physicsObject:SetVelocity(vel)
            end

            entity:SetVelocity(vel)
            entity:SetLocalAngularVelocity(Angle())
        end
    end)
end

function SWEP:Reset(throw)
    if ( IsValid(self.owCarry) ) then
        self.owCarry:Remove()
    end

    if ( IsValid(self.owConstraint) ) then
        self.owConstraint:Remove()
    end

    if ( IsValid(self.owHoldingEntity) ) then
        local desiredCollisionGroup = self.owHoldingEntity.oldCollisionGroup or COLLISION_GROUP_NONE
        self.owHoldingEntity:SetCollisionGroup(desiredCollisionGroup)
        self.owHoldingEntity.oldCollisionGroup = nil

        local children = self.owHoldingEntity:GetChildren()
        for i = 1, #children do
            children[i]:SetCollisionGroup(desiredCollisionGroup)
        end

        local physicsObject = self.owHoldingEntity:GetPhysicsObject()
        if ( self.holdingBone ) then
            physicsObject = self.owHoldingEntity:GetPhysicsObjectNum(self.holdingBone)
            self.holdingBone = nil
        end

        if ( IsValid(physicsObject) ) then
            physicsObject:ClearGameFlag(FVPHYSICS_PLAYER_HELD)
            physicsObject:AddGameFlag(FVPHYSICS_WAS_THROWN)
            physicsObject:EnableCollisions(true)
            physicsObject:EnableGravity(true)
            physicsObject:EnableDrag(true)
            physicsObject:EnableMotion(true)
        end

        if ( !throw ) then
            VelocityRemove(self.owHoldingEntity)
        else
            VelocityThrow(self.owHoldingEntity, self:GetOwner(), 300)
        end
    end

    self.owHoldingEntity = nil
    self.owCarry = nil
    self.owConstraint = nil
end

function SWEP:Drop(throw)
    if ( !self:CheckValidity() ) then return end
    if ( !self:AllowEntityDrop() ) then return end

    if ( SERVER ) then
        self.owConstraint:Remove()
        self.owCarry:Remove()

        local entity = self.owHoldingEntity

        local physicsObject = entity:GetPhysicsObject()
        if ( IsValid(physicsObject) ) then
            physicsObject:EnableCollisions(true)
            physicsObject:EnableGravity(true)
            physicsObject:EnableDrag(true)
            physicsObject:EnableMotion(true)
            physicsObject:Wake()

            physicsObject:ClearGameFlag(FVPHYSICS_PLAYER_HELD)
            physicsObject:AddGameFlag(FVPHYSICS_WAS_THROWN)
        end

        if ( entity:GetClass() == "prop_ragdoll" ) then
            VelocityRemove(entity)
        end

        entity:SetPhysicsAttacker(self:GetOwner())
    end

    self:Reset(throw)
end

function SWEP:CheckValidity()
    if ( !IsValid(self.owHoldingEntity) or !IsValid(self.owCarry) or !IsValid(self.owConstraint) ) then
        if ( self.owHoldingEntity or self.owCarry or self.owConstraint ) then
            self:Reset()
        end

        return false
    else
        return true
    end
end

function SWEP:IsEntityStoodOn(entity)
    for k, v in player.Iterator() do
        if ( v:GetGroundEntity() == entity ) then
            return true
        end
    end

    return false
end

function SWEP:PrimaryAttack()
    if ( !IsFirstTimePredicted() ) then return end

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    if ( IsValid(self.owHoldingEntity) ) then
        if ( SERVER ) then
            self:GetOwner():EmitSound("npc/vort/claw_swing" .. math.random(1, 2) .. ".wav", 60)
        end

        self:GetOwner():SetAnimation(PLAYER_ATTACK1)
        self:GetOwner():ViewPunch(Angle(2, 5, 0.125))

        self:DoPickup(true)
    end
end

function SWEP:SecondaryAttack()
    if ( !IsFirstTimePredicted() ) then return end

    local data = {}
    data.start = self:GetOwner():GetShootPos()
    data.endpos = data.start + self:GetOwner():GetAimVector() * ow.config:Get("hands.range", 96)
    data.mask = MASK_SHOT
    data.filter = {self, self:GetOwner()}
    local traceData = util.TraceLine(data)

    local entity = traceData.Entity
    if ( SERVER and IsValid(entity) ) then
        if ( entity:IsDoor() ) then
            if ( entity:GetPos():DistToSqr(self:GetOwner():GetPos()) > 6000 ) then
                return
            end

            if ( hook.Run("PlayerCanKnock", self:GetOwner(), entity) == false ) then
                return
            end

            self:GetOwner():ViewPunch(Angle(-1.3, 1.8, 0))
            self:GetOwner():EmitSound("physics/wood/wood_crate_impact_hard" .. math.random(2, 3) .. ".wav", 60)
            self:GetOwner():SetAnimation(PLAYER_ATTACK1)

            self:SetNextSecondaryFire(CurTime() + 0.4)
            self:SetNextPrimaryFire(CurTime() + 1)
        elseif ( !entity:IsPlayer() and !entity:IsNPC() ) then
            self:DoPickup()
        elseif entity:IsPlayer() and entity:Alive() then
            if ( ( self.owNextPush or 0 ) > CurTime() ) then return end
            if ( entity:GetPos():DistToSqr(self:GetOwner():GetPos()) > 2000 ) then return end

            timer.Simple (0.25, function()
                local vDirection = self:GetOwner():GetAimVector() * ( 350 + ( 3 * 3 ) )
                vDirection.z = 0
                entity:SetVelocity(vDirection)

                entity:ViewPunch(Angle(math.random(1, 2), math.random(2, 6), math.random(0, -3)))
                entity:EmitSound("physics/flesh/flesh_impact_hard" .. math.random(2, 5) .. ".wav", 60)
            end)

            self.owNextPush = CurTime() + 2
        elseif ( IsValid(self.owHeldEntity) and !self.owHeldEntity:IsPlayerHolding() ) then
            self.owHeldEntity = nil
        end
    else
        if ( IsValid(self.owHoldingEntity))  then
            self:DoPickup()
        end
    end
end

function SWEP:GetRange(target)
    local customRange = hook.Run("GetPickupRange", self, target)
    if ( customRange ) then
        return customRange
    end

    if ( IsValid(target) and target:GetClass() == "prop_ragdoll" ) then
        return 96
    else
        return 128
    end
end

function SWEP:AllowPickup(target)
    local physicsObject = target:GetPhysicsObject()
    local ply = self:GetOwner()

    return ( IsValid(physicsObject) and IsValid(ply) and !physicsObject:HasGameFlag(FVPHYSICS_NO_PLAYER_PICKUP) and physicsObject:GetMass() < ow.config:Get("hands.max.carry", 160) and !self:IsEntityStoodOn(target) and target.CanPickup != false )
end

function SWEP:DoPickup(throw)
    self:SetNextPrimaryFire(CurTime() + 0.2)
    self:SetNextSecondaryFire(CurTime() + 0.2)

    if ( IsValid(self.owHoldingEntity) ) then
        self:Drop(throw)
        self:SetNextSecondaryFire(CurTime() + 0.2)
        return
    end

    local ply = self:GetOwner()
    local traceData = ply:GetEyeTrace(MASK_SHOT)
    if ( IsValid(traceData.Entity) ) then
        local entity = traceData.Entity
        local physicsObject = traceData.Entity:GetPhysicsObject()

        if ( !IsValid(physicsObject) or !physicsObject:IsMoveable() or physicsObject:HasGameFlag(FVPHYSICS_PLAYER_HELD) ) then
            return
        end

        if ( SERVER and (ply:EyePos() - traceData.HitPos):Length() < self:GetRange(entity) and self:AllowPickup(entity) ) then
            self:Pickup()
            self:SendWeaponAnim(ACT_VM_HITCENTER)

            local delay = entity:GetClass() == "prop_ragdoll" and 1 or 0.2

            self:SetNextSecondaryFire(CurTime() + delay)

            return
        end
    end
end

local down = Vector(0, 0, -1)
function SWEP:AllowEntityDrop()
    local ply = self:GetOwner()
    local ent = self.owCarry
    if ( !IsValid(ply) or !IsValid(ent) ) then return false end

    local ground = ply:GetGroundEntity()
    if ( ground and ( ground:IsWorld() or IsValid(ground) ) ) then return true end

    local diff = (ent:GetPos() - ply:GetShootPos()):GetNormalized()

    return down:Dot(diff) <= 0.75
end