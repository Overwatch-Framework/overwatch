local PANEL = {}

DEFINE_BASECLASS("EditablePanel")

function PANEL:Init()
    if ( IsValid(ow.gui.chatbox) ) then
        ow.gui.chatbox:Remove()
    end

    ow.gui.chatbox = self

    self:SetSize(hook.Run("GetChatboxSize"))
    self:SetPos(hook.Run("GetChatboxPos"))

    local label = self:Add("ow.text")
    label:Dock(TOP)
    label:SetTextInset(8, -2)
    label:SetFont("ow.fonts.small")
    label:SetText(GetHostName(), true)
    label.Paint = function(this, width, height)
        surface.SetDrawColor(ow.color:Get("background.transparent"))
        surface.DrawRect(0, 0, width, height)
    end

    local bottom = self:Add("EditablePanel")
    bottom:Dock(BOTTOM)
    bottom:DockMargin(8, 8, 8, 8)

    self.chatType = bottom:Add("ow.text")
    self.chatType:Dock(LEFT)
    self.chatType:SetTextInset(8, -2)
    self.chatType:SetFont("ow.fonts.small")
    self.chatType:SetText("IC", true)
    self.chatType.Paint = function(this, width, height)
        surface.SetDrawColor(ow.color:Get("background.transparent"))
        surface.DrawRect(0, 0, width, height)
    end

    self.entry = bottom:Add("ow.text.entry")
    self.entry:Dock(FILL)
    self.entry:DockMargin(8, 0, 0, 0)
    self.entry:SetPlaceholderText("Say something...")
    self.entry:SetTextColor(color_white)
    self.entry:SetDrawLanguageID(false)

    bottom:SizeToChildren(false, true)

    self.entry.OnEnter = function(this)
        local text = this:GetValue()
        if ( #text > 0 ) then
            RunConsoleCommand("say", text)
            this:SetText("")
        end

        self:SetVisible(false)
    end

    self.entry.OnTextChanged = function(this)
        local text = this:GetValue()
        if ( string.sub(text, 1, 3) == ".//" ) then
            -- Check if it's a way of using local out of character chat using .// prefix
            local data = ow.command:Get("looc")
            if ( data ) then
                self.chatType:SetText("LOOC", true)
            end
        elseif ( string.sub(text, 1, 1) == "/" ) then
            -- This is a command, so we need to parse it
            local arguments = string.Explode(" ", string.sub(text, 2))
            local command = arguments[1]
            local data = ow.command:Get(command)
            if ( data ) then
                self.chatType:SetText(string.upper(data.UniqueID), true)
            else
                -- Just revert back to IC if the command doesn't exist
                self.chatType:SetText("IC", true)
            end
        else
            -- Everything else is a normal chat message
            self.chatType:SetText("IC", true)
        end
    end

    self.entry.OnLoseFocus = function(this)
        if ( this:GetText() == "" ) then
            self:SetVisible(false)
        end
    end

    self.history = self:Add("DScrollPanel")
    self.history:SetPos(8, label:GetTall() + 8)
    self.history:SetSize(self:GetWide() - 16, self:GetTall() - 16 - label:GetTall() - self.entry:GetTall())
    self.history:GetVBar():SetWide(0)

    self:SetVisible(false)

    chat.GetChatBoxPos = function()
        return self:GetPos()
    end

    chat.GetChatBoxSize = function()
        return self:GetSize()
    end
end

function PANEL:SetVisible(visible)
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

    surface.SetDrawColor(ow.color:Get("background.transparent"))
    surface.DrawRect(0, 0, width, height)
end

vgui.Register("ow.chatbox", PANEL, "EditablePanel")

if ( IsValid(ow.gui.chatbox) ) then
    ow.gui.chatbox:Remove()

    vgui.Create("ow.chatbox")
end