function MODULE:HandlePlayerJumping(ply, velocity, plyTable)
    if ( !istable(plyTable) ) then
        plyTable = ply:GetTable()
    end

    if ( ply:GetMoveType() == MOVETYPE_NOCLIP ) then
        plyTable.m_bJumping = false
        return
    end

    if ( !plyTable.m_bJumping and !ply:OnGround() and ply:WaterLevel() <= 0) then
        if ( !plyTable.m_fGroundTime ) then
            plyTable.m_fGroundTime = CurTime()
        elseif ( ( CurTime() - plyTable.m_fGroundTime ) > 0 and velocity:Length2DSqr() < 0.25 ) then
            plyTable.m_bJumping = true
            plyTable.m_bFirstJumpFrame = false
            plyTable.m_flJumpStartTime = 0
        end
    end

    if ( plyTable.m_bJumping ) then
        if ( plyTable.m_bFirstJumpFrame ) then
            plyTable.m_bFirstJumpFrame = false
            ply:AnimRestartMainSequence()
        end

        if ( ( ply:WaterLevel() >= 2 ) or ( ( CurTime() - plyTable.m_flJumpStartTime ) > 0.2 and ply:OnGround() ) ) then
            plyTable.m_bJumping = false
            plyTable.m_fGroundTime = nil
            ply:AnimRestartMainSequence()
        end

        if ( plyTable.m_bJumping ) then
            plyTable.CalcIdeal = ACT_MP_JUMP
            return true
        end
    end

    return false
end

function MODULE:HandlePlayerDucking(ply, velocity, plyTable)
    if ( !plyTable ) then
        plyTable = ply:GetTable()
    end

    if ( !ply:IsFlagSet(FL_ANIMDUCKING) ) then return false end

    if ( velocity:Length2DSqr() > 0.25 ) then
        plyTable.CalcIdeal = ACT_MP_CROUCHWALK
    else
        plyTable.CalcIdeal = ACT_MP_CROUCH_IDLE
    end

    return true
end

function MODULE:HandlePlayerNoClipping(ply, velocity, plyTable)
    if ( !istable(plyTable) ) then
        plyTable = ply:GetTable()
    end

    if ( ply:GetMoveType() != MOVETYPE_NOCLIP or ply:InVehicle() ) then
        if ( plyTable.m_bWasNoclipping ) then
            plyTable.m_bWasNoclipping = nil
            ply:AnimResetGestureSlot(GESTURE_SLOT_CUSTOM)

            if ( CLIENT ) then
                ply:SetIK(true)
            end
        end

        return
    end

    if ( !plyTable.m_bWasNoclipping ) then
        ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM, ACT_GMOD_NOCLIP_LAYER, false)

        if ( CLIENT ) then
            ply:SetIK(false)
        end
    end

    return true
end

function MODULE:HandlePlayerVaulting(ply, velocity, plyTable)
    if ( !istable(plyTable) ) then
        plyTable = ply:GetTable()
    end

    if ( velocity:LengthSqr() < 1000000 ) then return end
    if ( ply:IsOnGround() ) then return end

    plyTable.CalcIdeal = ACT_MP_SWIM

    return true
end

function MODULE:HandlePlayerSwimming(ply, velocity, plyTable)
    if ( !istable(plyTable) ) then
        plyTable = ply:GetTable()
    end

    if ( ply:WaterLevel() < 2 or ply:IsOnGround() ) then
        plyTable.m_bInSwim = false
        return false
    end

    plyTable.CalcIdeal = ACT_MP_SWIM
    plyTable.m_bInSwim = true

    return true
end

function MODULE:HandlePlayerLanding(ply, velocity, WasOnGround)
    if ( ply:GetMoveType() == MOVETYPE_NOCLIP ) then return end
    if ( ply:IsOnGround() and !WasOnGround ) then
        ply:AnimRestartGesture(GESTURE_SLOT_JUMP, ACT_LAND, true)
    end
end

