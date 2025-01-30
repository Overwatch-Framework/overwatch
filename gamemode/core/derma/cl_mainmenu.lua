local padding = ScreenScale(32)
local gradientLeft = Material("vgui/gradient-l")

local PANEL = {}

local color_button = Color(0, 0, 0, 150)
local color_button_hover = Color(0, 0, 0, 200)
local color_button_text = color_white

local function ButtonOnCursorEntered(this)
    surface.PlaySound("ow.button.enter")
end

local function ButtonPaint(this, width, height)
    local color = color_button
    if ( this.Depressed or this:IsSelected() ) then
        color = color_button_hover
    elseif ( this.Hovered ) then
        color = color_button_hover
    end

    paint.startPanel(this, true, true)
        paint.roundedBoxes.roundedBox(2, 0, 0, width, height, color)
    paint.endPanel(true, true)
end

function PANEL:Init()
    if ( IsValid(ow.gui.mainmenu) ) then
        ow.gui.mainmenu:Remove()
    end

    ow.gui.mainmenu = self

    if ( IsValid(LocalPlayer()) and LocalPlayer():IsTyping() ) then
        chat.Close()
    end

    CloseDermaMenus()

    if ( system.IsWindows() ) then
        system.FlashWindow()
    end

    self:SetSize(ScrW(), ScrH())
    self:MakePopup()

    local sideButtons = self:Add("EditablePanel")
    sideButtons:Dock(LEFT)
    sideButtons:SetSize(self:GetWide() / 2, self:GetTall())
    sideButtons.Paint = function(this, width, height)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.SetMaterial(gradientLeft)
        surface.DrawTexturedRect(0, 0, width, height)
    end

    local title = sideButtons:Add("DLabel")
    title:Dock(TOP)
    title:DockMargin(padding, padding, padding, 0)
    title:SetFont("ow.fonts.title")
    title:SetText("OVERWATCH")
    title:SetTextColor(hook.Run("GetFrameworkColor"))
    title:SetExpensiveShadow(4, color_button_hover)
    title:SizeToContents()

    local subtitle = sideButtons:Add("DLabel")
    subtitle:Dock(TOP)
    subtitle:DockMargin(padding * 1.5, 0, padding, 0)
    subtitle:SetFont("ow.fonts.subtitle")
    subtitle:SetText(string.upper(SCHEMA.Name))
    subtitle:SetTextColor(color_white)
    subtitle:SetExpensiveShadow(4, color_button_hover)
    subtitle:SizeToContents()

    local buttons = sideButtons:Add("EditablePanel")
    buttons:Dock(FILL)
    buttons:DockMargin(padding * 2, padding, padding * 4, padding)

    ow.util:Print("No main menu buttons, lel!")
    -- TODO: add real buttons like "Create Character", "Select Character", "Settings", "Credits", etc.

    local playButton = buttons:Add("DButton")
    playButton:Dock(TOP)
    playButton:SetTall(ScreenScale(14))
    playButton:SetText("PLAY")
    playButton:SetFont("ow.fonts.subtitle")
    playButton:SetTextColor(color_white)
    playButton:DockMargin(0, 2, 0, 0)

    playButton.Paint = ButtonPaint
    playButton.OnCursorEntered = ButtonOnCursorEntered

    playButton.DoClick = function()
        surface.PlaySound("ow.button.click")

        self:Remove()
    end

    local disconnectButton = buttons:Add("DButton")
    disconnectButton:Dock(TOP)
    disconnectButton:SetTall(ScreenScale(14))
    disconnectButton:SetText("DISCONNECT")
    disconnectButton:SetFont("ow.fonts.subtitle")
    disconnectButton:SetTextColor(color_white)
    disconnectButton:DockMargin(0, 2, 0, 0)

    disconnectButton.Paint = ButtonPaint
    disconnectButton.OnCursorEntered = function(this)
        ButtonOnCursorEntered(this)
        surface.PlaySound("ow.button.enter")
    end

    disconnectButton.DoClick = function()
        surface.PlaySound("ow.button.click")

        Derma_Query("Are you sure you want to disconnect?", "Disconnect", "Yes", function()
            RunConsoleCommand("disconnect")
        end, "No")
    end

    self:PlayMenuTrack()
end

function PANEL:PlayMenuTrack()
    local track = hook.Run("GetMainMenuMusic")
    if ( !track or #track == 0 ) then return end

    sound.PlayFile("sound/" .. track, "noplay", function(station, errorID, errorName)
        if ( IsValid(station) and IsValid(self) ) then
            station:Play()
            self.station = station
        else
            ow.util:PrintError("Error playing main menu music: " .. errorID .. " (" .. errorName .. ")")
        end
    end)
end

function PANEL:OnRemove()
    ow.gui.mainmenu = nil

    if ( IsValid(self.station) ) then
        self.station:Stop()
    end
end

vgui.Register("ow.mainmenu", PANEL, "EditablePanel")

if ( IsValid(ow.gui.mainmenu) ) then
    vgui.Create("ow.mainmenu")
end

-- TODO: add an actual button panel
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