--[[
    Animations - Spinner
    Modern UI spinner animations for Garry's Mod
    
    This module provides customizable loading spinner animations.
]]

local PANEL = {}

-- Default configuration
PANEL.Color = Color(255, 255, 255, 230)  -- Base color
PANEL.ColorSecondary = Color(70, 150, 255, 230) -- Secondary color
PANEL.Speed = 1                          -- Animation speed multiplier
PANEL.Style = 'dual'                     -- Style: 'simple', 'dual', 'dots', 'segments'
PANEL.Width = 3                          -- Line width
PANEL.SegmentCount = 8                   -- Number of segments/dots
PANEL.GapSize = 0.2                      -- Gap between segments (0-1)
PANEL.Reverse = false                    -- Reverse direction

-- Initialize the panel
function PANEL:Init()
    self.Time = 0
    
    -- Set default size
    self:SetSize(60, 60)
end

-- Think is called every frame
function PANEL:Think()
    if self.Reverse then
        self.Time = self.Time - (FrameTime() * self.Speed)
    else
        self.Time = self.Time + (FrameTime() * self.Speed)
    end
end

-- Helper function to draw an arc
function PANEL:DrawArc(x, y, radius, startAngle, endAngle, segments, width)
    segments = segments or 16
    local range = endAngle - startAngle
    local angleStep = range / segments
    
    for i = 0, segments - 1 do
        local a1 = startAngle + i * angleStep
        local a2 = startAngle + (i + 1) * angleStep
        
        local x1 = x + math.cos(a1) * radius
        local y1 = y + math.sin(a1) * radius
        local x2 = x + math.cos(a2) * radius
        local y2 = y + math.sin(a2) * radius
        
        surface.DrawLine(x1, y1, x2, y2)
        
        -- Draw additional lines to make the arc thicker
        for j = 1, width - 1 do
            local offset = j * 0.5
            local x1i = x + math.cos(a1) * (radius - offset)
            local y1i = y + math.sin(a1) * (radius - offset)
            local x2i = x + math.cos(a2) * (radius - offset)
            local y2i = y + math.sin(a2) * (radius - offset)
            
            surface.DrawLine(x1i, y1i, x2i, y2i)
            
            if width > 2 then
                x1i = x + math.cos(a1) * (radius + offset)
                y1i = y + math.sin(a1) * (radius + offset)
                x2i = x + math.cos(a2) * (radius + offset)
                y2i = y + math.sin(a2) * (radius + offset)
                
                surface.DrawLine(x1i, y1i, x2i, y2i)
            end
        end
    end
end

-- Draw a dot
function PANEL:DrawDot(x, y, radius)
    -- Draw a small circle
    local segments = 8
    local angleStep = (2 * math.pi) / segments
    
    for i = 0, segments - 1 do
        local a1 = i * angleStep
        local a2 = (i + 1) * angleStep
        
        local x1 = x + math.cos(a1) * radius
        local y1 = y + math.sin(a1) * radius
        local x2 = x + math.cos(a2) * radius
        local y2 = y + math.sin(a2) * radius
        
        surface.DrawLine(x1, y1, x2, y2)
    end
end

-- Draw the panel
function PANEL:Paint(w, h)
    -- Draw background (transparent by default)
    -- surface.SetDrawColor(30, 30, 30, 200) -- Uncomment for a dark background
    -- surface.DrawRect(0, 0, w, h)
    
    local centerX, centerY = w / 2, h / 2
    local radius = math.min(w, h) / 2 - self.Width
    
    if self.Style == 'simple' then
        -- Simple spinner - a rotating arc
        local rotationAngle = self.Time * 4 % (2 * math.pi)
        surface.SetDrawColor(self.Color)
        self:DrawArc(
            centerX, 
            centerY, 
            radius, 
            rotationAngle, 
            rotationAngle + (math.pi * 1.5), 
            16, 
            self.Width
        )
        
    elseif self.Style == 'dual' then
        -- Dual spinner - two arcs rotating in opposite directions
        local rotationAngle1 = self.Time * 3 % (2 * math.pi)
        local rotationAngle2 = -self.Time * 2 % (2 * math.pi)
        
        surface.SetDrawColor(self.Color)
        self:DrawArc(
            centerX, 
            centerY, 
            radius, 
            rotationAngle1, 
            rotationAngle1 + (math.pi * 1.2), 
            12, 
            self.Width
        )
        
        surface.SetDrawColor(self.ColorSecondary)
        self:DrawArc(
            centerX, 
            centerY, 
            radius * 0.7, 
            rotationAngle2, 
            rotationAngle2 + (math.pi * 1.5), 
            12, 
            self.Width
        )
        
    elseif self.Style == 'dots' then
        -- Dots spinner - dots arranged in a circle with fading
        local rotationAngle = self.Time * 2
        local dotRadius = self.Width * 0.8
        
        for i = 1, self.SegmentCount do
            local angle = (i / self.SegmentCount) * (2 * math.pi) + rotationAngle
            local x = centerX + math.cos(angle) * radius
            local y = centerY + math.sin(angle) * radius
            
            -- Calculate fade based on position
            local fadePhase = (i / self.SegmentCount + (self.Time * 0.5)) % 1
            local alpha = self.Color.a * (0.3 + 0.7 * (1 - fadePhase))
            local size = dotRadius * (0.7 + 0.3 * (1 - fadePhase))
            
            surface.SetDrawColor(self.Color.r, self.Color.g, self.Color.b, alpha)
            self:DrawDot(x, y, size)
        end
        
    elseif self.Style == 'segments' then
        -- Segments spinner - segments with varying alpha
        local segmentAngle = (2 * math.pi) / self.SegmentCount
        local arcAngle = segmentAngle * (1 - self.GapSize)
        local rotationAngle = self.Time * 2
        
        for i = 0, self.SegmentCount - 1 do
            local angle = i * segmentAngle + rotationAngle
            local fadePhase = (i / self.SegmentCount + (self.Time * 0.5)) % 1
            local alpha = self.Color.a * (0.2 + 0.8 * (1 - fadePhase))
            
            surface.SetDrawColor(self.Color.r, self.Color.g, self.Color.b, alpha)
            self:DrawArc(
                centerX, 
                centerY, 
                radius, 
                angle, 
                angle + arcAngle, 
                8, 
                self.Width
            )
        end
    end
end

-- Configure the animation settings
function PANEL:Configure(config)
    config = config or {}
    
    if config.Color then self.Color = config.Color end
    if config.ColorSecondary then self.ColorSecondary = config.ColorSecondary end
    if config.Speed then self.Speed = config.Speed end
    if config.Style then self.Style = config.Style end
    if config.Width then self.Width = config.Width end
    if config.SegmentCount then self.SegmentCount = config.SegmentCount end
    if config.GapSize then self.GapSize = config.GapSize end
    if config.Reverse ~= nil then self.Reverse = config.Reverse end
    
    return self
end

vgui.Register('AnimatedSpinner', PANEL, 'DPanel')

-- Return the panel so it can be used elsewhere
return PANEL
