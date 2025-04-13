local padding = ScreenScale(32)
local smallPadding = ScreenScale(16)
local gradientLeft = ow.util:GetMaterial("vgui/gradient-l")

DEFINE_BASECLASS("EditablePanel")

local PANEL = {}

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

    self.currentCreatePage = 0
    self.currentCreatePayload = {}

    self:SetSize(ScrW(), ScrH())
    self:MakePopup()

    self:Populate()
    self:PlayMenuTrack()
end

function PANEL:Populate()
    self:Clear()

    local sideButtons = self:Add("EditablePanel")
    sideButtons:Dock(LEFT)
    sideButtons:SetSize(self:GetWide() / 2, self:GetTall())

    local title = sideButtons:Add("DLabel")
    title:Dock(TOP)
    title:DockMargin(padding, padding, padding, 0)
    title:SetFont("ow.fonts.title")
    title:SetText("OVERWATCH")
    title:SetTextColor(hook.Run("GetFrameworkColor"))
    title:SetExpensiveShadow(4, color_black)
    title:SizeToContents()

    local subtitle = sideButtons:Add("DLabel")
    subtitle:Dock(TOP)
    subtitle:DockMargin(padding * 1.5, 0, padding, 0)
    subtitle:SetFont("ow.fonts.subtitle")
    subtitle:SetText(string.upper(SCHEMA.Name or "UNKNOWN SCHEMA"))
    subtitle:SetTextColor(hook.Run("GetSchemaColor"))
    subtitle:SetExpensiveShadow(4, color_black)
    subtitle:SizeToContents()

    local buttons = sideButtons:Add("EditablePanel")
    buttons:Dock(FILL)
    buttons:DockMargin(padding * 2, padding, padding * 4, padding)

    local ply = LocalPlayer()
    if ( ply.owCharacter ) then -- ply:GetCharacter() isn't validated yet, since it this panel is created before the meta tables are loaded
        local playButton = buttons:Add("ow.mainmenu.button")
        playButton:Dock(TOP)
        playButton:SetText("PLAY")
        playButton:DockMargin(0, 0, 0, 8)

        playButton.DoClick = function()
            self:Remove()
        end
    else
        local createButton = buttons:Add("ow.mainmenu.button")
        createButton:Dock(TOP)
        createButton:SetText("CREATE CHARACTER")
        createButton:DockMargin(0, 0, 0, 8)

        createButton.DoClick = function()
            local hasMultipleOptions = false
            for k, v in pairs(ow.faction:GetAll()) do
                if ( ow.faction:CanSwitchTo(ply, v.Index) ) then
                    hasMultipleOptions = true
                    break
                end
            end

            if ( hasMultipleOptions ) then
                self:PopulateFactionSelect()
            else
                self:PopulateCreateCharacter()
            end
        end
    end

    local bHasCharacters = table.Count(ply.owCharacters or {}) > 0
    if ( bHasCharacters ) then
        local selectButton = buttons:Add("ow.mainmenu.button")
        selectButton:Dock(TOP)
        selectButton:SetText("SELECT CHARACTER")
        selectButton:DockMargin(0, 0, 0, 8)

        selectButton.DoClick = function()
            self:PopulateSelectCharacter()
        end
    end

    local settingsButton = buttons:Add("ow.mainmenu.button")
    settingsButton:Dock(TOP)
    settingsButton:SetText("SETTINGS")
    settingsButton:DockMargin(0, 0, 0, 8)

    settingsButton.DoClick = function()
        self:PopulateSettings()
    end

    local disconnectButton = buttons:Add("ow.mainmenu.button")
    disconnectButton:Dock(TOP)
    disconnectButton:SetText("DISCONNECT")
    disconnectButton:SetTextColor(ow.color:Get("maroon"))

    disconnectButton.DoClick = function()
        Derma_Query("Are you sure you want to disconnect?", "Disconnect", "Yes", function()
            RunConsoleCommand("disconnect")
        end, "No")
    end
end

function PANEL:PopulateFactionSelect()
    self:Clear()

    local title = self:Add("DLabel")
    title:Dock(TOP)
    title:DockMargin(padding, padding, padding, 0)
    title:SetFont("ow.fonts.title")
    title:SetText("CREATE CHARACTER")
    title:SetTextColor(hook.Run("GetFrameworkColor"))
    title:SetExpensiveShadow(4, color_black)
    title:SizeToContents()

    local subtitle = self:Add("DLabel")
    subtitle:Dock(TOP)
    subtitle:DockMargin(padding * 1.5, 0, padding, 0)
    subtitle:SetFont("ow.fonts.subtitle")
    subtitle:SetText("SELECT YOUR FACTION")
    subtitle:SetTextColor(color_white)
    subtitle:SetExpensiveShadow(4, color_black)
    subtitle:SizeToContents()

    local navigation = self:Add("EditablePanel")
    navigation:Dock(BOTTOM)
    navigation:DockMargin(padding, 0, padding, padding)
    navigation:SetTall(ScreenScale(24))

    local backButton = navigation:Add("ow.mainmenu.button")
    backButton:Dock(LEFT)
    backButton:SetText("BACK")
    backButton.DoClick = function()
        self:Populate()
    end

    local factionList = self:Add("DPanel")
    factionList:Dock(FILL)
    factionList:DockMargin(padding * 2, padding, padding * 2, padding)
    factionList.Paint = nil

    for k, v in ipairs(ow.faction:GetAll()) do
        if ( !ow.faction:CanSwitchTo(LocalPlayer(), v.Index) ) then continue end

        local factionButton = factionList:Add("ow.mainmenu.button")
        factionButton:Dock(LEFT)
        factionButton:SetText(v.Name or "Unknown Faction")
        factionButton:SetWide(self:GetWide() / 2 - padding * 4)

        factionButton.DoClick = function()
            self.currentCreatePage = 0
            self.currentCreatePayload = {}
            self.currentCreatePayload.factionIndex = v.Index

            self:PopulateCreateCharacter()
        end
    end