function MODULE:HandlePlayerDriving(ply, plyTable)
    if ( !istable(plyTable) ) then
        plyTable = ply:GetTable()
    end

    if ( !ply:InVehicle() or !IsValid(ply:GetParent()) ) then
        return false
    end

    local pVehicle = ply:GetVehicle()
    if ( !pVehicle.HandleAnimation and pVehicle.GetVehicleClass ) then
        local c = pVehicle:GetVehicleClass()
        local t = list.Get("Vehicles")[c]
        if ( t and t.Members and t.Members.HandleAnimation ) then
            pVehicle.HandleAnimation = t.Members.HandleAnimation
        else
            pVehicle.HandleAnimation = true
        end
    end

    if ( isfunction(pVehicle.HandleAnimation) ) then
        local seq = pVehicle:HandleAnimation(ply)
        if ( seq != nil ) then
            plyTable.CalcSeqOverride = seq
        end
    end

    if ( plyTable.CalcSeqOverride == -1 ) then
        local class = pVehicle:GetClass()
        if ( class == "prop_vehicle_jeep" ) then
            plyTable.CalcSeqOverride = ply:LookupSequence("drive_jeep")
        elseif ( class == "prop_vehicle_airboat" ) then
            plyTable.CalcSeqOverride = ply:LookupSequence("drive_airboat")
        elseif ( class == "prop_vehicle_prisoner_pod" and pVehicle:GetModel() == "models/vehicles/prisoner_pod_inner.mdl" ) then
            plyTable.CalcSeqOverride = ply:LookupSequence("drive_pd")
        else
            plyTable.CalcSeqOverride = ply:LookupSequence("sit_rollercoaster")
        end
    end

    local use_anims = (plyTable.CalcSeqOverride == ply:LookupSequence("sit_rollercoaster") or plyTable.CalcSeqOverride == ply:LookupSequence("sit"))
    if ( use_anims and ply:GetAllowWeaponsInVehicle() and IsValid(ply:GetActiveWeapon()) ) then
        local holdtype = ply:GetActiveWeapon():GetHoldType()
        if ( holdtype == "smg" ) then
            holdtype = "smg1"
        end

        local seqid = ply:LookupSequence("sit_" .. holdtype)
        if ( seqid != -1 ) then
            plyTable.CalcSeqOverride = seqid
        end
    end

    return true
end

function MODULE:UpdateAnimation(ply, velocity, maxseqgroundspeed)
    local len = velocity:Length()
    local movement = 1.0
    if ( len > 0.2 ) then
        movement = (len / maxseqgroundspeed)
    end

    local rate = math.min(movement, 2)
    if ( ply:WaterLevel() >= 2 ) then
        rate = math.max(rate, 0.5)
    elseif ( !ply:IsOnGround() and len >= 1000 ) then
        rate = 0.1
    end

    ply:SetPlaybackRate(rate)

    if ( CLIENT ) then
        if ( ply:InVehicle() ) then
            local Vehicle = ply:GetVehicle()
            local Velocity = Vehicle:GetVelocity()
            local fwd = Vehicle:GetUp()
            local dp = fwd:Dot(Vector(0, 0, 1))
            ply:SetPoseParameter("vertical_velocity", (dp < 0 and dp or 0) + fwd:Dot(Velocity) * 0.005)

            local steer = Vehicle:GetPoseParameter("vehicle_steer")
            steer = steer * 2 - 1
            if ( Vehicle:GetClass() == "prop_vehicle_prisoner_pod" ) then
                steer = 0 ply:SetPoseParameter("aim_yaw", math.NormalizeAngle(ply:GetAimVector():Angle().y - Vehicle:GetAngles().y - 90))
            end

            ply:SetPoseParameter("vehicle_steer", steer)
        end

        self:GrabEarAnimation(ply)
        self:MouthMoveAnimation(ply)
    end
end

function MODULE:GrabEarAnimation(ply, plyTable)
    if ( !istable(plyTable) ) then
        plyTable = ply:GetTable()
    end

    plyTable.ChatGestureWeight = plyTable.ChatGestureWeight or 0

    if ( ply:IsPlayingTaunt() ) then
        return
    end

    if ( ply:IsTyping() ) then
        plyTable.ChatGestureWeight = math.Approach(plyTable.ChatGestureWeight, 1, FrameTime() * 5)
    else
        plyTable.ChatGestureWeight = math.Approach(plyTable.ChatGestureWeight, 0, FrameTime() * 5)
    end

    if ( plyTable.ChatGestureWeight > 0 ) then
        ply:AnimRestartGesture(GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true)
        ply:AnimSetGestureWeight(GESTURE_SLOT_VCD, plyTable.ChatGestureWeight)
    end
end

function MODULE:MouthMoveAnimation(ply)
    local flexes = {
        ply:GetFlexIDByName("jaw_drop"),
        ply:GetFlexIDByName("left_part"),
        ply:GetFlexIDByName("right_part"),
        ply:GetFlexIDByName("left_mouth_drop"),
        ply:GetFlexIDByName("right_mouth_drop")
    }

    local weight = ply:IsSpeaking() and math.Clamp(ply:VoiceVolume() * 2, 0, 2) or 0
    for k, v in ipairs(flexes) do
        ply:SetFlexWeight(v, weight)
    end
end

