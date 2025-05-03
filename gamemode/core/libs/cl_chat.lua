--- Chat library
-- @module ow.chat

ow.chat = ow.chat or {}

local nativeAddText = chat.AddText

function chat.AddText(...)
    if ( !IsValid(ow.gui.chatbox) ) then
        nativeAddText(...)
        return
    end

    local args = {...}
    local currentColor = color_white
    local segments = {}

    -- Parse arguments into color-tagged text segments
    for _, v in ipairs(args) do
        if ( IsColor(v) ) then
            currentColor = v
        elseif ( IsValid(v) and v:IsPlayer() ) then
            table.insert(segments, {text = v:Nick(), color = team.GetColor(v:Team())})
        else
            table.insert(segments, {text = tostring(v), color = currentColor})
        end
    end

    -- Merge segments into wrapped lines
    local font = "ow.fonts.small"
    local maxWidth = ow.gui.chatbox:GetWide() - 20
    local buffer = ""
    local bufferColor = color_white
    local lineQueue = {}

    for i, seg in ipairs(segments) do
        local lines = ow.util:WrapText(seg.text, font, maxWidth)

        for k, wrapped in ipairs(lines) do
            if (k == 1) then
                buffer = buffer .. wrapped
                bufferColor = seg.color
            else
                table.insert(lineQueue, {text = buffer, color = bufferColor})
                buffer = wrapped
                bufferColor = seg.color
            end
        end
    end

    if (#buffer > 0) then
        table.insert(lineQueue, {text = buffer, color = bufferColor})
    end

    -- Display each wrapped line
    for _, line in ipairs(lineQueue) do
        local label = ow.gui.chatbox.history:Add("DLabel")
        label:SetFont(font)
        label:SetText(line.text)
        label:SetTextColor(line.color)
        label:SetWrap(true)
        label:SetAutoStretchVertical(true)
        label:Dock(TOP)
        label:DockMargin(0, 0, 0, 2)
        label:SetContentAlignment(7)
    end

    ow.gui.chatbox.history:InvalidateLayout(true)
    ow.gui.chatbox.history:ScrollToChild(ow.gui.chatbox.history:GetChildren()[#ow.gui.chatbox.history:GetChildren()])
end