end

function PANEL:PopulateCreateCharacter()
    self:Clear()

    local title = self:Add("DLabel")
    title:Dock(TOP)
    title:DockMargin(padding, padding, padding, 0)
    title:SetFont("ow.fonts.title")
    title:SetText("CREATE CHARACTER")
    title:SetTextColor(hook.Run("GetFrameworkColor"))
    title:SetExpensiveShadow(4, color_black)
    title:SizeToContents()

    local subtitle = self:Add("DLabel")
    subtitle:Dock(TOP)
    subtitle:DockMargin(padding * 1.5, 0, padding, 0)
    subtitle:SetFont("ow.fonts.subtitle")
    subtitle:SetText("DEFINE YOUR NAME AND APPEARANCE")
    subtitle:SetTextColor(color_white)
    subtitle:SetExpensiveShadow(4, color_black)
    subtitle:SizeToContents()

    local navigation = self:Add("EditablePanel")
    navigation:Dock(BOTTOM)
    navigation:DockMargin(padding, 0, padding, padding)
    navigation:SetTall(ScreenScale(24))

    local backButton = navigation:Add("ow.mainmenu.button")
    backButton:Dock(LEFT)
    backButton:SetText("BACK")

    backButton.DoClick = function()
        if ( self.currentCreatePage == 0 ) then
            local hasMultipleOptions = false
            for k, v in pairs(ow.faction:GetAll()) do
                if ( ow.faction:CanSwitchTo(LocalPlayer(), v.Index) ) then
                    hasMultipleOptions = true
                    break
                end
            end

            if ( hasMultipleOptions ) then
                self:PopulateFactionSelect()
            else
                self:Populate()
            end
        else
            self.currentCreatePage = self.currentCreatePage - 1
            self:PopulateCreateCharacterForm()
        end
    end

    local nextButton = navigation:Add("ow.mainmenu.button")
    nextButton:Dock(RIGHT)
    nextButton:SetText("NEXT")

    nextButton.DoClick = function()
        -- TODO: Validate the form data of the current page

        self.currentCreatePage = self.currentCreatePage + 1
        self:PopulateCreateCharacterForm()
    end

    self:PopulateCreateCharacterForm()
end

function PANEL:PopulateCreateCharacterForm()
    if ( !IsValid(self.characterCreateForm) ) then
        self.characterCreateForm = self:Add("EditablePanel")
        self.characterCreateForm:Dock(FILL)
        self.characterCreateForm:DockMargin(padding * 6, smallPadding, padding * 6, padding)
    else
        self.characterCreateForm:Clear()
    end

    local zPos = 0
    for k, v in pairs(ow.character.variables) do
        if ( v.Editable != true ) then continue end

        local page = v.Page or 0
        if ( page != self.currentCreatePage ) then continue end

        if ( v.OnPopulate ) then
            v:OnPopulate(self.characterCreateForm, self.currentCreatePayload)
            continue
        end

        if ( v.Type == ow.type.string ) then
            zPos = zPos + 1 + v.ZPos

            local label = self.characterCreateForm:Add("ow.text")
            label:Dock(TOP)
            label:SetText(v.DisplayName or k)
            label:SetFont("ow.fonts.button")
            label:SetTextColor(color_white)
            label:SizeToContents()

            zPos = zPos - 1
            label:SetZPos(zPos)
            zPos = zPos + 1

            local entry = self.characterCreateForm:Add("ow.text.entry")
            entry:Dock(TOP)
            entry:DockMargin(0, 0, 0, smallPadding)
            entry:SetFont("ow.fonts.button")
            entry:SetTextColor(color_white)
            entry:SetPlaceholderText(v.Default or "")
            entry:SetZPos(zPos)
        elseif ( v.Type == ow.type.text ) then
            zPos = zPos + 1 + v.ZPos

            local label = self.characterCreateForm:Add("ow.text")
            label:Dock(TOP)
            label:SetText(v.DisplayName or k)
            label:SetFont("ow.fonts.button")
            label:SetTextColor(color_white)
            label:SizeToContents()

            zPos = zPos - 1
            label:SetZPos(zPos)
            zPos = zPos + 1

            local entry = self.characterCreateForm:Add("ow.text.entry")
            entry:Dock(TOP)
            entry:DockMargin(0, 0, 0, smallPadding)
            entry:SetFont("ow.fonts.button")
            entry:SetTextColor(color_white)
            entry:SetPlaceholderText(v.Default or "")
            entry:SetMultiline(true)
            entry:SetTall(ScreenScale(32))
            entry:SetZPos(zPos)
        end
    end
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

function PANEL:Paint(width, height)
    paint.rects.drawRect(0, 0, width / 2, height, color_black, gradientLeft)
end

vgui.Register("ow.mainmenu", PANEL, "EditablePanel")

if ( IsValid(ow.gui.mainmenu) ) then
    ow.gui.mainmenu:Remove()

    timer.Simple(0.1, function()
        vgui.Create("ow.mainmenu")
    end)
end