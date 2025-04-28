local padding = ScreenScale(32)
local paddingSmall = ScreenScale(16)
local paddingTiny = ScreenScale(8)
local gradientLeft = ow.util:GetMaterial("vgui/gradient-l")
local gradientRight = ow.util:GetMaterial("vgui/gradient-r")
local gradientTop = ow.util:GetMaterial("vgui/gradient-u")
local gradientBottom = ow.util:GetMaterial("vgui/gradient-d")

DEFINE_BASECLASS("DPanel")

local PANEL = {}

AccessorFunc(PANEL, "gradientLeft", "GradientLeft", FORCE_NUMBER)
AccessorFunc(PANEL, "gradientRight", "GradientRight", FORCE_NUMBER)
AccessorFunc(PANEL, "gradientTop", "GradientTop", FORCE_NUMBER)
AccessorFunc(PANEL, "gradientBottom", "GradientBottom", FORCE_NUMBER)

AccessorFunc(PANEL, "gradientLeftTarget", "GradientLeftTarget", FORCE_NUMBER)
AccessorFunc(PANEL, "gradientRightTarget", "GradientRightTarget", FORCE_NUMBER)
AccessorFunc(PANEL, "gradientTopTarget", "GradientTopTarget", FORCE_NUMBER)
AccessorFunc(PANEL, "gradientBottomTarget", "GradientBottomTarget", FORCE_NUMBER)

AccessorFunc(PANEL, "fadeTime", "FadeTime", FORCE_NUMBER)

function PANEL:Init()
    if ( IsValid(ow.gui.tab) ) then
        ow.gui.tab:Remove()
    end

    ow.gui.tab = self

    local ply = LocalPlayer()
    if ( IsValid(ply) and ply:IsTyping() ) then
        chat.Close()
    end

    CloseDermaMenus()

    if ( system.IsWindows() ) then
        system.FlashWindow()
    end

    self.gradientLeft = 0
    self.gradientRight = 0
    self.gradientTop = 0
    self.gradientBottom = 0

    self.gradientLeftTarget = 0
    self.gradientRightTarget = 0
    self.gradientTopTarget = 0
    self.gradientBottomTarget = 0

    self.fadeTime = ow.option:Get("tab.fade.time", 0.2)

    self.anchorTime = CurTime() + ow.option:Get("tab.anchor.time", 0.4)
    self.anchorEnabled = true

    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, 0)
    self:MakePopup()

    self.buttons = self:Add("DPanel")
    self.buttons:SetSize(ScrW() / 4 - paddingSmall, ScrH() - padding)
    self.buttons:SetPos(-self.buttons:GetWide(), paddingSmall)
    self.buttons:MoveTo(paddingTiny, paddingSmall, self.fadeTime, 0)
    self.buttons.Paint = nil

    local closeButton = self.buttons:Add("ow.mainmenu.button")
    closeButton:Dock(BOTTOM)
    closeButton:SetText("tab.close")

    closeButton.DoClick = function()
        self:Close()
    end

    local menuButton = self.buttons:Add("ow.mainmenu.button")
    menuButton:Dock(BOTTOM)
    menuButton:SetText("tab.mainmenu")

    menuButton.DoClick = function()
        self:Close(function()
            if ( IsValid(ow.gui.mainmenu) ) then
                ow.gui.mainmenu:Remove()
            end

            ow.gui.mainmenu = vgui.Create("ow.mainmenu")
        end)
    end

    self.container = self:Add("DPanel")
    self.container:SetSize(self:GetWide() - self.buttons:GetWide() - padding - paddingSmall, self:GetTall() - padding)
    self.container:SetPos(self:GetWide(), paddingSmall)
    self.container:MoveTo(self:GetWide() - self.container:GetWide() - paddingTiny, paddingSmall, self.fadeTime, 0)
    self.container.Paint = nil

    local buttons = {}
    hook.Run("PopulateTabButtons", buttons)
    for k, v in SortedPairs(buttons) do
        local button = self.buttons:Add("ow.mainmenu.button")
        button:Dock(TOP)
        button:SetText(k)

        button.DoClick = function()
            ow.gui.tabLast = k

            self.container:Clear()

            self:Populate(v)
        end
    end

    if ( ow.gui.tabLast and buttons[ow.gui.tabLast] ) then
        self:Populate(buttons[ow.gui.tabLast])
    end

    self:SetGradientLeftTarget(1)
    self:SetGradientRightTarget(1)
    self:SetGradientTopTarget(1)
    self:SetGradientBottomTarget(1)
