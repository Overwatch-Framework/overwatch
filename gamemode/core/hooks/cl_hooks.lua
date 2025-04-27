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

function GM:ScoreboardShow()
    if ( IsValid(ow.gui.mainmenu) ) then return false end

    if ( !IsValid(ow.gui.tab) ) then
        vgui.Create("ow.tab")
    else
        ow.gui.tab:Remove()
    end

    return false
end

function GM:ScoreboardHide()
    return false
end

function GM:Initialize()
    ow.schema:Initialize()

    hook.Run("LoadFonts")
end

function GM:InitPostEntity()
    ow.localClient = LocalPlayer()
    ow.option:Load()
end

function GM:OnCloseCaptionEmit()
    return true
end

function GM:PostSchemaLoad()
    -- TODO: Empty hook, MAYBE implement somthing in the future
end

local eyeTraceHullMin = Vector(-2, -2, -2)
local eyeTraceHullMax = Vector(2, 2, 2)
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
            mins = eyeTraceHullMin,
            maxs = eyeTraceHullMax
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
    if ( tobool(hook.Run("ShouldDrawVignette")) ) then
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

    local result = hook.Run("GetVignetteColor")
    if ( IsColor(result) ) then
        vignetteColor = result
    end

    paint.rects.drawRect(0, 0, scrW, scrH, vignetteColor, vignette)
end

