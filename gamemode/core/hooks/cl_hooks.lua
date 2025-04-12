function GM:PlayerStartVoice(ply)
    if ( IsValid(g_VoicePanelList) ) then
        g_VoicePanelList:Remove()
    end
end

function GM:PlayerEndVoice(ply)
    if ( IsValid(g_VoicePanelList) ) then
        g_VoicePanelList:Remove()
    end
end

function GM:Initialize()
    ow.schema:Initialize()

    hook.Run("LoadFonts")
end

function GM:InitPostEntity()
    ow.localClient = LocalPlayer()
end

function GM:OnCloseCaptionEmit()
    return true
end

function GM:PostSchemaLoad()
    -- Do something here
end

function GM:CalcView(ply, pos, angles, fov)
    if ( IsValid(ow.gui.mainmenu) ) then
        local menuCamPos = ow.config:Get("menuCamPos", vector_origin)
        local menuCamAng = ow.config:Get("menuCamAng", angle_zero)
        local menuCamFov = ow.config:Get("menuCamFov", 90)

        return {
            origin = menuCamPos,
            angles = menuCamAng,
            fov = menuCamFov,
            drawviewer = true
        }
    end

    if ( !ply:Alive() ) then
        local ragdoll = ply:GetRagdollEntity()
        if ( !IsValid(ragdoll) ) then return end

        local eyePos
        local eyeAng

        if ( ragdoll:LookupAttachment("eyes") ) then
            local attachment = ragdoll:GetAttachment(ragdoll:LookupAttachment("eyes"))
            if ( attachment ) then
                eyePos = attachment.Pos
                eyeAng = attachment.Ang
            end
        else
            local bone = ragdoll:LookupBone("ValveBiped.Bip01_Head1")
            if ( !bone ) then return end

            eyePos, eyeAng = ragdoll:GetBonePosition(bone)
        end

        if ( !eyePos or !eyeAng ) then return end

        local traceHull = util.TraceHull({
            start = eyePos,
            endpos = eyePos + eyeAng:Forward() * 2,
            filter = ragdoll,
            mask = MASK_PLAYERSOLID,
            mins = Vector(-2, -2, -2),
            maxs = Vector(2, 2, 2)
        })

        return {
            origin = traceHull.HitPos,
            angles = eyeAng,
            fov = fov,
            drawviewer = true
        }
    end
end

local vignette = ow.util:GetMaterial("overwatch/gui/vignette.png", "noclamp smooth")
local vignetteColor = Color(0, 0, 0, 255)
function GM:HUDPaintBackground()
    if ( hook.Run("ShouldDrawVignette") ) then
        hook.Run("DrawVignette")
    end
end

function GM:DrawVignette()
    local ply = LocalPlayer()
    if ( !IsValid(ply) ) then return end

    local scrW, scrH = ScrW(), ScrH()
    local trace = util.TraceLine({
        start = ply:GetShootPos(),
        endpos = ply:GetShootPos() + ply:GetAimVector() * 96,
        filter = ply,
        mask = MASK_SHOT
    })

    if ( trace.Hit and trace.HitPos:DistToSqr(ply:GetShootPos()) < 96 ^ 2 ) then
        vignetteColor.a = Lerp(FrameTime(), vignetteColor.a, 255)
    else
        vignetteColor.a = Lerp(FrameTime(), vignetteColor.a, 100)
    end

    surface.SetDrawColor(vignetteColor)
    surface.SetMaterial(vignette)
    surface.DrawTexturedRect(0, 0, scrW, scrH)
end

