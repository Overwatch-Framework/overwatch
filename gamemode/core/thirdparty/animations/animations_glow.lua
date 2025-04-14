--[[
    Glow Animation for Garry's Mod
    
    A pulsating glow effect with customizable properties.
    Part of the DDI Modern UI Animations package.
]]

local PANEL = {}

-- Default configuration
local DefaultConfig = {
    GlowColor = Color(70, 150, 255, 200),   -- Main glow color
    SecondaryColor = Color(255, 70, 150, 200), -- Secondary glow color
    PulseSpeed = 1,                  -- Speed of the pulsation
    MaxGlowSize = 15,                -- Maximum radius of the glow
    MinGlowSize = 5,                 -- Minimum radius of the glow
    GlowShape = 'circle',            -- Shape of the glow: circle, square, hexagon
    GlowIntensity = 0.8,             -- Glow intensity (0-1)
    MultiColor = false,              -- Use multiple colors
    ColorShift = false,              -- Shift colors over time
    ColorShiftSpeed = 1,             -- Speed of color shifting
    InteractionGlow = true,          -- Glow intensifies on mouse hover
    Content = nil,                   -- Optional content to display (text or material)
    ContentType = 'none',            -- Type of content: text, material, none
    ContentColor = Color(255, 255, 255, 255), -- Color of content
    Font = 'DermaLarge',             -- Font for text content
    DDIStyled = false                -- Use DDI styling
}

-- DDI styling options
local DDIStyling = {
    Colors = {
        Primary = Color(70, 150, 255),    -- DDI Blue
        Secondary = Color(255, 70, 150),  -- DDI Pink
        Accent = Color(100, 255, 100)     -- DDI Green
    },
    Shapes = {
        'circle',
        'square',
        'hexagon',
        'diamond'
    }
}

-- Initialize the panel
function PANEL:Init()
    self.Config = table.Copy(DefaultConfig)
    self.LastTime = CurTime()
    self.AnimationTime = 0
    self.HoverTime = 0
    self.IsHovered = false
    
    -- Default settings
    self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(false)
end

-- Apply configuration options
function PANEL:Configure(config)
    table.Merge(self.Config, config or {})
    
    -- Apply DDI styling if enabled
    if self.Config.DDIStyled then
        if not config or not config.GlowColor then
            self.Config.GlowColor = DDIStyling.Colors.Primary
        end
        if not config or not config.SecondaryColor then
            self.Config.SecondaryColor = DDIStyling.Colors.Secondary
        end
        if not config or not config.ContentColor then
            self.Config.ContentColor = DDIStyling.Colors.Accent
        end
        
        -- Enable multicolor by default for DDI styling
        if not config or not config.MultiColor then
            self.Config.MultiColor = true
        end
    end
    
    -- Load material if needed
    if self.Config.ContentType == 'material' and type(self.Config.Content) == 'string' then
        self.ContentMaterial = Material(self.Config.Content)
    else
        self.ContentMaterial = nil
    end
end

-- Handle mouse enter
function PANEL:OnCursorEntered()
    self.IsHovered = true
end

-- Handle mouse exit
function PANEL:OnCursorExited()
    self.IsHovered = false
end

-- Update the animation
function PANEL:Think()
    local currentTime = CurTime()
    local deltaTime = currentTime - self.LastTime
    self.LastTime = currentTime
    
    -- Update animation time
    self.AnimationTime = self.AnimationTime + deltaTime * self.Config.PulseSpeed
    
    -- Update hover effect
    if self.IsHovered then
        self.HoverTime = math.min(self.HoverTime + deltaTime * 2, 1)
    else
        self.HoverTime = math.max(self.HoverTime - deltaTime * 2, 0)
    end
end

-- Draw a circle glow
function PANEL:DrawCircleGlow(x, y, radius, color, intensity)
    local steps = math.max(8, math.floor(radius))
    
    for i = radius, 1, -1 do
        local alpha = (i / radius) * 255 * intensity
        local circleColor = Color(color.r, color.g, color.b, alpha)
        
        -- Проверяем доступность безопасной функции
        if surface.SafeDrawCircle then
            surface.SafeDrawCircle(x, y, i, steps, circleColor)
        else
            -- Запасной вариант с ручным рисованием
            surface.SetDrawColor(color.r, color.g, color.b, alpha)
            
            local vertices = {}
            for j = 0, steps do
                local angle = math.rad((j / steps) * 360)
                local px = x + math.cos(angle) * i
                local py = y + math.sin(angle) * i
                table.insert(vertices, {x = px, y = py})
            end
            
            if #vertices > 2 then
                surface.DrawPoly(vertices)
            end
        end
    end
end

-- Draw a square glow
function PANEL:DrawSquareGlow(x, y, radius, color, intensity)
    local size = radius * 2
    local centerX, centerY = x, y
    
    for i = 0, radius, 1 do
        local ratio = i / radius
        local alpha = (1 - ratio) * 255 * intensity
        local shrinkSize = size - (i * 2)
        
        surface.SetDrawColor(color.r, color.g, color.b, alpha)
        surface.DrawOutlinedRect(centerX - shrinkSize/2, centerY - shrinkSize/2, shrinkSize, shrinkSize, 1)
    end
end

