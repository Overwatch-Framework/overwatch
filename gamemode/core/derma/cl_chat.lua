local PANEL = {}

DEFINE_BASECLASS("EditablePanel")

function PANEL:Init()
    if ( IsValid(ow.gui.chatbox) ) then
        ow.gui.chatbox:Remove()
    end

    ow.gui.chatbox = self

    self:SetSize(hook.Run("GetChatboxSize"))
    self:SetPos(hook.Run("GetChatboxPos"))

    self.entry = self:Add("ow.text.entry")
    self.entry:Dock(BOTTOM)
    self.entry:SetPlaceholderText("Say something...")
    self.entry:SetTextColor(color_white)
    self.entry:SetDrawLanguageID(false)

    self.entry.OnEnter = function(this)
        local text = this:GetValue()
        if ( #text < 1 ) then return end

        RunConsoleCommand("say", text)
        this:SetText("")
        self:SetVisible(false)
    end

    self.entry.OnLoseFocus = function(this)
        self:SetVisible(false)
    end

    self.history = vgui.Create("DScrollPanel")
    self.history:SetSize(self:GetWide() - 16, self:GetTall() - ow.util:GetTextHeight("ow.fonts.small") - 20 - self.entry:GetTall())
    self.history:SetPos(self:GetX() + 8, self:GetY() + ow.util:GetTextHeight("ow.fonts.small") + 10)

    self:SetVisible(true)
end

function PANEL:AddLine(text, color)
    local label = self.history:Add("DLabel")
    label:SetFont("ChatFont")
    label:SetText(text)
    label:SetTextColor(color or color_white)
    label:SetWrap(true)
    label:SizeToContentsY()
    label:Dock(TOP)
    label:DockMargin(0, 0, 0, 4)

    self.history:InvalidateLayout(true)
    self.history:ScrollToChild(label)
end

function PANEL:SetVisible(visible)
    BaseClass.SetVisible(self, visible)

    if ( visible ) then
        self.entry:SetMouseInputEnabled(true)
        self.entry:SetKeyboardInputEnabled(true)
        self.entry:RequestFocus()
    else
        self.entry:SetMouseInputEnabled(false)
        self.entry:SetKeyboardInputEnabled(false)
        self.entry:Clear()
    end
end

function PANEL:OnRemove()
    if ( IsValid(self.history) ) then
        self.history:Remove()
    end
end

function PANEL:Paint(width, height)
    ow.util:DrawBlur(self)

    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, 0, width, height)

    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, 0, width, ow.util:GetTextHeight("ow.fonts.small") + 10)

    draw.SimpleText("Chat", "ow.fonts.small", 10, 5, color_white)
end

vgui.Register("ow.chatbox", PANEL, "EditablePanel")

if ( IsValid(ow.gui.chatbox) ) then
    ow.gui.chatbox:Remove()
end