--[[
    Particles Animation for Garry's Mod
    
    A customizable particle system with various effects.
    Part of the DDI Modern UI Animations package.
]]

local PANEL = {}

-- Default configuration
local DefaultConfig = {
    ParticleCount = 30,              -- Number of particles
    MinSize = 2,                     -- Minimum particle size
    MaxSize = 8,                     -- Maximum particle size
    MinSpeed = 20,                   -- Minimum particle speed
    MaxSpeed = 60,                   -- Maximum particle speed
    Colors = {                       -- Particle colors
        Color(70, 150, 255, 200),    -- Blue
        Color(255, 70, 150, 200),    -- Pink
        Color(100, 255, 100, 200)    -- Green
    },
    Shape = 'circle',                -- Particle shape: circle, square, diamond, triangle
    EmissionMode = 'all',            -- How particles are emitted: all, burst, continuous
    EmissionPoint = 'center',        -- Where particles start: center, edges, random
    GravityEffect = 0,               -- Gravity effect (0-1)
    MouseInteraction = true,         -- Particles react to mouse
    Turbulence = 0.2,                -- Random movement (0-1)
    FadeOut = true,                  -- Particles fade out at end of life
    RotatingParticles = true,        -- Particles rotate
    CollisionDetection = false,      -- Particles collide with each other
    BackgroundDim = 0,               -- Dim background (0-1)
    BackgroundColor = Color(0, 0, 0, 0), -- Background color
    DDIStyled = false                -- Use DDI styling
}

-- Particle class definition
local Particle = {}
Particle.__index = Particle

