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

function GM:HUDPaint()
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
        size = 16,
        weight = 500
    })

    surface.CreateFont("ow.fonts.default.bold", {
        font = "Arial",
        size = 16,
        weight = 700
    })

    surface.CreateFont("ow.fonts.default.italic", {
        font = "Arial",
        size = 16,
        weight = 500,
        italic = true
    })

    surface.CreateFont("ow.fonts.default.large", {
        font = "Arial",
        size = 24,
        weight = 500
    })

    surface.CreateFont("ow.fonts.default.large.bold", {
        font = "Arial",
        size = 24,
        weight = 700
    })

    surface.CreateFont("ow.fonts.default.extralarge", {
        font = "Arial",
        size = 32,
        weight = 500
    })

    surface.CreateFont("ow.fonts.default.extralarge.bold", {
        font = "Arial",
        size = 32,
        weight = 700
    })

    hook.Run("PostCreateFonts")
end