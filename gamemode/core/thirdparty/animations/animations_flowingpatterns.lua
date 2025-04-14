--[[
    Flowing Patterns Animation for Garry's Mod
    
    Animations with smooth moving patterns and effects.
    Part of the DDI Modern UI Animations package.
]]

local PANEL = {}

-- Default configuration
local DefaultConfig = {
    Colors = {
        Color(70, 150, 255),
        Color(255, 70, 150),
        Color(100, 255, 100)
    },
    PatternStyle = 'dots', -- dots, lines, blocks, circles, waves
    ItemSize = 6,
    Density = 0.5,
    Speed = 1,
    FlowDirection = 'random', -- left, right, up, down, circular, random
    ColorStyle = 'solid', -- solid, gradient, rainbow, pulse
    Interaction = false
}

-- Pattern generation functions
local PatternGenerators = {
    -- Pattern of flowing dots
    dots = function(self, w, h, config, time)
        local spacing = math.floor(config.ItemSize * (3 - config.Density))
        local rows = math.ceil(h / spacing)
        local cols = math.ceil(w / spacing)
        local maxItems = rows * cols
        local size = config.ItemSize
        
        for i = 1, maxItems do
            local row = math.floor((i-1) / cols)
            local col = (i-1) % cols
            
            local baseX = col * spacing
            local baseY = row * spacing
            
            -- Apply flow motion based on direction
            local x, y = self:ApplyFlow(baseX, baseY, w, h, config, time)
            
            -- Skip some dots based on density
            if math.random() < config.Density * 0.8 + 0.2 then
                local color = self:GetPatternColor(x, y, w, h, config, time)
                surface.SetDrawColor(color)
                surface.SafeDrawCircle(x, y, size/2, 16)
            end
        end
    end,
    
    -- Pattern of flowing lines
    lines = function(self, w, h, config, time)
        local spacing = math.floor(config.ItemSize * (3 - config.Density))
        local lineCount = math.ceil(h / spacing)
        local thickness = config.ItemSize / 2
        
        for i = 1, lineCount do
            local baseY = i * spacing
            
            -- Create wave effect in each line
            local amplitude = config.ItemSize * 1.5
            local frequency = 0.05
            local phaseOffset = time * config.Speed + (i / lineCount) * math.pi * 2
            
            -- Draw line segments
            local segmentLength = 10
            local segments = math.ceil(w / segmentLength)
            
            for j = 1, segments do
                local startX = (j-1) * segmentLength
                local endX = j * segmentLength
                
                local startWave = math.sin(startX * frequency + phaseOffset) * amplitude
                local endWave = math.sin(endX * frequency + phaseOffset) * amplitude
                
                local startY = baseY + startWave
                local endY = baseY + endWave
                
                -- Apply flow motion
                local flowStartX, flowStartY = self:ApplyFlow(startX, startY, w, h, config, time)
                local flowEndX, flowEndY = self:ApplyFlow(endX, endY, w, h, config, time)
                
                -- Skip some segments based on density
                if math.random() < config.Density * 0.8 + 0.2 then
                    local color = self:GetPatternColor((flowStartX + flowEndX)/2, (flowStartY + flowEndY)/2, w, h, config, time)
                    surface.SetDrawColor(color)
                    surface.DrawLine(flowStartX, flowStartY, flowEndX, flowEndY)
                end
            end
        end
    end,
    
    -- Pattern of flowing blocks
    blocks = function(self, w, h, config, time)
        local spacing = math.floor(config.ItemSize * (3 - config.Density))
        local rows = math.ceil(h / spacing)
        local cols = math.ceil(w / spacing)
        local maxItems = rows * cols
        local size = config.ItemSize
        
        for i = 1, maxItems do
            local row = math.floor((i-1) / cols)
            local col = (i-1) % cols
            
            local baseX = col * spacing
            local baseY = row * spacing
            
            -- Apply flow motion based on direction
            local x, y = self:ApplyFlow(baseX, baseY, w, h, config, time)
            
            -- Skip some blocks based on density
            if math.random() < config.Density * 0.7 + 0.3 then
                local color = self:GetPatternColor(x, y, w, h, config, time)
                surface.SetDrawColor(color)
                
                -- Alternative between squares and rounded squares
                if (row + col) % 2 == 0 then
                    draw.RoundedBox(2, x - size/2, y - size/2, size, size, color)
                else
                    surface.DrawRect(x - size/2, y - size/2, size, size)
                end
            end
        end
    end,
    
    -- Pattern of flowing circles
    circles = function(self, w, h, config, time)
        local spacing = math.floor(config.ItemSize * (3 - config.Density))
        local rows = math.ceil(h / spacing)
        local cols = math.ceil(w / spacing)
        local maxItems = rows * cols
        local maxSize = config.ItemSize * 1.5
        
        for i = 1, maxItems do
            local row = math.floor((i-1) / cols)
            local col = (i-1) % cols
            
            local baseX = col * spacing
            local baseY = row * spacing
            
            -- Apply flow motion based on direction
            local x, y = self:ApplyFlow(baseX, baseY, w, h, config, time)
            
            -- Skip some circles based on density
            if math.random() < config.Density * 0.7 + 0.3 then
                local sinOffset = math.sin(time * config.Speed + (row + col) / (rows + cols) * math.pi * 2)
                local circleSize = maxSize * (0.5 + sinOffset * 0.5)
                
                local color = self:GetPatternColor(x, y, w, h, config, time)
                surface.SetDrawColor(color)
                surface.SafeDrawCircle(x, y, circleSize/2, 16)
            end
        end
    end,
    
    -- Pattern of flowing waves
    waves = function(self, w, h, config, time)
        local waveCount = math.ceil(10 * config.Density)
        local maxAmplitude = h * 0.2
        
        for i = 1, waveCount do
            local phase = time * config.Speed + (i / waveCount) * math.pi * 2
            local amplitude = maxAmplitude * (0.3 + 0.7 * config.Density)
            local frequency = 0.01 * (1 + (i % 3))
            
            -- Draw the wave
            local points = {}
            local segmentWidth = 10
            local segments = math.ceil(w / segmentWidth) + 1
            
            for j = 1, segments do
                local x = (j-1) * segmentWidth
                local baseY = h / 2
                local waveY = baseY + math.sin(x * frequency + phase) * amplitude
                
                -- Apply flow motion
                local flowX, flowY = self:ApplyFlow(x, waveY, w, h, config, time)
                
                table.insert(points, {x = flowX, y = flowY})
            end
            
            -- Close the polygon for filled waves
            table.insert(points, {x = points[#points].x, y = h})
            table.insert(points, {x = points[1].x, y = h})
            
            -- Draw the wave
            local color = self:GetPatternColor(w/2, h/2, w, h, config, time, i)
            local fillColor = Color(color.r, color.g, color.b, 70)
            
            -- Draw filled area
            surface.SetDrawColor(fillColor)
            draw.NoTexture()
            surface.DrawPoly(points)
            
            -- Draw outline
            surface.SetDrawColor(color)
            for j = 1, #points - 3 do
                surface.DrawLine(points[j].x, points[j].y, points[j+1].x, points[j+1].y)
            end
        end
    end
}

-- Apply flow motion to a point based on direction
function PANEL:ApplyFlow(x, y, w, h, config, time)
    local speed = config.Speed * 50
    local direction = config.FlowDirection
    local timeOffset = time * speed
    
    if direction == 'left' then
        x = (x - timeOffset) % (w + config.ItemSize * 2) - config.ItemSize
        
    elseif direction == 'right' then
        x = (x + timeOffset) % (w + config.ItemSize * 2) - config.ItemSize
        
    elseif direction == 'up' then
        y = (y - timeOffset) % (h + config.ItemSize * 2) - config.ItemSize
        
    elseif direction == 'down' then
        y = (y + timeOffset) % (h + config.ItemSize * 2) - config.ItemSize
        
    elseif direction == 'circular' then
        local centerX, centerY = w/2, h/2
        local dx, dy = x - centerX, y - centerY
        local distance = math.sqrt(dx*dx + dy*dy)
        local angle = math.atan2(dy, dx) + time * config.Speed
        
        x = centerX + math.cos(angle) * distance
        y = centerY + math.sin(angle) * distance
        
    elseif direction == 'random' then
        -- Perlin-like noise for smooth random movement
        local noiseScale = 0.01
        local noiseTime = time * config.Speed * 0.5
        
        local noise1 = math.sin(x * noiseScale + noiseTime) * math.cos(y * noiseScale * 1.5 + noiseTime * 1.3)
        local noise2 = math.cos(x * noiseScale * 1.2 + noiseTime * 0.7) * math.sin(y * noiseScale + noiseTime * 0.9)
        
        x = x + noise1 * config.ItemSize * 2
        y = y + noise2 * config.ItemSize * 2
    end
    
    return x, y
end

-- Get color for a pattern item based on color style
function PANEL:GetPatternColor(x, y, w, h, config, time, index)
    local colorStyle = config.ColorStyle
    local colors = config.Colors
    
    if #colors == 0 then
        return Color(255, 255, 255)
    end
    
    if colorStyle == 'solid' then
        return colors[index or 1] or colors[1]
        
    elseif colorStyle == 'gradient' then
        local progress = y / h
        local colorIndex = math.floor(progress * #colors) + 1
        local nextColorIndex = colorIndex + 1
        
        if nextColorIndex > #colors then
            nextColorIndex = 1
        end
        
        local color1 = colors[colorIndex]
        local color2 = colors[nextColorIndex]
        local blendFactor = (progress * #colors) % 1
        
        return Color(
            Lerp(blendFactor, color1.r, color2.r),
            Lerp(blendFactor, color1.g, color2.g),
            Lerp(blendFactor, color1.b, color2.b),
            Lerp(blendFactor, color1.a or 255, color2.a or 255)
        )
        
    elseif colorStyle == 'rainbow' then
        local hue = (time * config.Speed * 0.5 + (index or 1) * 0.1 + x / w + y / h) % 1
        return HSVToColor(hue * 360, 0.8, 0.9)
        
    elseif colorStyle == 'pulse' then
        local pulse = (math.sin(time * config.Speed * 2 + (index or 1) * 0.5) + 1) / 2
        local colorIndex = (index or 1) % #colors
        if colorIndex == 0 then colorIndex = #colors end
        
        local color = colors[colorIndex]
        local alpha = Lerp(pulse, 100, 255)
        
        return Color(color.r, color.g, color.b, alpha)
    end
    
    return colors[1]
end

function PANEL:Init()
    self.Config = table.Copy(DefaultConfig)
    self.Time = 0
    self.MouseX, self.MouseY = 0, 0
end

function PANEL:Configure(config)
    self.Config = table.Merge(self.Config, config or {})
end

function PANEL:Think()
    self.Time = CurTime()
    
    -- Track mouse position for interaction
    if self.Config.Interaction then
        local x, y = self:CursorPos()
        if x > 0 and y > 0 and x < self:GetWide() and y < self:GetTall() then
            self.MouseX, self.MouseY = x, y
        end
    end
end

function PANEL:Paint(w, h)
    local config = self.Config
    local time = self.Time
    
    -- Get pattern generator function
    local generatePattern = PatternGenerators[config.PatternStyle] or PatternGenerators.dots
    
    -- Draw the pattern
    generatePattern(self, w, h, config, time)
    
    return true
end

vgui.Register('AnimatedFlowingPatterns', PANEL, 'Panel')