end

function PANEL:Populate(data)
    if ( !data ) then return end

    self.container:Clear()

    if ( istable(data) ) then
        if ( data.Populate ) then
            data.Populate(self.container)
        end

        if ( data.OnClose ) then
            self:CallOnRemove("ow.tab." .. data.name, function()
                data.OnClose()
            end)
        end
    elseif ( isfunction(data) ) then
        data(self.container)
    end
end

function PANEL:Close(callback)
    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(false)

    self:SetGradientLeftTarget(0)
    self:SetGradientRightTarget(0)
    self:SetGradientTopTarget(0)
    self:SetGradientBottomTarget(0)

    self:AlphaTo(0, self.fadeTime, 0, function()
        self:Remove()

        if ( callback ) then
            callback()
        end
    end)

    self.buttons:MoveTo(-self.buttons:GetWide() * 2, paddingSmall, self.fadeTime, 0, 1)
    self.buttons:AlphaTo(0, self.fadeTime / 2, 0)
    self.container:MoveTo(self:GetWide() * 2, paddingSmall, self.fadeTime, 0, 1)
    self.container:AlphaTo(0, self.fadeTime / 2, 0)
end

function PANEL:OnKeyCodePressed(keyCode)
    if ( keyCode == KEY_TAB or keyCode == KEY_ESCAPE ) then
        self:Close()

        return true
    end

    return false
end

function PANEL:Think()
    local bHoldingTab = input.IsKeyDown(KEY_TAB)
    if ( bHoldingTab and ( self.anchorTime < CurTime() ) and self.anchorEnabled ) then
        self.anchorEnabled = false
    end

    if ( ( !bHoldingTab and !self.anchorEnabled ) or gui.IsGameUIVisible() ) then
        self:Close()
    end
end

function PANEL:Paint(width, height)
    local ft = FrameTime()
    local time = ft * 5

    local performanceAnimations = ow.option:Get("performance.animations", true)
    if ( !performanceAnimations ) then
        time = 1
    end

    self:SetGradientLeft(Lerp(time, self:GetGradientLeft(), self:GetGradientLeftTarget()))
    self:SetGradientRight(Lerp(time, self:GetGradientRight(), self:GetGradientRightTarget()))
    self:SetGradientTop(Lerp(time, self:GetGradientTop(), self:GetGradientTopTarget()))
    self:SetGradientBottom(Lerp(time, self:GetGradientBottom(), self:GetGradientBottomTarget()))

    surface.SetDrawColor(0, 0, 0, 255 * self:GetGradientLeft())
    surface.SetMaterial(gradientLeft)
    surface.DrawTexturedRect(0, 0, width / 2, height)

    surface.SetDrawColor(0, 0, 0, 255 * self:GetGradientRight())
    surface.SetMaterial(gradientRight)
    surface.DrawTexturedRect(width / 2, 0, width / 2, height)

    surface.SetDrawColor(0, 0, 0, 255 * self:GetGradientTop())
    surface.SetMaterial(gradientTop)
    surface.DrawTexturedRect(0, 0, width, height / 2)

    surface.SetDrawColor(0, 0, 0, 255 * self:GetGradientBottom())
    surface.SetMaterial(gradientBottom)
    surface.DrawTexturedRect(0, height / 2, width, height / 2)
end

vgui.Register("ow.tab", PANEL, "DPanel")

if ( IsValid(ow.gui.tab) ) then
    ow.gui.tab:Remove()
end

ow.gui.tabLast = nil