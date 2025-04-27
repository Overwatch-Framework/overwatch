local PANEL = {}

AccessorFunc(PANEL, "min", "Min", FORCE_NUMBER)
AccessorFunc(PANEL, "max", "Max", FORCE_NUMBER)
AccessorFunc(PANEL, "decimals", "Decimals", FORCE_NUMBER)

function PANEL:Init()
    self.min = 0
    self.max = 100
    self.decimals = 0
    self.value = 0
    self.dragging = false
end

function PANEL:SetValue(value, bNoNotify)
    if ( value < self.min ) then value = self.min end
    if ( value > self.max ) then value = self.max end

    self.value = math.Round(value, self.decimals)

    if ( !bNoNotify and self.OnValueChanged ) then
        self:OnValueChanged(self.value)
    end
end

function PANEL:GetValue()
    return self.value
end

function PANEL:OnValueChanged(value)
    -- Override this function to handle value changes
end

function PANEL:Paint(width, height)
    draw.RoundedBox(0, 0, 0, width, height, Color(200, 200, 200, 100))
    local fraction = (self.value - self.min) / (self.max - self.min)
    local barWidth = math.Clamp(fraction * width, 0, width)
    draw.RoundedBox(0, 0, 0, barWidth, height, color_white)
end

function PANEL:OnMousePressed(mouseCode)
    if ( mouseCode == MOUSE_LEFT ) then
        self.dragging = true
        self:MouseCapture(true)
        self:OnCursorMoved(self:CursorPos())
    end
end

function PANEL:OnMouseReleased()
    self.dragging = false
    self:MouseCapture(false)
end

function PANEL:OnCursorMoved(x, y)
    if ( !self.dragging ) then return end

    local value = math.Clamp((x / self:GetWide()) * (self.max - self.min) + self.min, self.min, self.max)

    self:SetValue(value)
end

vgui.Register("ow.slider", PANEL, "EditablePanel")