--[[
    Wave Animation for Garry's Mod
    
    A wavy animation effect with customizable properties.
    Part of the DDI Modern UI Animations package.
]]

local PANEL = {}

-- Default configuration
local DefaultConfig = {
    Color = Color(70, 150, 255, 200),  -- Main wave color
    Speed = 1,                  -- Animation speed
    Amplitude = 8,              -- Wave height
    Frequency = 0.5,            -- Wave frequency
    LineWidth = 2,              -- Width of the wave line
    GlowFactor = 0.3,           -- Glow intensity
    Style = 'sine',             -- Wave style: sine, square, sawtooth
    Direction = 'horizontal',   -- Wave direction
    Points = 40,                -- Number of points to draw
    DDIColors = false           -- Whether to use DDI-branded colors
}

-- DDI color palette
local DDIColors = {
    Primary = Color(0, 128, 255, 200),    -- DDI blue
    Secondary = Color(255, 0, 128, 200),  -- DDI magenta
    Accent = Color(0, 255, 128, 200)      -- DDI mint
}

-- Initialize the panel
function PANEL:Init()
    self.Config = table.Copy(DefaultConfig)
    self.LastTime = CurTime()
    self.AnimationOffset = 0
    self.WavePoints = {}
    
    -- Default settings
    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(false)
end

-- Apply configuration options
function PANEL:Configure(config)
    table.Merge(self.Config, config or {})
    
    -- Reset animation when configuration changes
    self.AnimationOffset = 0
    self.WavePoints = {}
    
    -- Apply DDI colors if enabled
    if self.Config.DDIColors then
        self.WaveColors = {
            DDIColors.Primary,
            DDIColors.Secondary,
            DDIColors.Accent
        }
    else
        self.WaveColors = {self.Config.Color}
    end
end

-- Update the animation
function PANEL:Think()
    local currentTime = CurTime()
    local deltaTime = currentTime - self.LastTime
    self.LastTime = currentTime
    
    -- Update animation offset based on speed
    self.AnimationOffset = self.AnimationOffset + deltaTime * self.Config.Speed
    
    -- Keep offset in reasonable range
    if self.AnimationOffset > 1000 then
        self.AnimationOffset = 0
    end
end

-- Draw a sine wave
function PANEL:DrawSineWave(w, h, color, offset)
    offset = offset or 0
    
    local points = {}
    local amplitude = self.Config.Amplitude
    local frequency = self.Config.Frequency
    local pointCount = self.Config.Points
    
    -- Calculate wave points based on direction
    if self.Config.Direction == 'horizontal' then
        local step = w / (pointCount - 1)
        for i = 0, pointCount - 1 do
            local x = i * step
            local y = h/2 + math.sin((x / w * 10 * frequency) + self.AnimationOffset + offset) * amplitude
            table.insert(points, {x = x, y = y})
        end
    elseif self.Config.Direction == 'vertical' then
        local step = h / (pointCount - 1)
        for i = 0, pointCount - 1 do
            local y = i * step
            local x = w/2 + math.sin((y / h * 10 * frequency) + self.AnimationOffset + offset) * amplitude
            table.insert(points, {x = x, y = y})
        end
    elseif self.Config.Direction == 'diagonal' then
        local stepX = w / (pointCount - 1)
        local stepY = h / (pointCount - 1)
        for i = 0, pointCount - 1 do
            local progress = i / (pointCount - 1)
            local x = i * stepX
            local y = i * stepY
            local offset = math.sin((progress * 10 * frequency) + self.AnimationOffset + offset) * amplitude
            local angle = math.rad(45)
            x = x + math.cos(angle) * offset
            y = y + math.sin(angle) * offset
            table.insert(points, {x = x, y = y})
        end
    end
    
    -- Draw the wave
    if #points > 1 then
        -- Draw glow if enabled
        if self.Config.GlowFactor > 0 then
            self:DrawGlowingPolyLine(points, color, self.Config.LineWidth, self.Config.GlowFactor)
        else
            self:DrawPolyLine(points, color, self.Config.LineWidth)
        end
    end
    
    return points
end

