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
    self.container:GetVBar():SetWide(0)
    self.container.Paint = nil

    local categories = {}
    for k, v in pairs(ow.config.stored) do
        if ( table.HasValue(categories, v.Category) ) then continue end

        table.insert(categories, v.Category)
    end

    for k, v in SortedPairs(categories) do
        local button = self.buttons:Add("ow.button.small")
        button:Dock(LEFT)
        button:SetText(v)
        button:SizeToContents()

        button.DoClick = function()
            self:PopulateCategory(v)
        end
    end

    if ( ow.gui.configLast ) then
        self:PopulateCategory(ow.gui.configLast)
    else
        self:PopulateCategory(categories[1])
    end
end

function PANEL:PopulateCategory(category)
    ow.gui.configLast = category

    self.container:Clear()

    local config = {}
    for k, v in pairs(ow.config.stored) do
        if ( string.lower(v.Category) == string.lower(category) ) then
            table.insert(config, v)
        end
    end

    table.sort(config, function(a, b)
        return ow.localization:GetPhrase(a.Name) < ow.localization:GetPhrase(b.Name)
    end)

    local subCategories = {}
    for k, v in ipairs(config) do
        local subCategory = string.lower(v.SubCategory or "")
        if ( subCategory and !subCategories[subCategory] ) then
            subCategories[subCategory] = true
        end
    end

    if ( table.Count(subCategories) > 1 ) then
        for k, v in SortedPairs(subCategories) do
            local label = self.container:Add("ow.text")
            label:Dock(TOP)
            label:DockMargin(0, 0, 0, ScreenScale(4))
            label:SetFont("ow.fonts.title")
            label:SetText(string.upper(k))

            for k2, v2 in SortedPairs(config) do
                if ( string.lower(v2.SubCategory or "") == string.lower(k) ) then
                    self:AddConfig(v2)
                end
            end
        end
    else
        for k, v in SortedPairs(config) do
            self:AddConfig(v)
        end
    end
end

