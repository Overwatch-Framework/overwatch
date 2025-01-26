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

function GM:PostSchemaLoad()
    -- Do something here
end

function GM:CalcView(ply, pos, angles, fov)
    if ( IsValid(ow.gui.mainmenu) and ow.config.menuCamPos and ow.config.menuCamAng ) then
        return {
            origin = ow.config.menuCamPos,
            angles = ow.config.menuCamAng,
            fov = ow.config.menuCamFov or 90,
            drawviewer = true
        }
    end
end

function GM:HUDPaint()
    if ( ow.debugMode:GetBool() ) then
        local scrW, scrH = ScrW(), ScrH()
        draw.SimpleText(self.Name:upper(), "ow.fonts.fancy.large", 16, scrH / 2 + 8, hook.Run("GetFrameworkColor"), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        draw.SimpleText("debug mode enabled", "ow.fonts.fancy", 32, scrH / 2 - 6, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        if ( SCHEMA ) then
            draw.SimpleText(SCHEMA.Name:upper(), "ow.fonts.fancy.small", 48, scrH / 2 + 48, hook.Run("GetSchemaColor"), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        end
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
    ["CHudVehicle"] = true
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