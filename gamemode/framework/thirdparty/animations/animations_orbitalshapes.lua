--[[
    Orbital Shapes Animation for Garry's Mod
    
    Анимации с различными формами, двигающимися по орбитальным траекториям.
    Part of the DDI Modern UI Animations package.
]]

local PANEL = {}

-- Default configuration
local DefaultConfig = {
    Colors = {
        Color(70, 150, 255),
        Color(255, 70, 150),
        Color(100, 255, 100),
        Color(255, 200, 70)
    },
    ShapeSize = 15,
    ShapeCount = 5,
    Speed = 1,
    ShapeType = 'mixed', -- square, circle, triangle, diamond, star, hexagon, mixed
    OrbitStyle = 'circle', -- circle, ellipse, spiral, figure8, flower
    RotateShapes = true,
    GlowEffect = false,
    GlowAmount = 0.5
}

-- Shape drawing functions
local ShapeDrawers = {
    square = function(x, y, size, color, angle)
        local halfSize = size / 2
        
        if angle then
            local radians = math.rad(angle)
            local cos, sin = math.cos(radians), math.sin(radians)
            
            -- Create rotated points
            local points = {
                { x = -halfSize, y = -halfSize },
                { x = halfSize, y = -halfSize },
                { x = halfSize, y = halfSize },
                { x = -halfSize, y = halfSize }
            }
            
            -- Apply rotation to points
            for _, point in ipairs(points) do
                local rotX = point.x * cos - point.y * sin
                local rotY = point.x * sin + point.y * cos
                point.x, point.y = rotX + x, rotY + y
            end
            
            -- Draw the rotated square
            draw.NoTexture()
            surface.SetDrawColor(color)
            surface.DrawPoly(points)
        else
            -- Draw simple square
            draw.RoundedBox(0, x - halfSize, y - halfSize, size, size, color)
        end
    end,
    
    circle = function(x, y, size, color)
        draw.NoTexture()
        surface.SetDrawColor(color)
        surface.SafeDrawCircle(x, y, size/2, 32)
    end,
    
    triangle = function(x, y, size, color, angle)
        local points = {}
        local radius = size / 2
        
        for i = 1, 3 do
            local a = math.rad((i-1) * 120 + (angle or 0))
            table.insert(points, {
                x = x + math.cos(a) * radius,
                y = y + math.sin(a) * radius
            })
        end
        
        draw.NoTexture()
        surface.SetDrawColor(color)
        surface.DrawPoly(points)
    end,
    
    diamond = function(x, y, size, color, angle)
        local halfSize = size / 2
        
        -- Create diamond points
        local points = {
            { x = 0, y = -halfSize },  -- top
            { x = halfSize, y = 0 },   -- right
            { x = 0, y = halfSize },   -- bottom
            { x = -halfSize, y = 0 }   -- left
        }
        
        if angle then
            local radians = math.rad(angle)
            local cos, sin = math.cos(radians), math.sin(radians)
            
            -- Apply rotation to points
            for _, point in ipairs(points) do
                local rotX = point.x * cos - point.y * sin
                local rotY = point.x * sin + point.y * cos
                point.x, point.y = rotX + x, rotY + y
            end
        else
            -- Translate points to center position
            for _, point in ipairs(points) do
                point.x = point.x + x
                point.y = point.y + y
            end
        end
        
        -- Draw the diamond
        draw.NoTexture()
        surface.SetDrawColor(color)
        surface.DrawPoly(points)
    end,
    
    star = function(x, y, size, color, angle)
        local outerRadius = size / 2
        local innerRadius = outerRadius * 0.4
        local points = {}
        
        for i = 1, 10 do
            local a = math.rad((i-1) * 36 + (angle or 0))
            local radius = i % 2 == 1 and outerRadius or innerRadius
            table.insert(points, {
                x = x + math.cos(a) * radius,
                y = y + math.sin(a) * radius
            })
        end
        
        draw.NoTexture()
        surface.SetDrawColor(color)
        surface.DrawPoly(points)
    end,
    
    hexagon = function(x, y, size, color, angle)
        local points = {}
        local radius = size / 2
        
        for i = 1, 6 do
            local a = math.rad((i-1) * 60 + (angle or 0))
            table.insert(points, {
                x = x + math.cos(a) * radius,
                y = y + math.sin(a) * radius
            })
        end
        
        draw.NoTexture()
        surface.SetDrawColor(color)
        surface.DrawPoly(points)
    end
}

