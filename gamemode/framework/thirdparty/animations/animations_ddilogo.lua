--[[
    DDI Logo Animation for Garry's Mod
    
    A collection of animated DDI logo styles with customizable properties.
    Part of the DDI Modern UI Animations package.
]]

local PANEL = {}

-- Default configuration
local DefaultConfig = {
    LogoStyle = 'standard',     -- Logo style variant
    PrimaryColor = Color(0, 128, 255, 255),    -- Primary brand color
    SecondaryColor = Color(255, 0, 128, 255),  -- Secondary brand color
    AccentColor = Color(0, 255, 128, 255),     -- Accent color
    Size = 100,                 -- Logo size
    AnimationStyle = 'pulse',   -- Animation style
    AnimationSpeed = 1,         -- Animation speed
    BackgroundStyle = 'none',   -- Background style
    BorderStyle = 'none',       -- Border style
    TextTagline = false,        -- Show tagline
    Tagline = 'Digital Design Innovations', -- Tagline text
    GlowAmount = 0.5            -- Glow amount
}

-- Logo designs - 12 variations
local LogoDesigns = {
    standard = function(self, w, h, config)
        -- Main circle
        local centerX, centerY = w/2, h/2
        local radius = config.Size / 2
        
        -- Background if needed
        if config.BackgroundStyle == 'solid' then
            draw.RoundedBox(radius, centerX - radius, centerY - radius, radius*2, radius*2, Color(30, 30, 30, 200))
        elseif config.BackgroundStyle == 'gradient' then
            render.SetStencilWriteMask(0xFF)
            render.SetStencilTestMask(0xFF)
            render.SetStencilReferenceValue(0)
            render.SetStencilPassOperation(STENCIL_REPLACE)
            render.SetStencilFailOperation(STENCIL_KEEP)
            render.SetStencilZFailOperation(STENCIL_KEEP)
            render.ClearStencil()

            render.SetStencilEnable(true)
            render.SetStencilReferenceValue(1)
            render.SetStencilCompareFunction(STENCIL_NEVER)
            render.SetStencilFailOperation(STENCIL_REPLACE)
            
            draw.NoTexture()
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SafeDrawCircle(centerX, centerY, radius, 30)
            
            render.SetStencilCompareFunction(STENCIL_EQUAL)
            render.SetStencilFailOperation(STENCIL_KEEP)
            
            surface.SetDrawColor(config.PrimaryColor)
            draw.LinearGradient(centerX - radius, centerY - radius, radius*2, radius*2, 
                config.PrimaryColor, config.SecondaryColor, true)
            
            render.SetStencilEnable(false)
        end
        
        -- Draw outer circle
        local outerCol = config.PrimaryColor
        surface.SetDrawColor(outerCol.r, outerCol.g, outerCol.b, outerCol.a)
        
        -- Используем нашу безопасную функцию для рисования круга
        surface.SafeDrawCircle(centerX, centerY, radius - 2, 32)
        
        -- Draw inner 'D's
        local letterOffset = radius * 0.4
        local letterSize = radius * 0.7
        
        -- First D
        surface.SetDrawColor(config.SecondaryColor)
        local x1, y1 = centerX - letterOffset, centerY
        self:DrawD(x1, y1, letterSize, config.SecondaryColor)
        
        -- Second D  
        local x2, y2 = centerX + letterOffset * 0.2, centerY
        self:DrawD(x2, y2, letterSize, config.AccentColor)
        
        -- Draw 'I' between Ds
        local iHeight = letterSize * 0.8
        local iWidth = letterSize * 0.2
        local iX = centerX - iWidth/2
        local iY = centerY - iHeight/2
        
        surface.SetDrawColor(config.PrimaryColor)
        surface.DrawRect(iX, iY, iWidth, iHeight)
        
        -- Draw tagline if enabled
        if config.TextTagline then
            surface.SetFont('DermaDefault')
            local textW, textH = surface.GetTextSize(config.Tagline)
            surface.SetTextColor(config.PrimaryColor)
            surface.SetTextPos(centerX - textW/2, centerY + radius + 5)
            surface.DrawText(config.Tagline)
        end
        
        -- Draw border if enabled
        if config.BorderStyle == 'simple' then
            surface.SetDrawColor(config.PrimaryColor)
            surface.SafeDrawCircle(centerX, centerY, radius, 32)
        elseif config.BorderStyle == 'double' then
            surface.SetDrawColor(config.PrimaryColor)
            surface.SafeDrawCircle(centerX, centerY, radius, 32)
            surface.SafeDrawCircle(centerX, centerY, radius - 3, 32)
        elseif config.BorderStyle == 'glow' then
            local glowCol = Color(config.PrimaryColor.r, config.PrimaryColor.g, config.PrimaryColor.b, 
                              config.PrimaryColor.a * 0.7)
            self:DrawGlow(centerX, centerY, radius + 5, glowCol, 10 * config.GlowAmount)
        end
    end,
    
    minimal = function(self, w, h, config)
        local centerX, centerY = w/2, h/2
        local size = config.Size * 0.8
        
        -- Draw D outlines
        local letterOffset = size * 0.25
        local letterSize = size * 0.6
        
        -- Draw the 'DDI' in minimalist style
        -- First D outline
        self:DrawDOutline(centerX - letterOffset, centerY, letterSize, config.PrimaryColor)
        
        -- I in the middle
        local iHeight = letterSize * 0.8
        local iWidth = letterSize * 0.15
        surface.SetDrawColor(config.SecondaryColor)
        surface.DrawOutlinedRect(centerX - iWidth/2, centerY - iHeight/2, iWidth, iHeight, 2)
        
        -- Second D outline
        self:DrawDOutline(centerX + letterOffset, centerY, letterSize, config.AccentColor)
    end,
    
    full = function(self, w, h, config)
        local centerX, centerY = w/2, h/2
        local size = config.Size
        
        -- Background shape
        local bgW, bgH = size * 1.5, size * 0.8
        local bgX, bgY = centerX - bgW/2, centerY - bgH/2
        
        draw.RoundedBox(10, bgX, bgY, bgW, bgH, Color(30, 30, 30, 200))
        
        -- Draw text-based DDI logo
        surface.SetFont('DermaLarge')
        local textW = surface.GetTextSize('DDI')
        surface.SetTextColor(config.PrimaryColor)
        surface.SetTextPos(centerX - textW/2, centerY - 15)
        surface.DrawText('DDI')
        
        -- Draw full company name below
        if config.TextTagline then
            surface.SetFont('DermaDefault')
            local tagW = surface.GetTextSize(config.Tagline)
            surface.SetTextColor(config.SecondaryColor)
            surface.SetTextPos(centerX - tagW/2, centerY + 15)
            surface.DrawText(config.Tagline)
        end
        
        -- Add border
        if config.BorderStyle ~= 'none' then
            surface.SetDrawColor(config.AccentColor)
            surface.DrawOutlinedRect(bgX, bgY, bgW, bgH, 2)
        end
    end,
    
    tech = function(self, w, h, config)
        local centerX, centerY = w/2, h/2
        local size = config.Size
        
        -- Draw hexagon background
        local hexRadius = size/2
        self:DrawHexagon(centerX, centerY, hexRadius, Color(30, 30, 30, 200))
        
        -- Draw outer hexagon border
        surface.SetDrawColor(config.PrimaryColor)
        self:DrawHexagonOutline(centerX, centerY, hexRadius, config.PrimaryColor)
        
        -- Draw inner circuit pattern
        self:DrawCircuitPattern(centerX, centerY, hexRadius * 0.8, config.SecondaryColor)
        
        -- Draw DDI in tech style
        local letterSize = size * 0.3
        local yOffset = -letterSize * 0.1
        
        -- Draw the D's and I with tech styling
        self:DrawTechLetter(centerX - letterSize, centerY + yOffset, letterSize, 'D', config.PrimaryColor)
        self:DrawTechLetter(centerX, centerY + yOffset, letterSize * 0.6, 'I', config.AccentColor)
        self:DrawTechLetter(centerX + letterSize * 0.8, centerY + yOffset, letterSize, 'D', config.SecondaryColor)
    end,
    
    glitch = function(self, w, h, config)
        local centerX, centerY = w/2, h/2
        local size = config.Size
        
        -- Get current time-based offset for glitch effect
        local time = CurTime() * config.AnimationSpeed
        local glitchOffset = math.sin(time * 5) * 3
        
        -- Draw base shape
        draw.RoundedBox(5, centerX - size/2, centerY - size/2, size, size, Color(20, 20, 20, 200))
        
        -- Draw DDI letters with glitch effect
        surface.SetFont('DermaLarge')
        local text = 'DDI'
        local textW, textH = surface.GetTextSize(text)
        
        -- Draw glitch shadows
        if math.random() < 0.3 then
            surface.SetTextColor(config.SecondaryColor.r, config.SecondaryColor.g, config.SecondaryColor.b, 120)
            surface.SetTextPos(centerX - textW/2 + math.random(-3, 3), centerY - textH/2 + math.random(-3, 3))
            surface.DrawText(text)
        end
        
        -- Draw main text
        surface.SetTextColor(config.PrimaryColor)
        surface.SetTextPos(centerX - textW/2, centerY - textH/2)
        surface.DrawText(text)
        
        -- Draw accent glitch lines
        local lineCount = math.random(1, 3)
        for i=1, lineCount do
            local lineY = centerY - size/2 + math.random(0, size)
            local lineLength = math.random(size * 0.3, size * 0.8)
            local lineX = centerX - lineLength/2 + math.random(-10, 10)
            
            surface.SetDrawColor(config.AccentColor)
            surface.DrawRect(lineX, lineY, lineLength, math.random(1, 3))
        end
    end,
    
    neon = function(self, w, h, config)
        local centerX, centerY = w/2, h/2
        local size = config.Size
        
        -- Pulsing effect for neon
        local time = CurTime() * config.AnimationSpeed
        local pulse = 0.7 + math.sin(time * 2) * 0.3
        
        -- Background
        draw.RoundedBox(10, centerX - size/2, centerY - size/2, size, size, Color(20, 20, 20, 200))
        
        -- Draw neon DDI letters
        local letterWidth = size * 0.25
        local letterHeight = size * 0.5
        local spacing = letterWidth * 0.4
        local startX = centerX - (letterWidth * 2 + spacing * 2) / 2
        
        -- First D with glow
        self:DrawNeonLetter(startX, centerY, letterWidth, letterHeight, 'D', config.PrimaryColor, config.GlowAmount * pulse)
        
        -- Second D with glow
        self:DrawNeonLetter(startX + letterWidth + spacing, centerY, letterWidth, letterHeight, 'D', config.SecondaryColor, config.GlowAmount * pulse)
        
        -- I with glow
        self:DrawNeonLetter(startX + (letterWidth + spacing) * 2, centerY, letterWidth * 0.5, letterHeight, 'I', config.AccentColor, config.GlowAmount * pulse)
    end,
    
    holographic = function(self, w, h, config)
        local centerX, centerY = w/2, h/2
        local size = config.Size
        
        -- Animated elements for holographic effect
        local time = CurTime() * config.AnimationSpeed
        local scanlineOffset = (time % 2) * size
        
        -- Draw base circular shape
        draw.NoTexture()
        surface.SetDrawColor(30, 30, 30, 150)
        surface.SafeDrawCircle(centerX, centerY, size/2, 32)
        
        -- Draw holographic DDI
        surface.SetFont('DermaLarge')
        local text = 'DDI'
        local textW, textH = surface.GetTextSize(text)
        
        -- Draw holographic text
        surface.SetTextColor(config.PrimaryColor.r, config.PrimaryColor.g, config.PrimaryColor.b, 150)
        surface.SetTextPos(centerX - textW/2, centerY - textH/2)
        surface.DrawText(text)
        
        -- Draw scan lines
        for i=0, size, 4 do
            local lineY = centerY - size/2 + (i + scanlineOffset) % size
            local alpha = 70 + math.sin(time + i * 0.1) * 30
            
            surface.SetDrawColor(config.SecondaryColor.r, config.SecondaryColor.g, config.SecondaryColor.b, alpha)
            surface.DrawRect(centerX - size/2, lineY, size, 1)
        end
        
        -- Draw outer ring
        surface.SetDrawColor(config.AccentColor.r, config.AccentColor.g, config.AccentColor.b, 100)
        surface.SafeDrawCircle(centerX, centerY, size/2, 32)
    end,
    
    futuristic = function(self, w, h, config)
        local centerX, centerY = w/2, h/2
        local size = config.Size
        
        -- Draw futuristic frame
        local frameWidth = size * 1.2
        local frameHeight = size * 0.7
        local frameX = centerX - frameWidth/2
        local frameY = centerY - frameHeight/2
        
        -- Background panel
        draw.RoundedBox(5, frameX, frameY, frameWidth, frameHeight, Color(20, 20, 30, 200))
        
        -- Add tech lines
        surface.SetDrawColor(config.PrimaryColor.r, config.PrimaryColor.g, config.PrimaryColor.b, 100)
        
        -- Horizontal lines
        for i=1, 5 do
            local lineY = frameY + frameHeight * (i/6)
            surface.DrawLine(frameX, lineY, frameX + frameWidth, lineY)
        end
        
        -- Vertical lines
        for i=1, 7 do
            local lineX = frameX + frameWidth * (i/8)
            surface.DrawLine(lineX, frameY, lineX, frameY + frameHeight)
        end
        
        -- Draw DDI text
        surface.SetFont('DermaLarge')
        local text = 'DDI'
        local textW, textH = surface.GetTextSize(text)
        
        -- Draw text shadow
        surface.SetTextColor(config.AccentColor.r, config.AccentColor.g, config.AccentColor.b, 150)
        surface.SetTextPos(centerX - textW/2 + 2, centerY - textH/2 + 2)
        surface.DrawText(text)
        
        -- Draw main text
        surface.SetTextColor(config.SecondaryColor)
        surface.SetTextPos(centerX - textW/2, centerY - textH/2)
        surface.DrawText(text)
        
        -- Draw accent corners
        local cornerSize = 10
        
        -- Top-left corner
        surface.SetDrawColor(config.AccentColor)
        surface.DrawRect(frameX, frameY, cornerSize, 2)
        surface.DrawRect(frameX, frameY, 2, cornerSize)
        
        -- Top-right corner
        surface.DrawRect(frameX + frameWidth - cornerSize, frameY, cornerSize, 2)
        surface.DrawRect(frameX + frameWidth - 2, frameY, 2, cornerSize)
        
        -- Bottom-left corner
        surface.DrawRect(frameX, frameY + frameHeight - 2, cornerSize, 2)
        surface.DrawRect(frameX, frameY + frameHeight - cornerSize, 2, cornerSize)
        
        -- Bottom-right corner
        surface.DrawRect(frameX + frameWidth - cornerSize, frameY + frameHeight - 2, cornerSize, 2)
        surface.DrawRect(frameX + frameWidth - 2, frameY + frameHeight - cornerSize, 2, cornerSize)
    end,
    
    retro = function(self, w, h, config)
        local centerX, centerY = w/2, h/2
        local size = config.Size
        
        -- Draw pixelated retro background
        local pixelSize = 4
        local bgSize = size
        local startX = centerX - bgSize/2
        local startY = centerY - bgSize/2
        
        for x=0, bgSize, pixelSize do
            for y=0, bgSize, pixelSize do
                local colorBrightness = math.random(20, 40)
                surface.SetDrawColor(colorBrightness, colorBrightness, colorBrightness + 10, 200)
                surface.DrawRect(startX + x, startY + y, pixelSize, pixelSize)
            end
        end
        
        -- Draw pixelated DDI
        local letterWidth = size * 0.2
        local letterHeight = size * 0.4
        local spacing = letterWidth * 0.5
        local letterY = centerY - letterHeight/2
        
        -- First D - pixelated
        self:DrawPixelatedLetter(centerX - letterWidth - spacing, letterY, letterWidth, letterHeight, 'D', config.PrimaryColor, pixelSize)
        
        -- Second D - pixelated
        self:DrawPixelatedLetter(centerX, letterY, letterWidth, letterHeight, 'D', config.SecondaryColor, pixelSize)
        
        -- I - pixelated
        self:DrawPixelatedLetter(centerX + letterWidth + spacing * 0.5, letterY, letterWidth * 0.5, letterHeight, 'I', config.AccentColor, pixelSize)
        
        -- Draw retro frame
        surface.SetDrawColor(config.PrimaryColor)
        surface.DrawOutlinedRect(startX, startY, bgSize, bgSize, 2)
        
        -- Add scanlines
        local time = CurTime() * config.AnimationSpeed
        local scanOffset = (time % 1) * 8
        
        for y=0, bgSize, 4 do
            local lineY = startY + (y + scanOffset) % bgSize
            surface.SetDrawColor(255, 255, 255, 10)
            surface.DrawRect(startX, lineY, bgSize, 1)
        end
    end,
    
    classic = function(self, w, h, config)
        local centerX, centerY = w/2, h/2
        local size = config.Size
        
        -- Draw classic circular logo background
        surface.SetDrawColor(30, 30, 30, 200)
        surface.SafeDrawCircle(centerX, centerY, size/2, 32)
        
        -- Draw outer ring
        surface.SetDrawColor(config.PrimaryColor)
        surface.SafeDrawCircle(centerX, centerY, size/2, 32)
        surface.SafeDrawCircle(centerX, centerY, size/2 - 2, 32)
        
        -- Draw inner ring
        surface.SetDrawColor(config.SecondaryColor)
        surface.SafeDrawCircle(centerX, centerY, size/2 - 10, 32)
        
        -- Draw 'DDI' text
        surface.SetFont('DermaLarge')
        local text = 'DDI'
        local textW, textH = surface.GetTextSize(text)
        
        -- Draw text with classic styling
        surface.SetTextColor(255, 255, 255, 255)
        surface.SetTextPos(centerX - textW/2, centerY - textH/2)
        surface.DrawText(text)
        
        -- Add company name curved around bottom if enabled
        if config.TextTagline then
            -- Draw curved text approximation
            local radius = size/2 - 15
            local startAngle = -40
            local arcLength = 80
            local tagline = config.Tagline
            
            surface.SetFont('DermaDefaultBold')
            surface.SetTextColor(config.AccentColor)
            
            for i=1, #tagline do
                local char = tagline:sub(i, i)
                local angle = startAngle + (i-1) * (arcLength / #tagline)
                local rad = math.rad(angle)
                local x = centerX + math.cos(rad) * radius
                local y = centerY + math.sin(rad) * radius
                
                -- Rotate text to follow the curve
                local rotatedX, rotatedY = surface.RotatedPos(x, y, rad + math.rad(90), 0, 0)
                
                surface.SetTextPos(x - 4, y - 4)
                surface.DrawText(char)
            end
        end
    end,
    
    modern = function(self, w, h, config)
        local centerX, centerY = w/2, h/2
        local size = config.Size
        
        -- Draw modern style with clean lines and flat design
        local bgSize = size * 0.9
        local bgX = centerX - bgSize/2
        local bgY = centerY - bgSize/2
        
        -- Background square with rounded corners
        draw.RoundedBox(8, bgX, bgY, bgSize, bgSize, Color(30, 30, 30, 200))
        
        -- Single horizontal accent line
        surface.SetDrawColor(config.AccentColor)
        surface.DrawRect(bgX + bgSize * 0.2, centerY, bgSize * 0.6, 2)
        
        -- Draw modern DDI letters
        local letterWidth = bgSize * 0.2
        local letterHeight = bgSize * 0.4
        local startX = centerX - bgSize * 0.3
        local letterY = centerY - letterHeight/2 - 5
        
        -- First D
        draw.RoundedBox(4, startX, letterY, letterWidth * 0.25, letterHeight, config.PrimaryColor)
        draw.RoundedBox(4, startX, letterY, letterWidth, letterHeight * 0.2, config.PrimaryColor)
        draw.RoundedBox(4, startX, letterY + letterHeight * 0.8, letterWidth, letterHeight * 0.2, config.PrimaryColor)
        draw.RoundedBox(4, startX + letterWidth * 0.75, letterY + letterHeight * 0.2, letterWidth * 0.25, letterHeight * 0.6, config.PrimaryColor)
        
        -- Second D
        startX = centerX - letterWidth * 0.5
        draw.RoundedBox(4, startX, letterY, letterWidth * 0.25, letterHeight, config.SecondaryColor)
        draw.RoundedBox(4, startX, letterY, letterWidth, letterHeight * 0.2, config.SecondaryColor)
        draw.RoundedBox(4, startX, letterY + letterHeight * 0.8, letterWidth, letterHeight * 0.2, config.SecondaryColor)
        draw.RoundedBox(4, startX + letterWidth * 0.75, letterY + letterHeight * 0.2, letterWidth * 0.25, letterHeight * 0.6, config.SecondaryColor)
        
        -- I
        startX = centerX + letterWidth
        draw.RoundedBox(4, startX, letterY, letterWidth * 0.25, letterHeight, config.AccentColor)
        
        -- Tagline
        if config.TextTagline then
            surface.SetFont('DermaDefault')
            local tagW, tagH = surface.GetTextSize(config.Tagline)
            surface.SetTextColor(200, 200, 200, 200)
            surface.SetTextPos(centerX - tagW/2, letterY + letterHeight + 10)
            surface.DrawText(config.Tagline)
        end
    end,
    
    animated = function(self, w, h, config)
        local centerX, centerY = w/2, h/2
        local size = config.Size
        
        -- Time-based animations
        local time = CurTime() * config.AnimationSpeed
        local pulse = 0.8 + math.sin(time * 2) * 0.2
        local rotation = time * 30 % 360
        
        -- Draw rotating background elements
        for i=1, 3 do
            local angle = rotation + i * 120
            local rad = math.rad(angle)
            local distance = size * 0.3
            local x = centerX + math.cos(rad) * distance
            local y = centerY + math.sin(rad) * distance
            local elementSize = size * 0.15 * pulse
            
            surface.SetDrawColor(config.PrimaryColor.r, config.PrimaryColor.g, config.PrimaryColor.b, 150)
            surface.SafeDrawCircle(x, y, elementSize, 16)
        end
        
        -- Draw central DDI text that pulses
        surface.SetFont('DermaLarge')
        local text = 'DDI'
        local textW, textH = surface.GetTextSize(text)
        
        -- Text shadow with offset based on time
        local shadowOffset = math.sin(time * 3) * 2
        surface.SetTextColor(config.SecondaryColor.r, config.SecondaryColor.g, config.SecondaryColor.b, 100)
        surface.SetTextPos(centerX - textW/2 + shadowOffset, centerY - textH/2 + shadowOffset)
        surface.DrawText(text)
        
        -- Main text that pulses in size
        local textScale = 1 + (pulse - 0.9) * 0.5
        surface.SetTextColor(config.PrimaryColor)
        
        -- We can't actually scale the font, so we'll just offset the position to simulate scaling
        local scaledOffset = (textW * (textScale - 1)) / 2
        surface.SetTextPos(centerX - textW/2 - scaledOffset, centerY - textH/2 - scaledOffset/2)
        surface.DrawText(text)
        
        -- Animated rings that expand outward
        local ringTime = time % 3
        local ringRadius = ringTime * (size/2) / 1.5
        
        if ringRadius < size/2 then
            local ringAlpha = 255 * (1 - ringTime/3)
            surface.SetDrawColor(config.AccentColor.r, config.AccentColor.g, config.AccentColor.b, ringAlpha)
            surface.SafeDrawCircle(centerX, centerY, ringRadius, 32)
        end
    end,
}

-- Initialize the panel
function PANEL:Init()
    self.Config = table.Copy(DefaultConfig)
    self.LastTime = CurTime()
    
    -- Start animation timer
    self.AnimationTimer = 0
    
    -- Store animation state variables
    self.AnimationState = {
        RotationAngle = 0,
        PulseValue = 0,
        MorphPosition = 0,
    }
    
    -- Default settings
    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(false)
end

-- Apply configuration options
function PANEL:Configure(config)
    table.Merge(self.Config, config or {})
    
    -- Reset animation state when configuration changes
    self.AnimationState = {
        RotationAngle = 0,
        PulseValue = 0,
        MorphPosition = 0,
    }
    
    -- Dynamic options
    if config and config.PrimaryColor then
        self.Config.PrimaryColor = config.PrimaryColor
    end
    
    if config and config.SecondaryColor then
        self.Config.SecondaryColor = config.SecondaryColor
    end
    
    if config and config.LogoStyle then
        self.Config.LogoStyle = config.LogoStyle
    end
    
    -- Call any immediate configuration effects
    self:UpdateAnimation()
end

-- Update animation state
function PANEL:UpdateAnimation()
    local currentTime = CurTime()
    local deltaTime = currentTime - self.LastTime
    self.LastTime = currentTime
    
    -- Update animation timer
    self.AnimationTimer = self.AnimationTimer + deltaTime * self.Config.AnimationSpeed
    
    -- Update animation state based on style
    if self.Config.AnimationStyle == 'spin' then
        self.AnimationState.RotationAngle = (self.AnimationState.RotationAngle + deltaTime * 90 * self.Config.AnimationSpeed) % 360
    elseif self.Config.AnimationStyle == 'pulse' then
        self.AnimationState.PulseValue = 0.8 + math.sin(self.AnimationTimer * 2) * 0.2
    elseif self.Config.AnimationStyle == 'morph' then
        self.AnimationState.MorphPosition = (math.sin(self.AnimationTimer) + 1) / 2
    elseif self.Config.AnimationStyle == 'glitch' then
        -- Random glitch values updated periodically
        if math.random() < 0.05 then
            self.AnimationState.GlitchOffsetX = math.random(-5, 5)
            self.AnimationState.GlitchOffsetY = math.random(-5, 5)
            self.AnimationState.GlitchSlice = math.random(0, 1) == 1
        end
    end
end

-- Helper function to draw D letter
function PANEL:DrawD(x, y, size, color)
    local height = size
    local width = size * 0.75
    
    -- Draw vertical line
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    surface.DrawRect(x - width/2, y - height/2, width * 0.25, height)
    
    -- Draw top horizontal line
    surface.DrawRect(x - width/2, y - height/2, width, height * 0.2)
    
    -- Draw bottom horizontal line
    surface.DrawRect(x - width/2, y + height/2 - height * 0.2, width, height * 0.2)
    
    -- Draw curved right side (approximated with a rect)
    surface.DrawRect(x + width/2 - width * 0.25, y - height/2 + height * 0.2, width * 0.25, height * 0.6)
end

-- Helper function to draw D outline
function PANEL:DrawDOutline(x, y, size, color)
    local height = size
    local width = size * 0.75
    local thickness = 2
    
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    
    -- Left vertical
    surface.DrawRect(x - width/2, y - height/2, thickness, height)
    
    -- Top horizontal
    surface.DrawRect(x - width/2, y - height/2, width, thickness)
    
    -- Bottom horizontal
    surface.DrawRect(x - width/2, y + height/2 - thickness, width, thickness)
    
    -- Right side (curve approximated with vertical line)
    surface.DrawRect(x + width/2 - thickness, y - height/2 + height * 0.2, thickness, height * 0.6)
    
    -- Connecting lines for the curve
    surface.DrawLine(x + width/2 - thickness, y - height/2 + height * 0.2, x - width/2 + width, y - height/2 + thickness)
    surface.DrawLine(x + width/2 - thickness, y + height/2 - height * 0.2, x - width/2 + width, y + height/2 - thickness)
end

-- Helper function to draw tech-styled letter
function PANEL:DrawTechLetter(x, y, size, letter, color)
    surface.SetFont('DermaDefaultBold')
    local textW, textH = surface.GetTextSize(letter)
    
    -- Draw tech frame around letter
    local padding = 3
    local frameW = textW + padding * 2
    local frameH = textH + padding * 2
    
    -- Draw tech background
    draw.RoundedBox(2, x - frameW/2, y - frameH/2, frameW, frameH, Color(30, 30, 30, 200))
    
    -- Draw tech accents
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    
    -- Draw corners
    local cornerSize = 4
    
    -- Top-left
    surface.DrawRect(x - frameW/2, y - frameH/2, cornerSize, 1)
    surface.DrawRect(x - frameW/2, y - frameH/2, 1, cornerSize)
    
    -- Top-right
    surface.DrawRect(x + frameW/2 - cornerSize, y - frameH/2, cornerSize, 1)
    surface.DrawRect(x + frameW/2 - 1, y - frameH/2, 1, cornerSize)
    
    -- Bottom-left
    surface.DrawRect(x - frameW/2, y + frameH/2 - 1, cornerSize, 1)
    surface.DrawRect(x - frameW/2, y + frameH/2 - cornerSize, 1, cornerSize)
    
    -- Bottom-right
    surface.DrawRect(x + frameW/2 - cornerSize, y + frameH/2 - 1, cornerSize, 1)
    surface.DrawRect(x + frameW/2 - 1, y + frameH/2 - cornerSize, 1, cornerSize)
    
    -- Draw letter
    surface.SetTextColor(color.r, color.g, color.b, color.a)
    surface.SetTextPos(x - textW/2, y - textH/2)
    surface.DrawText(letter)
end

-- Helper function to draw neon letter
function PANEL:DrawNeonLetter(x, y, width, height, letter, color, glowAmount)
    surface.SetFont('DermaDefaultBold')
    local textW, textH = surface.GetTextSize(letter)
    
    -- Draw glow
    local glowSize = 5 * glowAmount
    self:DrawGlow(x, y, width * 0.6, color, glowSize)
    
    -- Draw the letter
    surface.SetTextColor(255, 255, 255, 255)
    surface.SetTextPos(x - textW/2, y - textH/2)
    surface.DrawText(letter)
    
    -- Draw outer border
    surface.SetDrawColor(color.r, color.g, color.b, 255)
    surface.DrawOutlinedRect(x - width/2, y - height/2, width, height, 1)
end

-- Helper function to draw pixelated letter
function PANEL:DrawPixelatedLetter(x, y, width, height, letter, color, pixelSize)
    -- Pixel grid for each letter
    local pixelMaps = {
        D = {
            {1,1,1,0},
            {1,0,0,1},
            {1,0,0,1},
            {1,0,0,1},
            {1,1,1,0}
        },
        I = {
            {1},
            {1},
            {1},
            {1},
            {1}
        }
    }
    
    local pixelMap = pixelMaps[letter]
    if not pixelMap then return end
    
    local mapWidth = #pixelMap[1]
    local mapHeight = #pixelMap
    
    local gridWidth = mapWidth * pixelSize
    local gridHeight = mapHeight * pixelSize
    
    local startX = x - gridWidth/2
    local startY = y - gridHeight/2
    
    -- Draw the pixelated letter
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    
    for py=1, mapHeight do
        for px=1, mapWidth do
            if pixelMap[py][px] == 1 then
                local pixelX = startX + (px-1) * pixelSize
                local pixelY = startY + (py-1) * pixelSize
                surface.DrawRect(pixelX, pixelY, pixelSize, pixelSize)
            end
        end
    end
end

-- Helper function to draw hexagon
function PANEL:DrawHexagon(x, y, radius, color)
    local vertices = {}
    for i=0, 5 do
        local angle = math.rad(i * 60)
        table.insert(vertices, {
            x = x + math.cos(angle) * radius,
            y = y + math.sin(angle) * radius
        })
    end
    
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    draw.NoTexture()
    surface.DrawPoly(vertices)
end

-- Helper function to draw hexagon outline
function PANEL:DrawHexagonOutline(x, y, radius, color)
    local vertices = {}
    for i=0, 6 do
        local angle = math.rad(i * 60)
        table.insert(vertices, {
            x = x + math.cos(angle) * radius,
            y = y + math.sin(angle) * radius
        })
    end
    
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    
    for i=1, 6 do
        local v1 = vertices[i]
        local v2 = vertices[i % 6 + 1]
        surface.DrawLine(v1.x, v1.y, v2.x, v2.y)
    end
end

-- Helper function to draw circuit pattern
function PANEL:DrawCircuitPattern(x, y, radius, color)
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    
    -- Draw some circuit-like lines
    local segments = 8
    local segmentAngle = 360 / segments
    
    for i=0, segments-1 do
        local angle1 = math.rad(i * segmentAngle)
        local angle2 = math.rad((i+1) * segmentAngle)
        
        local x1 = x + math.cos(angle1) * radius * 0.5
        local y1 = y + math.sin(angle1) * radius * 0.5
        local x2 = x + math.cos(angle2) * radius * 0.5
        local y2 = y + math.sin(angle2) * radius * 0.5
        
        -- Draw connecting lines
        surface.DrawLine(x, y, x1, y1)
        
        -- Draw nodes at endpoints
        surface.DrawRect(x1-2, y1-2, 4, 4)
    end
    
    -- Draw inner circle
    surface.SafeDrawCircle(x, y, radius * 0.2, 16)
end

-- Helper function to draw a glow effect
function PANEL:DrawGlow(x, y, radius, color, blurSize)
    local glowMaterial = Material('effects/blurscreen')
    
    -- Store the current render target and setup for blur
    render.PushRenderTarget(render.GetScreenEffectTexture(0))
    render.Clear(0, 0, 0, 0, true, true)
    
    -- Draw the shape to be blurred
    draw.NoTexture()
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SafeDrawCircle(x, y, radius, 32)
    
    -- Apply blur effect
    render.BlurRenderTarget(render.GetScreenEffectTexture(0), blurSize, blurSize, 1)
    
    -- Restore render target
    render.PopRenderTarget()
    
    -- Draw the blurred result
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    surface.SetMaterial(glowMaterial)
    surface.DrawTexturedRect(x - radius - blurSize, y - radius - blurSize, 
                          (radius + blurSize) * 2, (radius + blurSize) * 2)
end

-- Helper function for drawing linear gradients
function draw.LinearGradient(x, y, w, h, startColor, endColor, horizontal)
    local vertices = {}
    
    if horizontal then
        vertices[1] = { x = x, y = y, u = 0, v = 0, r = startColor.r, g = startColor.g, b = startColor.b, a = startColor.a }
        vertices[2] = { x = x + w, y = y, u = 1, v = 0, r = endColor.r, g = endColor.g, b = endColor.b, a = endColor.a }
        vertices[3] = { x = x + w, y = y + h, u = 1, v = 1, r = endColor.r, g = endColor.g, b = endColor.b, a = endColor.a }
        vertices[4] = { x = x, y = y + h, u = 0, v = 1, r = startColor.r, g = startColor.g, b = startColor.b, a = startColor.a }
    else
        vertices[1] = { x = x, y = y, u = 0, v = 0, r = startColor.r, g = startColor.g, b = startColor.b, a = startColor.a }
        vertices[2] = { x = x + w, y = y, u = 1, v = 0, r = startColor.r, g = startColor.g, b = startColor.b, a = startColor.a }
        vertices[3] = { x = x + w, y = y + h, u = 1, v = 1, r = endColor.r, g = endColor.g, b = endColor.b, a = endColor.a }
        vertices[4] = { x = x, y = y + h, u = 0, v = 1, r = endColor.r, g = endColor.g, b = endColor.b, a = endColor.a }
    end
    
    surface.DrawPoly(vertices)
end

-- Paint the panel
function PANEL:Paint(w, h)
    -- Update animation
    self:UpdateAnimation()
    
    -- Get the selected logo style
    local style = self.Config.LogoStyle
    local drawFunc = LogoDesigns[style] or LogoDesigns['standard']
    
    -- Apply animation transforms
    local centerX, centerY = w/2, h/2
    
    -- Handle different animation styles
    if self.Config.AnimationStyle == 'spin' then
        -- Save current drawing state
        local angle = self.AnimationState.RotationAngle
        
        -- Apply rotation transform
        surface.PushModelMatrix(Matrix():Translate(Vector(centerX, centerY, 0))
                             :Rotate(Angle(0, angle, 0))
                             :Translate(Vector(-centerX, -centerY, 0)))
        
        -- Draw the logo
        drawFunc(self, w, h, self.Config)
        
        -- Restore drawing state
        surface.PopModelMatrix()
    elseif self.Config.AnimationStyle == 'pulse' then
        -- Scale animation
        local scale = self.AnimationState.PulseValue
        
        -- Apply scale transform by adjusting the config size
        local configCopy = table.Copy(self.Config)
        configCopy.Size = configCopy.Size * scale
        
        -- Draw the logo with scaled size
        drawFunc(self, w, h, configCopy)
    elseif self.Config.AnimationStyle == 'glitch' then
        -- Glitch effect - occasionally shift parts of the logo
        if self.AnimationState.GlitchSlice then
            -- Draw main logo
            drawFunc(self, w, h, self.Config)
            
            -- Draw glitched parts
            local offsetX = self.AnimationState.GlitchOffsetX or 0
            local offsetY = self.AnimationState.GlitchOffsetY or 0
            
            -- Apply offset for part of the logo
            surface.PushModelMatrix(Matrix():Translate(Vector(offsetX, offsetY, 0)))
            
            -- Only draw part of the logo (using stencil buffer)
            render.SetStencilEnable(true)
            render.SetStencilWriteMask(255)
            render.SetStencilTestMask(255)
            render.SetStencilReferenceValue(1)
            render.SetStencilCompareFunction(STENCIL_ALWAYS)
            render.SetStencilPassOperation(STENCIL_REPLACE)
            render.SetStencilFailOperation(STENCIL_KEEP)
            render.SetStencilZFailOperation(STENCIL_KEEP)
            render.ClearStencil()
            
            -- Define the stencil region (middle third)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawRect(0, h/3, w, h/3)
            
            render.SetStencilCompareFunction(STENCIL_EQUAL)
            
            -- Draw the glitched portion
            local configCopy = table.Copy(self.Config)
            configCopy.PrimaryColor = self.Config.GlitchColor1 or self.Config.PrimaryColor
            drawFunc(self, w, h, configCopy)
            
            render.SetStencilEnable(false)
            surface.PopModelMatrix()
        else
            -- Just draw the normal logo
            drawFunc(self, w, h, self.Config)
        end
    else
        -- Default rendering for other animation styles
        drawFunc(self, w, h, self.Config)
    end
    
    return true
end

vgui.Register('AnimatedDDILogo', PANEL, 'Panel')
return PANEL