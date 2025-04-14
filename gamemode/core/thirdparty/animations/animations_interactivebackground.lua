--[[
    Interactive Background Animation for Garry's Mod
    
    Animated background that reacts to mouse movements.
    Part of the Modern UI Animations package.
]]

local PANEL = {}

-- Default configuration
local DefaultConfig = {
    -- Base colors
    BackgroundColor = Color(30, 30, 35),
    
    -- Element settings
    ElementType = 'particles', -- particles, grid, waves, flow, voronoi
    ElementCount = 100,
    ElementSize = 3,
    ElementSpacing = 40,
    
    -- Interaction settings
    InteractionRadius = 150,
    InteractionStrength = 1,
    InteractionFade = 0.95, -- How quickly the interaction effect fades (0-1)
    InteractionPersistence = 0.4, -- How long the effect persists (0-1)
    
    -- Motion settings
    BaseMotion = 'gentle', -- none, gentle, wave, pulse, circular
    MotionSpeed = 0.5,
    MotionAmount = 0.3,
    
    -- Visual settings
    ColorMode = 'monochrome', -- monochrome, gradient, rainbow, theme
    ColorScheme = {
        Color(70, 150, 255, 100), -- Primary
        Color(255, 70, 150, 100), -- Secondary
        Color(100, 255, 100, 100)  -- Accent
    },
    Depth = 0.3, -- 3D depth effect (0-1)
    GlowEffect = false,
    ConnectElements = false, -- Connect nearby elements with lines
    ConnectionThreshold = 60, -- Maximum distance to draw connections
    
    -- Performance
    UpdateFrequency = 0.03, -- Lower for smoother but more CPU-intensive updates
    EnableFading = true -- Enable fading elements in/out
}

-- Element-specific drawing functions
local ElementDrawers = {
    -- Particle elements
    particles = function(self, x, y, size, color, depth)
        -- Apply depth effect to size if enabled
        local adjustedSize = depth > 0 and size * (0.5 + depth * 0.5) or size
        
        -- Draw particle with optional glow
        if self.Config.GlowEffect then
            local glowSize = adjustedSize * 2
            local glowColor = Color(color.r, color.g, color.b, color.a * 0.3)
            draw.NoTexture()
            surface.SetDrawColor(glowColor)
            surface.SafeDrawCircle(x, y, glowSize/2, 16)
        end
        
        -- Draw main particle
        draw.NoTexture()
        surface.SetDrawColor(color)
        surface.SafeDrawCircle(x, y, adjustedSize/2, 16)
    end,
    
    -- Grid elements
    grid = function(self, x, y, size, color, depth)
        -- Apply depth effect to size
        local adjustedSize = depth > 0 and size * (0.5 + depth * 0.5) or size
        
        -- Draw grid cell
        surface.SetDrawColor(color)
        surface.DrawRect(x - adjustedSize/2, y - adjustedSize/2, adjustedSize, adjustedSize)
        
        -- Add subtle 3D effect
        if depth > 0.3 then
            local highlightColor = Color(255, 255, 255, 30 * depth)
            local shadowColor = Color(0, 0, 0, 30 * depth)
            
            surface.SetDrawColor(highlightColor)
            surface.DrawRect(x - adjustedSize/2, y - adjustedSize/2, adjustedSize, adjustedSize/4)
            
            surface.SetDrawColor(shadowColor)
            surface.DrawRect(x - adjustedSize/2, y + adjustedSize/4, adjustedSize, adjustedSize/4)
        end
    end,
    
    -- Wave elements
    waves = function(self, x, y, size, color, depth)
        -- Wave element is a small arc/curve
        local adjustedSize = depth > 0 and size * (0.5 + depth * 0.5) or size
        local radius = adjustedSize * 2
        
        -- Angle based on position and time
        local baseAngle = (x + y) * 0.01 + CurTime() * self.Config.MotionSpeed
        local startAngle = baseAngle % 360
        local endAngle = (startAngle + 120) % 360
        
        -- Draw arc
        draw.NoTexture()
        surface.SetDrawColor(color)
        
        -- Draw a curved line segment
        local segments = 8
        local prevX, prevY = x + math.cos(math.rad(startAngle)) * radius, y + math.sin(math.rad(startAngle)) * radius
        
        for i = 1, segments do
            local progress = i / segments
            local angle = startAngle + (endAngle - startAngle) * progress
            local nextX = x + math.cos(math.rad(angle)) * radius
            local nextY = y + math.sin(math.rad(angle)) * radius
            
            surface.DrawLine(prevX, prevY, nextX, nextY)
            prevX, prevY = nextX, nextY
        end
    end,
    
    -- Flow elements
    flow = function(self, x, y, size, color, depth)
        -- Flow element is a line with direction
        local adjustedSize = depth > 0 and size * (0.5 + depth * 0.5) or size
        local length = adjustedSize * 3
        
        -- Direction based on time and interaction
        local angle = math.atan2(y - self.CenterY, x - self.CenterX) + 
                     self.Config.MotionSpeed * CurTime() * 0.5
        
        local endX = x + math.cos(angle) * length
        local endY = y + math.sin(angle) * length
        
        -- Draw the flow line
        surface.SetDrawColor(color)
        surface.DrawLine(x, y, endX, endY)
        
        -- Draw a small dot at the end for direction indication
        draw.NoTexture()
        surface.SafeDrawCircle(endX, endY, adjustedSize/3, 8)
    end,
    
    -- Voronoi cell patterns
    voronoi = function(self, x, y, size, color, depth)
        -- Voronoi is more complex - we fake it with a simple polygon
        local adjustedSize = depth > 0 and size * (1 + depth) or size
        local sides = 5 + math.floor(depth * 3)
        local points = {}
        
        -- Generate an irregular polygon
        for i = 1, sides do
            local angle = (i / sides) * math.pi * 2
            local dist = adjustedSize * (0.8 + math.sin(angle * 3 + CurTime() * self.Config.MotionSpeed) * 0.2)
            table.insert(points, {
                x = x + math.cos(angle) * dist,
                y = y + math.sin(angle) * dist
            })
        end
        
        -- Draw the polygon
        draw.NoTexture()
        surface.SetDrawColor(color)
        surface.DrawPoly(points)
    end
}