-- Orbit path generators
local OrbitPaths = {
    circle = function(w, h, config, index, count, time)
        local centerX, centerY = w/2, h/2
        local radius = math.min(w, h) * 0.35
        local angle = time * config.Speed * 1.5 + (index / count) * math.pi * 2
        
        local x = centerX + math.cos(angle) * radius
        local y = centerY + math.sin(angle) * radius
        
        return x, y, angle * 57.3 -- Convert to degrees for rotation
    end,
    
    ellipse = function(w, h, config, index, count, time)
        local centerX, centerY = w/2, h/2
        local radiusX = w * 0.4
        local radiusY = h * 0.25
        local angle = time * config.Speed * 1.5 + (index / count) * math.pi * 2
        
        local x = centerX + math.cos(angle) * radiusX
        local y = centerY + math.sin(angle) * radiusY
        
        return x, y, angle * 57.3
    end,
    
    spiral = function(w, h, config, index, count, time)
        local centerX, centerY = w/2, h/2
        local maxRadius = math.min(w, h) * 0.35
        local baseAngle = time * config.Speed + (index / count) * math.pi * 2
        
        -- Each shape has its own phase in the spiral
        local phaseOffset = (index / count) * 4
        local spiralProgress = ((time * config.Speed * 0.5) + phaseOffset) % 1
        local radius = maxRadius * spiralProgress
        
        -- Spiral path
        local angle = baseAngle * 3
        local x = centerX + math.cos(angle) * radius
        local y = centerY + math.sin(angle) * radius
        
        return x, y, angle * 57.3
    end,
    
    figure8 = function(w, h, config, index, count, time)
        local centerX, centerY = w/2, h/2
        local radiusX = w * 0.3
        local radiusY = h * 0.25
        
        local phase = (index / count) * math.pi * 2
        local angle = time * config.Speed * 2 + phase
        local x = centerX + math.sin(angle) * radiusX
        local y = centerY + math.sin(angle * 2) * radiusY
        
        return x, y, angle * 30
    end,
    
    flower = function(w, h, config, index, count, time)
        local centerX, centerY = w/2, h/2
        local maxRadius = math.min(w, h) * 0.4
        local petalCount = 5
        local phase = (index / count) * math.pi * 2
        local angle = time * config.Speed * 2 + phase
        
        -- Flower petal effect using sine variation
        local radius = maxRadius * (0.3 + 0.7 * math.abs(math.sin(angle * petalCount / 2)))
        
        local x = centerX + math.cos(angle) * radius
        local y = centerY + math.sin(angle) * radius
        
        return x, y, angle * 57.3
    end
}

-- Draw glow effect
function PANEL:DrawGlow(x, y, size, color, amount)
    local glowSize = size * 1.5
    local glowColor = Color(color.r, color.g, color.b, color.a * 0.7 * amount)
    
    -- Draw multiple layers with decreasing opacity
    for i = 1, 3 do
        local layerSize = glowSize * (1 + i * 0.2)
        local layerAlpha = glowColor.a * (1 - i * 0.25)
        local layerColor = Color(glowColor.r, glowColor.g, glowColor.b, layerAlpha)
        
        draw.NoTexture()
        surface.SetDrawColor(layerColor)
        surface.SafeDrawCircle(x, y, layerSize/2, 32)
    end
end

function PANEL:Init()
    self.Config = table.Copy(DefaultConfig)
    self.Time = 0
    self.ShapeTypes = {'square', 'circle', 'triangle', 'diamond', 'star', 'hexagon'}
end

function PANEL:Configure(config)
    self.Config = table.Merge(self.Config, config or {})
end

function PANEL:Think()
    self.Time = CurTime()
end

function PANEL:Paint(w, h)
    local config = self.Config
    local time = self.Time
    local orbitPath = OrbitPaths[config.OrbitStyle] or OrbitPaths.circle
    
    -- Draw each shape
    for i = 1, config.ShapeCount do
        local color = config.Colors[(i-1) % #config.Colors + 1]
        local x, y, angle = orbitPath(w, h, config, i, config.ShapeCount, time)
        
        -- Draw glow effect if enabled
        if config.GlowEffect then
            self:DrawGlow(x, y, config.ShapeSize, color, config.GlowAmount)
        end
        
        -- Determine shape type
        local shapeType
        if config.ShapeType == 'mixed' then
            shapeType = self.ShapeTypes[(i-1) % #self.ShapeTypes + 1]
        else
            shapeType = config.ShapeType
        end
        
        -- Get shape drawer function
        local drawShape = ShapeDrawers[shapeType] or ShapeDrawers.square
        
        -- Draw the shape with rotation if enabled
        if config.RotateShapes then
            drawShape(x, y, config.ShapeSize, color, angle)
        else
            drawShape(x, y, config.ShapeSize, color)
        end
    end
    
    return true
end

vgui.Register('AnimatedOrbitalShapes', PANEL, 'Panel')