function PANEL:AddConfig(configData)
    local value = ow.config:Get(configData.UniqueID)

    local panel = self.container:Add("ow.button.small")
    panel:Dock(TOP)
    panel:SetText(configData.Name)
    panel:SetTall(ScreenScale(20))
    panel:SetContentAlignment(4)
    panel:SetTextInset(ScreenScale(6), 0)

    local enabled = ow.localization:GetPhrase("enabled")
    local disabled = ow.localization:GetPhrase("disabled")
    local unknown = ow.localization:GetPhrase("unknown")

    local label
    local configs
    if ( configData.Type == ow.type.bool ) then
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
            net.Start("ow.config.set")
                net.WriteString(configData.UniqueID)
                net.WriteType(!value)
            net.SendToServer()

            value = !value

            label:SetText(value and "< " .. enabled .. " >" or "< " .. disabled .. " >", true)
        end

        panel.DoRightClick = function()
            local menu = DermaMenu()
            menu:AddOption(ow.localization:GetPhrase("reset"), function()
                net.Start("ow.config.reset")
                    net.WriteString(configData.UniqueID)
                net.SendToServer()

                value = ow.config:GetDefault(configData.UniqueID)
                label:SetText(value and enabled or disabled, true)
            end)
            menu:Open()
        end
    elseif ( configData.Type == ow.type.number ) then
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

        slider:SetMin(configData.Min or 0)
        slider:SetMax(configData.Max or 100)
        slider:SetDecimals(configData.Decimals or 0)
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

        slider.OnValueSet = function(this, _)
            value = this:GetValue()
            label:SetText(this:GetValue())
        end

        slider.OnValueChanged = function(this, _)
            net.Start("ow.config.set")
                net.WriteString(configData.UniqueID)
                net.WriteType(this:GetValue())
            net.SendToServer()
            ow.localClient:EmitSound("ui/buttonrollover.wav", 100, 100, 1, CHAN_STATIC)
        end

        panel.DoClick = function(this)
            if ( !slider.bCursorInside ) then
                net.Start("ow.config.reset")
                    net.WriteString(configData.UniqueID)
                net.SendToServer()

                value = ow.config:GetDefault(configData.UniqueID)
                slider:SetValue(value)
                label:SetText(value)

                return
            end

            slider.dragging = true
            slider:MouseCapture(true)
            slider:OnCursorMoved(slider:CursorPos())
        end

        panel.DoRightClick = function(this)
            local menu = DermaMenu()
            menu:AddOption(ow.localization:GetPhrase("reset"), function()
                net.Start("ow.config.reset")
                    net.WriteString(configData.UniqueID)
                net.SendToServer()

                value = ow.config:GetDefault(configData.UniqueID)
                slider:SetValue(value)
                label:SetText(value)
            end)
            menu:Open()
        end
    elseif ( configData.Type == ow.type.array ) then
        configs = configData:Populate()
        local keys = {}
        for k2, _ in pairs(configs) do
            table.insert(keys, k2)
        end

        local phrase = (configs and configs[value]) and ow.localization:GetPhrase(configs[value]) or unknown

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

            net.Start("ow.config.set")
                net.WriteString(configData.UniqueID)
                net.WriteType(nextKey)
            net.SendToServer()

            value = nextKey

            label:SetText("< " .. (configs and configs[value] or "Unknown") .. " >", true)
        end

        panel.DoRightClick = function()
            local menu = DermaMenu()
            menu:AddOption(ow.localization:GetPhrase("reset"), function()
                net.Start("ow.config.reset")
                    net.WriteString(configData.UniqueID)
                net.SendToServer()

                value = ow.config:GetDefault(configData.UniqueID)
                label:SetText(configs and configs[value] or unknown, true)
            end)
            menu:AddSpacer()
            for k2, v2 in SortedPairs(configs) do
                menu:AddOption(v2, function()
                    net.Start("ow.config.set")
                        net.WriteString(configData.UniqueID)
                        net.WriteType(k2)
                    net.SendToServer()

                    value = k2

                    phrase = (configs and configs[value]) and ow.localization:GetPhrase(configs[value]) or unknown
                    label:SetText(panel:IsHovered() and "< " .. phrase .. " >" or phrase, true)
                end)
            end
            menu:Open()
        end
    elseif ( configData.Type == ow.type.color ) then
        local color = panel:Add("DPanel")
        color:Dock(RIGHT)
        color:DockMargin(ScreenScale(8), ScreenScale(6), ScreenScale(8), ScreenScale(6))
        color:SetWide(ScreenScale(128))
        color:SetBackgroundColor(value)
        color:SetMouseInputEnabled(false)
        color.Paint = function(this, width, height)
            draw.RoundedBox(0, 0, 0, width, height, this:GetBackgroundColor())
        end

        panel.DoClick = function()
            local blocker = vgui.Create("DPanel", self)
            blocker:SetSize(ScrW(), ScrH())
            blocker:SetPos(0, 0)
            blocker:MakePopup()
            blocker.Paint = function(this, width, height)
                ow.util:DrawBlur(this, 2)
                draw.RoundedBox(0, 0, 0, width, height, Color(0, 0, 0, 200))
            end
            blocker.OnMousePressed = function(this, key)
                if ( key == MOUSE_LEFT ) then
                    this:Remove()
                end
            end
            blocker.OnKeyPressed = function(this, key)
                this:Remove()
            end
            blocker.Think = function(this)
                if ( ! system.HasFocus() ) then
                    this:Remove()
                end
            end
            blocker.OnRemove = function(this)
                net.Start("ow.config.set")
                    net.WriteString(configData.UniqueID)
                    net.WriteType(value)
                net.SendToServer()
            end

            local frame = blocker:Add("DPanel")
            frame:SetSize(300, 200)
            frame:SetPos(gui.MouseX() - 150, gui.MouseY() - 100)
            frame.Paint = nil

            local mixer = frame:Add("DColorMixer")
            mixer:Dock(FILL)
            mixer:SetAlphaBar(false)
            mixer:SetPalette(true)
            mixer:SetWangs(true)
            mixer:SetColor(value)
            mixer.ValueChanged = function(this, old)
                local new = Color(old.r, old.g, old.b, 255)
                value = new
                color:SetBackgroundColor(new)
            end
        end

        panel.DoRightClick = function()
            local menu = DermaMenu()
            menu:AddOption(ow.localization:GetPhrase("reset"), function()
                net.Start("ow.config.reset")
                    net.WriteString(configData.UniqueID)
                net.SendToServer()

                value = ow.config:GetDefault(configData.UniqueID)
                color:SetBackgroundColor(value)
            end)
            menu:Open()
        end
    end

    panel.OnHovered = function(this)
        if ( configData.Type == ow.type.bool ) then
            label:SetText(value and "< " .. enabled .. " >" or "< " .. disabled .. " >", true)
        elseif ( configData.Type == ow.type.array ) then
            local phrase = (configs and configs[value]) and ow.localization:GetPhrase(configs[value]) or unknown
            label:SetText("< " .. phrase .. " >", true)
        end

        if ( !IsValid(ow.gui.tooltip) ) then
            ow.gui.tooltip = vgui.Create("ow.tooltip")
            ow.gui.tooltip:SetText(configData.Name, configData.Description)
            ow.gui.tooltip:SizeToContents()
            ow.gui.tooltip:SetPanel(this)
        else
            ow.gui.tooltip:SetText(configData.Name, configData.Description)
            ow.gui.tooltip:SizeToContents()

            timer.Simple(0, function()
                if ( IsValid(ow.gui.tooltip) ) then
                    ow.gui.tooltip:SetPanel(this)
                end
            end)
        end
    end

    panel.OnUnHovered = function(this)
        if ( configData.Type == ow.type.bool ) then
            label:SetText(value and enabled or disabled, true)
        elseif ( configData.Type == ow.type.array ) then
            local phrase = (configs and configs[value]) and ow.localization:GetPhrase(configs[value]) or unknown
            label:SetText(phrase, true)
        end

        if ( IsValid(ow.gui.tooltip) ) then
            ow.gui.tooltip:SetPanel(nil)
        end
    end
end

vgui.Register("ow.config", PANEL, "EditablePanel")

ow.gui.configLast = nil