-- Motion modifiers for elements
local MotionModifiers = {
    -- No additional motion
    none = function(x, y, time, config)
        return 0, 0
    end,
    
    -- Gentle random drifting
    gentle = function(x, y, time, config)
        local speed = config.MotionSpeed * 0.5
        local amount = config.MotionAmount * 10
        
        local offsetX = math.sin(x * 0.01 + time * speed) * amount
        local offsetY = math.cos(y * 0.01 + time * speed) * amount
        
        return offsetX, offsetY
    end,
    
    -- Wave-like motion
    wave = function(x, y, time, config)
        local speed = config.MotionSpeed
        local amount = config.MotionAmount * 15
        
        local offsetX = math.sin(y * 0.02 + time * speed) * amount
        local offsetY = math.sin(x * 0.02 + time * speed) * amount
        
        return offsetX, offsetY
    end,
    
    -- Pulsing outward from center
    pulse = function(x, y, centerX, centerY, time, config)
        local speed = config.MotionSpeed
        local amount = config.MotionAmount * 20
        
        local dx = x - centerX
        local dy = y - centerY
        local dist = math.sqrt(dx*dx + dy*dy)
        local angle = math.atan2(dy, dx)
        
        local pulseWave = math.sin(dist * 0.05 - time * speed * 2)
        local offsetX = math.cos(angle) * pulseWave * amount
        local offsetY = math.sin(angle) * pulseWave * amount
        
        return offsetX, offsetY
    end,
    
    -- Circular rotation
    circular = function(x, y, centerX, centerY, time, config)
        local speed = config.MotionSpeed
        local amount = config.MotionAmount * 10
        
        local dx = x - centerX
        local dy = y - centerY
        local dist = math.sqrt(dx*dx + dy*dy)
        local angle = math.atan2(dy, dx) + time * speed * 0.5
        
        local offsetX = (math.cos(angle) * dist - dx) * amount * 0.1
        local offsetY = (math.sin(angle) * dist - dy) * amount * 0.1
        
        return offsetX, offsetY
    end
}

-- Get color based on settings
function PANEL:GetElementColor(x, y, depth, index)
    local mode = self.Config.ColorMode
    local colors = self.Config.ColorScheme
    
    if #colors == 0 then
        return Color(255, 255, 255, 100)
    end
    
    if mode == 'monochrome' then
        local color = colors[1]
        local alphaMod = depth * 200 + 55 -- Deeper elements are more opaque
        return Color(color.r, color.g, color.b, alphaMod)
        
    elseif mode == 'gradient' then
        local progress = y / self:GetTall()
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
            Lerp(blendFactor, color1.a or 200, color2.a or 200) * depth
        )
        
    elseif mode == 'rainbow' then
        local hue = (CurTime() * 0.1 + (index or 1) * 0.01 + x / self:GetWide() + y / self:GetTall()) % 1
        local color = HSVToColor(hue * 360, 0.7, 0.8)
        return Color(color.r, color.g, color.b, 100 + depth * 155)
        
    elseif mode == 'theme' then
        -- Use colors based on position relative to center
        local centerX, centerY = self:GetWide() / 2, self:GetTall() / 2
        local dx, dy = x - centerX, y - centerY
        local angle = math.deg(math.atan2(dy, dx)) + 180
        local section = math.floor(angle / 120) + 1
        
        local color = colors[section] or colors[1]
        return Color(color.r, color.g, color.b, (color.a or 200) * depth)
    end
    
    return colors[1]
