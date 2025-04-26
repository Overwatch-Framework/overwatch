--[[
    Universal Logo Animation for Garry's Mod
    
    A collection of animated logo styles with customizable text and properties.
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
    Tagline = 'Custom Logo Animation', -- Tagline text
    GlowAmount = 0.5,           -- Glow amount
    CustomText = 'LOGO'         -- Custom logo text
}

-- Logo designs - variations
local LogoDesigns = {
    standard = function(self, w, h, config)
        local centerX, centerY = w/2, h/2
        local size = config.Size
        local text = config.CustomText or 'LOGO'
        
        -- Main circle
        local radius = size / 2
        
        -- Background if needed
        if config.BackgroundStyle == 'circle' then
            surface.SetDrawColor(30, 30, 30, 200)
            surface.SafeDrawCircle(centerX, centerY, radius, 32)
        elseif config.BackgroundStyle == 'square' then
            draw.RoundedBox(5, centerX - radius, centerY - radius, radius*2, radius*2, Color(30, 30, 30, 200))
        elseif config.BackgroundStyle == 'hex' then
            self:DrawHexagon(centerX, centerY, radius, Color(30, 30, 30, 200))
        end
        
        -- Draw text logo
        surface.SetFont('DermaLarge')
        local textW, textH = surface.GetTextSize(text)
        
        -- Draw main text
        surface.SetTextColor(config.PrimaryColor)
        surface.SetTextPos(centerX - textW/2, centerY - textH/2)
        surface.DrawText(text)
        
        -- Draw tagline if enabled
        if config.TextTagline then
            surface.SetFont('DermaDefault')
            local tagW, tagH = surface.GetTextSize(config.Tagline)
            surface.SetTextColor(config.SecondaryColor)
            surface.SetTextPos(centerX - tagW/2, centerY + textH/2 + 5)
            surface.DrawText(config.Tagline)
        end
        
        -- Draw border if enabled
        if config.BorderStyle == 'simple' then
            if config.BackgroundStyle == 'circle' then
                surface.SetDrawColor(config.AccentColor)
                surface.SafeDrawCircle(centerX, centerY, radius, 32)
            elseif config.BackgroundStyle == 'square' then
                surface.SetDrawColor(config.AccentColor)
                surface.DrawOutlinedRect(centerX - radius, centerY - radius, radius*2, radius*2, 2)
            elseif config.BackgroundStyle == 'hex' then
                self:DrawHexagonOutline(centerX, centerY, radius, config.AccentColor)
            else
                local boxSize = math.max(textW, textH) + 20
                surface.SetDrawColor(config.AccentColor)
                surface.DrawOutlinedRect(centerX - boxSize/2, centerY - boxSize/2, boxSize, boxSize, 2)
            end
        elseif config.BorderStyle == 'double' then
            if config.BackgroundStyle == 'circle' then
                surface.SetDrawColor(config.AccentColor)
                surface.SafeDrawCircle(centerX, centerY, radius, 32)
                surface.SafeDrawCircle(centerX, centerY, radius - 3, 32)
            elseif config.BackgroundStyle == 'square' then
                surface.SetDrawColor(config.AccentColor)
                surface.DrawOutlinedRect(centerX - radius, centerY - radius, radius*2, radius*2, 2)
                surface.DrawOutlinedRect(centerX - radius + 3, centerY - radius + 3, radius*2 - 6, radius*2 - 6, 2)
            else
                local boxSize = math.max(textW, textH) + 20
                surface.SetDrawColor(config.AccentColor)
                surface.DrawOutlinedRect(centerX - boxSize/2, centerY - boxSize/2, boxSize, boxSize, 2)
                surface.DrawOutlinedRect(centerX - boxSize/2 + 3, centerY - boxSize/2 + 3, boxSize - 6, boxSize - 6, 2)
            end
        elseif config.BorderStyle == 'glow' then
            local glowCol = Color(config.AccentColor.r, config.AccentColor.g, config.AccentColor.b, config.AccentColor.a * 0.7)
            self:DrawGlow(centerX, centerY, size/2 + 5, glowCol, 10 * config.GlowAmount)
        end
    end,
    
    minimal = function(self, w, h, config)
        local centerX, centerY = w/2, h/2
        local size = config.Size * 0.8
        local text = config.CustomText or 'LOGO'
        
        -- Calculate text dimensions
        surface.SetFont('DermaLarge')
        local textW, textH = surface.GetTextSize(text)
        
        -- Draw minimal text outline
        for i=1, #text do
            local char = text:sub(i, i)
            local charWidth = surface.GetTextSize(char)
            local xPos = centerX - textW/2 + surface.GetTextSize(text:sub(1, i-1)) + charWidth/2
            
            surface.SetTextColor(config.PrimaryColor)
            surface.SetTextPos(xPos - charWidth/2, centerY - textH/2)
            surface.DrawText(char)
            
            -- Draw letter outline
            local charBox = {
                x = xPos - charWidth/2 - 1,
                y = centerY - textH/2 - 1,
                w = charWidth + 2,
                h = textH + 2
            }
            
            surface.SetDrawColor(config.SecondaryColor)
            surface.DrawOutlinedRect(charBox.x, charBox.y, charBox.w, charBox.h, 1)
        end
        
        -- Draw tagline if enabled
        if config.TextTagline then
            surface.SetFont('DermaDefault')
            local tagW = surface.GetTextSize(config.Tagline)
            surface.SetTextColor(config.AccentColor)
            surface.SetTextPos(centerX - tagW/2, centerY + textH/2 + 10)
            surface.DrawText(config.Tagline)
        end
    end,
    
    tech = function(self, w, h, config)
        local centerX, centerY = w/2, h/2
        local size = config.Size
        local text = config.CustomText or 'LOGO'
        
        -- Draw hexagon background
        local hexRadius = size/2
        self:DrawHexagon(centerX, centerY, hexRadius, Color(30, 30, 30, 200))
        
        -- Draw outer hexagon border
        surface.SetDrawColor(config.PrimaryColor)
        self:DrawHexagonOutline(centerX, centerY, hexRadius, config.PrimaryColor)
        
        -- Draw inner circuit pattern
        self:DrawCircuitPattern(centerX, centerY, hexRadius * 0.8, config.SecondaryColor)
        
        -- Draw logo text in tech style
        surface.SetFont('DermaDefault')
        local textW, textH = surface.GetTextSize(text)
        
        -- Text with tech styling
        local letterSpacing = 2
        for i=1, #text do
            local char = text:sub(i, i)
            local singleWidth = surface.GetTextSize(char)
            local xPos = centerX - textW/2 - letterSpacing * (#text-1)/2 + (i-1) * (singleWidth + letterSpacing)
            
            -- Add tech details around each letter
            local boxSize = singleWidth + 4
            surface.SetDrawColor(config.AccentColor)
            surface.DrawOutlinedRect(xPos - 2, centerY - textH/2 - 2, boxSize, textH + 4, 1)
            
            -- Draw small connector lines
            surface.DrawLine(xPos + boxSize/2, centerY - textH/2 - 5, xPos + boxSize/2, centerY - textH/2 - 2)
            surface.DrawLine(xPos + boxSize/2, centerY + textH/2 + 2, xPos + boxSize/2, centerY + textH/2 + 5)
            
            -- Draw the letter
            surface.SetTextColor(config.PrimaryColor)
            surface.SetTextPos(xPos, centerY - textH/2)
            surface.DrawText(char)
        end
    end,
    
    glow = function(self, w, h, config)
        local centerX, centerY = w/2, h/2
        local size = config.Size
        local text = config.CustomText or 'LOGO'
        
        -- Get current time-based offset for glow effect
        local time = CurTime() * config.AnimationSpeed
        local glowIntensity = 0.5 + math.sin(time * 2) * 0.5
        
        -- Draw base shape
        if config.BackgroundStyle ~= 'none' then
            draw.RoundedBox(5, centerX - size/2, centerY - size/2, size, size, Color(20, 20, 20, 200))
        end
        
        -- Draw text with glow effect
        surface.SetFont('DermaLarge')
        local textW, textH = surface.GetTextSize(text)
        
        -- Draw glow
        local glowColor = Color(
            config.PrimaryColor.r, 
            config.PrimaryColor.g, 
            config.PrimaryColor.b, 
            math.floor(150 * glowIntensity)
        )
        
        local glowSize = config.GlowAmount * 15 * glowIntensity
        self:DrawTextGlow(centerX - textW/2, centerY - textH/2, text, glowColor, glowSize)
        
        -- Draw main text
        surface.SetTextColor(config.SecondaryColor)
        surface.SetTextPos(centerX - textW/2, centerY - textH/2)
        surface.DrawText(text)
    end,
    
    neon = function(self, w, h, config)
        local centerX, centerY = w/2, h/2
        local size = config.Size
        local text = config.CustomText or 'LOGO'
        
        -- Pulsing effect for neon
        local time = CurTime() * config.AnimationSpeed
        local pulse = 0.7 + math.sin(time * 2) * 0.3
        
        -- Background
        if config.BackgroundStyle ~= 'none' then
            draw.RoundedBox(10, centerX - size/2, centerY - size/2, size, size, Color(20, 20, 20, 200))
        end
        
        -- Calculate text dimensions
        surface.SetFont('DermaLarge')
        local textW, textH = surface.GetTextSize(text)
        
        -- Draw each letter with neon glow
        for i=1, #text do
            local char = text:sub(i, i)
            local charWidth = surface.GetTextSize(char)
            local xPos = centerX - textW/2 + surface.GetTextSize(text:sub(1, i-1))
            
            -- Alternate colors for each letter
            local letterColor
            if i % 3 == 0 then
                letterColor = config.AccentColor
            elseif i % 2 == 0 then
                letterColor = config.SecondaryColor
            else
                letterColor = config.PrimaryColor
            end
            
            -- Draw the neon letter with glow
            self:DrawNeonLetter(xPos, centerY, charWidth, textH, char, letterColor, config.GlowAmount * pulse)
        end
        
        -- Draw tagline if enabled
        if config.TextTagline then
            surface.SetFont('DermaDefault')
            local tagW = surface.GetTextSize(config.Tagline)
            surface.SetTextColor(config.SecondaryColor)
            surface.SetTextPos(centerX - tagW/2, centerY + textH/2 + 10)
            surface.DrawText(config.Tagline)
        end
    end,
    
    retro = function(self, w, h, config)
        local centerX, centerY = w/2, h/2
        local size = config.Size
        local text = config.CustomText or 'LOGO'
        
        -- Draw pixelated retro background
        local pixelSize = 4
        local bgSize = size
        local startX = centerX - bgSize/2
        local startY = centerY - bgSize/2
        
        if config.BackgroundStyle ~= 'none' then
            for x=0, bgSize, pixelSize do
                for y=0, bgSize, pixelSize do
                    local colorBrightness = math.random(20, 40)
                    surface.SetDrawColor(colorBrightness, colorBrightness, colorBrightness + 10, 200)
                    surface.DrawRect(startX + x, startY + y, pixelSize, pixelSize)
                end
            end
        end
        
        -- Calculate text dimensions
        surface.SetFont('DermaLarge')
        local textW, textH = surface.GetTextSize(text)
        
        -- Draw pixelated text
        for i=1, #text do
            local char = text:sub(i, i)
            local charWidth = surface.GetTextSize(char)
            local xPos = centerX - textW/2 + surface.GetTextSize(text:sub(1, i-1))
            
            -- Alternate colors for each letter
            local letterColor
            if i % 3 == 0 then
                letterColor = config.AccentColor
            elseif i % 2 == 0 then
                letterColor = config.SecondaryColor
            else
                letterColor = config.PrimaryColor
            end
            
            self:DrawPixelatedLetter(xPos, centerY - textH/2, charWidth, textH, char, letterColor, pixelSize)
        end
        
        -- Draw retro frame
        if config.BorderStyle ~= 'none' then
            surface.SetDrawColor(config.PrimaryColor)
            surface.DrawOutlinedRect(startX, startY, bgSize, bgSize, 2)
        end
    end
}

-- Helper function - Draw text with glow
function PANEL:DrawTextGlow(x, y, text, color, glowSize)
    for i=1, 5 do
        local alpha = color.a * (1 - i/5)
        local glowColor = Color(color.r, color.g, color.b, alpha)
        
        -- Draw glow in different positions
        for ox=-1, 1 do
            for oy=-1, 1 do
                if ox ~= 0 or oy ~= 0 then
                    surface.SetTextColor(glowColor)
                    surface.SetTextPos(x + ox * i, y + oy * i)
                    surface.DrawText(text)
                end
            end
        end
    end
end

-- Helper function - Draw hexagon
function PANEL:DrawHexagon(x, y, radius, color)
    local vertices = {}
    for i=0, 5 do
        local angle = math.rad(i * 60)
        table.insert(vertices, {x = x + math.sin(angle) * radius, y = y - math.cos(angle) * radius})
    end
    
    surface.SetDrawColor(color)
    draw.NoTexture()
    surface.DrawPoly(vertices)
end

-- Helper function - Draw hexagon outline
function PANEL:DrawHexagonOutline(x, y, radius, color)
    local vertices = {}
    for i=0, 6 do
        local angle = math.rad(i * 60)
        table.insert(vertices, {x = x + math.sin(angle) * radius, y = y - math.cos(angle) * radius})
    end
    
    surface.SetDrawColor(color)
    for i=1, 6 do
        local j = i % 6 + 1
        surface.DrawLine(vertices[i].x, vertices[i].y, vertices[j].x, vertices[j].y)
    end
end

-- Helper function - Draw circuit pattern
function PANEL:DrawCircuitPattern(x, y, radius, color)
    local linesCount = math.random(5, 10)
    
    surface.SetDrawColor(color.r, color.g, color.b, color.a * 0.6)
    
    for i=1, linesCount do
        local angle1 = math.rad(math.random(0, 359))
        local angle2 = math.rad(math.random(0, 359))
        
        local x1 = x + math.sin(angle1) * radius * math.random(5, 10) / 10
        local y1 = y - math.cos(angle1) * radius * math.random(5, 10) / 10
        local x2 = x + math.sin(angle2) * radius * math.random(5, 10) / 10
        local y2 = y - math.cos(angle2) * radius * math.random(5, 10) / 10
        
        surface.DrawLine(x1, y1, x2, y2)
        
        -- Draw junction points
        surface.DrawRect(x1 - 1, y1 - 1, 3, 3)
        surface.DrawRect(x2 - 1, y2 - 1, 3, 3)
    end
    
    -- Draw central node
    surface.DrawRect(x - 3, y - 3, 6, 6)
end

-- Helper function - Draw glow effect
function PANEL:DrawGlow(x, y, radius, color, intensity)
    for i=1, 5 do
        local r = radius - i * (intensity / 5)
        local alpha = color.a * (1 - i/5)
        local glowColor = Color(color.r, color.g, color.b, alpha)
        
        surface.SetDrawColor(glowColor)
        surface.SafeDrawCircle(x, y, r, 32)
    end
end

-- Helper function - Draw a neon letter
function PANEL:DrawNeonLetter(x, y, w, h, letter, color, glowIntensity)
    -- Draw glow
    local glowColor = Color(color.r, color.g, color.b, math.floor(100 * glowIntensity))
    
    -- Draw the text with glow
    surface.SetFont('DermaDefault')
    local textW, textH = surface.GetTextSize(letter)
    
    -- Draw glow layers
    for i=1, 5 do
        local glowAlpha = glowColor.a * (1 - i/5)
        local layerColor = Color(glowColor.r, glowColor.g, glowColor.b, glowAlpha)
        
        surface.SetTextColor(layerColor)
        for offsetX = -i, i do
            for offsetY = -i, i do
                if math.abs(offsetX) + math.abs(offsetY) <= i then
                    surface.SetTextPos(x + offsetX, y - textH/2 + offsetY)
                    surface.DrawText(letter)
                end
            end
        end
    end
    
    -- Draw the actual letter
    surface.SetTextColor(color)
    surface.SetTextPos(x, y - textH/2)
    surface.DrawText(letter)
    
    -- Draw a light line under the letter
    surface.SetDrawColor(color.r, color.g, color.b, color.a * 0.8)
    surface.DrawRect(x, y + textH/2 + 1, textW, 1)
}

-- Helper function - Draw a pixelated letter
function PANEL:DrawPixelatedLetter(x, y, w, h, letter, color, pixelSize)
    -- Draw the text to a smaller area first
    surface.SetFont('DermaDefault')
    local textW, textH = surface.GetTextSize(letter)
    
    -- Create a grid of 'pixels'
    local gridW = math.ceil(w / pixelSize)
    local gridH = math.ceil(h / pixelSize)
    
    -- Draw the letter in a pixelated style
    surface.SetTextColor(color)
    surface.SetTextPos(x, y)
    surface.DrawText(letter)
    
    -- Add pixelation effect by drawing squares
    for px=0, gridW-1 do
        for py=0, gridH-1 do
            local checkX = x + px * pixelSize + pixelSize/2
            local checkY = y + py * pixelSize + pixelSize/2
            
            -- Check if this pixel should be drawn (inside the letter)
            if checkX >= x and checkX <= x + textW and 
               checkY >= y and checkY <= y + textH then
                surface.SetDrawColor(color)
                surface.DrawRect(x + px * pixelSize, y + py * pixelSize, pixelSize - 1, pixelSize - 1)
            end
        end
    end
}

