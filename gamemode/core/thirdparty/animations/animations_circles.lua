--[[
    Animations - Circles
    Modern UI animations with circles for Garry's Mod
    
    This module provides a customizable loading animation 
    with circles that move between each other.
]]

local PANEL = {}

-- Default configuration
PANEL.Colors = {
    Color(255, 70, 70, 230),   -- Red (slightly transparent)
    Color(70, 150, 255, 230),  -- Blue (slightly transparent)
    Color(70, 255, 70, 230),   -- Green (slightly transparent)
    Color(255, 200, 70, 230)   -- Yellow (slightly transparent)
}
PANEL.CircleRadius = 10        -- Radius of each circle
PANEL.CircleCount = 4          -- Number of circles
PANEL.Speed = 1                -- Animation speed multiplier
PANEL.OrbitRadius = 30         -- Orbit radius
PANEL.InnerRotation = true     -- Whether circles should rotate around themselves

-- Initialize the panel
function PANEL:Init()
    self.Time = 0
    self.CirclePositions = {}
    
    -- Set default size
    self:SetSize(120, 120)
end

-- Think is called every frame
function PANEL:Think()
    self.Time = self.Time + (FrameTime() * self.Speed)
    
    -- Update circle positions
    self.CirclePositions = {}
    
    for i = 1, self.CircleCount do
        local angle = self.Time * 2 + ((i - 1) * (2 * math.pi / self.CircleCount))
        local x = math.cos(angle) * self.OrbitRadius
        local y = math.sin(angle) * self.OrbitRadius
        
        table.insert(self.CirclePositions, {x = x, y = y})
    end
end

-- Draw the panel
function PANEL:Paint(w, h)
    -- Draw background (transparent by default)
    -- surface.SetDrawColor(30, 30, 30, 200) -- Uncomment for a dark background
    -- surface.DrawRect(0, 0, w, h)
    
    local centerX, centerY = w / 2, h / 2
    
    -- Draw each circle
    for i = 1, self.CircleCount do
        local color = self.Colors[(i % #self.Colors) + 1]
        local pos = self.CirclePositions[i]
        
        -- Glow effect
        local glowRadius = self.CircleRadius * 1.5
        local steps = 5
        for j = 1, steps do
            local alpha = color.a * (1 - (j / steps)) * 0.5
            local radius = self.CircleRadius + (glowRadius - self.CircleRadius) * (j / steps)
            
            surface.SetDrawColor(color.r, color.g, color.b, alpha)
            self:DrawCircle(centerX + pos.x, centerY + pos.y, radius)
        end
        
        -- Main circle
        surface.SetDrawColor(color)
        self:DrawCircle(centerX + pos.x, centerY + pos.y, self.CircleRadius)
        
        -- Inner circle pattern (optional)
        if self.InnerRotation then
            local innerAngle = -self.Time * 3 + (i * (math.pi / 2))
            local innerX = math.cos(innerAngle) * (self.CircleRadius * 0.4)
            local innerY = math.sin(innerAngle) * (self.CircleRadius * 0.4)
            
            surface.SetDrawColor(255, 255, 255, 180)
            self:DrawCircle(
                centerX + pos.x + innerX, 
                centerY + pos.y + innerY, 
                self.CircleRadius * 0.3
            )
        end
    end
end

-- Helper function to draw a circle
function PANEL:DrawCircle(x, y, radius)
    -- Проверяем, доступна ли наша безопасная функция
    if surface.SafeDrawCircle then
        -- Используем текущий цвет
        surface.SafeDrawCircle(x, y, radius, 24)
    else
        -- Запасной вариант с ручным рисованием
        local segments = 24
        local angleStep = (2 * math.pi) / segments
        
        for i = 0, segments - 1 do
            local a1 = i * angleStep
            local a2 = (i + 1) * angleStep
            
            local x1 = x + math.cos(a1) * radius
            local y1 = y + math.sin(a1) * radius
            local x2 = x + math.cos(a2) * radius
            local y2 = y + math.sin(a2) * radius
            
            surface.DrawLine(x1, y1, x2, y2)
            
            -- Make the circle more filled
            if radius > 4 then
                local xMid = x + math.cos(a1 + angleStep/2) * (radius * 0.9)
                local yMid = y + math.sin(a1 + angleStep/2) * (radius * 0.9)
                surface.DrawLine(x, y, xMid, yMid)
            end
        end
    end
end

-- Configure the animation settings
function PANEL:Configure(config)
    config = config or {}
    
    if config.Colors then self.Colors = config.Colors end
    if config.CircleRadius then self.CircleRadius = config.CircleRadius end
    if config.CircleCount then self.CircleCount = config.CircleCount end
    if config.Speed then self.Speed = config.Speed end
    if config.OrbitRadius then self.OrbitRadius = config.OrbitRadius end
    if config.InnerRotation ~= nil then self.InnerRotation = config.InnerRotation end
    
    return self
end

vgui.Register('AnimatedCircles', PANEL, 'DPanel')

-- Return the panel so it can be used elsewhere
return PANEL
