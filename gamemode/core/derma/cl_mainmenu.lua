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

AccessorFunc(PANEL, "dim", "Dim", FORCE_NUMBER)
AccessorFunc(PANEL, "dimTarget", "DimTarget", FORCE_NUMBER)

function PANEL:Init()
    if ( IsValid(ow.gui.mainmenu) ) then
        ow.gui.mainmenu:Remove()
    end

    ow.gui.mainmenu = self

    local ply = ow.localClient
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

    self.dim = 0
    self.dimTarget = 0

    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, 0)
    self:MakePopup()

    self.createPanel = self:Add("ow.mainmenu.create")
    self.selectPanel = self:Add("ow.mainmenu.load")
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
    self:SetDimTarget(0)

    self.container:Clear()
    self.container:SetVisible(true)

    local sideButtons = self.container:Add("EditablePanel")
    sideButtons:Dock(LEFT)
    sideButtons:DockMargin(padding * 2, padding * 3, 0, 0)
    sideButtons:SetSize(self.container:GetWide() / 3, self.container:GetTall() - padding * 2)

    local title = sideButtons:Add("DLabel")
    title:Dock(TOP)
    title:DockMargin(0, 0, padding, 0)
    title:SetFont("ow.fonts.title")
    title:SetText("OVERWATCH")
    title:SetTextColor(hook.Run("GetFrameworkColour"))
    title:SizeToContents()

    local subtitle = sideButtons:Add("DLabel")
    subtitle:Dock(TOP)
    subtitle:DockMargin(padding / 4, -padding / 8, 0, 0)
    subtitle:SetFont("ow.fonts.subtitle")
    subtitle:SetText(string.upper(SCHEMA.Name or "UNKNOWN SCHEMA"))
    subtitle:SetTextColor(hook.Run("GetSchemaColour"))
    subtitle:SizeToContents()

    local buttons = sideButtons:Add("EditablePanel")
    buttons:Dock(FILL)
    buttons:DockMargin(0, padding / 4, 0, padding)

    local ply = ow.localClient
    local plyTable = ply:GetTable()
    if ( plyTable.owCharacter ) then -- ply:GetCharacter() isn't validated yet, since it this panel is created before the meta tables are loaded
        local playButton = buttons:Add("ow.mainmenu.button")
        playButton:Dock(TOP)
        playButton:DockMargin(0, 0, 0, 16)
        playButton:SetText("mainmenu.play")

        playButton.DoClick = function(this)
            self:Remove()
        end
    end

    local createButton = buttons:Add("ow.mainmenu.button")
    createButton:Dock(TOP)
    createButton:DockMargin(0, 0, 0, 16)
    createButton:SetText("mainmenu.create.character")

    createButton.DoClick = function(this)
        local availableFactions = 0
        for k, v in ipairs(ow.faction:GetAll()) do
            if ( ow.faction:CanSwitchTo(ow.localClient, v.Index) ) then
                availableFactions = availableFactions + 1
            end
        end

        if ( availableFactions > 1 ) then
            self.createPanel:PopulateFactionSelect()
        else
            self.createPanel:PopulateCreateCharacter()
        end
    end

    local bHasCharacters = table.Count(plyTable.owCharacters or {}) > 0
    if ( bHasCharacters ) then
        local selectButton = buttons:Add("ow.mainmenu.button")
        selectButton:Dock(TOP)
        selectButton:DockMargin(0, 0, 0, 16)
        selectButton:SetText("mainmenu.select.character")

        selectButton.DoClick = function()
            self.selectPanel:Populate()
        end
    end

    local settingsButton = buttons:Add("ow.mainmenu.button")
    settingsButton:Dock(TOP)
    settingsButton:DockMargin(0, 0, 0, 16)
    settingsButton:SetText("mainmenu.settings")

    settingsButton.DoClick = function()
        self.settingsPanel:Populate()
    end

    local disconnectButton = buttons:Add("ow.mainmenu.button")
    disconnectButton:Dock(TOP)
    disconnectButton:DockMargin(0, 0, 0, 16)
    disconnectButton:SetText("mainmenu.leave")
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

    sound.PlayFile("sound/" .. track, "noplay noblock", function(station, errorID, errorName)
        if ( IsValid(station) ) then
            station:Play()
            station:SetVolume(ow.option:Get("mainmenu.music.volume", 75) / 100)
            station:EnableLooping(ow.option:Get("mainmenu.music.loop", true))
            self.station = station
        else
            ow.localClient:Notify("Error playing main menu music: " .. tostring(errorID) .. " (" .. tostring(errorName) .. ")", NOTIFY_ERROR, 5)
        end
    end)
end

function PANEL:Think()
    if ( IsValid(self.station) ) then
        if ( !ow.option:Get("mainmenu.music", true) ) then
            self.station:Stop()
            self.station = nil
            return
        end

        local volume = ow.option:Get("mainmenu.music.volume", 75) / 100
        if ( self.station:GetVolume() != volume ) then
            self.station:SetVolume(volume)
        end
    elseif ( ow.option:Get("mainmenu.music", true) ) then
        self:PlayMenuTrack()
    end
end

function PANEL:OnRemove()
    if ( IsValid(self.station) ) then
        self.station:Stop()
        self.station = nil
    end

    ow.gui.mainmenu = nil
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

    self:SetDim(Lerp(time, self:GetDim(), self:GetDimTarget()))

    surface.SetDrawColor(0, 0, 0, 255 * self:GetDim())
    surface.DrawRect(0, 0, width, height)

    surface.SetDrawColor(0, 0, 0, 255 * self:GetGradientLeft())
    surface.SetMaterial(gradientLeft)
    surface.DrawTexturedRect(0, 0, width, height)

    surface.SetDrawColor(0, 0, 0, 255 * self:GetGradientRight())
    surface.SetMaterial(gradientRight)
    surface.DrawTexturedRect(0, 0, width, height)

    surface.SetDrawColor(0, 0, 0, 255 * self:GetGradientTop())
    surface.SetMaterial(gradientTop)
    surface.DrawTexturedRect(0, 0, width, height)

    surface.SetDrawColor(0, 0, 0, 255 * self:GetGradientBottom())
    surface.SetMaterial(gradientBottom)
    surface.DrawTexturedRect(0, 0, width, height)
end

vgui.Register("ow.mainmenu", PANEL, "EditablePanel")

if ( IsValid(ow.gui.mainmenu) ) then
    ow.gui.mainmenu:Remove()

    timer.Simple(0.1, function()
        vgui.Create("ow.mainmenu")
    end)
end