-- Animation styles
local AnimationStyles = {
    none = function(self, w, h, config, time) 
        -- No animation, just draw the logo
        local logoDesign = LogoDesigns[config.LogoStyle] or LogoDesigns.standard
        logoDesign(self, w, h, config)
    end,
    
    pulse = function(self, w, h, config, time)
        -- Pulse animation
        local pulse = math.sin(time * 2) * 0.1
        local scale = 1 + pulse
        
        -- Scale the context
        local centerX, centerY = w/2, h/2
        surface.SetDrawColor(255, 255, 255)
        
        -- Draw with scaling
        self:ScaledDraw(centerX, centerY, scale, function()
            local logoDesign = LogoDesigns[config.LogoStyle] or LogoDesigns.standard
            logoDesign(self, w, h, config)
        end)
    end,
    
    rotate = function(self, w, h, config, time)
        -- Rotation animation
        local rotation = time * 30 % 360
        
        -- Rotate the context
        local centerX, centerY = w/2, h/2
        surface.SetDrawColor(255, 255, 255)
        
        -- Draw with rotation
        self:RotatedDraw(centerX, centerY, rotation, function()
            local logoDesign = LogoDesigns[config.LogoStyle] or LogoDesigns.standard
            logoDesign(self, w, h, config)
        end)
    end,
    
    wave = function(self, w, h, config, time)
        -- Wave animation (similar to a flag waving)
        local logoDesign = LogoDesigns[config.LogoStyle] or LogoDesigns.standard
        
        -- Draw with wave distortion
        local waveFreq = 3
        local waveAmp = 3
        local wavePhase = time * 5
        
        -- Draw the distorted logo
        -- We'll simulate wave by changing y-coordinates based on x position
        local centerX, centerY = w/2, h/2
        local modConfig = table.Copy(config)
        
        -- Apply wave effect based on style
        -- For text-based logos, we need to handle this differently
        if config.LogoStyle == 'standard' or config.LogoStyle == 'minimal' then
            logoDesign(self, w, h, config)
        else
            -- Use wave displacement
            local text = config.CustomText or 'LOGO'
            surface.SetFont('DermaLarge')
            local textW, textH = surface.GetTextSize(text)
            
            -- Draw each letter with wave offset
            for i=1, #text do
                local char = text:sub(i, i)
                local charWidth = surface.GetTextSize(char)
                local xPos = centerX - textW/2 + surface.GetTextSize(text:sub(1, i-1))
                
                -- Calculate wave offset based on character position
                local waveOffset = math.sin(wavePhase + (i / #text) * waveFreq) * waveAmp
                
                -- Draw the character with offset
                surface.SetTextColor(config.PrimaryColor)
                surface.SetTextPos(xPos, centerY - textH/2 + waveOffset)
                surface.DrawText(char)
            end
            
            -- Draw tagline if enabled
            if config.TextTagline then
                surface.SetFont('DermaDefault')
                local tagW = surface.GetTextSize(config.Tagline)
                surface.SetTextColor(config.SecondaryColor)
                surface.SetTextPos(centerX - tagW/2, centerY + textH/2 + 10)
                surface.DrawText(config.Tagline)
            end
        end
    end,
    
    flicker = function(self, w, h, config, time)
        -- Flicker animation (like a neon sign)
        local logoDesign = LogoDesigns[config.LogoStyle] or LogoDesigns.standard
        
        -- Create a flickering effect
        local flicker = math.random() > 0.05 and 1 or 0.7
        
        -- Modify colors for flicker
        local flickerConfig = table.Copy(config)
        flickerConfig.PrimaryColor = Color(
            config.PrimaryColor.r, 
            config.PrimaryColor.g, 
            config.PrimaryColor.b, 
            config.PrimaryColor.a * flicker
        )
        flickerConfig.SecondaryColor = Color(
            config.SecondaryColor.r, 
            config.SecondaryColor.g, 
            config.SecondaryColor.b, 
            config.SecondaryColor.a * flicker
        )
        flickerConfig.AccentColor = Color(
            config.AccentColor.r, 
            config.AccentColor.g, 
            config.AccentColor.b, 
            config.AccentColor.a * flicker
        )
        
        -- Draw with flickering
        logoDesign(self, w, h, flickerConfig)
    end,
    
    morph = function(self, w, h, config, time)
        -- Morphing animation between different shapes
        local morphPhase = (math.sin(time) + 1) / 2 -- 0 to 1
        
        -- Draw the morphing logo
        local text = config.CustomText or 'LOGO'
        surface.SetFont('DermaLarge')
        local textW, textH = surface.GetTextSize(text)
        
        -- Draw text with morphing effect
        local centerX, centerY = w/2, h/2
        
        -- Create distortion effect
        for i=1, #text do
            local char = text:sub(i, i)
            local charWidth = surface.GetTextSize(char)
            local xPos = centerX - textW/2 + surface.GetTextSize(text:sub(1, i-1))
            
            -- Calculate morph offset based on character position and time
            local xOffset = math.sin(time * 3 + i) * 2 * morphPhase
            local yOffset = math.cos(time * 2 + i) * 3 * morphPhase
            
            -- Draw character with morphing
            surface.SetTextColor(config.PrimaryColor)
            surface.SetTextPos(xPos + xOffset, centerY - textH/2 + yOffset)
            surface.DrawText(char)
        end
    end
}

-- Helper for scaled drawing
function PANEL:ScaledDraw(x, y, scale, drawFunc)
    local oldMatrix = Matrix()
    oldMatrix:Translate(Vector(x, y, 0))
    oldMatrix:Scale(Vector(scale, scale, scale))
    oldMatrix:Translate(Vector(-x, -y, 0))
    
    cam.PushModelMatrix(oldMatrix)
        drawFunc()
    cam.PopModelMatrix()
end

-- Helper for rotated drawing
function PANEL:RotatedDraw(x, y, angle, drawFunc)
    local oldMatrix = Matrix()
    oldMatrix:Translate(Vector(x, y, 0))
    oldMatrix:Rotate(Angle(0, angle, 0))
    oldMatrix:Translate(Vector(-x, -y, 0))
    
    cam.PushModelMatrix(oldMatrix)
        drawFunc()
    cam.PopModelMatrix()
end

function PANEL:Init()
    self.Config = table.Copy(DefaultConfig)
    self.Time = 0
end

function PANEL:Configure(config)
    table.Merge(self.Config, config or {})
end

function PANEL:Think()
    self.Time = CurTime()
end

function PANEL:Paint(w, h)
    local config = self.Config
    local time = self.Time * config.AnimationSpeed
    
    -- Use the selected animation style
    local animStyle = AnimationStyles[config.AnimationStyle] or AnimationStyles.none
    animStyle(self, w, h, config, time)
    
    return true
end

vgui.Register('AnimatedUniversalLogo', PANEL, 'Panel')