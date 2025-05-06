AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ow.net:Hook("hands.reset", function(client)
    if ( client.owHandsReset and client.owHandsReset > CurTime() ) then return end
    client.owHandsReset = CurTime() + 0.5

    if ( !IsValid(client) ) then return end

    local weapon = client:GetActiveWeapon()
    if ( !IsValid(weapon) ) then return end

    if ( weapon:GetClass() == "ow_hands" ) then
        weapon:Reset()
    end
end)

function SWEP:SetWeaponRaised(bRaised)
    if ( bRaised ) then
        self:SetHoldType("fist")

        local vm = self:GetOwner():GetViewModel()
        vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_draw"))
    else
        self:SetHoldType("normal")

        local vm = self:GetOwner():GetViewModel()
        vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_holster"))
    end
end

function SWEP:CalcLerpSpeed(eHoldingEntity)
    if ( eHoldingEntity:IsRagdoll() ) then
        return 4
    end

    return 8
end

local entDiff = vector_origin
local entDiffTime = CurTime()
local standTime = 0
function SWEP:Think()
    if ( !self:CheckValidity() ) then
        return
    end

    local curTime = CurTime()
    if ( curTime > entDiffTime ) then
        entDiff = self:GetPos() - self.owHoldingEntity:GetPos()
        if ( entDiff:Dot(entDiff) > 40000 ) then
            self:Reset()
            return
        end

        entDiffTime = curTime + 1
    end

    if ( curTime > standTime ) then
        if ( self:IsEntityStoodOn(self.owHoldingEntity) ) then
            self:Reset()
            return
        end

        standTime = curTime + 0.1
    end

    local pos = self:GetOwner():EyePos() + self:GetOwner():GetAimVector() * self.owCarry.distance
    local lerpSpeed = self:CalcLerpSpeed(self.owHoldingEntity)

    local ft = FrameTime()
    self.owCarry.lerpPos = LerpVector(ft * lerpSpeed, self.owCarry.lerpPos or pos, pos)

    self.owCarry:SetPos(self.owCarry.lerpPos)

    local targetAng = self:GetOwner():GetAngles()
    if ( self.owCarry.preferedAngle ) then
        targetAng.p = 0
    end

    self.owCarry.lerpAng = LerpAngle(ft * lerpSpeed, self.owCarry.lerpAng or targetAng, targetAng)

    self.owCarry:SetAngles(self.owCarry.lerpAng)
    self.owHoldingEntity:PhysWake()
end

function SWEP:Pickup()
    if ( IsValid(self.owHoldingEntity) ) then return end

    local client = self:GetOwner()
    local traceData = client:GetEyeTrace(MASK_SHOT)
    local ent = traceData.Entity
    local holdingPhysicsObject = ent:GetPhysicsObject()

    if ( ent:GetRelay("disallowPickup", false) ) then return end
    if ( ent:GetMoveType() == MOVETYPE_NONE ) then return end

    self.owHoldingEntity = ent
    if ( IsValid(ent) and IsValid(holdingPhysicsObject) ) then
        self.owCarry = ents.Create("prop_physics")

        if ( IsValid(self.owCarry) ) then
            local pos, obb = self.owHoldingEntity:GetPos(), self.owHoldingEntity:OBBCenter()
            pos = pos + self.owHoldingEntity:GetForward() * obb.x
            pos = pos + self.owHoldingEntity:GetRight() * obb.y
            pos = pos + self.owHoldingEntity:GetUp() * obb.z
            pos = traceData.HitPos

            self.owCarry:SetPos(pos)
            self.owCarry.distance = math.min(64, client:GetShootPos():Distance(pos))

            self.owCarry:SetModel("models/weapons/w_bugbait.mdl")

            self.owCarry:SetNoDraw(true)
            self.owCarry:DrawShadow(false)

            self.owCarry:SetHealth(999)
            self.owCarry:SetOwner(self.owHoldingEntity:GetOwner())
            self.owCarry:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
            self.owCarry:SetSolid(SOLID_NONE)

            local preferredAngles = hook.Run("GetPreferredCarryAngles", self.owHoldingEntity)
            if ( self:GetOwner():KeyDown(IN_RELOAD) and !preferredAngles ) then
                preferredAngles = Angle()
            end

            if ( preferredAngles ) then
                local entAngle = self.owHoldingEntity:GetAngles()
                self.owCarry.preferedAngle = self.owHoldingEntity:GetAngles()
                local grabAngle = self.owHoldingEntity:GetAngles()

                grabAngle:RotateAroundAxis(entAngle:Right(), preferredAngles[1])
                grabAngle:RotateAroundAxis(entAngle:Up(), preferredAngles[2])
                grabAngle:RotateAroundAxis(entAngle:Forward(), preferredAngles[3])

                self.owCarry:SetAngles(grabAngle)
            else
                local ang = self:GetOwner():GetAngles()
                self.owCarry.StoredAng = LerpAngle(FrameTime() * 2, self.owCarry.StoredAng or ang, ang)
                self.owCarry:SetAngles(self.owCarry.StoredAng)
            end

            self.owCarry:Spawn()

            local physicsObject = self.owCarry:GetPhysicsObject()
            if ( IsValid(physicsObject) ) then
                physicsObject:SetMass(200)
                physicsObject:SetDamping(0, 1000)
                physicsObject:EnableGravity(false)
                physicsObject:EnableCollisions(false)
                physicsObject:EnableMotion(false)
                physicsObject:AddGameFlag(FVPHYSICS_PLAYER_HELD)
            end

            local bone = math.Clamp(traceData.PhysicsBone, 0, 1)
            if ( ent:GetClass() == "prop_ragdoll" ) then
                bone = traceData.PhysicsBone
                self.holdingBone = bone
                holdingPhysicsObject = self.owHoldingEntity:GetPhysicsObjectNum(bone)
            end

            holdingPhysicsObject:AddGameFlag(FVPHYSICS_PLAYER_HELD)

            local maxForce = ow.config:Get("hands.max.force", 16500)
            local vSize = self.owHoldingEntity:OBBMaxs() - self.owHoldingEntity:OBBMins()
            if ( self.owHoldingEntity:IsRagdoll() or math.max(vSize.x, vSize.y, vSize.z) > 60 ) then
                self.owConstraint = constraint.Ballsocket(self.owCarry, self.owHoldingEntity, 0, bone, holdingPhysicsObject:WorldToLocal(pos), maxForce / 3, 0, 1)
            else
                self.owConstraint = constraint.Weld(self.owCarry, self.owHoldingEntity, 0, bone, maxForce, true)

                self.owHoldingEntity.HandsConstraint = self.owConstraint
            end

            self.owHoldingEntity.oldCollisionGroup = self.owHoldingEntity.oldCollisionGroup or self.owHoldingEntity:GetCollisionGroup()
            self.owHoldingEntity:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)

            local children = self.owHoldingEntity:GetChildren()
            for i = 1, #children do
                children[i]:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
            end

            self:GetOwner():EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 3) .. ".wav", 60)
        end
    end
end