DEFINE_BASECLASS("EditablePanel")

local PANEL = {}

function PANEL:Init()
    if ( IsValid(ow.gui.tooltip) ) then
        ow.gui.tooltip:Remove()
    end

    ow.gui.tooltip = self

    self:SetSize(ScreenScale(128), ScreenScale(24))
    self:SetMouseInputEnabled(false)
    self:SetPos(gui.MouseX(), gui.MouseY())
    self:SetAlpha(0)
    self:SetDrawOnTop(true)

    self.title = ""
    self.description = ""
    self.next = 0
    self.fading = false
    self.alpha = 0
    self.panel = nil
end

function PANEL:SetTitle(title)
    self.title = title
end

function PANEL:SetDescription(description)
    self.description = description
end

function PANEL:SetText(title, description)
    self.title = title
    self.description = description
end

function PANEL:SetPanel(panel)
    self.panel = panel
end

function PANEL:SizeToContents()
    local title = ow.localization:GetPhrase(self.title) or self.title
    local desc = ow.localization:GetPhrase(self.description) or self.description
    local descWrapped = ow.util:GetWrappedText(desc, "ow.fonts", ScreenScale(128))

    local width = 0
    local titleWidth = ow.util:GetTextWidth("ow.fonts.large.bold", title)
    width = math.max(width, titleWidth)
    for i = 1, #descWrapped do
        local descWidth = ow.util:GetTextWidth("ow.fonts", descWrapped[i])
        width = math.max(width, descWidth)
    end

    local height = ow.util:GetTextHeight("ow.fonts.large.bold")
    for i = 1, #descWrapped do
        height = height + ow.util:GetTextHeight("ow.fonts")
    end

    self:SetSize(width + 32, height)
end

function PANEL:Think()
    self:SetPos(gui.MouseX() + 16, gui.MouseY())

    local mouseX, mouseY = gui.MouseX(), gui.MouseY()
    local screenWidth = ScrW()
    local tooltipWidth = self:GetWide()

    self:SetPos(math.Clamp(mouseX + 16, 0, screenWidth - tooltipWidth), mouseY)
    self:SetAlpha(self.alpha)

    if ( IsValid(self.panel) ) then
        self.next = nil
        self.fading = false
        return
    elseif ( !self.next ) then
        self.next = CurTime() + 0.2
    end

    if ( self.next < CurTime() and !self.fading ) then
        self.fading = true
    end

    if ( self:GetAlpha() <= 1 and self.fading ) then
        self:Remove()
    end
end

function PANEL:Paint(width, height)
    self.alpha = Lerp(FrameTime() * 5, self.alpha, self.fading and 0 or 255)

    ow.util:DrawBlur(self)
    draw.RoundedBox(0, 0, 0, width, height, Color(0, 0, 0, 200))
    local title = ow.localization:GetPhrase(self.title) or self.title
    draw.SimpleText(title, "ow.fonts.large.bold", 8, 0, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    local desc = ow.localization:GetPhrase(self.description) or self.description
    local descWrapped = ow.util:GetWrappedText(desc, "ow.fonts", width - 32)
    for i = 1, #descWrapped do
        draw.SimpleText(descWrapped[i], "ow.fonts", 16, 32 + (i - 1) * ow.util:GetTextHeight("ow.fonts"), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
end

vgui.Register("ow.tooltip", PANEL, "EditablePanel")

if ( IsValid(ow.gui.tooltip) ) then
    ow.gui.tooltip:Remove()
end