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

    if ( !IsValid(ow.gui.chatbox) ) then
        vgui.Create("ow.chatbox")
    end
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

local vignette = ow.util:GetMaterial("overwatch/gui/overlay_vignette.png", "noclamp smooth")
local vignetteColor = Color(0, 0, 0, 255)
function GM:HUDPaintBackground()
    if ( tobool(hook.Run("ShouldDrawVignette")) ) then
        hook.Run("DrawVignette")
    end
end

function GM:DrawVignette()
    local ply = ow.localClient
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
local staminaLerp = 0
local staminaAlpha = 0
local staminaTime = 0
local staminaLast = ow.stamina:GetFraction()
function GM:HUDPaint()
    local ply = ow.localClient
    if ( !IsValid(ply) ) then return end

    local x, y = 24, 24
    local scrW, scrH = ScrW(), ScrH()
    local shouldDraw = hook.Run("ShouldDrawDebugHUD")
    if ( shouldDraw != false ) then
        local green = ow.config:Get("color.framework")
        local width = math.max(ow.util:GetTextWidth("ow.fonts.developer", "Pos: " .. tostring(ply:GetPos())), ow.util:GetTextWidth("ow.fonts.developer", "Ang: " .. tostring(ply:EyeAngles())))
        local height = 16 * 6

        local character = ply:GetCharacter()
        if ( character ) then
            height = height + 16 * 6
        end

        ow.util:DrawBlurRect(x - padding, y - padding, width + padding * 2, height + padding * 2)

        surface.SetDrawColor(backgroundColor)
        surface.DrawRect(x - padding, y - padding, width + padding * 2, height + padding * 2)

        draw.SimpleText("[DEVELOPER HUD]", "ow.fonts.developer", x, y, green, TEXT_ALIGN_LEFT)

        draw.SimpleText("Pos: " .. tostring(ply:GetPos()), "ow.fonts.developer", x, y + 16 * 1, green, TEXT_ALIGN_LEFT)
        draw.SimpleText("Ang: " .. tostring(ply:EyeAngles()), "ow.fonts.developer", x, y + 16 * 2, green, TEXT_ALIGN_LEFT)
        draw.SimpleText("Health: " .. ply:Health(), "ow.fonts.developer", x, y + 16 * 3, green, TEXT_ALIGN_LEFT)
        draw.SimpleText("Ping: " .. ply:Ping(), "ow.fonts.developer", x, y + 16 * 4, green, TEXT_ALIGN_LEFT)

        local fps = math.floor(1 / FrameTime())
        draw.SimpleText("FPS: " .. fps, "ow.fonts.developer", x, y + 16 * 5, green, TEXT_ALIGN_LEFT)

        if ( character ) then
            local name = character:GetName()
            local charModel = character:GetModel()
            local inventories = ow.inventory:GetByCharacterID(character:GetID()) or {}
            for k, v in pairs(inventories) do
                inventories[k] = tostring(v)
            end
            local inventoryText = "Inventories: " .. table.concat(inventories, ", ")

            draw.SimpleText("[CHARACTER INFO]", "ow.fonts.developer", x, y + 16 * 7, green, TEXT_ALIGN_LEFT)
            draw.SimpleText("Character: " .. tostring(character), "ow.fonts.developer", x, y + 16 * 8, green, TEXT_ALIGN_LEFT)
            draw.SimpleText("Name: " .. name, "ow.fonts.developer", x, y + 16 * 9, green, TEXT_ALIGN_LEFT)
            draw.SimpleText("Model: " .. charModel, "ow.fonts.developer", x, y + 16 * 10, green, TEXT_ALIGN_LEFT)
            draw.SimpleText(inventoryText, "ow.fonts.developer", x, y + 16 * 11, green, TEXT_ALIGN_LEFT)
        end
    end

    shouldDraw = hook.Run("ShouldDrawPreviewHUD")
    if ( shouldDraw != false ) then
        local orange = ow.color:Get("orange")
        local red = ow.color:Get("red")

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

        draw.SimpleTextOutlined(ammoText, "ow.fonts.bold", scrW - 16, scrH - 16, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, color_black)
    end

    shouldDraw = hook.Run("ShouldDrawStamina")
    if ( shouldDraw != nil and shouldDraw != false ) then
        local staminaFraction = ow.stamina:GetFraction()
        staminaLerp = Lerp(FrameTime() * 5, staminaLerp, staminaFraction)

        if ( staminaLast != staminaFraction ) then
            staminaTime = CurTime() + 5
            staminaLast = staminaFraction
        elseif ( staminaTime < CurTime() ) then
            staminaAlpha = Lerp(FrameTime() * 5, staminaAlpha, 0)
        elseif ( staminaAlpha < 255 ) then
            staminaAlpha = Lerp(FrameTime() * 5, staminaAlpha, 255)
        end

        if ( staminaAlpha > 0 ) then
            local barWidth, barHeight = scrW / 3, ScreenScale(10)
            local barX, barY = scrW / 2 - barWidth / 2, scrH / 1.25 - barHeight / 2

            ow.util:DrawBlurRect(barX, barY, barWidth, barHeight, 2, nil, staminaAlpha)

            surface.SetDrawColor(ColorAlpha(ow.color:Get("background.transparent"), staminaAlpha / 2))
            surface.DrawRect(barX, barY, barWidth, barHeight)

            surface.SetDrawColor(ColorAlpha(ow.color:Get("white"), staminaAlpha))
            surface.DrawRect(barX, barY, barWidth * staminaLerp, barHeight)
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
    local scale4 = ScreenScale(4)
    local scale6 = ScreenScale(6)
    local scale8 = ScreenScale(8)
    local scale10 = ScreenScale(10)
    local scale12 = ScreenScale(12)
    local scale16 = ScreenScale(16)
    local scale20 = ScreenScale(20)
    local scale24 = ScreenScale(24)

    surface.CreateFont("ow.fonts.tiny", {
        font = "GorDIN Regular",
        size = scale4,
        weight = 500,
        antialias = true
    })

    surface.CreateFont("ow.fonts.tiny.bold", {
        font = "GorDIN Bold",
        size = scale4,
        weight = 700,
        antialias = true
    })

    surface.CreateFont("ow.fonts.small", {
        font = "GorDIN Regular",
        size = scale6,
        weight = 500,
        antialias = true
    })

    surface.CreateFont("ow.fonts.small.bold", {
        font = "GorDIN Bold",
        size = scale6,
        weight = 700,
        antialias = true
    })

    surface.CreateFont("ow.fonts", {
        font = "GorDIN Regular",
        size = scale8,
        weight = 500,
        antialias = true
    })

    surface.CreateFont("ow.fonts.bold", {
        font = "GorDIN Bold",
        size = scale8,
        weight = 700,
        antialias = true
    })

    surface.CreateFont("ow.fonts.italic", {
        font = "GorDIN Regular",
        size = ScreenScale(8),
        weight = 500,
        italic = true,
        antialias = true
    })

    surface.CreateFont("ow.fonts.italic.bold", {
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
        size = scale12,
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

    surface.CreateFont("ow.fonts.button.tiny", {
        font = "GorDIN SemiBold",
        size = scale10,
        weight = 600,
        antialias = true
    })

    surface.CreateFont("ow.fonts.button.tiny.hover", {
        font = "GorDIN Bold",
        size = scale10,
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

    if ( IsValid(ow.gui.chatbox) and ow.gui.chatbox:GetAlpha() == 255 ) then
        ow.gui.chatbox:SetVisible(false)
        return false
    end

    if ( !IsValid(ow.gui.mainmenu) ) then
        vgui.Create("ow.mainmenu")
    else
        if ( ow.localClient:GetCharacter() ) then
            ow.gui.mainmenu:Remove()
            return
        end
    end

    return false
end

function GM:ShouldDrawCrosshair()
    if ( IsValid(ow.gui.mainmenu) ) then return false end
    if ( IsValid(ow.gui.tab) ) then return false end

    return true
end

function GM:ShouldDrawAmmoBox()
    if ( IsValid(ow.gui.mainmenu) ) then return false end
    if ( IsValid(ow.gui.tab) ) then return false end

    return true
end

function GM:ShouldDrawStamina()
    if ( IsValid(ow.gui.mainmenu) ) then return false end
    if ( IsValid(ow.gui.tab) ) then return false end

    return true
end

function GM:ShouldDrawDebugHUD()
    if ( !ow.convars:Get("ow_debug"):GetBool() ) then return false end
    if ( IsValid(ow.gui.mainmenu) ) then return false end
    if ( IsValid(ow.gui.tab) ) then return false end

    return ow.localClient:IsAdmin()
end

function GM:ShouldDrawPreviewHUD()
    if ( !ow.convars:Get("ow_preview"):GetBool() ) then return false end
    if ( IsValid(ow.gui.mainmenu) ) then return false end
    if ( IsValid(ow.gui.tab) ) then return false end

    return !hook.Run("ShouldDrawDebugHUD")
end

function GM:ShouldDrawVignette()
    if ( IsValid(ow.gui.mainmenu) ) then return false end
    if ( !ow.option:Get("vignette", true) ) then return false end

    return true
end

function GM:ShouldShowInventory()
    return true
end

function GM:GetCharacterName(ply, target)
    -- TODO: Empty hook, implement this in the future
end

function GM:PopulateTabButtons(buttons)
    if ( CAMI.PlayerHasAccess(ow.localClient, "Overwatch - Manage Config", nil) ) then
        buttons["tab.config"] = {
            Populate = function(this, container)
                container:Add("ow.tab.config")
            end
        }
    end

    buttons["tab.help"] = {
        Populate = function(this, container)
            container:Add("ow.tab.help")
        end
    }

    if ( hook.Run("ShouldShowInventory") != false ) then
        buttons["tab.inventory"] = {
            Populate = function(this, container)
                container:Add("ow.tab.inventory")
            end
        }
    end

    buttons["tab.inventory"] = {
        Populate = function(this, container)
            container:Add("ow.tab.inventory")
        end
    }

    buttons["tab.scoreboard"] = {
        Populate = function(this, container)
            container:Add("ow.tab.scoreboard")
        end
    }

    buttons["tab.settings"] = {
        Populate = function(this, container)
            container:Add("ow.tab.settings")
        end
    }
end

function GM:PopulateHelpCategories(categories)
    categories["flags"] = function(container)
        for k, v in SortedPairs(ow.flag.stored) do
            local char = ow.localClient:GetCharacter()
            if ( !char ) then return end

            local hasFlag = char:HasFlag(k)

            local button = container:Add("ow.button.small")
            button:Dock(TOP)
            button:SetText("")
            button:SetBackgroundAlphaHovered(1)
            button:SetBackgroundAlphaUnHovered(0.5)
            button:SetBackgroundColor(hasFlag and ow.color:Get("success") or ow.color:Get("error"))

            local key = button:Add("ow.text")
            key:Dock(LEFT)
            key:DockMargin(ScreenScale(8), 0, 0, 0)
            key:SetFont("ow.fonts.button.hover")
            key:SetText(k)

            local seperator = button:Add("ow.text")
            seperator:Dock(LEFT)
            seperator:SetFont("ow.fonts.button")
            seperator:SetText(" - ")

            local description = button:Add("ow.text")
            description:Dock(LEFT)
            description:SetFont("ow.fonts.button")
            description:SetText(v.description)

            local function Think(this)
                this:SetTextColor(button:GetTextColor())
            end

            key.Think = Think
            seperator.Think = Think
            description.Think = Think
        end
    end
end

-- Idk if this is good
local suggestionIndex = 1
local lastText = ""
local lastSuggestions = {}

function GM:OnChatTab(text)
    if ( !text:StartWith("/") ) then return end

    local split = string.Explode(" ", text)
    local cmd = string.sub(split[1], 2)
    local command = ow.command.stored[cmd]

    if ( command and command.AutoComplete ) then
        if ( text != lastText ) then
            lastSuggestions = command.AutoComplete(ow.localClient, split) or {}
            suggestionIndex = 1
        else
            suggestionIndex = ( suggestionIndex % #lastSuggestions ) + 1
        end

        lastText = text

        return lastSuggestions[suggestionIndex]
    end
end

function GM:GetChatboxSize()
    local width = ScrW() * 0.4
    local height = ScrH() * 0.35

    return width, height
end

function GM:GetChatboxPos()
    local _, height = self:GetChatboxSize()
    local x = ScrW() * 0.0125
    local y = ScrH() * 0.025
    y = ScrH() - height - y

    return x, y
end

function GM:PlayerBindPress(ply, bind, pressed)
    bind = bind:lower()

    if ( bind:find("messagemode") and pressed ) then
        ow.gui.chatbox:SetVisible(true)

        for _, pnl in ipairs(ow.chat.messages) do
            if ( IsValid(pnl) ) then
                pnl.alpha = 1
            end
        end

        return true
    end
end

function GM:StartChat()
end

function GM:FinishChat()
end

function GM:OnPlayerChat(ply, text, team, dead)
    if ( !IsValid(ow.gui.chatbox) ) then return end

    local prefix = IsValid(ply) and ply:Nick() .. ": " or ""
    local msg = prefix .. text

    ow.gui.chatbox:AddLine(msg, team and Color(150, 200, 255) or color_white)
end

function GM:ForceDermaSkin()
    return "Overwatch"
end