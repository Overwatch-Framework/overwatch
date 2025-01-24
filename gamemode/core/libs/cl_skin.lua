local SKIN = {}

SKIN.PrintName = "Overwatch"
SKIN.Author = "Riggs"

SKIN.fontFrame = "DermaDefault"
SKIN.fontTab = "DermaDefault"
SKIN.fontButton = "DermaDefault"

SKIN.Colours = table.Copy(derma.SkinList.Default.Colours)
SKIN.Colours.Window.TitleActive = color_white
SKIN.Colours.Window.TitleInactive = color_white

SKIN.Colours.Button.Normal = color_white
SKIN.Colours.Button.Hover = color_white
SKIN.Colours.Button.Down = color_white
SKIN.Colours.Button.Disabled = Color(0, 0, 0, 100)

SKIN.Colours.Label.Highlight = Color(90, 200, 250, 255)

function SKIN:PaintFrame(panel, width, height)
    ow.util.DrawBlur(panel)

    draw.RoundedBox(0, 0, 0, width, height, Color(50, 50, 50, 150))
    draw.RoundedBox(0, 0, 0, width, 24, Color(100, 100, 100, 150))
end

function SKIN:PaintButton(panel, width, height)
    local color = Color(100, 100, 100, 150)
    if ( panel:GetDisabled() ) then
        color = Color(50, 50, 50, 150)
    elseif ( panel.Depressed or panel:IsSelected() ) then
        color =  Color(100, 100, 100, 200)
    elseif ( panel.Hovered ) then
        color = Color(100, 100, 100, 200)
    end

    if ( !panel.owLerpColor ) then
        panel.owLerpColor = color
    end

    panel.owLerpColor = panel.owLerpColor:Lerp(color, FrameTime() * 10)

    draw.RoundedBox(0, 0, 0, width, height, panel.owLerpColor)
end

function SKIN:PaintWindowMinimizeButton(panel, width, height)
end

function SKIN:PaintWindowMaximizeButton(panel, width, height)
end

function SKIN:PaintComboBox(panel, width, height)
    local color = Color(100, 100, 100, 150)
    if ( panel:GetDisabled() ) then
        color = Color(50, 50, 50, 150)
    elseif ( panel.Depressed or panel:IsSelected() ) then
        color =  Color(100, 100, 100, 200)
    elseif ( panel.Hovered ) then
        color = Color(100, 100, 100, 200)
    end

    if ( !panel.owLerpColor ) then
        panel.owLerpColor = color
    end

    panel.owLerpColor = panel.owLerpColor:Lerp(color, FrameTime() * 10)

    draw.RoundedBox(0, 0, 0, width, height, panel.owLerpColor)
end


function SKIN:PaintMenu(panel, width, height)
    draw.RoundedBox(0, 0, 0, width, height, Color(50, 50, 50, 150))
end

function SKIN:PaintMenuOption(panel, width, height)
    local color = Color(100, 100, 100, 150)
    if ( panel:GetDisabled() ) then
        color = Color(50, 50, 50, 150)
    elseif ( panel.Depressed or panel:IsSelected() ) then
        color =  Color(100, 100, 100, 200)
    elseif ( panel.Hovered ) then
        color = Color(100, 100, 100, 200)
    end

    if ( !panel.owLerpColor ) then
        panel.owLerpColor = color
    end

    panel.owLerpColor = panel.owLerpColor:Lerp(color, FrameTime() * 10)

    draw.RoundedBox(0, 0, 0, width, height, panel.owLerpColor)
end

derma.DefineSkin("Overwatch", "Overwatch", SKIN)