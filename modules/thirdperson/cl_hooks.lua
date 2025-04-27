local MODULE = MODULE

concommand.Add("ow_thirdperson_toggle", function()
    ow.option:Set("thirdperson", !ow.option:Get("thirdperson", false))
end, nil, ow.localization:GetPhrase("options.thirdperson.toggle"))

concommand.Add("ow_thirdperson_reset", function()
    ow.option:Set("thirdperson.position.x", ow.option:GetDefault("thirdperson.position.x"))
    ow.option:Set("thirdperson.position.y", ow.option:GetDefault("thirdperson.position.y"))
    ow.option:Set("thirdperson.position.z", ow.option:GetDefault("thirdperson.position.z"))
end, nil, ow.localization:GetPhrase("options.thirdperson.reset"))

local fakePos
local fakeAngles
local fakeFov

function MODULE:PreRenderThirdpersonView(ply, pos, angles, fov)
    if ( IsValid(ow.gui.mainmenu) ) then
        return false
    end

    if ( IsValid(ply:GetVehicle()) ) then
        return false
    end

    return true
end

function MODULE:CalcView(ply, pos, angles, fov)
    if ( !ow.option:Get("thirdperson", false) or hook.Run("PreRenderThirdpersonView", ply, pos, angles, fov) == false ) then
        fakePos = nil
        fakeAngles = nil
        fakeFov = nil

        return
    end

    local view = {}

    if ( ow.option:Get("thirdperson.followhead", false) ) then
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
        endpos = pos - (angles:Forward() * ow.option:Get("thirdperson.position.x", 0)) + (angles:Right() * ow.option:Get("thirdperson.position.y", 0)) + (angles:Up() * ow.option:Get("thirdperson.position.z", 0)),
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
    local curTime = CurTime()
    local frameTime = FrameTime()

    viewBob.p = math.sin(curTime / 4) / 2
    viewBob.y = math.cos(curTime) / 2

    fakeAngles = LerpAngle(frameTime * 8, fakeAngles or angles, (shootPos - trace.HitPos):Angle() + viewBob)
    fakePos = LerpVector(frameTime * 8, fakePos or trace.HitPos, trace.HitPos)

    local distance = pos:Distance(traceData.HitPos) / 64
    distance = math.Clamp(distance, 0, 50)
    fakeFov = Lerp(frameTime, fakeFov or fov, fov - distance)

    view.origin = fakePos or trace.HitPos
    view.angles = fakeAngles or angles
    view.fov = fakeFov or fov

    return view
end

function MODULE:ShouldDrawLocalPlayer(ply)
    return ow.option:Get("thirdperson", false)
end

/*
function MODULE:AddToolMenuCategories()
    spawnmenu.AddToolCategory("Overwatch", "User", "User")
end

function MODULE:AddToolMenuTabs()
    spawnmenu.AddToolTab("Overwatch", "Overwatch", "icon16/computer.png")

    spawnmenu.AddToolMenuOption("Overwatch", "User", "ow_thirdperson", "Third Person", "", "", function(panel)
        panel:ClearControls()

        panel:AddControl("Header", { Text = ow.localization:GetPhrase("options.thirdperson.title"), Description = ow.localization:GetPhrase("options.thirdperson.description") })
        panel:CheckBox(ow.localization:GetPhrase("options.thirdperson.enable"), "ow_thirdperson_enable")
        panel:NumSlider(ow.localization:GetPhrase("options.thirdperson.position.x"), "ow_thirdperson_position_x", -1000, 1000, 0)
        panel:NumSlider(ow.localization:GetPhrase("options.thirdperson.position.y"), "ow_thirdperson_position_y", -1000, 1000, 0)
        panel:NumSlider(ow.localization:GetPhrase("options.thirdperson.position.z"), "ow_thirdperson_position_z", -1000, 1000, 0)
    end)
end
*/