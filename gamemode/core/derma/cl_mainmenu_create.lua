local padding = ScreenScale(32)
local smallPadding = ScreenScale(16)

DEFINE_BASECLASS("EditablePanel")

local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, 0)
    self:SetVisible(false)

    self.currentCreatePage = 0
    self.currentCreatePayload = {}
end

function PANEL:PopulateFactionSelect()
    local parent = self:GetParent()
    parent:SetGradientLeftTarget(0)
    parent:SetGradientRightTarget(0)
    parent:SetGradientTopTarget(1)
    parent:SetGradientBottomTarget(1)
    parent.container:Clear()
    parent.container:SetVisible(false)

    self:Clear()
    self:SetVisible(true)

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

    local backButton = navigation:Add("DButton")
    backButton:Dock(LEFT)
    backButton:SetText("BACK")
    backButton.DoClick = function()
        self.currentCreatePage = 0
        self.currentCreatePayload = {}
        parent:Populate()

        self:Clear()
        self:SetVisible(false)
    end

    local factionList = self:Add("DPanel")
    factionList:Dock(FILL)
    factionList:DockMargin(padding * 2, padding, padding * 2, padding)
    factionList.Paint = nil

    for k, v in ipairs(ow.faction:GetAll()) do
        if ( !ow.faction:CanSwitchTo(LocalPlayer(), v.Index) ) then continue end

        local factionButton = factionList:Add("DButton")
        factionButton:Dock(LEFT)
        factionButton:SetText(v.Name or "Unknown Faction")
        factionButton:SetWide(self:GetWide() / 2 - padding * 4) -- In HL2 the create background images are 2048x1024

        factionButton.DoClick = function()
            self.currentCreatePage = 0
            self.currentCreatePayload = {}
            self.currentCreatePayload.factionIndex = v.Index

            self:PopulateCreateCharacter()
        end
    end
end

function PANEL:PopulateCreateCharacter()
    local parent = self:GetParent()
    parent:SetGradientLeftTarget(0)
    parent:SetGradientRightTarget(0)
    parent:SetGradientTopTarget(1)
    parent:SetGradientBottomTarget(1)
    parent.container:Clear()
    parent.container:SetVisible(false)

    self:Clear()
    self:SetVisible(true)

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

    local backButton = navigation:Add("DButton")
    backButton:Dock(LEFT)
    backButton:SetText("BACK")

    backButton.DoClick = function()
        if ( self.currentCreatePage == 0 ) then
            local hasMultipleOptions = false
            for k, v in ipairs(ow.faction:GetAll()) do
                if ( ow.faction:CanSwitchTo(LocalPlayer(), v.Index) ) then
                    hasMultipleOptions = true
                    break
                end
            end

            if ( hasMultipleOptions ) then
                self:PopulateFactionSelect()
            else
                self.currentCreatePage = 0
                self.currentCreatePayload = {}
                parent:Populate()
                self:Clear()
            end
        else
            self.currentCreatePage = self.currentCreatePage - 1
            self:PopulateCreateCharacterForm()
        end
    end

    local nextButton = navigation:Add("DButton")
    nextButton:Dock(RIGHT)
    nextButton:SetText("NEXT")

    nextButton.DoClick = function()
        local isNextEmpty = true
        for k, v in pairs(ow.character.variables) do
            if ( v.Editable != true ) then continue end

            local page = v.Page or 0
            if ( page != self.currentCreatePage + 1 ) then continue end

            if ( v.OnValidate ) then
                isNextEmpty = v:OnValidate(self.characterCreateForm, self.currentCreatePayload)
                if ( isNextEmpty ) then break end
            end

            if ( v.Type == ow.type.string ) then
                local entry = self.characterCreateForm:GetChild(k)
                if ( entry and entry:GetValue() != "" ) then
                    self.currentCreatePayload[k] = entry:GetValue()
                    isNextEmpty = false
                end
            elseif ( v.Type == ow.type.text ) then
                local entry = self.characterCreateForm:GetChild(k)
                if ( entry and entry:GetValue() != "" ) then
                    self.currentCreatePayload[k] = entry:GetValue()
                    isNextEmpty = false
                end
            end
        end

        if ( isNextEmpty ) then
            -- TODO: Start networking to create the character

            net.Start("ow.character.create")
                net.WriteTable(self.currentCreatePayload)
            net.SendToServer()
        else
            self.currentCreatePage = self.currentCreatePage + 1
            self:PopulateCreateCharacterForm()
        end
    end

    self:PopulateCreateCharacterForm()
end

function PANEL:PopulateCreateCharacterForm()
    self:SetVisible(true)

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

vgui.Register("ow.mainmenu.create", PANEL, "EditablePanel")