-- Draw a square wave
function PANEL:DrawSquareWave(w, h, color, offset)
    offset = offset or 0
    
    local points = {}
    local amplitude = self.Config.Amplitude
    local frequency = self.Config.Frequency
    local pointCount = self.Config.Points * 2 -- Need more points for square wave
    
    if self.Config.Direction == 'horizontal' then
        local step = w / (pointCount - 1)
        for i = 0, pointCount - 1 do
            local x = i * step
            local sineVal = math.sin((x / w * 10 * frequency) + self.AnimationOffset + offset)
            local squareVal = sineVal > 0 and 1 or -1
            local y = h/2 + squareVal * amplitude
            
            -- Insert points at corners for sharp transitions
            if i > 0 then
                local prevSineVal = math.sin(((i-1) * step / w * 10 * frequency) + self.AnimationOffset + offset)
                local prevSquareVal = prevSineVal > 0 and 1 or -1
                
                if prevSquareVal ~= squareVal then
                    -- Add a point at the transition
                    table.insert(points, {x = x, y = h/2 + prevSquareVal * amplitude})
                end
            end
            
            table.insert(points, {x = x, y = y})
        end
    elseif self.Config.Direction == 'vertical' then
        local step = h / (pointCount - 1)
        for i = 0, pointCount - 1 do
            local y = i * step
            local sineVal = math.sin((y / h * 10 * frequency) + self.AnimationOffset + offset)
            local squareVal = sineVal > 0 and 1 or -1
            local x = w/2 + squareVal * amplitude
            
            if i > 0 then
                local prevSineVal = math.sin(((i-1) * step / h * 10 * frequency) + self.AnimationOffset + offset)
                local prevSquareVal = prevSineVal > 0 and 1 or -1
                
                if prevSquareVal ~= squareVal then
                    table.insert(points, {x = w/2 + prevSquareVal * amplitude, y = y})
                end
            end
            
            table.insert(points, {x = x, y = y})
        end
    elseif self.Config.Direction == 'diagonal' then
        local stepX = w / (pointCount - 1)
        local stepY = h / (pointCount - 1)
        for i = 0, pointCount - 1 do
            local progress = i / (pointCount - 1)
            local x = i * stepX
            local y = i * stepY
            local sineVal = math.sin((progress * 10 * frequency) + self.AnimationOffset + offset)
            local squareVal = sineVal > 0 and 1 or -1
            local offset = squareVal * amplitude
            local angle = math.rad(45)
            x = x + math.cos(angle) * offset
            y = y + math.sin(angle) * offset
            
            if i > 0 then
                local prevProgress = (i-1) / (pointCount - 1)
                local prevSineVal = math.sin((prevProgress * 10 * frequency) + self.AnimationOffset + offset)
                local prevSquareVal = prevSineVal > 0 and 1 or -1
                
                if prevSquareVal ~= squareVal then
                    local prevX = (i-1) * stepX
                    local prevY = (i-1) * stepY
                    local prevOffset = prevSquareVal * amplitude
                    table.insert(points, {
                        x = prevX + math.cos(angle) * prevOffset,
                        y = prevY + math.sin(angle) * prevOffset
                    })
                end
            end
            
            table.insert(points, {x = x, y = y})
        end
    end
    
    -- Draw the wave
    if #points > 1 then
        if self.Config.GlowFactor > 0 then
            self:DrawGlowingPolyLine(points, color, self.Config.LineWidth, self.Config.GlowFactor)
        else
            self:DrawPolyLine(points, color, self.Config.LineWidth)
        end
    end
    
    return points
end