-- Create a new particle
function Particle.new(x, y, config)
    local self = setmetatable({}, Particle)
    
    self.x = x
    self.y = y
    self.size = math.random(config.MinSize, config.MaxSize)
    self.opacity = math.random(150, 255)
    self.rotation = math.random(0, 360)
    self.rotationSpeed = math.random(-180, 180) / 100
    
    -- Random velocity
    local angle = math.random(0, 360)
    local speed = math.random(config.MinSpeed, config.MaxSpeed)
    self.vx = math.cos(math.rad(angle)) * speed
    self.vy = math.sin(math.rad(angle)) * speed
    
    -- Random color from the config
    self.color = table.Copy(config.Colors[math.random(1, #config.Colors)])
    
    -- Life properties
    self.lifetime = math.random(1, 3)
    self.age = 0
    
    return self
end

-- Update particle position and properties
function Particle:update(deltaTime, w, h, config)
    -- Update age
    self.age = self.age + deltaTime
    
    -- Apply gravity if enabled
    if config.GravityEffect > 0 then
        self.vy = self.vy + (50 * config.GravityEffect * deltaTime)
    end
    
    -- Apply turbulence if enabled
    if config.Turbulence > 0 then
        self.vx = self.vx + (math.random(-100, 100) / 100) * config.Turbulence * deltaTime
        self.vy = self.vy + (math.random(-100, 100) / 100) * config.Turbulence * deltaTime
    end
    
    -- Update position
    self.x = self.x + self.vx * deltaTime
    self.y = self.y + self.vy * deltaTime
    
    -- Update rotation if enabled
    if config.RotatingParticles then
        self.rotation = self.rotation + self.rotationSpeed * 100 * deltaTime
    end
    
    -- Handle collisions with walls
    if self.x < 0 then
        self.x = 0
        self.vx = -self.vx * 0.8
    elseif self.x > w then
        self.x = w
        self.vx = -self.vx * 0.8
    end
    
    if self.y < 0 then
        self.y = 0
        self.vy = -self.vy * 0.8
    elseif self.y > h then
        self.y = h
        self.vy = -self.vy * 0.8
    end
    
    -- Fade out if enabled
    if config.FadeOut and self.age > self.lifetime * 0.7 then
        local fadeRatio = 1 - ((self.age - (self.lifetime * 0.7)) / (self.lifetime * 0.3))
        self.color.a = self.opacity * fadeRatio
    end
    
    -- Check if particle is dead
    return self.age < self.lifetime
end

-- Draw particle based on shape
function Particle:draw(config)
    local shape = config.Shape
    local x, y = self.x, self.y
    local size = self.size
    local col = self.color
    
    surface.SetDrawColor(col.r, col.g, col.b, col.a)
    
    if shape == 'circle' then
        draw.NoTexture()
        draw.Circle(x, y, size, col)
    elseif shape == 'square' then
        surface.DrawRect(x - size/2, y - size/2, size, size)
    elseif shape == 'diamond' then
        local points = {
            {x = x, y = y - size},
            {x = x + size, y = y},
            {x = x, y = y + size},
            {x = x - size, y = y}
        }
        draw.NoTexture()
        surface.DrawPoly(points)
    elseif shape == 'triangle' then
        local points = {
            {x = x, y = y - size},
            {x = x + size * 0.866, y = y + size/2},
            {x = x - size * 0.866, y = y + size/2}
        }
        draw.NoTexture()
        surface.DrawPoly(points)
    end
end

-- Apply mouse interaction to particle
function Particle:applyMouseInteraction(mouseX, mouseY, strength)
    local dx = self.x - mouseX
    local dy = self.y - mouseY
    local distance = math.sqrt(dx * dx + dy * dy)
    
    if distance < 100 then
        local factor = (1 - distance / 100) * strength
        
        -- Normalize the direction vector
        if distance > 0 then
            dx = dx / distance
            dy = dy / distance
        end
        
        -- Apply force away from cursor
        self.vx = self.vx + dx * factor * 500
        self.vy = self.vy + dy * factor * 500
    end
end

-- Check collision with another particle
function Particle:checkCollision(other)
    local dx = self.x - other.x
    local dy = self.y - other.y
    local distSquared = dx * dx + dy * dy
    local minDist = self.size/2 + other.size/2
    
    if distSquared < minDist * minDist then
        -- Calculate collision response
        local dist = math.sqrt(distSquared)
        local nx = dx / dist
        local ny = dy / dist
        
        -- Calculate relative velocity
        local vrx = self.vx - other.vx
        local vry = self.vy - other.vy
        
        -- Calculate impulse
        local impulse = (vrx * nx + vry * ny) / (1/self.size + 1/other.size)
        
        -- Apply impulse
        self.vx = self.vx - (impulse * nx) / self.size
        self.vy = self.vy - (impulse * ny) / self.size
        other.vx = other.vx + (impulse * nx) / other.size
        other.vy = other.vy + (impulse * ny) / other.size
        
        -- Prevent particles from sticking
        local overlap = minDist - dist
        self.x = self.x + nx * overlap * 0.5
        self.y = self.y + ny * overlap * 0.5
        other.x = other.x - nx * overlap * 0.5
        other.y = other.y - ny * overlap * 0.5
    end
end

-- DDI styling options
local DDIStyling = {
    Colors = {
        Primary = Color(70, 150, 255, 200),    -- DDI Blue
        Secondary = Color(255, 70, 150, 200),  -- DDI Pink
        Accent = Color(100, 255, 100, 200)     -- DDI Green
    },
    Shapes = {
        'circle',
        'square',
        'diamond',
        'triangle'
    }
}

-- Initialize the panel
function PANEL:Init()
    self.Config = table.Copy(DefaultConfig)
    self.LastTime = CurTime()
    self.Particles = {}
    self.EmissionTimer = 0
    self.MouseX = 0
    self.MouseY = 0
    
    -- Initial particle creation
    if self.Config.EmissionMode == 'all' then
        self:CreateParticles()
    end
    
    -- Default settings
    self:SetMouseInputEnabled(self.Config.MouseInteraction)
    self:SetKeyboardInputEnabled(false)
end

-- Apply configuration options
function PANEL:Configure(config)
    table.Merge(self.Config, config or {})
    
    -- Apply DDI styling if enabled
    if self.Config.DDIStyled then
        self.Config.Colors = {
            DDIStyling.Colors.Primary,
            DDIStyling.Colors.Secondary,
            DDIStyling.Colors.Accent
        }
    end
    
    -- Reset particles when config changes
    self.Particles = {}
    
    -- Create initial particles if set to 'all' mode
    if self.Config.EmissionMode == 'all' then
        self:CreateParticles()
    end
    
    -- Update mouse input based on config
    self:SetMouseInputEnabled(self.Config.MouseInteraction)
end

-- Create particles based on config
function PANEL:CreateParticles()
    local w, h = self:GetSize()
    
    for i = 1, self.Config.ParticleCount do
        local x, y
        
        -- Determine emission point
        if self.Config.EmissionPoint == 'center' then
            x, y = w/2, h/2
        elseif self.Config.EmissionPoint == 'edges' then
            if math.random() > 0.5 then
                -- Top or bottom edge
                x = math.random(0, w)
                y = math.random() > 0.5 and 0 or h
            else
                -- Left or right edge
                x = math.random() > 0.5 and 0 or w
                y = math.random(0, h)
            end
        else -- random
            x = math.random(0, w)
            y = math.random(0, h)
        end
        
        table.insert(self.Particles, Particle.new(x, y, self.Config))
    end
end

-- Mouse tracking
function PANEL:OnCursorMoved(x, y)
    self.MouseX = x
    self.MouseY = y
end

-- Update the animation
function PANEL:Think()
    local currentTime = CurTime()
    local deltaTime = math.min(0.1, currentTime - self.LastTime) -- Cap deltaTime to prevent huge jumps
    self.LastTime = currentTime
    
    local w, h = self:GetSize()
    
    -- Handle continuous emission
    if self.Config.EmissionMode == 'continuous' then
        self.EmissionTimer = self.EmissionTimer + deltaTime
        
        -- Emit particles based on rate
        local emissionRate = 1 / self.Config.ParticleCount * 10 -- Emit full set every 10 seconds
        while self.EmissionTimer > emissionRate do
            self.EmissionTimer = self.EmissionTimer - emissionRate
            
            local x, y
            if self.Config.EmissionPoint == 'center' then
                x, y = w/2, h/2
            elseif self.Config.EmissionPoint == 'edges' then
                if math.random() > 0.5 then
                    x = math.random(0, w)
                    y = math.random() > 0.5 and 0 or h
                else
                    x = math.random() > 0.5 and 0 or w
                    y = math.random(0, h)
                end
            else -- random
                x = math.random(0, w)
                y = math.random(0, h)
            end
            
            table.insert(self.Particles, Particle.new(x, y, self.Config))
        end
    end
    
    -- Update all particles
    for i = #self.Particles, 1, -1 do
        local particle = self.Particles[i]
        
        -- Apply mouse interaction if enabled
        if self.Config.MouseInteraction then
            particle:applyMouseInteraction(self.MouseX, self.MouseY, 1)
        end
        
        -- Update particle
        local isAlive = particle:update(deltaTime, w, h, self.Config)
        
        -- Remove dead particles
        if not isAlive then
            table.remove(self.Particles, i)
        end
    end
    
    -- Handle particle collisions if enabled
    if self.Config.CollisionDetection then
        for i = 1, #self.Particles do
            for j = i + 1, #self.Particles do
                self.Particles[i]:checkCollision(self.Particles[j])
            end
        end
    end
    
    -- When all particles are dead in burst mode, create new ones
    if self.Config.EmissionMode == 'burst' and #self.Particles == 0 then
        self:CreateParticles()
    end
    
    -- Add particles until we hit ParticleCount in 'all' mode
    if self.Config.EmissionMode == 'all' and #self.Particles < self.Config.ParticleCount then
        local needed = self.Config.ParticleCount - #self.Particles
        for i = 1, needed do
            local x, y
            if self.Config.EmissionPoint == 'center' then
                x, y = w/2, h/2
            elseif self.Config.EmissionPoint == 'edges' then
                if math.random() > 0.5 then
                    x = math.random(0, w)
                    y = math.random() > 0.5 and 0 or h
                else
                    x = math.random() > 0.5 and 0 or w
                    y = math.random(0, h)
                end
            else -- random
                x = math.random(0, w)
                y = math.random(0, h)
            end
            
            table.insert(self.Particles, Particle.new(x, y, self.Config))
        end
    end
end

-- Paint the panel
function PANEL:Paint(w, h)
    -- Draw background if needed
    if self.Config.BackgroundDim > 0 then
        local bgColor = self.Config.BackgroundColor
        if bgColor.a == 0 then
            bgColor = Color(0, 0, 0, 255 * self.Config.BackgroundDim)
        end
        
        draw.RoundedBox(0, 0, 0, w, h, bgColor)
    end
    
    -- Draw all particles
    for _, particle in ipairs(self.Particles) do
        particle:draw(self.Config)
    end
    
    -- Draw DDI-styled flourishes if enabled
    if self.Config.DDIStyled then
        -- Draw small DDI logo in corner
        local logoSize = 20
        local margin = 5
        
        draw.RoundedBox(4, margin, margin, logoSize, logoSize, Color(40, 40, 44, 150))
        draw.SimpleText('DDI', 'DermaDefaultBold', margin + logoSize/2, margin + logoSize/2, DDIStyling.Colors.Primary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Draw subtle accent line at bottom
        local accentHeight = 2
        local accentWidth = w / 3
        
        surface.SetDrawColor(DDIStyling.Colors.Primary)
        surface.DrawRect(0, h - accentHeight, accentWidth, accentHeight)
        
        surface.SetDrawColor(DDIStyling.Colors.Secondary)
        surface.DrawRect(accentWidth, h - accentHeight, accentWidth, accentHeight)
        
        surface.SetDrawColor(DDIStyling.Colors.Accent)
        surface.DrawRect(accentWidth * 2, h - accentHeight, accentWidth, accentHeight)
    end
    
    return true
end

-- Helper function to draw a circle
function draw.Circle(x, y, radius, color)
    local segments = math.max(8, math.floor(radius))
    
    local vertices = {}
    for i = 0, segments do
        local angle = math.rad((i / segments) * 360)
        local px = x + math.cos(angle) * radius
        local py = y + math.sin(angle) * radius
        table.insert(vertices, {x = px, y = py})
    end
    
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    draw.NoTexture()
    surface.DrawPoly(vertices)
end

vgui.Register('AnimatedParticles', PANEL, 'Panel')
return PANEL