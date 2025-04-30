local MODULE = MODULE

MODULE.Name = "Sway"
MODULE.Description = "Implements a swaying effect ported over from ARC9."
MODULE.Author = "Riggs"

ow.localization:Register("en", {
    ["category.sway"] = "Sway",
    ["option.sway"] = "Sway",
    ["option.sway.help"] = "Enable or disable sway.",
    ["option.sway.multiplier"] = "Sway Multiplier",
    ["option.sway.multiplier.help"] = "Set the sway multiplier.",
    ["option.sway.multiplier.sprint"] = "Sway Multiplier Sprint",
    ["option.sway.multiplier.sprint.help"] = "Set the sway multiplier while sprinting.",
})

ow.option:Register("sway", {
    Name = "option.sway",
    Type = ow.type.bool,
    Default = true,
    Description = "option.sway.help",
    bNoNetworking = true,
    Category = "category.sway"
})

ow.option:Register("sway.multiplier", {
    Name = "option.sway.multiplier",
    Type = ow.type.number,
    Default = 1,
    Min = 0,
    Max = 10,
    Decimals = 1,
    Description = "option.sway.multiplier.help",
    bNoNetworking = true,
    Category = "category.sway"
})

ow.option:Register("sway.multiplier.sprint", {
    Name = "option.sway.multiplier.sprint",
    Type = ow.type.number,
    Default = 1,
    Min = 0,
    Max = 10,
    Decimals = 1,
    Description = "option.sway.multiplier.sprint.help",
    bNoNetworking = true,
    Category = "category.sway"
})

if ( !CLIENT ) then return end

local SideMove = 0
local JumpMove = 0

local ViewModelBobVelocity = 0
local ViewModelNotOnGround = 0

local BobCT = 0
local Multiplier = 0

local SprintInertia = 0
local WalkInertia = 0
local CrouchMultiplier = 0
local SprintMultiplier = 0
local WalkMultiplier = 0

