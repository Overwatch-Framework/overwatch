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
        local mainmenuPos = ow.config:Get("mainmenu.pos", vector_origin)
        local mainmenuAng = ow.config:Get("mainmenu.ang", angle_zero)
        local mainmenuFov = ow.config:Get("mainmenu.fov", 90)

        return {
            origin = mainmenuPos,
            angles = mainmenuAng,
            fov = mainmenuFov,
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

local padding = 16
local backgroundColor = Color(10, 10, 10, 220)
function GM:HUDPaint()
    local ply = LocalPlayer()
    if ( !IsValid(ply) ) then return end

    local x, y = 24, 24
    local shouldDraw = hook.Run("ShouldDrawDebugHUD")
    if ( shouldDraw != false ) then
        local green = ow.colour:Get("green")
        local width = math.max(ow.util:GetTextWidth("ow.fonts.developer", "Pos: " .. tostring(ply:GetPos())), ow.util:GetTextWidth("ow.fonts.developer", "Ang: " .. tostring(ply:EyeAngles())))

        ow.util:DrawBlurRect(x - padding, y - padding, width + padding * 2, 95 + padding * 2)

        surface.SetDrawColor(backgroundColor)
        surface.DrawRect(x - padding, y - padding, width + padding * 2, 95 + padding * 2)

        draw.SimpleText("[DEVELOPER HUD]", "ow.fonts.developer", x, y, green, TEXT_ALIGN_LEFT)

        draw.SimpleText("Pos: " .. tostring(ply:GetPos()), "ow.fonts.developer", x, y + 16 * 1, green, TEXT_ALIGN_LEFT)
        draw.SimpleText("Ang: " .. tostring(ply:EyeAngles()), "ow.fonts.developer", x, y + 16 * 2, green, TEXT_ALIGN_LEFT)
        draw.SimpleText("Health: " .. ply:Health(), "ow.fonts.developer", x, y + 16 * 3, green, TEXT_ALIGN_LEFT)
        draw.SimpleText("Ping: " .. ply:Ping(), "ow.fonts.developer", x, y + 16 * 4, green, TEXT_ALIGN_LEFT)

        local fps = math.floor(1 / FrameTime())
        draw.SimpleText("FPS: " .. fps, "ow.fonts.developer", x, y + 16 * 5, green, TEXT_ALIGN_LEFT)
    end

    shouldDraw = hook.Run("ShouldDrawPreviewHUD")
    if ( shouldDraw != false ) then
        local orange = ow.colour:Get("orange")
        local red = ow.colour:Get("red")

        ow.util:DrawBlurRect(x - padding, y - padding, 410 + padding * 2, 45 + padding * 2)

        surface.SetDrawColor(backgroundColor)
        surface.DrawRect(x - padding, y - padding, 410 + padding * 2, 45 + padding * 2)

        draw.SimpleText("[PREVIEW MODE]", "ow.fonts.developer", x, y, orange, TEXT_ALIGN_LEFT)
        draw.SimpleText("Warning! Anything you witness is subject to change.", "ow.fonts.developer", x, y + 16, red, TEXT_ALIGN_LEFT)
        draw.SimpleText("This is not the final product.", "ow.fonts.developer", x, y + 16 * 2, red, TEXT_ALIGN_LEFT)
    end

    shouldDraw = hook.Run("ShouldDrawCrosshair")
    if ( shouldDraw != false ) then
        x, y = ScrW() / 2, ScrH() / 2
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
    local scale8 = ScreenScale(8)
    local scale10 = ScreenScale(10)
    local scale12 = ScreenScale(12)
    local scale16 = ScreenScale(16)
    local scale20 = ScreenScale(20)
    local scale24 = ScreenScale(24)

    surface.CreateFont("ow.fonts.default", {
        font = "GorDIN Regular",
        size = ScreenScale(8),
        weight = 500,
        antialias = true
    })

    surface.CreateFont("ow.fonts.default.bold", {
        font = "GorDIN Bold",
        size = scale8,
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
        size = scale8,
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
        size = scale10,
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
        size = scale10,
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
        size = scale12,
        weight = 700,
        antialias = true
    })

    surface.CreateFont("ow.fonts.extralarge.italic", {
        font = "GorDIN",
        size = scale12,
        weight = 500,
        italic = true,
        antialias = true
    })

    surface.CreateFont("ow.fonts.extralarge.italic.bold", {
        font = "GorDIN Bold",
        size = scale12,
        weight = 700,
        italic = true,
        antialias = true
    })

    surface.CreateFont("ow.fonts.button.large", {
        font = "GorDIN SemiBold",
        size = scale20,
        weight = 600,
        antialias = true
    })

    surface.CreateFont("ow.fonts.button.large.hover", {
        font = "GorDIN Bold",
        size = scale20,
        weight = 700,
        antialias = true
    })

    surface.CreateFont("ow.fonts.button", {
        font = "GorDIN SemiBold",
        size = scale16,
        weight = 600,
        antialias = true
    })

    surface.CreateFont("ow.fonts.button.hover", {
        font = "GorDIN Bold",
        size = scale16,
        weight = 700,
        antialias = true
    })

    surface.CreateFont("ow.fonts.button.small", {
        font = "GorDIN SemiBold",
        size = scale12,
        weight = 600,
        antialias = true
    })

    surface.CreateFont("ow.fonts.button.small.hover", {
        font = "GorDIN Bold",
        size = scale12,
        weight = 700,
        antialias = true
    })

    surface.CreateFont("ow.fonts.title", {
        font = "GorDIN Bold",
        size = scale24,
        weight = 700,
        antialias = true,
    })

    surface.CreateFont("ow.fonts.subtitle", {
        font = "GorDIN SemiBold",
        size = scale16,
        weight = 600,
        antialias = true,
    })

    surface.CreateFont("ow.fonts.developer", {
        font = "Courier New",
        size = 16,
        weight = 500,
        antialias = true
    })

    hook.Run("PostLoadFonts")
end

function GM:OnPauseMenuShow()
    if ( IsValid(ow.gui.tab) ) then
        ow.gui.tab:Close()
        return false
    end

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

    return ow.localClient:IsAdmin()
end

function GM:ShouldDrawPreviewHUD()
    if ( !ow.convars:Get("ow_preview"):GetBool() ) then return false end
    if ( IsValid(ow.gui.mainmenu) ) then return false end

    return !ow.localClient:IsAdmin()
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
            container:Add("ow.tab.inventory")
        end
    }
    buttons["tab.scoreboard"] = {
        Populate = function(container)
            container:Add("ow.tab.scoreboard")
        end
    }
    buttons["tab.settings"] = {
        Populate = function(container)
            container:Add("ow.tab.settings")
        end
    }
end

-- TODO: Maybe if it looks good someday
--[[
function GM:ForceDermaSkin()
    return "Overwatch"
end
]]
