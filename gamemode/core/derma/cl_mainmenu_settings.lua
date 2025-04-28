local padding = ScreenScale(32)

DEFINE_BASECLASS("EditablePanel")

local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, 0)
    self:SetVisible(false)
end

function PANEL:Populate()
    local parent = self:GetParent()
    parent:SetGradientLeftTarget(0)
    parent:SetGradientRightTarget(0)
    parent:SetGradientTopTarget(1)
    parent:SetGradientBottomTarget(1)
    parent:SetDimTarget(0.25)
    parent.container:Clear()
    parent.container:SetVisible(false)

    self:SetVisible(true)

    local title = self:Add("DLabel")
    title:Dock(TOP)
    title:DockMargin(padding, padding, padding, 0)
    title:SetFont("ow.fonts.title")
    title:SetText("SETTINGS")
    title:SetTextColor(color_white)
    title:SizeToContents()

    local navigation = self:Add("EditablePanel")
    navigation:Dock(BOTTOM)
    navigation:DockMargin(padding, 0, padding, padding)
    navigation:SetTall(ScreenScale(24))

    local backButton = navigation:Add("ow.mainmenu.button.small")
    backButton:Dock(LEFT)
    backButton:SetText("BACK")
    backButton.DoClick = function()
        self.currentCreatePage = 0
        self.currentCreatePayload = {}
        parent:Populate()

        self:Clear()
        self:SetVisible(false)
    end

    self.buttons = self:Add("DHorizontalScroller")
    self.buttons:Dock(TOP)
    self.buttons:DockMargin(padding, padding / 8, padding, 0)
    self.buttons:SetTall(ScreenScale(24))
    self.buttons.Paint = nil

    self.container = self:Add("DScrollPanel")
    self.container:Dock(FILL)
    self.container:DockMargin(padding, 0, padding, 0)
    self.container.Paint = nil

    local categories = {}
    for k, v in pairs(ow.option.stored) do
        if categories[v.Category] then continue end

        categories[v.Category] = true 
    end

    for k, v in SortedPairs(categories) do
        local button = self.buttons:Add("ow.mainmenu.button.small")
        button:Dock(LEFT)
        button:SetText(k)
        button:SizeToContents()

        button.DoClick = function()
            self:PopulateCategory(k)
        end
    end

    if ( ow.gui.settingsLast ) then
        self:PopulateCategory(ow.gui.settingsLast)
    else
        self:PopulateCategory(categories[1])
    end
end

