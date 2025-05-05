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
    local font = "ow.fonts.chat"
    local maxWidth = ow.gui.chatbox:GetWide() - 20

    local markupStr = ""

    for _, v in ipairs(args) do
        if ( IsColor(v) ) then
            currentColor = v
        elseif ( istable(v) and v.r and v.g and v.b ) then
            currentColor = Color(v.r, v.g, v.b)
        elseif ( IsValid(v) and v:IsPlayer() ) then
            local c = team.GetColor(v:Team())
            markupStr = markupStr .. string.format("<color=%d %d %d>%s</color>", c.r, c.g, c.b, v:Nick())
        else
            markupStr = markupStr .. string.format(
                "<color=%d %d %d>%s</color>",
                currentColor.r, currentColor.g, currentColor.b, tostring(v)
            )
        end
    end

    local rich = markup.Parse("<font=" .. font .. ">" .. markupStr .. "</font>", maxWidth)

    local panel = ow.gui.chatbox.history:Add("EditablePanel")
    panel:SetTall(rich:GetHeight())
    panel:Dock(TOP)

    panel.alpha = 1
    panel.created = CurTime()

    function panel:SizeToContents()
        rich = markup.Parse("<font=" .. font .. ">" .. markupStr .. "</font>", maxWidth)
        self:SetTall(rich:GetHeight())
    end

    function panel:Paint(w, h)
        surface.SetAlphaMultiplier(self.alpha)
        rich:Draw(0, 0)
        surface.SetAlphaMultiplier(1)
    end

    function panel:Think()
        if ( ow.gui.chatbox:GetAlpha() != 255 ) then
            local dt = CurTime() - self.created
            if ( dt >= 8 ) then
                self.alpha = math.max(0, 1 - (dt - 8) / 4)
            end
        else
            self.alpha = 1
        end
    end

    table.insert(ow.chat.messages, panel)

    timer.Simple(0.1, function()
        if ( !IsValid(panel) ) then return end

        local scrollBar = ow.gui.chatbox.history:GetVBar()
        if ( scrollBar ) then
            scrollBar:AnimateTo(scrollBar.CanvasSize, 0.2, 0, 0.2)
        end
    end)
end