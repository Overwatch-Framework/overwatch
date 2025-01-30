local MODULE = MODULE

MODULE.cvar_thirdperson = CreateClientConVar("ow_thirdperson", 0, true, false, ow.localization:GetPhrase("ow.option.thirdperson.enable"), 0, 1)
MODULE.cvar_thirdperson_pos_x = CreateClientConVar("ow_thirdperson_pos_x", 50, true, false, ow.localization:GetPhrase("ow.options.thirdperson.position.x.help"), -100, 100)
MODULE.cvar_thirdperson_pos_y = CreateClientConVar("ow_thirdperson_pos_y", 15, true, false, ow.localization:GetPhrase("ow.options.thirdperson.position.y.help"), -100, 100)
MODULE.cvar_thirdperson_pos_z = CreateClientConVar("ow_thirdperson_pos_z", 0, true, false, ow.localization:GetPhrase("ow.options.thirdperson.position.z.help"), -100, 100)
MODULE.cvar_thirdperson_follow_head = CreateClientConVar("ow_thirdperson_follow_head", 0, true, false, ow.localization:GetPhrase("ow.options.thirdperson.followhead.help"))

concommand.Add("ow_thirdperson_toggle", function()
    RunConsoleCommand("ow_thirdperson", MODULE.cvar_thirdperson:GetBool() and 0 or 1)
end, nil, ow.localization:GetPhrase("ow.options.thirdperson.toggle"))

concommand.Add("ow_thirdperson_reset", function()
    RunConsoleCommand("ow_thirdperson_pos_x", 0)
    RunConsoleCommand("ow_thirdperson_pos_y", 0)
    RunConsoleCommand("ow_thirdperson_pos_z", 0)
end, nil, ow.localization:GetPhrase("ow.options.thirdperson.reset"))

local fakePos
local fakeAngles
local fakeFov
function MODULE:CalcView(ply, pos, angles, fov)
    if ( !self.cvar_thirdperson:GetBool() ) then
        fakePos = nil
        fakeAngles = nil
        fakeFov = nil

        return
    end

    local view = {}

    if ( self.cvar_thirdperson_follow_head:GetBool() ) then
        local head

        for i = 0, ply:GetBoneCount() do
            local bone = ply:GetBoneName(i)
            if ( ow.util:FindString(bone, "head") ) then
                head = i
                break
            end
        end

        if ( head ) then
            local head_pos = select(1, ply:GetBonePosition(head))
            pos = head_pos
        end
    end

    pos = pos + ply:GetVelocity() / 8

    local trace = util.TraceHull({
        start = pos,
        endpos = pos - (angles:Forward() * self.cvar_thirdperson_pos_x:GetInt()) + (angles:Right() * self.cvar_thirdperson_pos_y:GetInt()) + (angles:Up() * self.cvar_thirdperson_pos_z:GetInt()),
        filter = function(ent)
            if ( ent == ply ) then
                return true
            end

            if ( ent:GetClass() == "prop_physics" ) then
                return true
            end

            return false
        end,
        mask = MASK_SHOT,
        mins = Vector(-4, -4, -4),
        maxs = Vector(4, 4, 4)
    })

    local traceData = util.TraceHull({
        start = pos,
        endpos = pos + (angles:Forward() * 32768),
        filter = function(ent)
            if ( ent == ply ) then
                return true
            end

            if ( ent:GetClass() == "prop_physics" ) then
                return true
            end

            return false
        end,
        mask = MASK_SHOT,
        mins = Vector(-8, -8, -8),
        maxs = Vector(8, 8, 8)
    })

    local shootPos = traceData.HitPos

    local viewBob = angle_zero
    viewBob.p = math.sin(CurTime() / 4) / 2
    viewBob.y = math.cos(CurTime()) / 2

    fakeAngles = LerpAngle(FrameTime() * 8, fakeAngles or angles, (shootPos - trace.HitPos):Angle() + viewBob)
    fakePos = LerpVector(FrameTime() * 8, fakePos or trace.HitPos, trace.HitPos)

    local distance = pos:Distance(traceData.HitPos) / 64
    distance = math.Clamp(distance, 0, 50)
    fakeFov = Lerp(FrameTime(), fakeFov or fov, fov - distance)

    view.origin = fakePos or trace.HitPos
    view.angles = fakeAngles or angles
    view.fov = fakeFov or fov

    return view
end

function MODULE:ShouldDrawLocalPlayer(ply)
    return self.cvar_thirdperson:GetBool()
end

function MODULE:AddToolMenuCategories()
    spawnmenu.AddToolCategory("Overwatch", "User", "User")
end

function MODULE:PopulateToolMenu()
    spawnmenu.AddToolMenuOption("Overwatch", "User", "ow_thirdperson", ow.localization:GetPhrase("ow.option.thirdperson"), "", "", function(form)
        form:CheckBox(ow.localization:GetPhrase("ow.option.thirdperson.enable"), "ow_thirdperson")
        form:CheckBox(ow.localization:GetPhrase("ow.options.thirdperson.followhead"), "ow_thirdperson_follow_head")

        form:NumSlider(ow.localization:GetPhrase("ow.options.thirdperson.position.x"), "ow_thirdperson_pos_x", -100, 100, 0)
        form:NumSlider(ow.localization:GetPhrase("ow.options.thirdperson.position.y"), "ow_thirdperson_pos_y", -100, 100, 0)
        form:NumSlider(ow.localization:GetPhrase("ow.options.thirdperson.position.z"), "ow_thirdperson_pos_z", -100, 100, 0)
    end)
end