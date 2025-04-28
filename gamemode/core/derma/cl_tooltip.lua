DEFINE_BASECLASS("DPanel")

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
    self:AlphaTo(255, 0.2, 0)
    self:SetDrawOnTop(true)

    self.title = ""
    self.description = ""
    self.next = 0
    self.fading = false
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
    local descWrapped = ow.util:WrapText(desc, "ow.fonts.default", ScreenScale(128))

    local width = 0
    local titleWidth = ow.util:GetTextWidth("ow.fonts.large.bold", title)
    width = math.max(width, titleWidth)
    for i = 1, #descWrapped do
        local descWidth = ow.util:GetTextWidth("ow.fonts.default", descWrapped[i])
        width = math.max(width, descWidth)
    end

    local height = ow.util:GetTextHeight("ow.fonts.large.bold") + 16
    for i = 1, #descWrapped do
        height = height + 16
    end

    self:SetSize(width + 32, height)
end

function PANEL:Think()
    self:SetPos(gui.MouseX() + 16, gui.MouseY())

    if ( IsValid(self.panel) ) then
        self.next = CurTime() + 0.1
        return
    end

    if ( self.next < CurTime() and !self.fading ) then
        self.fading = true
        self:AlphaTo(0, 0.2, 0, function()
            if ( IsValid(self) ) then
                self:Remove()
            end
        end)
    end

    if ( self:GetAlpha() == 0 ) then
        self:Remove()
    end
end

function PANEL:Paint(width, height)
    ow.util:DrawBlur(self)
    draw.RoundedBox(0, 0, 0, width, height, Color(0, 0, 0, 200))
    local title = ow.localization:GetPhrase(self.title) or self.title
    draw.SimpleText(title, "ow.fonts.large.bold", 8, 0, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    local desc = ow.localization:GetPhrase(self.description) or self.description
    local descWrapped = ow.util:WrapText(desc, "ow.fonts.default", width - 32)
    for i = 1, #descWrapped do
        draw.SimpleText(descWrapped[i], "ow.fonts.default", 16, 32 + (i - 1) * 16, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
end

vgui.Register("ow.tooltip", PANEL, "DPanel")

if ( IsValid(ow.gui.tooltip) ) then
    ow.gui.tooltip:Remove()
end