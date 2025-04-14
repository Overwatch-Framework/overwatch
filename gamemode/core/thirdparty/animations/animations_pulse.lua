--[[
    Animations - Pulse
    Modern UI animations with pulsing elements for Garry's Mod
    
    This module provides a customizable pulsing animation 
    that can be used for highlighting elements.
]]

local PANEL = {}

-- Default configuration
PANEL.Color = Color(70, 150, 255, 180)  -- Base color
PANEL.Speed = 1                         -- Animation speed multiplier
PANEL.PulseSize = 0.3                   -- Size variation during pulse (percentage)
PANEL.PulseMin = 0.7                    -- Minimum size multiplier
PANEL.BorderWidth = 2                   -- Width of the border
PANEL.Style = 'circle'                  -- Style: 'circle', 'square', 'hexagon'
PANEL.GlowFactor = 0.5                  -- Glow intensity

-- Initialize the panel
function PANEL:Init()
    self.Time = 0
    self.PulseValue = 0
    
    -- Set default size
    self:SetSize(80, 80)
end

-- Think is called every frame
function PANEL:Think()
    self.Time = self.Time + (FrameTime() * self.Speed)
    
    -- Calculate pulse value (between PulseMin and 1.0)
    self.PulseValue = self.PulseMin + (math.sin(self.Time * 3) + 1) / 2 * self.PulseSize
end

-- Helper function to draw a polygon
function PANEL:DrawPolygon(x, y, radius, sides, startAngle)
    local vertices = {}
    
    for i = 0, sides - 1 do
        local angle = startAngle + (i * (2 * math.pi / sides))
        table.insert(vertices, {
            x = x + math.cos(angle) * radius,
            y = y + math.sin(angle) * radius
        })
    end
    
    -- Draw the polygon
    for i = 1, sides do
        local nextIndex = (i % sides) + 1
        surface.DrawLine(
            vertices[i].x, 
            vertices[i].y, 
            vertices[nextIndex].x, 
            vertices[nextIndex].y
        )
    end
    
    return vertices
end

-- Draw the panel
function PANEL:Paint(w, h)
    -- Draw background (transparent by default)
    -- surface.SetDrawColor(30, 30, 30, 200) -- Uncomment for a dark background
    -- surface.DrawRect(0, 0, w, h)
    
    local centerX, centerY = w / 2, h / 2
    local size = math.min(w, h) / 2 * self.PulseValue
    
    -- Calculate alpha based on pulse
    local alpha = self.Color.a * (0.7 + 0.3 * self.PulseValue)
    local color = Color(self.Color.r, self.Color.g, self.Color.b, alpha)
    
    -- Draw glow effect
    if self.GlowFactor > 0 then
        local glowSteps = 5
        for i = 1, glowSteps do
            local glowSize = size * (1 + (i / glowSteps) * self.GlowFactor)
            local glowAlpha = alpha * (1 - (i / glowSteps))
            
            surface.SetDrawColor(color.r, color.g, color.b, glowAlpha)
            
            if self.Style == 'circle' then
                if surface.SafeDrawCircle then
                    local glowColor = Color(color.r, color.g, color.b, glowAlpha)
                    surface.SafeDrawCircle(centerX, centerY, glowSize, 24, glowColor)
                else
                    self:DrawPolygon(centerX, centerY, glowSize, 24, 0)
                end
            elseif self.Style == 'square' then
                surface.DrawOutlinedRect(
                    centerX - glowSize, 
                    centerY - glowSize, 
                    glowSize * 2, 
                    glowSize * 2,
                    1
                )
            elseif self.Style == 'hexagon' then
                self:DrawPolygon(centerX, centerY, glowSize, 6, math.pi / 6)
            end
        end
    end
    
    -- Draw main shape
    surface.SetDrawColor(color)
    
    if self.Style == 'circle' then
        -- Проверяем доступность SafeDrawCircle
        if surface.SafeDrawCircle then
            -- Draw a circle
            surface.SafeDrawCircle(centerX, centerY, size, 24, color)
            
            -- Draw inner cicle
            if self.BorderWidth > 0 then
                local innerColor = Color(color.r, color.g, color.b, alpha * 0.7)
                surface.SafeDrawCircle(centerX, centerY, size - self.BorderWidth, 24, innerColor)
            end
        else
            -- Fallback to polygon method
            -- Draw a circle
            self:DrawPolygon(centerX, centerY, size, 24, 0)
            
            -- Draw inner cicle
            if self.BorderWidth > 0 then
                surface.SetDrawColor(color.r, color.g, color.b, alpha * 0.7)
                self:DrawPolygon(centerX, centerY, size - self.BorderWidth, 24, 0)
            end
        end
        
    elseif self.Style == 'square' then
        -- Draw a square
        surface.DrawOutlinedRect(
            centerX - size, 
            centerY - size, 
            size * 2, 
            size * 2,
            self.BorderWidth
        )
        
    elseif self.Style == 'hexagon' then
        -- Draw a hexagon
        self:DrawPolygon(centerX, centerY, size, 6, math.pi / 6)
        
        -- Draw inner hexagon
        if self.BorderWidth > 0 then
            surface.SetDrawColor(color.r, color.g, color.b, alpha * 0.7)
            self:DrawPolygon(centerX, centerY, size - self.BorderWidth, 6, math.pi / 6)
        end
    end
end

-- Configure the animation settings
function PANEL:Configure(config)
    config = config or {}
    
    if config.Color then self.Color = config.Color end
    if config.Speed then self.Speed = config.Speed end
    if config.PulseSize then self.PulseSize = config.PulseSize end
    if config.PulseMin then self.PulseMin = config.PulseMin end
    if config.BorderWidth then self.BorderWidth = config.BorderWidth end
    if config.Style then self.Style = config.Style end
    if config.GlowFactor ~= nil then self.GlowFactor = config.GlowFactor end
    
    return self
end

vgui.Register('AnimatedPulse', PANEL, 'DPanel')

-- Return the panel so it can be used elsewhere
return PANEL