end

function PANEL:Init()
    self.Config = table.Copy(DefaultConfig)
    self.Time = 0
    self.LastUpdateTime = 0
    self.Elements = {}
    self.MouseX, self.MouseY = 0, 0
    self.LastMouseX, self.LastMouseY = 0, 0
    self.MouseSpeed = 0
    self.MouseDirection = {x = 0, y = 0}
    self.CenterX, self.CenterY = 0, 0
    self.InteractionPoints = {}
    
    -- Generate initial elements
    self:RegenerateElements()
end

function PANEL:Configure(config)
    self.Config = table.Merge(self.Config, config or {})
    self:RegenerateElements()
end

-- Generate elements based on configuration
function PANEL:RegenerateElements()
    self.Elements = {}
    
    local w, h = self:GetSize()
    self.CenterX, self.CenterY = w/2, h/2
    
    local config = self.Config
    local elementType = config.ElementType
    local count = config.ElementCount
    
    if elementType == 'grid' then
        -- Create a grid of elements
        local spacing = config.ElementSpacing
        local cols = math.ceil(w / spacing)
        local rows = math.ceil(h / spacing)
        
        for row = 0, rows do
            for col = 0, cols do
                local x = col * spacing
                local y = row * spacing
                
                -- Add some variation to grid
                if config.BaseMotion ~= 'none' then
                    x = x + math.random(-spacing/5, spacing/5)
                    y = y + math.random(-spacing/5, spacing/5)
                end
                
                -- Random depth for 3D effect
                local depth = math.random() * 0.8 + 0.2
                
                table.insert(self.Elements, {
                    x = x,
                    y = y,
                    baseX = x,
                    baseY = y,
                    offsetX = 0,
                    offsetY = 0,
                    size = config.ElementSize,
                    depth = depth,
                    interactionOffset = {x = 0, y = 0},
                    opacity = 1
                })
            end
        end
    else
        -- Create randomly positioned elements
        for i = 1, count do
            local x = math.random(0, w)
            local y = math.random(0, h)
            local depth = math.random() * 0.8 + 0.2
            
            table.insert(self.Elements, {
                x = x,
                y = y,
                baseX = x,
                baseY = y,
                offsetX = 0,
                offsetY = 0,
                size = config.ElementSize,
                depth = depth,
                interactionOffset = {x = 0, y = 0},
                opacity = config.EnableFading and math.random() or 1
            })
        end
    end
end

