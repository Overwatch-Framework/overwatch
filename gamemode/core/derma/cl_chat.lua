local PANEL = {}

DEFINE_BASECLASS("EditablePanel")

function PANEL:Init()
    if ( IsValid(ow.gui.chatbox) ) then
        ow.gui.chatbox:Remove()
    end

    ow.gui.chatbox = self

    self:SetSize(hook.Run("GetChatboxSize"))
    self:SetPos(hook.Run("GetChatboxPos"))

    local title = self:Add("ow.button.small")
    title:Dock(TOP)
    title:SetText("chat", true, true)
    title:SetFont("ow.fonts.button.tiny")
    title:SetContentAlignment(4)

    self.entry = self:Add("ow.text.entry")
    self.entry:Dock(BOTTOM)
    self.entry:SetPlaceholderText("Say something...")
    self.entry:SetTextColor(color_white)
    self.entry:SetDrawLanguageID(false)

    self.entry.OnEnter = function(this)
        local text = this:GetValue()
        if ( #text > 0 ) then
            RunConsoleCommand("say", text)
            this:SetText("")
        end

        self:SetVisible(false)
    end

    self.history = self:Add("DScrollPanel")
    self.history:SetPos(8, title:GetTall() + 8)
    self.history:SetSize(self:GetWide() - 16, self:GetTall() - 16 - title:GetTall() - self.entry:GetTall())
    self.history:GetVBar():SetWide(0)
    self.history.PerformLayout = function(this)
        local scrollBar = this:GetVBar()
        if ( scrollBar ) then
            scrollBar:SetScroll(scrollBar.CanvasSize)
        end
    end

    self:SetVisible(false)

    chat.GetChatBoxPos = function()
        return self:GetPos()
    end

    chat.GetChatBoxSize = function()
        return self:GetSize()
    end
end

function PANEL:SetVisible(visible)
    -- BaseClass.SetVisible(self, visible)

    if ( visible ) then
        input.SetCursorPos(self:LocalToScreen(self:GetWide() / 2, self:GetTall() / 2))

        self:SetAlpha(255)
        self:MakePopup()
        self.entry:RequestFocus()
        self.entry:SetVisible(true)
    else
        self:SetAlpha(0)
        self:SetMouseInputEnabled(false)
        self:SetKeyboardInputEnabled(false)
        self.entry:SetText("")
        self.entry:SetVisible(false)
    end
end

function PANEL:Think()
    if ( input.IsKeyDown(KEY_ESCAPE) and self:IsVisible() ) then
        self:SetVisible(false)
    end
end

function PANEL:Paint(width, height)
    ow.util:DrawBlur(self)

    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, 0, width, height)
end

vgui.Register("ow.chatbox", PANEL, "EditablePanel")

if ( IsValid(ow.gui.chatbox) ) then
    ow.gui.chatbox:Remove()

    vgui.Create("ow.chatbox")
end