local function GetViewModelBob(pos, ang)
    local step = 10
    local mag = 1
    local ts = 0

    local swayEnabled = ow.option:Get("sway")
    if ( !swayEnabled ) then return pos, ang end

    local swayMult = ow.option:Get("sway.multiplier")
    local swayMultSprint = ow.option:Get("sway.multiplier.sprint")

    local ply = ow.localClient
    local ft = FrameTime()
    local time = ft * 16

    Multiplier = ow.ease:Lerp("InExpo", time, Multiplier, ply:IsSprinting() and swayMultSprint or swayMult)

    local velocityangle = ply:GetVelocity()
    local v = velocityangle:Length()
    v = math.Clamp(v, 0, 250)
    ViewModelBobVelocity = math.Approach(ViewModelBobVelocity, v, ft * 10000)
    local d = math.Clamp(ViewModelBobVelocity / 250, 0, 1)

    if ( ply:OnGround() and ply:GetMoveType() != MOVETYPE_NOCLIP ) then
        ViewModelNotOnGround = math.Approach(ViewModelNotOnGround, 0, ft / 0.1)
    else
        ViewModelNotOnGround = math.Approach(ViewModelNotOnGround, 1, ft / 0.1)
    end

    local amount = math.Clamp(math.ease.InExpo(math.Clamp(v, 0, 250) / 250), 0, 1)

    d = d * ow.ease:Lerp("InExpo", amount, 1, 0.03) * ow.ease:Lerp("InExpo", ts, 1, 1.5)
    mag = d * 2
    mag = mag * ow.ease:Lerp("InExpo", ts, 1, 2)
    step = ow.ease:Lerp("InExpo", time, step, 10)

    local sidemove = (ply:GetVelocity():Dot(ply:EyeAngles():Right()) / ply:GetMaxSpeed()) * 4 * (1.5-amount)
    SideMove = ow.ease:Lerp("InExpo", math.Clamp(ft * 8, 0, 1), SideMove, sidemove)

    CrouchMultiplier = ow.ease:Lerp("InExpo", time, CrouchMultiplier, 1)
    if ( ply:Crouching() ) then
        CrouchMultiplier = ow.ease:Lerp("InExpo", time, CrouchMultiplier, 3.5 + amount * 10)
        step = ow.ease:Lerp("InExpo", time, step, 6)
    end

    local jumpmove = math.Clamp(math.ease.InExpo(math.Clamp(velocityangle.z, -150, 0) / -150) * 0.5 + math.ease.InExpo(math.Clamp(velocityangle.z, 0, 350) / 350) * -50, -4, 2.5) * 0.5
    JumpMove = ow.ease:Lerp("InExpo", math.Clamp(ft * 8, 0, 1), JumpMove, jumpmove)
    local smoothjumpmove2 = math.Clamp(JumpMove, -0.3, 0.01) * ( 1.5 - amount )

    if ( ply:IsSprinting() ) then
        SprintInertia = ow.ease:Lerp("InExpo", time, SprintInertia, 1)
        WalkInertia = ow.ease:Lerp("InExpo", time, WalkInertia, 0)
    else
        SprintInertia = ow.ease:Lerp("InExpo", time, SprintInertia, 0)
        WalkInertia = ow.ease:Lerp("InExpo", time, WalkInertia, 1)
    end

    if ( SprintInertia > 0 ) then
        SprintMultiplier = Multiplier * SprintInertia
        pos = pos - (ang:Up() * math.sin(BobCT * step) * 0.45 * ((math.sin(BobCT * 3.515) * 0.2) + 1) * mag * SprintMultiplier)
        pos = pos + (ang:Forward() * math.sin(BobCT * step * 0.3) * 0.11 * ((math.sin(BobCT * 2) * ts * 1.25) + 1) * ((math.sin(BobCT * 0.615) * 0.2) + 2) * mag * SprintMultiplier)
        pos = pos + (ang:Right() * (math.sin(BobCT * step * 0.5) + (math.cos(BobCT * step * 0.5))) * 0.55 * mag * SprintMultiplier)
        ang:RotateAroundAxis(ang:Forward(), math.sin(BobCT * step * 0.5) * ((math.sin(BobCT * 6.151) * 0.2) + 1) * 9 * d * SprintMultiplier + SideMove * 1.5)
        ang:RotateAroundAxis(ang:Right(), math.sin(BobCT * step * 0.12) * ((math.sin(BobCT * 1.521) * 0.2) + 1) * 1 * d * SprintMultiplier)
        ang:RotateAroundAxis(ang:Up(), math.sin(BobCT * step * 0.5) * ((math.sin(BobCT * 1.521) * 0.2) + 1) * 6 * d * SprintMultiplier)
        ang:RotateAroundAxis(ang:Right(), smoothjumpmove2 * 5)
    end

    if ( WalkInertia > 0 ) then
        WalkMultiplier = Multiplier * WalkInertia
        pos = pos - (ang:Up() * math.sin(BobCT * step) * 0.1 * ((math.sin(BobCT * 3.515) * 0.2) + 2) * mag * CrouchMultiplier * WalkMultiplier) - (ang:Up() * SideMove * -0.05) - (ang:Up() * smoothjumpmove2 * 0.2)
        pos = pos + (ang:Forward() * math.sin(BobCT * step * 0.3) * 0.11 * ((math.sin(BobCT * 2) * ts * 1.25) + 1) * ((math.sin(BobCT * 0.615) * 0.2) + 1) * mag * WalkMultiplier)
        pos = pos + (ang:Right() * (math.sin(BobCT * step * 0.5) + (math.cos(BobCT * step * 0.5))) * 0.55 * mag * WalkMultiplier)
        ang:RotateAroundAxis(ang:Forward(), math.sin(BobCT * step * 0.5) * ((math.sin(BobCT * 6.151) * 0.2) + 1) * 5 * d * WalkMultiplier + SideMove)
        ang:RotateAroundAxis(ang:Right(), math.sin(BobCT * step * 0.12) * ((math.sin(BobCT * 1.521) * 0.2) + 1) * 0.1 * d * WalkMultiplier)
        ang:RotateAroundAxis(ang:Right(), smoothjumpmove2 * 5)
    end

    local steprate = ow.ease:Lerp("InExpo", d, 1, 2.75)
    steprate = ow.ease:Lerp("InExpo", ViewModelNotOnGround, steprate, 0.75)

    if ( IsFirstTimePredicted() or game.SinglePlayer() ) then
        BobCT = BobCT + ( ft * steprate )
    end

    return pos, ang
end

DEFINE_BASECLASS("sway")
function MODULE:CalcViewModelView(wep, vm, oldPos, oldAng, pos, ang)
    if ( !IsValid(wep) or !IsValid(vm) ) then return end

    pos, ang = GAMEMODE.BaseClass:CalcViewModelView(wep, vm, oldPos, oldAng, pos, ang)
    pos, ang = GetViewModelBob(pos, ang)

    return pos, ang
end