local padding = ScreenScale(32)
local smallPadding = ScreenScale(16)

DEFINE_BASECLASS("EditablePanel")

local PANEL = {}

function PANEL:Init()
    self:SetSize(self:GetWide(), self:GetTall())
    self:SetPos(0, 0)
end

function PANEL:Populate()
    self:SetGradientLeftTarget(0)
    self:SetGradientRightTarget(0)
    self:SetGradientTopTarget(1)
    self:SetGradientBottomTarget(1)
end

vgui.Register("ow.mainmenu.create", PANEL, "EditablePanel")