function GM:HUDPaint()
    local ply = LocalPlayer()
    if ( !IsValid(ply) ) then return end

    if ( hook.Run("ShouldDrawDebugHUD") ) then
        local scrW, scrH = ScrW(), ScrH()
        local width, height
        local x, y = ScrW() / 2 - 400, scrH - 100

        width, height = draw.SimpleText(self.Name:upper(), "ow.fonts.fancy.large", x, y, hook.Run("GetFrameworkColor"), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        x, y = x + 16, y + 10

        if ( SCHEMA ) then
            width, height =  draw.SimpleText(SCHEMA.Name:upper(), "ow.fonts.fancy.small", x + width, y, hook.Run("GetSchemaColor"), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            x, y = x + 16, y + height
        end

        width, height = draw.SimpleText("FPS: " .. math.Round(1 / FrameTime()), "ow.fonts.default.bold", x, y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    if ( hook.Run("ShouldDrawCrosshair") ) then
        local x, y = ScrW() / 2, ScrH() / 2
        local size = 3

        if ( ow.module:Get("thirdperson") and ow.option:Get("thirdperson", false) ) then
            local trace = util.TraceLine({
                start = ply:GetShootPos(),
                endpos = ply:GetShootPos() + ply:GetAimVector() * 8192,
                filter = ply,
                mask = MASK_SHOT
            })

            local screen = trace.HitPos:ToScreen()
            x, y = screen.x, screen.y
        end

        paint.circles.drawCircle(x, y, size, size, color_white)
    end

    if ( hook.Run("ShouldDrawAmmoBox") ) then
        local activeWeapon = ply:GetActiveWeapon()
        if ( !IsValid(activeWeapon) ) then return end

        local ammo = ply:GetAmmoCount(activeWeapon:GetPrimaryAmmoType())
        local clip = activeWeapon:Clip1()
        local ammoText = clip .. " / " .. ammo

        draw.SimpleTextOutlined(ammoText, "ow.fonts.default.bold", ScrW() - 16, ScrH() - 16, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, color_black)
    end
end

local elements = {
    ["CHUDQuickInfo"] = true,
    ["CHudAmmo"] = true,
    ["CHudBattery"] = true,
    ["CHudDamageIndicator"] = true,
    ["CHudGeiger"] = true,
    ["CHudHealth"] = true,
    ["CHudHistoryResource"] = true,
    ["CHudPoisonDamageIndicator"] = true,
    ["CHudSecondaryAmmo"] = true,
    ["CHudSquadStatus"] = true,
    ["CHudSuitPower"] = true,
    ["CHudTrain"] = true,
    ["CHudVehicle"] = true,
    ["CHudCrosshair"] = true,
}

function GM:HUDShouldDraw(name)
    if ( elements[name] ) then
        return false
    end

    return true
end

function GM:LoadFonts()
    surface.CreateFont("ow.fonts.default", {
        font = "Arial",
        size = ScreenScale(6),
        weight = 500
    })

    surface.CreateFont("ow.fonts.default.bold", {
        font = "Arial",
        size = ScreenScale(6),
        weight = 700
    })

    surface.CreateFont("ow.fonts.default.italic", {
        font = "Arial",
        size = ScreenScale(6),
        weight = 500,
        italic = true
    })

    surface.CreateFont("ow.fonts.default.large", {
        font = "Arial",
        size = ScreenScale(10),
        weight = 500
    })

    surface.CreateFont("ow.fonts.default.large.bold", {
        font = "Arial",
        size = ScreenScale(10),
        weight = 700
    })

    surface.CreateFont("ow.fonts.default.extralarge", {
        font = "Arial",
        size = ScreenScale(12),
        weight = 500
    })

    surface.CreateFont("ow.fonts.default.extralarge.bold", {
        font = "Arial",
        size = ScreenScale(12),
        weight = 700
    })

    surface.CreateFont("ow.fonts.button", {
        font = "Roboto",
        size = ScreenScale(8),
        weight = 800
    })

    surface.CreateFont("ow.fonts.fancy", {
        font = "K12HL2",
        size = ScreenScale(8)
    })

    surface.CreateFont("ow.fonts.fancy.small", {
        font = "K12HL2",
        size = ScreenScale(6)
    })

    surface.CreateFont("ow.fonts.fancy.large", {
        font = "K12HL2",
        size = ScreenScale(10)
    })

    surface.CreateFont("ow.fonts.fancy.extralarge", {
        font = "K12HL2",
        size = ScreenScale(12)
    })

    surface.CreateFont("ow.fonts.title", {
        font = "K12HL2",
        size = ScreenScale(24)
    })

    surface.CreateFont("ow.fonts.subtitle", {
        font = "K12HL2",
        size = ScreenScale(16)
    })

    hook.Run("PostLoadFonts")
end

function GM:OnPauseMenuShow()
    if ( !IsValid(ow.gui.mainmenu) ) then
        vgui.Create("ow.mainmenu")
    else
        ow.gui.mainmenu:Remove()
        return
    end

    return false
end

function GM:ShouldDrawCrosshair()
    if ( IsValid(ow.gui.mainmenu) ) then return false end

    return true
end

function GM:ShouldDrawAmmoBox()
    if ( IsValid(ow.gui.mainmenu) ) then return false end

    return true
end

function GM:ShouldDrawDebugHUD()
    if ( !ow.convars:Get("ow_debug"):GetBool() ) then return false end
    if ( IsValid(ow.gui.mainmenu) ) then return false end

    return true
end

function GM:ShouldDrawVignette()
    if ( IsValid(ow.gui.mainmenu) ) then return false end

    return true
end