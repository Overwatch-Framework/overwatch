local gradientLeft = Material("vgui/gradient-l")

DEFINE_BASECLASS("DTextEntry")

local PANEL = {}

function PANEL:Init()
    self:SetFont("ow.fonts.default")
    self:SetTextColor(color_white)
    self:SetExpensiveShadow(1, color_black)
    self:SetPaintBackground(false)
    self:SetUpdateOnType(true)
    self:SetCursorColor(color_white)
    self:SetHighlightColor(color_white)

    self:SetTall(ScreenScale(12))
end

function PANEL:SizeToContents()
    BaseClass.SizeToContents(self)

    local width, height = self:GetSize()
    self:SetSize(width + 8, height + 4)
end

local color = Color(0, 0, 0, 150)
function PANEL:Paint(width, height)
    paint.startPanel(self, true, true)
        paint.blur.requestBlur("default")
        paint.roundedBoxes.roundedBox(8, 0, 0, width, height, color)
    paint.endPanel(true, true)

    BaseClass.Paint(self, width, height)
end

vgui.Register("ow.text.entry", PANEL, "DTextEntry")