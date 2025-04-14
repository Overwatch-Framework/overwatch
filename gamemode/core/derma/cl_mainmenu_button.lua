DEFINE_BASECLASS("DButton")

local PANEL = {}

function PANEL:Init()
    self:SetFont("ow.fonts.button")
    self:SetTextColor(color_white)
    self:SetContentAlignment(5)
    self:SetExpensiveShadow(1, color_black)
    self:SetTall(ScreenScale(14))
    self:SetTextInset(0, 0)
end

function PANEL:SetText(text)
    BaseClass.SetText(self, text)
    self:SizeToContentsX()

    local width = self:GetWide()
    self:SetWide(width + self:GetTall())
end

local color_button = Color(0, 0, 0, 150)
local color_button_hover = Color(0, 0, 0, 200)
function PANEL:Paint(width, height)
    local color = color_button
    if ( self.Depressed or self:IsSelected() ) then
        color = color_button_hover
    elseif ( self.Hovered ) then
        color = color_button_hover
    end

    paint.startVGUI()
        paint.roundedBoxes.roundedBox(8, 0, 0, width, height, color)
    paint.endVGUI()
end

function PANEL:OnCursorEntered()
    surface.PlaySound("ow.button.enter")
end

function PANEL:OnMousePressed(key)
    surface.PlaySound("ow.button.click")

    if ( key == MOUSE_LEFT ) then
        self:DoClick()
    else
        self:DoRightClick()
    end
end

vgui.Register("ow.mainmenu.button", PANEL, "DButton")


sound.Add({
    name = "ow.button.click",
    channel = CHAN_STATIC,
    volume = 0.2,
    level = 80,
    pitch = 120,
    sound = "buttons/button9.wav"
})

sound.Add({
    name = "ow.button.enter",
    channel = CHAN_STATIC,
    volume = 0.1,
    level = 80,
    pitch = 120,
    sound = "buttons/lightswitch2.wav"
})