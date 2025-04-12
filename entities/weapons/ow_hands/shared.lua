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
SWEP.Primary.Delay = 0.25

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""
SWEP.Secondary.Delay = 0.5

SWEP.HoldType = "fist"

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "Dragging")
    self:NetworkVar("Entity", 0, "DraggingTarget")
    self:NetworkVar("Entity", 1, "Constraint")
    self:NetworkVar("Entity", 2, "ConstraintTarget")
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
    if ( !IsFirstTimePredicted() ) then return end
    if ( self:GetNextPrimaryFire() > CurTime() ) then return end

    if ( self:GetDragging() ) then
        if ( IsValid(self:GetConstraint()) ) then
            self:GetConstraint():Remove()
        end

        if ( IsValid(self:GetConstraintTarget()) ) then
            self:GetConstraintTarget():Remove()
        end

        self:SetDragging(false)
        self:SetDraggingTarget(nil)
        return
    end
end

function SWEP:GetMaxMassHold()
    return hook.Run("GetPlayerHandsMaxMass", self:GetOwner())
end

function SWEP:GetReachDistance()
    return hook.Run("GetPlayerHandsReachDistance", self:GetOwner())
end

function SWEP:GetPushForce()
    return hook.Run("GetPlayerHandsPushForce", self:GetOwner())
end

function SWEP:CanPush(ent)
    return hook.Run("CanPlayerHandsPush", self:GetOwner(), ent)
end

function SWEP:CanPickup(ent)
    return hook.Run("CanPlayerHandsPickup", self:GetOwner(), ent)
end

function SWEP:SecondaryAttack()
    if ( !IsFirstTimePredicted() ) then return end
    if ( self:GetNextSecondaryFire() > CurTime() ) then return end

    if ( self:GetDragging() ) then
        if ( IsValid(self:GetConstraint()) ) then
            self:GetConstraint():Remove()
        end

        if ( IsValid(self:GetConstraintTarget()) ) then
            self:GetConstraintTarget():Remove()
        end

        self:SetDragging(false)
        self:SetDraggingTarget(nil)
        return
    end

    local ply = self:GetOwner()

    local traceData = util.TraceLine({
        start = ply:GetShootPos(),
        endpos = ply:GetShootPos() + ply:GetAimVector() * self:GetReachDistance(),
        filter = ply
    })

    local ent = traceData.Entity
    if ( !IsValid(ent) ) then return end

    local physicsObject = ent:GetPhysicsObject()

    if ( ( ent:IsPlayer() or ent:IsNPC() ) and self:CanPush() ) then
        if ( SERVER ) then
            ply:EmitSound("physics/flesh/flesh_impact_hard" .. math.random(3, 4) .. ".wav")
        end

        ply:ViewPunch(Angle(-4, 0, 0))

        if ( ent:IsPlayer() ) then
            ent:ViewPunch(Angle(4, 0, 0))
        end

        ent:SetVelocity(ply:GetAimVector() * self:GetPushForce())

        hook.Run("OWHandsPush", ply, ent)
    elseif ( ent:GetClass():find("door") ) then
        if ( SERVER ) then
            ply:EmitSound("physics/wood/wood_crate_impact_hard" .. math.random(1, 5) .. ".wav")
        end

        ply:ViewPunch(Angle(2, 0, 0))

        hook.Run("OWHandsKnock", ply, ent)
    elseif ( SERVER and IsValid(physicsObject) and self:CanPickup() ) then
        if ( physicsObject:GetMass() > self:GetMaxMassHold() ) then return end

        if ( !self:GetDragging() ) then
            local aimTarget = ply:EyePos() + ply:GetAimVector() * self:GetReachDistance()
            local target = ents.Create("prop_physics")
            target:SetModel("models/props_junk/popcan01a.mdl")
            target:SetPos(aimTarget)
            target:SetOwner(ply)
            target:Spawn()
            target:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
            target:SetSolid(SOLID_NONE)
            target:SetNoDraw(true)
            target:SetNotSolid(true)
            target:SetMoveType(MOVETYPE_CUSTOM)

            self:SetConstraintTarget(target)

            local targetHitPos = ent:WorldToLocal(traceData.HitPos)

            local rope = constraint.Rope(ent, target, 0, 0, targetHitPos, vector_origin, 0, 0, 5000, 1, "cable/cable2", false)
            self:SetConstraint(rope)

            self:SetDragging(true)
            self:SetDraggingTarget(ent)
        else
            if ( IsValid(self:GetConstraint()) ) then
                self:GetConstraint():Remove()
            end

            if ( IsValid(self:GetConstraintTarget()) ) then
                self:GetConstraintTarget():Remove()
            end

            self:SetDragging(false)
            self:SetDraggingTarget(nil)
        end
    end

    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
end

function SWEP:Think()
    if ( !IsValid(self:GetOwner()) ) then return end

    if ( self:GetDragging() ) then
        if ( !IsValid(self:GetConstraint()) or !IsValid(self:GetConstraintTarget()) ) then
            self:SetDragging(false)
            self:SetDraggingTarget(nil)
            return
        end

        local ply = self:GetOwner()
        local aimTarget = ply:EyePos() + ply:GetAimVector() * self:GetReachDistance()

        local target = self:GetConstraintTarget()
        if ( IsValid(target) ) then
            target:SetPos(aimTarget)
            debugoverlay.Axis(target:GetPos(), target:GetAngles(), 16, 0.1, true)
        end

        local ent = self:GetDraggingTarget()
        if ( IsValid(ent) ) then
            local physicsObject = ent:GetPhysicsObject()
            if ( IsValid(physicsObject) ) then
                physicsObject:Wake()
            end

            debugoverlay.Axis(ent:GetPos(), ent:GetAngles(), 16, 0.1, true)
        end
    end

    self:NextThink(CurTime())
end

function SWEP:OnRemove()
    SafeRemoveEntity(self:GetConstraint())
    SafeRemoveEntity(self:GetConstraintTarget())

    self:SetDragging(false)
    self:SetDraggingTarget(nil)
end