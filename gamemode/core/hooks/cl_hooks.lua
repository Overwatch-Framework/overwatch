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
        draw.SimpleText(self.Name .. " - " .. self.Version, "ow.fonts.default.large", 10, 5, ow.config.color)
        draw.SimpleText("DEBUG MODE ENABLED", "ow.fonts.default.italic", 10, 35, color_white)
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
        size = ScreenScale(8),
        weight = 500
    })

    surface.CreateFont("ow.fonts.default.bold", {
        font = "Arial",
        size = ScreenScale(8),
        weight = 700
    })

    surface.CreateFont("ow.fonts.default.italic", {
        font = "Arial",
        size = ScreenScale(8),
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