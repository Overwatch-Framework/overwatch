local padding = ScreenScale(32)

DEFINE_BASECLASS("EditablePanel")

local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)

    self.buttons = self:Add("DHorizontalScroller")
    self.buttons:Dock(TOP)
    self.buttons:DockMargin(0, padding / 8, 0, 0)
    self.buttons:SetTall(ScreenScale(24))
    self.buttons.Paint = nil

    self.container = self:Add("DScrollPanel")
    self.container:Dock(FILL)
    self.container.Paint = nil

    local categories = {}
    for k, v in pairs(ow.option.stored) do
        if ( table.HasValue(categories, v.Category) ) then continue end

        table.insert(categories, v.Category)
    end

    for k, v in SortedPairs(categories) do
        local button = self.buttons:Add("ow.mainmenu.button.small")
        button:Dock(LEFT)
        button:SetText(v)
        button:SizeToContents()

        button.DoClick = function()
            self:PopulateCategory(v)
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
        return ow.localization:GetPhrase(a.Name) < ow.localization:GetPhrase(b.Name)
    end)

    local subCategories = {}
    for k, v in ipairs(settings) do
        if ( v.SubCategory and !subCategories[v.SubCategory] ) then
            subCategories[v.SubCategory] = true
        end
    end

    local subCategoriesActive = {}
    for k, v in ipairs(settings) do
        if ( v.SubCategory and !subCategoriesActive[v.SubCategory] and table.Count(subCategories) > 1 ) then
            local label = self.container:Add("ow.text")
            label:Dock(TOP)
            label:DockMargin(0, 0, 0, ScreenScale(4))
            label:SetFont("ow.fonts.title")
            label:SetText(v.SubCategory:upper())

            subCategoriesActive[v.SubCategory] = true
        end

        local value = ow.option:Get(v.UniqueID)

        local panel = self.container:Add("ow.mainmenu.button.small")
        panel:Dock(TOP)
        panel:SetText(v.Name)
        panel:SetTall(ScreenScale(20))
        panel:SetContentAlignment(4)
        panel:SetTextInset(ScreenScale(6), 0)

        local enabled = ow.localization:GetPhrase("enabled")
        local disabled = ow.localization:GetPhrase("disabled")
        local unknown = ow.localization:GetPhrase("unknown")

        local label
        local options
        if ( v.Type == ow.type.bool ) then
            label = panel:Add("ow.text")
            label:Dock(RIGHT)
            label:DockMargin(0, 0, ScreenScale(8), 0)
            label:SetText(value and enabled or disabled, true)
            label:SetFont("ow.fonts.button")
            label:SetWide(ScreenScale(128))
            label:SetContentAlignment(6)
            label.Think = function(this)
                this:SetTextColor(panel:GetTextColor())
            end

            panel.DoClick = function()
                ow.option:Set(v.UniqueID, !value)
                value = !value

                label:SetText(value and "< " .. enabled .. " >" or "< " .. disabled .. " >", true)
            end
        elseif ( v.Type == ow.type.number ) then
            local slider = panel:Add("ow.slider")
            slider:Dock(RIGHT)
            slider:DockMargin(ScreenScale(8), ScreenScale(6), ScreenScale(8), ScreenScale(6))
            slider:SetWide(ScreenScale(128))
            slider:SetMouseInputEnabled(false)

            slider.Paint = function(this, width, height)
                draw.RoundedBox(0, 0, 0, width, height, ow.color:Get("slider.background"))
                local fraction = (this.value - this.min) / (this.max - this.min)
                local barWidth = math.Clamp(fraction * width, 0, width)
                local inertia = panel:GetInertia()
                local full = 255 * (-inertia + 1)
                draw.RoundedBox(0, 0, 0, barWidth, height, Color(full, full, full, 255))
            end

            slider.Think = function(this)
                local x, y = this:CursorPos()
                local w, h = this:GetSize()
                if ( x >= 0 and x <= w and y >= 0 and y <= h ) then
                    this.bCursorInside = true
                else
                    this.bCursorInside = false
                end
            end

            slider:SetMin(v.Min or 0)
            slider:SetMax(v.Max or 100)
            slider:SetDecimals(v.Decimals or 0)
            slider:SetValue(value, true)

            label = panel:Add("ow.text")
            label:Dock(RIGHT)
            label:DockMargin(0, 0, -ScreenScale(4), 8)
            label:SetText(value)
            label:SetFont("ow.fonts.button.small")
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
                    label:SetText(value)
                    return
                end

                slider.dragging = true
                slider:MouseCapture(true)
                slider:OnCursorMoved(slider:CursorPos())
            end
        elseif ( v.Type == ow.type.array ) then
            options = v:Populate()
            local keys = {}
            for k2, _ in pairs(options) do
                table.insert(keys, k2)
            end

            local phrase = (options and options[value]) and ow.localization:GetPhrase(options[value]) or unknown

            label = panel:Add("ow.text")
            label:Dock(RIGHT)
            label:DockMargin(0, 0, ScreenScale(8), 0)
            label:SetText(phrase, true)
            label:SetFont("ow.fonts.button")
            label:SetWide(ScreenScale(128))
            label:SetContentAlignment(6)
            label.Think = function(this)
                this:SetTextColor(panel:GetTextColor())
            end

            panel.DoClick = function()
                -- Pick the next key depending on where the cursor is near the label, if the cursor is near the left side of the label, pick the previous key, if it's near the right side, pick the next key.
                local x, y = label:CursorPos() -- not used
                local w, h = label:GetSize() -- not used
                local percent = x / w
                local nextKey = nil
                for i = 1, #keys do
                    if ( keys[i] == value ) then
                        nextKey = keys[i + (percent < 0.5 and -1 or 1)] or keys[1]
                        break
                    end
                end

                nextKey = nextKey or keys[1]
                nextKey = tostring(nextKey)

                ow.option:Set(v.UniqueID, nextKey)
                value = nextKey

                label:SetText("< " .. (options and options[value] or "Unknown") .. " >", true)
                label:SizeToContents()
            end

            panel.DoRightClick = function()
                local menu = DermaMenu()
                for k2, v2 in SortedPairs(options) do
                    menu:AddOption(v2, function()
                        ow.option:Set(v.UniqueID, k2)
                        value = k2

                        phrase = (options and options[value]) and ow.localization:GetPhrase(options[value]) or unknown
                        label:SetText( panel:IsHovered() and "< " .. phrase .. " >" or phrase, true )

                        label:SizeToContents()
                    end)
                end
                menu:Open()
            end
        end

        panel.OnHovered = function(this)
            if ( v.Type == ow.type.bool ) then
                label:SetText(value and "< " .. enabled .. " >" or "< " .. disabled .. " >", true)
            elseif ( v.Type == ow.type.array ) then
                local phrase = (options and options[value]) and ow.localization:GetPhrase(options[value]) or unknown
                label:SetText("< " .. phrase .. " >", true)
            end

            if ( !IsValid(ow.gui.tooltip) ) then
                ow.gui.tooltip = vgui.Create("ow.tooltip")
                ow.gui.tooltip:SetText(v.Name, v.Description)
                ow.gui.tooltip:SizeToContents()
                ow.gui.tooltip:SetPanel(this)
            else
                ow.gui.tooltip:SetText(v.Name, v.Description)
                ow.gui.tooltip:SizeToContents()

                timer.Simple(0, function()
                    if ( IsValid(ow.gui.tooltip) ) then
                        ow.gui.tooltip:SetPanel(this)
                    end
                end)
            end
        end

        panel.OnUnHovered = function(this)
            if ( v.Type == ow.type.bool ) then
                label:SetText(value and enabled or disabled, true)
            elseif ( v.Type == ow.type.array ) then
                local phrase = (options and options[value]) and ow.localization:GetPhrase(options[value]) or unknown
                label:SetText(phrase, true)
            end

            if ( IsValid(ow.gui.tooltip) ) then
                ow.gui.tooltip:SetPanel(nil)
            end
        end
    end
end

vgui.Register("ow.settings", PANEL, "EditablePanel")

ow.gui.settingsLast = nil