local overWatchLogo = ow.util:GetMaterial("overwatch/gui/logo_white_x512.png", "noclamp smooth")
local previewColor = Color(255, 210, 80)
function GM:HUDPaint()
    local ply = LocalPlayer()
    if ( !IsValid(ply) ) then return end

    local shouldDraw = hook.Run("ShouldDrawDebugHUD")
    if ( shouldDraw != false ) then
        local scrW, scrH = ScrW(), ScrH()
        local width, height
        local logoWidth, logoHeight = overWatchLogo:Width() / 7, overWatchLogo:Height() / 7
        local x, y = scrW / 2 - logoWidth * 4, scrH - 100

        surface.SetDrawColor(hook.Run("GetFrameworkColor") or color_white)
        surface.SetMaterial(overWatchLogo)
        surface.DrawTexturedRect(x - logoWidth, y - 30, logoWidth, logoHeight)

        if ( SCHEMA ) then
            width, height = draw.SimpleText(SCHEMA.Name:upper(), "ow.fonts.large.bold", x, y, hook.Run("GetSchemaColor"), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            x, y = x + 16, y + height
        end

        shouldDraw = hook.Run("ShouldDrawPreviewHUD")
        if ( shouldDraw != false ) then
            width, height = draw.SimpleText("PREVIEW BUILD - ", "ow.fonts.default.bold", x, y, previewColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            x, y = x + width, y

            width = select(1, draw.SimpleText("The following gameplay can be subjected to change", "ow.fonts.default.bold", x, y, ow.colour:Get("light.gray"), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP))
            return
        end

        width, height = draw.SimpleText(Format("LATENCY: %s :: FPS: %s",  ply:Ping(), math.Round(1 / FrameTime())), "ow.fonts.default.bold", x, y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    if ( shouldDraw != nil and shouldDraw != false ) then
        local x, y = 100, 100

        local logoWidth, logoHeight = overWatchLogo:Width() / 7, overWatchLogo:Height() / 7
        surface.SetDrawColor(hook.Run("GetFrameworkColor") or color_white)
        surface.SetMaterial(overWatchLogo)
        surface.DrawTexturedRect(x - logoWidth, y - 30, logoWidth, logoHeight)

        draw.SimpleText("PREVIEW BUILD", "ow.fonts.button", x, y, previewColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    shouldDraw = hook.Run("ShouldDrawCrosshair")
    if ( shouldDraw != nil and shouldDraw != false ) then
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

    shouldDraw = hook.Run("ShouldDrawAmmoBox")
    if ( shouldDraw != nil and shouldDraw != false ) then
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
        font = "GorDIN Regular",
        size = ScreenScale(8),
        weight = 500,
        antialias = true
    })

    surface.CreateFont("ow.fonts.default.bold", {
        font = "GorDIN Bold",
        size = ScreenScale(8),
        weight = 700,
        antialias = true
    })

    surface.CreateFont("ow.fonts.default.italic", {
        font = "GorDIN Regular",
        size = ScreenScale(8),
        weight = 500,
        italic = true,
        antialias = true
    })

    surface.CreateFont("ow.fonts.default.italic.bold", {
        font = "GorDIN Bold",
        size = ScreenScale(8),
        weight = 700,
        italic = true,
        antialias = true
    })

    surface.CreateFont("ow.fonts.large", {
        font = "GorDIN Regular",
        size = ScreenScale(10),
        weight = 500,
        antialias = true
    })

    surface.CreateFont("ow.fonts.large.bold", {
        font = "GorDIN Bold",
        size = ScreenScale(10),
        weight = 700,
        antialias = true
    })

    surface.CreateFont("ow.fonts.large.italic", {
        font = "GorDIN Regular",
        size = ScreenScale(10),
        weight = 500,
        italic = true,
        antialias = true
    })

    surface.CreateFont("ow.fonts.large.italic.bold", {
        font = "GorDIN Bold",
        size = ScreenScale(10),
        weight = 700,
        italic = true,
        antialias = true
    })

    surface.CreateFont("ow.fonts.extralarge", {
        font = "GorDIN Regular",
        size = ScreenScale(12),
        weight = 500,
        antialias = true
    })

    surface.CreateFont("ow.fonts.extralarge.bold", {
        font = "GorDIN Bold",
        size = ScreenScale(12),
        weight = 700,
        antialias = true
    })

    surface.CreateFont("ow.fonts.extralarge.italic", {
        font = "GorDIN",
        size = ScreenScale(12),
        weight = 500,
        italic = true,
        antialias = true
    })

    surface.CreateFont("ow.fonts.extralarge.italic.bold", {
        font = "GorDIN Bold",
        size = ScreenScale(12),
        weight = 700,
        italic = true,
        antialias = true
    })

    surface.CreateFont("ow.fonts.button", {
        font = "GorDIN SemiBold",
        size = ScreenScale(16),
        weight = 600,
        antialias = true
    })

    surface.CreateFont("ow.fonts.button.hover", {
        font = "GorDIN Bold",
        size = ScreenScale(16),
        weight = 700,
        antialias = true
    })

    surface.CreateFont("ow.fonts.button.small", {
        font = "GorDIN SemiBold",
        size = ScreenScale(12),
        weight = 600,
        antialias = true
    })

    surface.CreateFont("ow.fonts.button.small.hover", {
        font = "GorDIN Bold",
        size = ScreenScale(12),
        weight = 700,
        antialias = true
    })

    surface.CreateFont("ow.fonts.title", {
        font = "GorDIN Bold",
        size = ScreenScale(24),
        weight = 700,
        antialias = true,
    })

    surface.CreateFont("ow.fonts.subtitle", {
        font = "GorDIN SemiBold",
        size = ScreenScale(16),
        weight = 600,
        antialias = true,
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

    return
end

function GM:ShouldDrawPreviewHUD()
    if ( !ow.convars:Get("ow_preview"):GetBool() ) then return false end
    if ( IsValid(ow.gui.mainmenu) ) then return false end

    return true
end

function GM:ShouldDrawVignette()
    if ( IsValid(ow.gui.mainmenu) ) then return false end
    if ( !ow.option:Get("vignette", true) ) then return false end

    return true
end

function GM:GetCharacterName(ply, target)
    -- TODO: Empty hook, implement this in the future
end

function GM:PopulateTabButtons(buttons)
    buttons["tab.config"] = {
        Populate = function(container)
            -- TODO: Implement this in the future
            -- container:Add("ow.tab.config")
        end
    }
    buttons["tab.inventory"] = {
        Populate = function(container)
            -- TODO: Implement this in the future
            -- container:Add("ow.tab.inventory")
        end
    }
    buttons["tab.scoreboard"] = {
        Populate = function(container)
            container:Add("ow.tab.scoreboard")
        end
    }
    buttons["tab.settings"] = {
        Populate = function(container)
            -- TODO: Implement this in the future
            -- container:Add("ow.tab.settings")
        end
    }
end