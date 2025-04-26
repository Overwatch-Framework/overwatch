local padding = ScreenScale(32)
local gradientLeft = ow.util:GetMaterial("vgui/gradient-l")
local gradientRight = ow.util:GetMaterial("vgui/gradient-r")
local gradientTop = ow.util:GetMaterial("vgui/gradient-u")
local gradientBottom = ow.util:GetMaterial("vgui/gradient-d")

-- TODO: Full on localization support

DEFINE_BASECLASS("EditablePanel")

local PANEL = {}

AccessorFunc(PANEL, "currentCreatePage", "CurrentCreatePage", FORCE_NUMBER)
AccessorFunc(PANEL, "currentCreatePayload", "CurrentCreatePayload")

AccessorFunc(PANEL, "gradientLeft", "GradientLeft", FORCE_NUMBER)
AccessorFunc(PANEL, "gradientRight", "GradientRight", FORCE_NUMBER)
AccessorFunc(PANEL, "gradientTop", "GradientTop", FORCE_NUMBER)
AccessorFunc(PANEL, "gradientBottom", "GradientBottom", FORCE_NUMBER)

AccessorFunc(PANEL, "gradientLeftTarget", "GradientLeftTarget", FORCE_NUMBER)
AccessorFunc(PANEL, "gradientRightTarget", "GradientRightTarget", FORCE_NUMBER)
AccessorFunc(PANEL, "gradientTopTarget", "GradientTopTarget", FORCE_NUMBER)
AccessorFunc(PANEL, "gradientBottomTarget", "GradientBottomTarget", FORCE_NUMBER)

function PANEL:Init()
    if ( IsValid(ow.gui.mainmenu) ) then
        ow.gui.mainmenu:Remove()
    end

    ow.gui.mainmenu = self

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

    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, 0)
    self:MakePopup()

    self.createPanel = self:Add("ow.mainmenu.create")
    self.settingsPanel = self:Add("ow.mainmenu.settings")

    self.container = self:Add("EditablePanel")
    self.container:SetSize(self:GetWide(), self:GetTall())
    self.container:SetPos(0, 0)

    self:Populate()
    self:PlayMenuTrack()
end

function PANEL:Populate()
    self:SetGradientLeftTarget(1)
    self:SetGradientRightTarget(0)
    self:SetGradientTopTarget(0)
    self:SetGradientBottomTarget(0)

    self.container:Clear()
    self.container:SetVisible(true)

    local sideButtons = self.container:Add("EditablePanel")
    sideButtons:Dock(LEFT)
    sideButtons:DockMargin(padding * 3, padding, 0, 0)
    sideButtons:SetSize(self.container:GetWide() / 3, self.container:GetTall() - padding * 2)

    local title = sideButtons:Add("DLabel")
    title:Dock(TOP)
    title:DockMargin(0, 0, padding, 0)
    title:SetFont("ow.fonts.title")
    title:SetText("OVERWATCH")
    title:SetTextColor(hook.Run("GetFrameworkColor"))
    title:SizeToContents()

    local subtitle = sideButtons:Add("DLabel")
    subtitle:Dock(TOP)
    subtitle:DockMargin(padding / 2, 0, 0, 0)
    subtitle:SetFont("ow.fonts.subtitle")
    subtitle:SetText(string.upper(SCHEMA.Name or "UNKNOWN SCHEMA"))
    subtitle:SetTextColor(hook.Run("GetSchemaColor"))
    subtitle:SizeToContents()

    local buttons = sideButtons:Add("EditablePanel")
    buttons:Dock(FILL)
    buttons:DockMargin(0, padding, 0, padding)

    local ply = LocalPlayer()
    if ( ply.owCharacter ) then -- ply:GetCharacter() isn't validated yet, since it this panel is created before the meta tables are loaded
        local playButton = buttons:Add("ow.mainmenu.button")
        playButton:Dock(TOP)
        playButton:SetText(ow.localization:GetPhrase("mainmenu.play"):upper())

        playButton.DoClick = function(this)
            self:Remove()
        end
    else
        local createButton = buttons:Add("ow.mainmenu.button")
        createButton:Dock(TOP)
        createButton:SetText(ow.localization:GetPhrase("mainmenu.charactercreate"):upper())

        createButton.DoClick = function(this)
            local availableFactions = 0
            for k, v in ipairs(ow.faction:GetAll()) do
                if ( ow.faction:CanSwitchTo(LocalPlayer(), v.Index) ) then
                    availableFactions = availableFactions + 1
                end
            end

            if ( availableFactions > 1 ) then
                self.createPanel:PopulateFactionSelect()
            else
                self.createPanel:PopulateCreateCharacter()
            end
        end
    end

    local bHasCharacters = table.Count(ply.owCharacters or {}) > 0
    if ( bHasCharacters ) then
        local selectButton = buttons:Add("ow.mainmenu.button")
        selectButton:Dock(TOP)
        selectButton:SetText(ow.localization:GetPhrase("mainmenu.characterselect"):upper())

        selectButton.DoClick = function()
            self.createPanel:PopulateSelectCharacter()
        end
    end

    local settingsButton = buttons:Add("ow.mainmenu.button")
    settingsButton:Dock(TOP)
    settingsButton:SetText(ow.localization:GetPhrase("mainmenu.settings"):upper())

    settingsButton.DoClick = function()
        self.settingsPanel:Populate()
    end

    local testButton = buttons:Add("ow.mainmenu.button")
    testButton:Dock(TOP)
    testButton:SetText(ow.localization:GetPhrase("mainmenu.test"):upper())

    local disconnectButton = buttons:Add("ow.mainmenu.button")
    disconnectButton:Dock(TOP)
    disconnectButton:SetText(ow.localization:GetPhrase("mainmenu.leave"):upper())
    disconnectButton:SetTextColorProperty(ow.colour:Get("maroon"))

    disconnectButton.DoClick = function()
        Derma_Query("Are you sure you want to disconnect?", "Disconnect", "Yes", function()
            RunConsoleCommand("disconnect")
        end, "No")
    end
end

function PANEL:PlayMenuTrack()
    local track = hook.Run("GetMainMenuMusic")
    if ( !isstring(track) or #track == 0 ) then return end

    sound.PlayFile("sound/" .. track, "noplay", function(station, errorID, errorName)
        if ( IsValid(station) and IsValid(self) ) then
            station:Play()
            self.station = station
        else
            ow.util:PrintError("Error playing main menu music: " .. tostring(errorID) .. " (" .. tostring(errorName) .. ")")
        end
    end)
end

function PANEL:OnRemove()
    ow.gui.mainmenu = nil

    if ( IsValid(self.station) ) then
        self.station:Stop()
    end
end

function PANEL:Paint(width, height)
    local ft = FrameTime()
    local time = ft * 5

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

vgui.Register("ow.mainmenu", PANEL, "EditablePanel")

if ( IsValid(ow.gui.mainmenu) ) then
    ow.gui.mainmenu:Remove()

    timer.Simple(0.1, function()
        vgui.Create("ow.mainmenu")
    end)
end