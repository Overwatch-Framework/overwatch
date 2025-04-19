DEFINE_BASECLASS("DLabel")

local PANEL = {}

function PANEL:Init()
    self:SetFont("ow.fonts.default")
    self:SetTextColor(color_white)
    self:SetExpensiveShadow(1, color_black)
end

function PANEL:SizeToContents()
    BaseClass.SizeToContents(self)

    local width, height = self:GetSize()
    self:SetSize(width + 8, height + 4)
end

vgui.Register("ow.text", PANEL, "DLabel")