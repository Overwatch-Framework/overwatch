local padding = ScreenScale(32)
local smallPadding = ScreenScale(16)
local tinyPadding = ScreenScale(8)

DEFINE_BASECLASS("EditablePanel")

local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, 0)
    self:SetVisible(false)

    self.currentCreatePage = 0
end

function PANEL:ResetPayload()
    self.currentCreatePage = 0

    for k, v in pairs(ow.character.variables) do
        if ( v.Editable != true ) then continue end

        -- This is a bit of a hack, but it works for now.
        if ( v.Type == ow.type.string or v.Type == ow.type.text ) then
            self:SetPayload(k, "")
        end
    end
end

function PANEL:SetPayload(key, value)
    if ( !self.currentCreatePayload ) then
        self.currentCreatePayload = {}
    end

    self.currentCreatePayload[key] = value
end

function PANEL:GetPayload(key)
    if ( !self.currentCreatePayload ) then
        self.currentCreatePayload = {}
    end

    return self.currentCreatePayload[key]
end

function PANEL:PopulateFactionSelect()
    local parent = self:GetParent()
    parent:SetGradientLeftTarget(0)
    parent:SetGradientRightTarget(0)
    parent:SetGradientTopTarget(1)
    parent:SetGradientBottomTarget(1)
    parent:SetDimTarget(0.25)
    parent.container:Clear()
    parent.container:SetVisible(false)

    self:Clear()
    self:SetVisible(true)

    local title = self:Add("ow.text")
    title:Dock(TOP)
    title:DockMargin(padding, padding, padding, 0)
    title:SetFont("ow.fonts.title")
    title:SetText(string.upper("mainmenu.create.character.faction"))

    local navigation = self:Add("EditablePanel")
    navigation:Dock(BOTTOM)
    navigation:DockMargin(padding, 0, padding, padding)
    navigation:SetTall(ScreenScale(24))

    local backButton = navigation:Add("ow.mainmenu.button.small")
    backButton:Dock(LEFT)
    backButton:SetText("BACK")
    backButton.DoClick = function()
        self.currentCreatePage = 0
        self:ResetPayload()

        self:Clear()
        self:SetVisible(false)
        parent:Populate()
    end

    local factionList = self:Add("DHorizontalScroller")
    factionList:Dock(FILL)
    factionList:DockMargin(padding, padding * 2, padding, padding)
    factionList:InvalidateParent(true)
    factionList.Paint = nil

    for k, v in ipairs(ow.faction:GetAll()) do
        if ( !ow.faction:CanSwitchTo(LocalPlayer(), v.Index) ) then continue end

        local name = (v.Name and string.upper(v.Name)) or "UNKNOWN FACTION"
        local description = (v.Description and string.upper(v.Description)) or "UNKNOWN FACTION DESCRIPTION"
        local descriptionWrapped = ow.util:WrapText(description, "ow.fonts.button.small", factionList:GetTall() * 1.5)

        -- In HL2 the create (chapter) background images are 2048x1024 -- thank you eon
        local factionButton = factionList:Add("ow.mainmenu.button.small")
        factionButton:Dock(LEFT)
        factionButton:DockMargin(0, 0, 16, 0)
        factionButton:SetText(v.Name or "Unknown Faction")
        factionButton:SetWide(factionList:GetTall() * 1.5)

        factionButton.DoClick = function()
            self.currentCreatePage = 0
            self:ResetPayload()
            self:SetPayload("factionIndex", v.Index)

            self:PopulateCreateCharacter()
        end

        local image = factionButton:Add("DPanel")
        image:Dock(FILL)
        image:SetMouseInputEnabled(false)
        image:SetSize(factionButton:GetTall(), factionButton:GetTall())
        --image:SetImage(v.Image or "gamepadui/chapter14")
        image.Paint = function(this, width, height)
            local imageHeight = height * 0.85
            imageHeight = math.Round(imageHeight)

            surface.SetDrawColor(color_white)
            surface.SetTexture(surface.GetTextureID(v.Image or "gamepadui/chapter14"))
            surface.DrawTexturedRect(0, 0, width, imageHeight)

            local inertia = factionButton:GetInertia()
            local boxHeightStatic = (height * 0.15)
            boxHeightStatic = math.Round(boxHeightStatic)

            local boxHeight = boxHeightStatic * inertia
            boxHeight = math.Round(boxHeight)
            draw.RoundedBox(0, 0, imageHeight - boxHeight, width, boxHeight, ColorAlpha(color_white, 255 * inertia))

            local textColor = factionButton:GetTextColor()

            draw.SimpleText(name, factionButton:IsHovered() and "ow.fonts.button.large.hover" or "ow.fonts.button.large", tinyPadding, imageHeight - boxHeight + boxHeightStatic / 2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            --draw.SimpleText(description, "ow.fonts.button.small", tinyPadding, imageHeight - boxHeight + boxHeightStatic, ColorAlpha(textColor, 255 * inertia), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            for i = 1, #descriptionWrapped do
                draw.SimpleText(descriptionWrapped[i], "ow.fonts.button.small", tinyPadding, imageHeight - boxHeight + boxHeightStatic + (i - 1) * ScreenScale(8), ColorAlpha(textColor, 255 * inertia), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
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

    local title = self:Add("ow.text")
    title:Dock(TOP)
    title:DockMargin(padding, padding, padding, 0)
    title:SetFont("ow.fonts.title")
    title:SetText(string.upper("mainmenu.create.character"))

    local navigation = self:Add("EditablePanel")
    navigation:Dock(BOTTOM)
    navigation:DockMargin(padding, 0, padding, padding)
    navigation:SetTall(ScreenScale(24))

    local backButton = navigation:Add("ow.mainmenu.button.small")
    backButton:Dock(LEFT)
    backButton:SetText("BACK")

    backButton.DoClick = function()
        if ( self.currentCreatePage == 0 ) then
            local availableFactions = 0
            for k, v in ipairs(ow.faction:GetAll()) do
                if ( ow.faction:CanSwitchTo(LocalPlayer(), v.Index) ) then
                    availableFactions = availableFactions + 1
                end
            end

            if ( availableFactions > 1 ) then
                self:PopulateFactionSelect()
            else
                self.currentCreatePage = 0
                self:ResetPayload()
                parent:Populate()
                self:Clear()
            end
        else
            self.currentCreatePage = self.currentCreatePage - 1
            self:PopulateCreateCharacterForm()
        end
    end

    local nextButton = navigation:Add("ow.mainmenu.button.small")
    nextButton:Dock(RIGHT)
    nextButton:SetText("NEXT")

    nextButton.DoClick = function()
        local isNextEmpty = true
        for k, v in pairs(ow.character.variables) do
            if ( v.Editable != true ) then continue end

            if ( isfunction(v.OnValidate) ) then
                local isValid, errorMessage = v:OnValidate(self.characterCreateForm, self.currentCreatePayload)
                if ( !isValid ) then
                    notification.AddLegacy(errorMessage, NOTIFY_ERROR, 5)
                    return
                end
            end

            local page = v.Page or 0
            if ( page != self.currentCreatePage + 1 ) then continue end

            if ( isfunction(v.OnValidate) ) then
                isNextEmpty = v:OnValidate(self.characterCreateForm, self.currentCreatePayload)
                if ( isNextEmpty ) then continue end
            end

            if ( v.Type == ow.type.string or v.Type == ow.type.text ) then
                local entry = self.characterCreateForm:GetChild(k)
                if ( entry and entry:GetValue() != "" ) then
                    self:SetPayload(k, entry:GetValue())
                    isNextEmpty = false
                end
            end
        end

        if ( isNextEmpty ) then
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

        if ( isfunction(v.OnPopulate) ) then
            v:OnPopulate(self.characterCreateForm, self.currentCreatePayload)
            continue
        end

        if ( v.Type == ow.type.string ) then
            zPos = zPos + 1 + v.ZPos

            local label = self.characterCreateForm:Add("ow.text")
            label:Dock(TOP)
            label:SetFont("ow.fonts.button")
            label:SetText(v.Name or k)

            zPos = zPos - 1
            label:SetZPos(zPos)
            zPos = zPos + 1

            local entry = self.characterCreateForm:Add("ow.text.entry")
            entry:Dock(TOP)
            entry:DockMargin(0, 0, 0, smallPadding)
            entry:SetFont("ow.fonts.button")
            entry:SetTextColor(color_white)
            entry:SetPlaceholderText(v.Default or "")
            entry:SetTall(ScreenScale(16))
            entry:SetZPos(zPos)

            entry:SetNumeric(v.Numeric or false)
            entry:SetAllowNonAsciiCharacters(v.AllowNonAscii or false)

            entry.OnTextChanged = function(this)
                local text = this:GetValue()

                if ( isfunction(v.OnChange) ) then
                    v:OnChange(this, text, self.currentCreatePayload)
                end

                self:SetPayload(k, text)
            end
        elseif ( v.Type == ow.type.text ) then
            zPos = zPos + 1 + v.ZPos

            local label = self.characterCreateForm:Add("ow.text")
            label:Dock(TOP)
            label:SetText(v.Name or k)
            label:SetFont("ow.fonts.button")
            label:SetTextColor(color_white)
            label:SizeToContents()

            zPos = zPos - 1
            label:SetZPos(zPos)
            zPos = zPos + 1

            local entry = self.characterCreateForm:Add("ow.text.entry")
            entry:Dock(TOP)
            entry:DockMargin(0, 0, 0, smallPadding)
            entry:SetFont("ow.fonts.button.small")
            entry:SetTextColor(color_white)
            entry:SetPlaceholderText(v.Default or "")
            entry:SetMultiline(true)
            entry:SetTall(ScreenScale(12) * 4)
            entry:SetZPos(zPos)

            entry.OnTextChanged = function(this)
                local text = this:GetValue()

                if ( isfunction(v.OnChange) ) then
                    v:OnChange(this, text, self.currentCreatePayload)
                end

                self:SetPayload(k, text)
            end
        end
    end
end

vgui.Register("ow.mainmenu.create", PANEL, "EditablePanel")