function PANEL:Think()
    local curTime = CurTime()
    self.Time = curTime
    
    -- Only update on interval for performance
    if curTime - self.LastUpdateTime < self.Config.UpdateFrequency then
        return
    end
    
    self.LastUpdateTime = curTime
    
    -- Get current mouse position
    local x, y = self:CursorPos()
    if x >= 0 and y >= 0 and x <= self:GetWide() and y <= self:GetTall() then
        -- Calculate mouse movement speed and direction
        local dx = x - self.MouseX
        local dy = y - self.MouseY
        local dist = math.sqrt(dx*dx + dy*dy)
        
        -- Update mouse speed (with smoothing)
        self.MouseSpeed = Lerp(0.3, self.MouseSpeed, dist)
        
        -- Update mouse direction if moving
        if dist > 1 then
            self.MouseDirection = {x = dx/dist, y = dy/dist}
        end
        
        -- Store current position for next frame
        self.LastMouseX, self.LastMouseY = self.MouseX, self.MouseY
        self.MouseX, self.MouseY = x, y
        
        -- Add interaction point if mouse is moving significantly
        if self.MouseSpeed > 3 then
            table.insert(self.InteractionPoints, {
                x = x,
                y = y,
                strength = math.min(self.MouseSpeed / 10, 1) * self.Config.InteractionStrength,
                time = curTime,
                direction = {x = self.MouseDirection.x, y = self.MouseDirection.y}
            })
            
            -- Limit number of interaction points
            if #self.InteractionPoints > 20 then
                table.remove(self.InteractionPoints, 1)
            end
        end
    end
    
    -- Update elements
    local config = self.Config
    local w, h = self:GetSize()
    local centerX, centerY = w/2, h/2
    
    -- Get motion function
    local motionFunc = MotionModifiers[config.BaseMotion] or MotionModifiers.gentle
    
    -- Remove old interaction points
    for i = #self.InteractionPoints, 1, -1 do
        local point = self.InteractionPoints[i]
        local age = curTime - point.time
        
        -- Fade out strength over time
        point.strength = point.strength * config.InteractionFade
        
        -- Remove if too old or too weak
        if age > 2 or point.strength < 0.05 then
            table.remove(self.InteractionPoints, i)
        end
    end
    
    -- Update each element
    for i, element in ipairs(self.Elements) do
        -- Reset interaction offset
        element.interactionOffset.x = 0
        element.interactionOffset.y = 0
        
        -- Apply base motion
        if config.BaseMotion == 'pulse' or config.BaseMotion == 'circular' then
            -- Motion that needs center point
            element.offsetX, element.offsetY = motionFunc(
                element.baseX, element.baseY, centerX, centerY, curTime, config
            )
        else
            -- Standard motion
            element.offsetX, element.offsetY = motionFunc(
                element.baseX, element.baseY, curTime, config
            )
        end
        
        -- Apply all interaction points' influence
        for _, point in ipairs(self.InteractionPoints) do
            local dx = element.baseX - point.x
            local dy = element.baseY - point.y
            local dist = math.sqrt(dx*dx + dy*dy)
            
            if dist < config.InteractionRadius then
                local power = (1 - dist/config.InteractionRadius) * point.strength
                
                -- Push element away from interaction point
                local pushX = dx/dist * power * 30
                local pushY = dy/dist * power * 30
                
                -- Add directional bias based on mouse movement
                pushX = pushX + point.direction.x * power * 15
                pushY = pushY + point.direction.y * power * 15
                
                -- Add to total interaction offset
                element.interactionOffset.x = element.interactionOffset.x + pushX
                element.interactionOffset.y = element.interactionOffset.y + pushY
            end
        end
        
        -- Apply the offsets to position
        element.x = element.baseX + element.offsetX + element.interactionOffset.x
        element.y = element.baseY + element.offsetY + element.interactionOffset.y
        
        -- Handle fading elements if enabled
        if config.EnableFading then
            -- Randomly change opacity
            if math.random() < 0.01 then
                element.targetOpacity = math.random() > 0.5 and 1 or 0
            end
            
            -- Smoothly transition opacity
            if element.targetOpacity then
                element.opacity = Lerp(0.05, element.opacity, element.targetOpacity)
            end
        end
    end
end

function PANEL:Paint(w, h)
    -- Paint background
    surface.SetDrawColor(self.Config.BackgroundColor)
    surface.DrawRect(0, 0, w, h)
    
    -- Store center for convenience
    self.CenterX, self.CenterY = w/2, h/2
    
    -- Draw connections between elements if enabled
    if self.Config.ConnectElements then
        self:DrawConnections()
    end
    
    -- Get the drawer function for the current element type
    local drawElement = ElementDrawers[self.Config.ElementType] or ElementDrawers.particles
    
    -- Draw each element
    for i, element in ipairs(self.Elements) do
        -- Skip fully transparent elements
        if element.opacity <= 0.05 then continue end
        
        -- Get color based on settings and depth
        local color = self:GetElementColor(element.x, element.y, element.depth, i)
        color.a = color.a * element.opacity
        
        -- Draw the element
        drawElement(self, element.x, element.y, element.size, color, element.depth)
    end
    
    return true
end

-- Draw connections between nearby elements
function PANEL:DrawConnections()
    local maxDist = self.Config.ConnectionThreshold
    
    for i, element1 in ipairs(self.Elements) do
        for j = i+1, math.min(i+10, #self.Elements) do
            local element2 = self.Elements[j]
            
            local dx = element1.x - element2.x
            local dy = element1.y - element2.y
            local dist = math.sqrt(dx*dx + dy*dy)
            
            if dist < maxDist then
                -- Draw connection with alpha based on distance
                local alpha = (1 - dist/maxDist) * 100
                local color1 = self:GetElementColor(element1.x, element1.y, element1.depth, i)
                local color2 = self:GetElementColor(element2.x, element2.y, element2.depth, j)
                
                -- Average the colors
                local color = Color(
                    (color1.r + color2.r) / 2,
                    (color1.g + color2.g) / 2,
                    (color1.b + color2.b) / 2,
                    alpha * math.min(element1.opacity, element2.opacity)
                )
                
                surface.SetDrawColor(color)
                surface.DrawLine(element1.x, element1.y, element2.x, element2.y)
            end
        end
    end
end

vgui.Register('AnimatedInteractiveBackground', PANEL, 'Panel')