-- Draw a hexagon glow
function PANEL:DrawHexagonGlow(x, y, radius, color, intensity)
    local centerX, centerY = x, y
    local sides = 6
    
    for r = radius, 1, -1 do
        local ratio = r / radius
        local alpha = (1 - ratio) * 255 * intensity
        surface.SetDrawColor(color.r, color.g, color.b, alpha)
        
        local points = {}
        for i = 0, sides do
            local angle = (i / sides) * math.pi * 2
            local px = centerX + math.sin(angle) * r
            local py = centerY + math.cos(angle) * r
            table.insert(points, {x = px, y = py})
        end
        
        for i = 1, #points - 1 do
            surface.DrawLine(points[i].x, points[i].y, points[i+1].x, points[i+1].y)
        end
    end
end

-- Draw a diamond glow
function PANEL:DrawDiamondGlow(x, y, radius, color, intensity)
    local centerX, centerY = x, y
    
    for r = radius, 1, -1 do
        local ratio = r / radius
        local alpha = (1 - ratio) * 255 * intensity
        surface.SetDrawColor(color.r, color.g, color.b, alpha)
        
        local points = {
            {x = centerX, y = centerY - r},         -- Top
            {x = centerX + r, y = centerY},         -- Right
            {x = centerX, y = centerY + r},         -- Bottom
            {x = centerX - r, y = centerY},         -- Left
            {x = centerX, y = centerY - r}          -- Back to top
        }
        
        for i = 1, #points - 1 do
            surface.DrawLine(points[i].x, points[i].y, points[i+1].x, points[i+1].y)
        end
    end
end

-- Get current glow color based on animation time
function PANEL:GetCurrentColor()
    if self.Config.ColorShift then
        local time = self.AnimationTime * self.Config.ColorShiftSpeed
        local r = math.sin(time) * 0.5 + 0.5
        local g = math.sin(time + 2) * 0.5 + 0.5
        local b = math.sin(time + 4) * 0.5 + 0.5
        return Color(
            r * 255, 
            g * 255, 
            b * 255,
            self.Config.GlowColor.a
        )
    else
        return self.Config.GlowColor
    end
end

-- Get current glow size based on animation
function PANEL:GetCurrentGlowSize()
    local min = self.Config.MinGlowSize
    local max = self.Config.MaxGlowSize
    
    -- Pulsating size
    local pulseFactor = (math.sin(self.AnimationTime * 2) * 0.5 + 0.5)
    local baseSize = min + pulseFactor * (max - min)
    
    -- Add hover effect if enabled
    if self.Config.InteractionGlow and self.HoverTime > 0 then
        baseSize = baseSize + self.HoverTime * max * 0.3
    end
    
    return baseSize
end

-- Draw glow based on selected shape
function PANEL:DrawGlow(x, y, radius, color, intensity)
    local shape = self.Config.GlowShape
    
    if shape == 'circle' then
        self:DrawCircleGlow(x, y, radius, color, intensity)
    elseif shape == 'square' then
        self:DrawSquareGlow(x, y, radius, color, intensity)
    elseif shape == 'hexagon' then
        self:DrawHexagonGlow(x, y, radius, color, intensity)
    elseif shape == 'diamond' then
        self:DrawDiamondGlow(x, y, radius, color, intensity)
    else
        -- Default to circle
        self:DrawCircleGlow(x, y, radius, color, intensity)
    end
end

-- Paint the panel
function PANEL:Paint(w, h)
    local centerX, centerY = w/2, h/2
    local glowSize = self:GetCurrentGlowSize()
    local mainColor = self:GetCurrentColor()
    local intensity = self.Config.GlowIntensity
    
    -- Draw main glow
    self:DrawGlow(centerX, centerY, glowSize, mainColor, intensity)
    
    -- Draw secondary glow if multicolor enabled
    if self.Config.MultiColor then
        local secondaryColor = self.Config.SecondaryColor
        local secondarySize = glowSize * 0.7
        
        -- For DDI-styled, draw all three brand colors
        if self.Config.DDIStyled then
            -- Secondary color (smaller)
            self:DrawGlow(centerX, centerY, secondarySize, secondaryColor, intensity * 0.8)
            
            -- Accent color (smallest)
            local accentSize = glowSize * 0.4
            self:DrawGlow(centerX, centerY, accentSize, DDIStyling.Colors.Accent, intensity * 0.9)
        else
            -- Just draw the secondary color
            self:DrawGlow(centerX, centerY, secondarySize, secondaryColor, intensity * 0.8)
        end
    end
    
    -- Draw content if specified
    if self.Config.ContentType == 'text' and self.Config.Content then
        surface.SetFont(self.Config.Font)
        local textWidth, textHeight = surface.GetTextSize(self.Config.Content)
        
        draw.SimpleText(
            self.Config.Content,
            self.Config.Font,
            centerX,
            centerY,
            self.Config.ContentColor,
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    elseif self.Config.ContentType == 'material' and self.ContentMaterial then
        local matSize = math.min(w, h) * 0.5
        
        surface.SetDrawColor(self.Config.ContentColor)
        surface.SetMaterial(self.ContentMaterial)
        surface.DrawTexturedRect(centerX - matSize/2, centerY - matSize/2, matSize, matSize)
    end
    
    -- Add DDI styling flourishes if enabled
    if self.Config.DDIStyled then
        -- Draw small DDI logo in corner if panel is large enough
        if w > 100 and h > 100 then
            local logoSize = 15
            local margin = 5
            
            draw.RoundedBox(4, margin, margin, logoSize, logoSize, Color(40, 40, 44, 100))
            draw.SimpleText('DDI', 'DermaDefaultBold', margin + logoSize/2, margin + logoSize/2, DDIStyling.Colors.Primary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    return true
end

vgui.Register('AnimatedGlow', PANEL, 'Panel')
return PANEL