local vectorAngle = FindMetaTable("Vector").Angle
local normalizeAngle = math.NormalizeAngle
function MODULE:CalcMainActivity(ply, velocity)
    local plyTable = ply:GetTable()
    plyTable.CalcIdeal = ACT_MP_STAND_IDLE

    ply:SetPoseParameter("move_yaw", normalizeAngle(vectorAngle(velocity)[2] - ply:EyeAngles()[2]))

    self:HandlePlayerLanding(ply, velocity, plyTable.m_bWasOnGround)

    if !( self:HandlePlayerNoClipping(ply, velocity, plyTable) or
        self:HandlePlayerDriving(ply, plyTable) or
        self:HandlePlayerVaulting(ply, velocity, plyTable) or
        self:HandlePlayerJumping(ply, velocity, plyTable) or
        self:HandlePlayerSwimming(ply, velocity, plyTable) or
        self:HandlePlayerDucking(ply, velocity, plyTable) ) then

        local len2d = velocity:Length2DSqr()
        if ( len2d > 22500 ) then
            plyTable.CalcIdeal = ACT_MP_RUN
        elseif ( len2d > 0.25 ) then
            plyTable.CalcIdeal = ACT_MP_WALK
        end
    end

    hook.Run("TranslateActivity", ply, plyTable.CalcIdeal)

    local seqOverride = plyTable.CalcSeqOverride
    plyTable.CalcSeqOverride = -1

    plyTable.m_bWasOnGround = ply:IsOnGround()
    plyTable.m_bWasNoclipping = (ply:GetMoveType() == MOVETYPE_NOCLIP and !ply:InVehicle())

    return plyTable.CalcIdeal, seqOverride or plyTable.CalcSeqOverride
end

local IdleActivity = ACT_HL2MP_IDLE
local IdleActivityTranslate = {}
IdleActivityTranslate[ACT_MP_STAND_IDLE] = IdleActivity
IdleActivityTranslate[ACT_MP_WALK] = IdleActivity + 1
IdleActivityTranslate[ACT_MP_RUN] = IdleActivity + 2
IdleActivityTranslate[ACT_MP_CROUCH_IDLE] = IdleActivity + 3
IdleActivityTranslate[ACT_MP_CROUCHWALK] = IdleActivity + 4
IdleActivityTranslate[ACT_MP_ATTACK_STAND_PRIMARYFIRE] = IdleActivity + 5
IdleActivityTranslate[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] = IdleActivity + 5
IdleActivityTranslate[ACT_MP_RELOAD_STAND] = IdleActivity + 6
IdleActivityTranslate[ACT_MP_RELOAD_CROUCH] = IdleActivity + 6
IdleActivityTranslate[ACT_MP_JUMP] = ACT_HL2MP_JUMP_SLAM
IdleActivityTranslate[ACT_MP_SWIM] = IdleActivity + 9
IdleActivityTranslate[ACT_LAND] = ACT_LAND

function MODULE:TranslateActivity(ply, act)
    local newact = ply:TranslateWeaponActivity(act)
    if ( act == newact ) then
        return IdleActivityTranslate[act]
    end

    local plyTable = ply:GetTable()
    local owAnimations = plyTable.owAnimations
    if ( owAnimations ) then
        local animTable = owAnimations[act]
        if ( animTable ) then
            local preferred = animTable[ply:IsWeaponRaised() and 2 or 1]
            newact = preferred
        end
    end

    return newact
end

function MODULE:DoAnimationEvent(ply, event, data)
    local plyTable = ply:GetTable()
    if ( event == PLAYERANIMEVENT_ATTACK_PRIMARY ) then
        if ( ply:IsFlagSet(FL_ANIMDUCKING) ) then
            ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_CROUCH_PRIMARYFIRE, true)
        else
            ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_STAND_PRIMARYFIRE, true)
        end

        return ACT_VM_PRIMARYATTACK
    elseif ( event == PLAYERANIMEVENT_ATTACK_SECONDARY ) then
        return ACT_VM_SECONDARYATTACK
    elseif ( event == PLAYERANIMEVENT_RELOAD ) then
        if ( ply:IsFlagSet(FL_ANIMDUCKING) ) then
            ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_CROUCH, true)
        else
            ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_STAND, true)
        end

        return ACT_INVALID
    elseif ( event == PLAYERANIMEVENT_JUMP ) then
        plyTable.m_bJumping = true
        plyTable.m_bFirstJumpFrame = true
        plyTable.m_flJumpStartTime = CurTime()

        ply:AnimRestartMainSequence()

        return ACT_INVALID
    elseif ( event == PLAYERANIMEVENT_CANCEL_RELOAD ) then
        ply:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)

        return ACT_INVALID
    end
end