--- Chat library
-- @module ow.chat

ow.chat = ow.chat or {}
ow.chat.messages = ow.chat.messages or {}

local nativeAddText = chat.AddText

function chat.AddText(...)
    if ( !IsValid(ow.gui.chatbox) ) then
        nativeAddText(...)
        return
    end

    local args = {...}
    local currentColor = color_white
    local font = "ow.fonts.small"
    local maxWidth = ow.gui.chatbox:GetWide() - 20

    local textParts = ""
    for _, v in ipairs(args) do
        if ( IsColor(v) ) then
            currentColor = v
        elseif ( IsValid(v) and v:IsPlayer() ) then
            local c = team.GetColor(v:Team())
            textParts = textParts .. string.format("<color=%d %d %d>%s</color>", c.r, c.g, c.b, v:Nick())
        else
            local c = currentColor
            textParts = textParts .. string.format("<color=%d %d %d>%s</color>", c.r, c.g, c.b, tostring(v))
        end
    end

    local wrappedLines = ow.util:WrapText(textParts, font, maxWidth)
    for _, line in ipairs(wrappedLines) do
        local rich = markup.Parse("<font=" .. font .. ">" .. line .. "</font>", maxWidth)

        local panel = ow.gui.chatbox.history:Add("DPanel")
        panel:SetTall(rich:GetHeight())
        panel:Dock(TOP)
        panel:DockMargin(0, 0, 0, 2)

        panel.alpha = 1
        panel.created = CurTime()

        panel.Paint = function(s, w, h)
            surface.SetAlphaMultiplier(s.alpha)
            rich:Draw(0, 0)
            surface.SetAlphaMultiplier(1)
        end

        panel.Think = function(s)
            if ( !ow.gui.chatbox:IsVisible() ) then
                local dt = CurTime() - s.created
                if ( dt >= 8 ) then
                    s.alpha = math.max(0, 1 - (dt - 8) / 4)
                end
            else
                s.alpha = 1
            end
        end

        table.insert(ow.chat.messages, panel)
    end

    ow.gui.chatbox.history:InvalidateLayout(true)
    ow.gui.chatbox.history:ScrollToChild(ow.gui.chatbox.history:GetChildren()[#ow.gui.chatbox.history:GetChildren()])
end