-- Draw a sawtooth wave
function PANEL:DrawSawtoothWave(w, h, color, offset)
    offset = offset or 0
    
    local points = {}
    local amplitude = self.Config.Amplitude
    local frequency = self.Config.Frequency
    local pointCount = self.Config.Points
    
    if self.Config.Direction == 'horizontal' then
        local step = w / (pointCount - 1)
        for i = 0, pointCount - 1 do
            local x = i * step
            local sawVal = ((((x / w * frequency * 10) + self.AnimationOffset + offset) % 1) * 2 - 1)
            local y = h/2 + sawVal * amplitude
            table.insert(points, {x = x, y = y})
        end
    elseif self.Config.Direction == 'vertical' then
        local step = h / (pointCount - 1)
        for i = 0, pointCount - 1 do
            local y = i * step
            local sawVal = ((((y / h * frequency * 10) + self.AnimationOffset + offset) % 1) * 2 - 1)
            local x = w/2 + sawVal * amplitude
            table.insert(points, {x = x, y = y})
        end
    elseif self.Config.Direction == 'diagonal' then
        local stepX = w / (pointCount - 1)
        local stepY = h / (pointCount - 1)
        for i = 0, pointCount - 1 do
            local progress = i / (pointCount - 1)
            local x = i * stepX
            local y = i * stepY
            local sawVal = ((((progress * frequency * 10) + self.AnimationOffset + offset) % 1) * 2 - 1)
            local offset = sawVal * amplitude
            local angle = math.rad(45)
            x = x + math.cos(angle) * offset
            y = y + math.sin(angle) * offset
            table.insert(points, {x = x, y = y})
        end
    end
    
    -- Draw the wave
    if #points > 1 then
        if self.Config.GlowFactor > 0 then
            self:DrawGlowingPolyLine(points, color, self.Config.LineWidth, self.Config.GlowFactor)
        else
            self:DrawPolyLine(points, color, self.Config.LineWidth)
        end
    end
    
    return points
end

-- Draw a polyline from points
function PANEL:DrawPolyLine(points, color, thickness)
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    
    for i = 1, #points - 1 do
        local p1 = points[i]
        local p2 = points[i + 1]
        surface.DrawLine(p1.x, p1.y, p2.x, p2.y)
        
        -- Draw thicker line by drawing multiple offset lines
        if thickness and thickness > 1 then
            for t = 1, math.floor(thickness/2) do
                surface.DrawLine(p1.x, p1.y - t, p2.x, p2.y - t)
                surface.DrawLine(p1.x, p1.y + t, p2.x, p2.y + t)
            end
        end
    end
end

-- Draw a glowing polyline from points
function PANEL:DrawGlowingPolyLine(points, color, thickness, glowAmount)
    -- Draw base line
    self:DrawPolyLine(points, color, thickness)
    
    -- Draw glow
    local glowColor = Color(color.r, color.g, color.b, color.a * 0.5)
    local glowThickness = thickness + 2 + glowAmount * 6
    
    for i = 1, #points - 1 do
        local p1 = points[i]
        local p2 = points[i + 1]
        
        -- Draw blurred line for glow effect
        for t = 1, glowThickness do
            local alpha = glowColor.a * (1 - t / glowThickness)
            surface.SetDrawColor(glowColor.r, glowColor.g, glowColor.b, alpha)
            surface.DrawLine(p1.x, p1.y - t, p2.x, p2.y - t)
            surface.DrawLine(p1.x, p1.y + t, p2.x, p2.y + t)
        end
    end
end

-- Paint the panel
function PANEL:Paint(w, h)
    -- Draw based on selected wave style
    local waveStyle = self.Config.Style or 'sine'
    
    -- If using DDI colors, draw multiple waves with different colors and slight offsets
    if self.Config.DDIColors then
        -- Draw primary wave
        self:DrawWave(w, h, DDIColors.Primary, 0, waveStyle)
        
        -- Draw secondary waves with offsets
        self:DrawWave(w, h, DDIColors.Secondary, 0.7, waveStyle)
        self:DrawWave(w, h, DDIColors.Accent, 1.4, waveStyle)
    else
        -- Draw a single wave with the configured color
        self:DrawWave(w, h, self.Config.Color, 0, waveStyle)
    end
    
    return true
end

-- Draw a wave of the specified style
function PANEL:DrawWave(w, h, color, offset, style)
    if style == 'sine' then
        return self:DrawSineWave(w, h, color, offset)
    elseif style == 'square' then
        return self:DrawSquareWave(w, h, color, offset)
    elseif style == 'sawtooth' then
        return self:DrawSawtoothWave(w, h, color, offset)
    else
        -- Default to sine
        return self:DrawSineWave(w, h, color, offset)
    end
end

vgui.Register('AnimatedWave', PANEL, 'Panel')
return PANEL