function PANEL:PopulateCategory(category)
    ow.gui.settingsLast = category
    self.activeCategory = category
    self.container:Clear()

    local settings = {}
    for k, v in pairs(ow.option.stored) do
        if ( v.Category == category ) then
            table.insert(settings, v)
        end
    end

    table.sort(settings, function(a, b)
        return a.Name < b.Name
    end)

    for k, v in ipairs(settings) do
        local value = ow.option:Get(v.UniqueID)

        local panel = self.container:Add("ow.mainmenu.button.small")
        panel:Dock(TOP)
        panel:SetText(v.Name)
        panel:SetTall(ScreenScale(20))
        panel:SetContentAlignment(4)
        panel:SetTextInset(ScreenScale(6), 0)

        if ( v.Type == ow.type.bool ) then
            local label = panel:Add("ow.text")
            label:Dock(RIGHT)
            label:DockMargin(0, 0, ScreenScale(8), 0)
            label:SetText(value and "Enabled" or "Disabled")
            label:SetFont("ow.fonts.button")
            label:SetExpensiveShadow(0, Color(0, 0, 0, 150))
            label:SetWide(ScreenScale(128))
            label:SetContentAlignment(6)
            label.Think = function(this)
                this:SetTextColor(panel:GetTextColor())
            end

            panel.DoClick = function()
                ow.option:Set(v.UniqueID, !value)
                value = !value

                label:SetText(value and "< Enabled >" or "< Disabled >")
            end

            panel.OnHovered = function(this)
                label:SetText(value and "< Enabled >" or "< Disabled >")
            end

            panel.OnUnHovered = function(this)
                label:SetText(value and "Enabled" or "Disabled")
            end
        elseif ( v.Type == ow.type.number ) then
            local slider = panel:Add("ow.slider")
            slider:Dock(RIGHT)
            slider:DockMargin(ScreenScale(8), ScreenScale(6), ScreenScale(8), ScreenScale(6))
            slider:SetWide(ScreenScale(128))
            slider:SetMouseInputEnabled(false)

            slider.Paint = function(this, width, height)
                draw.RoundedBox(0, 0, 0, width, height, ow.colour:Get("slider.background"))
                local fraction = (this.value - this.min) / (this.max - this.min)
                local barWidth = math.Clamp(fraction * width, 0, width)
                local inertia = panel:GetInertia()
                local full = 255 * (-inertia + 1)
                draw.RoundedBox(0, 0, 0, barWidth, height, Color(full, full, full, 255))
            end

            slider.Think = function(this)
                local x, y = this:CursorPos()
                local w, h = this:GetSize()

                this.bCursorInside = x >= 0 and x <= w and y >= 0 and y <= h
            end

            slider:SetMin(v.Min or 0)
            slider:SetMax(v.Max or 100)
            slider:SetDecimals(v.Decimals or 0)
            slider:SetValue(value)

            local label = panel:Add("ow.text")
            label:Dock(RIGHT)
            label:DockMargin(0, 0, -ScreenScale(4), 8)
            label:SetText(value)
            label:SetFont("ow.fonts.button.small")
            label:SetExpensiveShadow(0, Color(0, 0, 0, 150))
            label:SetWide(ScreenScale(128))
            label:SetContentAlignment(6)
            label.Think = function(this)
                this:SetTextColor(panel:GetTextColor())
            end

            slider.OnValueChanged = function(this, _)
                ow.option:Set(v.UniqueID, this:GetValue())
                value = this:GetValue()
                label:SetText(this:GetValue())
            end

            panel.DoClick = function(this)
                if ( !slider.bCursorInside ) then
                    ow.option:Reset(v.UniqueID)
                    value = ow.option:Get(v.UniqueID)
                    slider:SetValue(value)
                    return
                end

                slider.dragging = true
                slider:MouseCapture(true)
                slider:OnCursorMoved(slider:CursorPos())
            end
        elseif ( v.Type == ow.type.array ) then
            local options = v:Populate()
            local keys = {}
            for k2, _ in pairs(options) do
                table.insert(keys, k2)
            end

            local label = panel:Add("ow.text")
            label:Dock(RIGHT)
            label:DockMargin(0, 0, ScreenScale(8), 0)
            label:SetText(options and options[value] or "Unknown")
            label:SetFont("ow.fonts.button")
            label:SetExpensiveShadow(0, Color(0, 0, 0, 150))
            label:SetWide(ScreenScale(128))
            label:SetContentAlignment(6)
            label.Think = function(this)
                this:SetTextColor(panel:GetTextColor())
            end

            panel.DoClick = function()
                -- Pick the next key depending on where the cursor is near the label, if the cursor is near the left side of the label, pick the previous key, if it's near the right side, pick the next key.
                local x, y = label:CursorPos()
                local w, h = label:GetSize()
                local percent = x / w
                local nextKey = nil
                for i = 1, #keys do
                    if ( keys[i] == value ) then
                        if ( percent < 0.5 ) then
                            nextKey = keys[i - 1] or keys[#keys]
                        else
                            nextKey = keys[i + 1] or keys[1]
                        end

                        break
                    end
                end

                nextKey = nextKey or keys[1]
                nextKey = tostring(nextKey)

                ow.option:Set(v.UniqueID, nextKey)
                value = nextKey

                label:SetText("< " .. (options and options[value] or "Unknown") .. " >")
                label:SizeToContents()
            end

            panel.DoRightClick = function()
                local menu = DermaMenu()
                for k2, v2 in SortedPairs(options) do
                    menu:AddOption(v2, function()
                        ow.option:Set(v.UniqueID, k2)
                        value = k2

                        label:SetText("< " .. (options and options[value] or "Unknown") .. " >")
                        label:SizeToContents()
                    end)
                end
                menu:Open()
            end

            panel.OnHovered = function(this)
                label:SetText("< " .. (options and options[value] or "Unknown") .. " >")
            end

            panel.OnUnHovered = function(this)
                label:SetText(options and options[value] or "Unknown")
            end
        end
    end
end

vgui.Register("ow.mainmenu.settings", PANEL, "EditablePanel")

ow.gui.settingsLast = nil