ow.notification = ow.notification or {}
ow.notification.stored = ow.notification.stored or {}

-- Configuration
local PANEL_WIDTH = ScrW() / 2.5
local PANEL_MARGIN = 8
local PANEL_SPACING = 4
local INTERP_SPEED = 8
local FONT_NAME = "ow.fonts.bold"

-- Utility function to create a notification
function ow.notification:Add(text, duration, bgColor)
    duration = duration or 3
    -- bgColor = bgColor or ow.color:Get("notification.backgroun", color_white) -- TODO: What is this?
    bgColor.a = 200

    -- Create panel
    local panel = vgui.Create("DPanel")
    panel:SetWide(PANEL_WIDTH)
    panel:SetDrawOnTop(true)

    -- Prepare wrapped lines
    local maxTextWidth = PANEL_WIDTH - PANEL_MARGIN * 2
    local lines = ow.util:WrapText(text, FONT_NAME, maxTextWidth)
    surface.SetFont(FONT_NAME)
    local _, lineHeight = surface.GetTextSize("Ay")
    local totalHeight = #lines * lineHeight + PANEL_MARGIN * 2
    panel:SetTall(totalHeight)

    -- Paint background and text
    panel.Paint = function(this, width, height)
        surface.SetDrawColor(bgColor)
        surface.DrawRect(0, 0, width, height)

        -- draw each line
        for i, line in ipairs(lines) do
            draw.SimpleText(
                line,
                FONT_NAME,
                PANEL_MARGIN,
                PANEL_MARGIN + (i - 1) * lineHeight,
                color_white,
                TEXT_ALIGN_LEFT,
                TEXT_ALIGN_TOP
            )
        end
    end

    -- Initial position off-screen
    local scrW, _ = ScrW(), ScrH()
    panel.CurrentX = (scrW - PANEL_WIDTH) / 2
    panel.CurrentY = -panel:GetTall()
    panel.TargetX = panel.CurrentX
    panel.TargetY = panel.CurrentY
    panel:SetPos(panel.CurrentX, panel.CurrentY)

    -- Think hook for interpolation
    panel.Think = function(this)
        this.CurrentX = Lerp(FrameTime() * INTERP_SPEED, this.CurrentX, this.TargetX)
        this.CurrentY = Lerp(FrameTime() * INTERP_SPEED, this.CurrentY, this.TargetY)
        this:SetPos(this.CurrentX, this.CurrentY)
    end

    -- Insert at beginning
    table.insert(self.stored, 1, panel)

    -- Animate all notifications to new positions
    self:RepositionAll()

    -- Fade in
    panel:SetAlpha(0)
    panel:AlphaTo(255, 0.2, 0)

    -- Remove after duration
    timer.Simple(duration, function()
        if ( IsValid(panel) ) then
            panel:AlphaTo(0, 0.2, 0, function() panel:Remove() end)
            -- Remove and reposition
            timer.Simple(0.35, function()
                for i, v in ipairs(self.stored) do
                    if v == panel then
                        table.remove(self.stored, i)
                        break
                    end
                end
                self:RepositionAll()
            end)
        end
    end)
end

-- Reposition notifications using Lerp targets
function ow.notification:RepositionAll()
    local scrW = ScrW()
    for i, panel in ipairs(self.stored) do
        if ( IsValid(panel) ) then
            panel.TargetX = (scrW - PANEL_WIDTH) / 2
            panel.TargetY = PANEL_SPACING + (i - 1) * (panel:GetTall() + PANEL_SPACING)
        end
    end
end

notification.AddLegacy = function(text, type, length)
    local color
    if ( type == NOTIFY_ERROR ) then
        color = ow.color:Get("error")
        ow.localClient:EmitSound("ow.notification.error")
    elseif ( type == NOTIFY_HINT ) then
        color = ow.color:Get("success")
        ow.localClient:EmitSound("ow.notification.hint")
    else
        color = ow.color:Get("info")
        ow.localClient:EmitSound("ow.notification.generic")
    end

    ow.notification:Add(text, length or 3, color)
end

concommand.Add("test_notification", function(client, cmd, args)
    local text = table.concat(args, " ")
    ow.notification:Add(text, 5)
end)

sound.Add({
    name = "ow.notification.error",
    channel = CHAN_STATIC,
    volume = 1.0,
    level = 80,
    sound = "overwatch/ui/error.wav"
})

sound.Add({
    name = "ow.notification.hint",
    channel = CHAN_STATIC,
    volume = 1.0,
    level = 80,
    sound = "overwatch/ui/hint.wav"
})

sound.Add({
    name = "ow.notification.generic",
    channel = CHAN_STATIC,
    volume = 1.0,
    level = 80,
    sound = "overwatch/ui/generic.wav"
})