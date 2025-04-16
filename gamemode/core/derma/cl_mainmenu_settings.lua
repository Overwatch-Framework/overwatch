local padding = ScreenScale(32)
local smallPadding = ScreenScale(16)

DEFINE_BASECLASS("EditablePanel")

local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, 0)
    self:SetVisible(false)
end

function PANEL:Populate()
    local parent = self:GetParent()
    parent:SetGradientLeftTarget(0)
    parent:SetGradientRightTarget(0)
    parent:SetGradientTopTarget(1)
    parent:SetGradientBottomTarget(1)
    parent.container:Clear()
    parent.container:SetVisible(false)

    self:SetVisible(true)

    local title = self:Add("DLabel")
    title:Dock(TOP)
    title:DockMargin(padding, padding, padding, 0)
    title:SetFont("ow.fonts.title")
    title:SetText("SETTINGS")
    title:SetTextColor(hook.Run("GetFrameworkColor"))
    title:SetExpensiveShadow(4, color_black)
    title:SizeToContents()

    local subtitle = self:Add("DLabel")
    subtitle:Dock(TOP)
    subtitle:DockMargin(padding * 1.5, 0, padding, 0)
    subtitle:SetFont("ow.fonts.subtitle")
    subtitle:SetText("CONFIGURE YOUR PREFERENCES")
    subtitle:SetTextColor(color_white)
    subtitle:SetExpensiveShadow(4, color_black)
    subtitle:SizeToContents()

    local navigation = self:Add("EditablePanel")
    navigation:Dock(BOTTOM)
    navigation:DockMargin(padding, 0, padding, padding)
    navigation:SetTall(ScreenScale(24))

    local backButton = navigation:Add("DButton")
    backButton:Dock(LEFT)
    backButton:SetText("BACK")
    backButton.DoClick = function()
        self.currentCreatePage = 0
        self.currentCreatePayload = {}
        parent:Populate()

        self:Clear()
        self:SetVisible(false)
    end
end

vgui.Register("ow.mainmenu.settings", PANEL, "EditablePanel")