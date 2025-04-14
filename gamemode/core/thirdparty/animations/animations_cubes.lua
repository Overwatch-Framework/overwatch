--[[
    Animations - Cubes
    Modern UI animations with cubes for Garry's Mod
    
    This module provides a customizable loading animation 
    with colored cubes that move between each other.
]]

local PANEL = {}

-- Default configuration
PANEL.Colors = {
    Color(255, 70, 70),   -- Red
    Color(70, 150, 255),  -- Blue
    Color(70, 255, 70),   -- Green
    Color(255, 200, 70)   -- Yellow
}
PANEL.CubeSize = 20       -- Size of each cube
PANEL.CubeCount = 4       -- Number of cubes
PANEL.Speed = 1           -- Animation speed multiplier
PANEL.Spacing = 15        -- Spacing between cubes
PANEL.MovementRange = 20  -- How far cubes move from their original position

-- Initialize the panel
function PANEL:Init()
    self.Time = 0
    self.CubePositions = {}
    self.StartPositions = {}
    
    -- Set default size
    self:SetSize(200, 60)
    
    -- Calculate initial positions
    self:CalculatePositions()
end

-- Calculate cube positions
function PANEL:CalculatePositions()
    local centerY = self:GetTall() / 2
    local totalWidth = (self.CubeSize * self.CubeCount) + (self.Spacing * (self.CubeCount - 1))
    local startX = (self:GetWide() - totalWidth) / 2
    
    self.CubePositions = {}
    self.StartPositions = {}
    
    for i = 1, self.CubeCount do
        local x = startX + ((i - 1) * (self.CubeSize + self.Spacing))
        self.StartPositions[i] = {x = x, y = centerY - self.CubeSize / 2}
        self.CubePositions[i] = {x = x, y = centerY - self.CubeSize / 2}
    end
end

-- Called when the panel size changes
function PANEL:PerformLayout(w, h)
    self:CalculatePositions()
end

-- Think is called every frame
function PANEL:Think()
    self.Time = self.Time + (FrameTime() * self.Speed)
    
    -- Update cube positions using sine waves to create smooth motion
    for i = 1, self.CubeCount do
        local phase = (i - 1) * (math.pi / 2) -- Phase shift for each cube
        
        -- Horizontal movement
        self.CubePositions[i].x = self.StartPositions[i].x + 
            math.sin(self.Time * 2 + phase) * self.MovementRange
        
        -- Vertical movement (smaller amplitude)
        self.CubePositions[i].y = self.StartPositions[i].y + 
            math.cos(self.Time * 3 + phase) * (self.MovementRange / 2)
    end
end

-- Draw the panel
function PANEL:Paint(w, h)
    -- Draw background (transparent by default)
    -- surface.SetDrawColor(30, 30, 30, 200) -- Uncomment for a dark background
    -- surface.DrawRect(0, 0, w, h)
    
    -- Draw each cube
    for i = 1, self.CubeCount do
        local color = self.Colors[(i % #self.Colors) + 1]
        
        -- Small shadow/glow effect
        surface.SetDrawColor(color.r, color.g, color.b, 40)
        surface.DrawRect(
            self.CubePositions[i].x + 2, 
            self.CubePositions[i].y + 2, 
            self.CubeSize, 
            self.CubeSize
        )
        
        -- Main cube
        surface.SetDrawColor(color)
        surface.DrawRect(
            self.CubePositions[i].x, 
            self.CubePositions[i].y, 
            self.CubeSize, 
            self.CubeSize
        )
    end
end

-- Configure the animation settings
function PANEL:Configure(config)
    config = config or {}
    
    if config.Colors then self.Colors = config.Colors end
    if config.CubeSize then 
        self.CubeSize = config.CubeSize 
        self:CalculatePositions()
    end
    if config.CubeCount then 
        self.CubeCount = config.CubeCount 
        self:CalculatePositions()
    end
    if config.Speed then self.Speed = config.Speed end
    if config.Spacing then 
        self.Spacing = config.Spacing 
        self:CalculatePositions()
    end
    if config.MovementRange then self.MovementRange = config.MovementRange end
    
    return self
end

vgui.Register('AnimatedCubes', PANEL, 'DPanel')

-- Return the panel so it can be used elsewhere
return PANEL
