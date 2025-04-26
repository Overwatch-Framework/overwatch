--[[
    Moving Cubes Animation for Garry's Mod
    
    Animations with cubes moving along different trajectories.
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
    CubeSize = 15,
    CubeCount = 4,
    Speed = 1,
    AnimationStyle = 'circle', -- circle, wave, bounce, zigzag, spiral
    TrailEffect = false, 
    RotateCubes = true
}

-- Animation Path Generators
local PathGenerators = {
    -- Круговое движение
    circle = function(w, h, config, cubeIndex, totalCubes, time)
        local centerX, centerY = w/2, h/2
        local radius = math.min(w, h) * 0.35
        local angle = time * config.Speed * 1.5 + (cubeIndex / totalCubes) * math.pi * 2
        
        local x = centerX + math.cos(angle) * radius
        local y = centerY + math.sin(angle) * radius
        
        return x, y, angle * 57.3 -- Convert to degrees for rotation
    end,
    
    -- Волнообразное движение
    wave = function(w, h, config, cubeIndex, totalCubes, time)
        local amplitude = h * 0.25
        local frequency = 2 * math.pi / w
        local phase = time * config.Speed * 2 + (cubeIndex / totalCubes) * math.pi * 2
        
        local progress = (time * config.Speed * 0.5 + (cubeIndex / totalCubes)) % 1
        local x = w * progress
        local y = h/2 + math.sin(phase) * amplitude
        
        return x, y, math.sin(phase) * 45 -- Rotate based on wave direction
    end,
    
    -- Отскакивающее движение
    bounce = function(w, h, config, cubeIndex, totalCubes, time)
        local modTime = (time * config.Speed + (cubeIndex / totalCubes) * 2) % 2
        local x, y
        
        if modTime < 1 then
            -- Движение по диагонали вниз-вправо
            x = modTime * w
            y = modTime * h
        else
            -- Движение по диагонали вверх-влево
            local t = modTime - 1
            x = w - (t * w)
            y = h - (t * h)
        end
        
        return x, y, modTime * 180 -- Rotation angle
    end,
    
    -- Зигзагообразное движение
    zigzag = function(w, h, config, cubeIndex, totalCubes, time)
        local period = 1 -- Время на один полный цикл зигзага
        local modTime = (time * config.Speed + (cubeIndex / totalCubes) * period) % period
        local xProgress = modTime / period
        
        local segmentCount = 4 -- Количество сегментов зигзага
        local segmentWidth = w / segmentCount
        
        local segmentIndex = math.floor(xProgress * segmentCount)
        local segmentProgress = (xProgress * segmentCount) % 1
        
        local x = segmentIndex * segmentWidth + segmentProgress * segmentWidth
        local y = h/2
        
        if segmentIndex % 2 == 0 then
            y = h/4 + segmentProgress * h/2
        else
            y = h*3/4 - segmentProgress * h/2
        end
        
        return x, y, segmentIndex % 2 == 0 and 45 or -45 -- Alternating rotation
    end,
    
    -- Спиральное движение
    spiral = function(w, h, config, cubeIndex, totalCubes, time)
        local centerX, centerY = w/2, h/2
        local maxRadius = math.min(w, h) * 0.4
        local angle = time * config.Speed * 3 + (cubeIndex / totalCubes) * math.pi * 2
        
        -- Radius grows and shrinks over time
        local radiusFactor = (math.sin(time * config.Speed) + 1) / 2
        local radius = maxRadius * (0.2 + radiusFactor * 0.8)
        
        local x = centerX + math.cos(angle) * radius
        local y = centerY + math.sin(angle) * radius
        
        return x, y, angle * 57.3 -- Convert to degrees for rotation
    end,
    
    -- Орбитальное движение (кубики вращаются вокруг друг друга)
    orbital = function(w, h, config, cubeIndex, totalCubes, time)
        local centerX, centerY = w/2, h/2
        local baseRadius = math.min(w, h) * 0.25
        local orbitRadius = baseRadius * 0.3
        
        -- Base orbit
        local baseAngle = time * config.Speed + (2 * math.pi * cubeIndex / totalCubes)
        local baseX = centerX + math.cos(baseAngle) * baseRadius
        local baseY = centerY + math.sin(baseAngle) * baseRadius
        
        -- Secondary orbit around the base point
        local secondaryAngle = time * config.Speed * 3
        local x = baseX + math.cos(secondaryAngle) * orbitRadius
        local y = baseY + math.sin(secondaryAngle) * orbitRadius
        
        return x, y, baseAngle * 57.3 -- Convert to degrees for rotation
    end,
    
    -- Движение по восьмерке (фигура 8)
    figure8 = function(w, h, config, cubeIndex, totalCubes, time)
        local centerX, centerY = w/2, h/2
        local radiusX = w * 0.3
        local radiusY = h * 0.25
        
        local angle = time * config.Speed * 2 + (cubeIndex / totalCubes) * math.pi * 2
        local x = centerX + math.sin(angle) * radiusX
        local y = centerY + math.sin(angle * 2) * radiusY
        
        return x, y, math.sin(angle * 2) * 45 -- Rotation angle
    end
}

-- Trail effect for cubes
function PANEL:DrawTrail(x, y, size, color, trailLength)
    local trailCount = 5
    for i=1, trailCount do
        local trailProgress = i / trailCount
        local trailSize = size * (1 - trailProgress * 0.5)
        local trailAlpha = (1 - trailProgress) * 120
        local trailColor = Color(color.r, color.g, color.b, trailAlpha)
        
        local trailAngle = self.TrailAngles[i] or 0
        local trailX = self.TrailPositions[i][1] or x
        local trailY = self.TrailPositions[i][2] or y
        
        -- Draw cube with rotation
        self:DrawCube(trailX, trailY, trailSize, trailColor, trailAngle)
    end
end

-- Draw a cube with 3D-like appearance
function PANEL:DrawCube(x, y, size, color, angle)
    local halfSize = size / 2
    
    -- If rotation is enabled, apply it
    if self.Config.RotateCubes and angle then
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
        
        -- Draw the rotated cube
        draw.NoTexture()
        surface.SetDrawColor(color)
        surface.DrawPoly(points)
        
        -- Draw outline
        surface.SetDrawColor(color.r, color.g, color.b, color.a * 0.7)
        for i = 1, #points do
            local j = i % #points + 1
            surface.DrawLine(points[i].x, points[i].y, points[j].x, points[j].y)
        end
    else
        -- Draw simple cube without rotation
        draw.RoundedBox(2, x - halfSize, y - halfSize, size, size, color)
        
        -- Draw shadow/highlight for 3D effect
        surface.SetDrawColor(255, 255, 255, 30)
        surface.DrawRect(x - halfSize, y - halfSize, size, size/4)
        
        surface.SetDrawColor(0, 0, 0, 30)
        surface.DrawRect(x - halfSize, y - halfSize + size * 3/4, size, size/4)
    end
end

function PANEL:Init()
    self.Config = table.Copy(DefaultConfig)
    self.Time = 0
    
    -- Trail positions for each cube
    self.CubeTrails = {}
    self.TrailPositions = {}
    self.TrailAngles = {}
    
    for i = 1, 10 do -- Max trail length
        self.TrailPositions[i] = {0, 0}
    end
end

function PANEL:Configure(config)
    self.Config = table.Merge(self.Config, config or {})
end

function PANEL:Think()
    self.Time = CurTime()
    
    -- Update trail positions
    if self.Config.TrailEffect then
        -- Shift all positions down the trail
        for i = #self.TrailPositions, 2, -1 do
            self.TrailPositions[i][1] = self.TrailPositions[i-1][1]
            self.TrailPositions[i][2] = self.TrailPositions[i-1][2]
            self.TrailAngles[i] = self.TrailAngles[i-1]
        end
    end
end

function PANEL:Paint(w, h)
    local config = self.Config
    local time = self.Time
    local pathGenerator = PathGenerators[config.AnimationStyle] or PathGenerators.circle
    
    -- Draw each cube
    for i = 1, config.CubeCount do
        local color = config.Colors[(i-1) % #config.Colors + 1]
        local x, y, angle = pathGenerator(w, h, config, i, config.CubeCount, time)
        
        -- Update trail
        if config.TrailEffect then
            self.TrailPositions[1] = {x, y}
            self.TrailAngles[1] = angle
            self:DrawTrail(x, y, config.CubeSize, color, 5)
        end
        
        -- Draw the cube
        self:DrawCube(x, y, config.CubeSize, color, angle)
    end
    
    return true
end

vgui.Register('AnimatedMovingCubes', PANEL, 'Panel')