--[[
    Neon Animation for Garry's Mod
    
    A neon text effect with customizable properties.
    Part of the DDI Modern UI Animations package.
]]

local PANEL = {}

-- Default configuration
local DefaultConfig = {
    Text = 'DDI NEON',               -- Text to display
    PrimaryColor = Color(255, 0, 128, 255),   -- Primary color (pink)
    SecondaryColor = Color(0, 255, 255, 255), -- Secondary color (cyan)
    Font = 'DermaLarge',             -- Font to use
    GlowSize = 8,                    -- Size of the glow effect
    GlowIntensity = 1,               -- Intensity of the glow
    FlickerAmount = 0.1,             -- Amount of flickering (0-1)
    PulseSpeed = 0.5,                -- Speed of pulsing effect
    ColorCycle = false,              -- Whether to cycle through colors
    CycleSpeed = 1,                  -- Speed of color cycling
    BackgroundDim = 0.7,             -- Darkness of background (0-1)
    DDISignature = false             -- Whether to show DDI signature
}

-- Initialize the panel
function PANEL:Init()
    self.Config = table.Copy(DefaultConfig)
    self.LastTime = CurTime()
    self.AnimationTime = 0
    self.FlickerValue = 1
    self.LastFlickerUpdate = 0
    
    -- Prepare bloom effect
    self.BloomMaterial = Material('pp/bloom')
    
    -- Default settings
    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(false)
end

-- Apply configuration options
function PANEL:Configure(config)
    table.Merge(self.Config, config or {})
    
    -- Create a font for the neon text
    local fontName = 'NeonFont' .. self:GetModelName()
    surface.CreateFont(fontName, {
        font = 'Arial',
        size = 40,
        weight = 800,
        antialias = true,
        shadow = false,
        extended = true,
    })
    
    self.FontName = fontName
end

-- Update the animation
function PANEL:Think()
    local currentTime = CurTime()
    local deltaTime = currentTime - self.LastTime
    self.LastTime = currentTime
    
    -- Update animation time
    self.AnimationTime = self.AnimationTime + deltaTime * self.Config.PulseSpeed
    
    -- Update flicker effect
    if currentTime - self.LastFlickerUpdate > 0.05 then
        self.LastFlickerUpdate = currentTime
        
        -- Random flicker based on FlickerAmount
        if math.random() < self.Config.FlickerAmount then
            self.FlickerValue = math.Rand(0.7, 1.0)
        else
            self.FlickerValue = 1
        end
    end
end

-- Calculate current color based on animation
function PANEL:GetCurrentColor()
    local primary = self.Config.PrimaryColor
    local secondary = self.Config.SecondaryColor
    
    -- If color cycling is enabled, interpolate between colors
    if self.Config.ColorCycle then
        local cycleFactor = (math.sin(self.AnimationTime * self.Config.CycleSpeed) + 1) / 2
        
        return Color(
            Lerp(cycleFactor, primary.r, secondary.r),
            Lerp(cycleFactor, primary.g, secondary.g),
            Lerp(cycleFactor, primary.b, secondary.b),
            255
        )
    else
        return primary
    end
end

-- Draw neon text with glow
function PANEL:DrawNeonText(text, x, y, font, color, glowSize, glowIntensity, alpha)
    -- Set up the font
    surface.SetFont(font or self.FontName or self.Config.Font)
    local textWidth, textHeight = surface.GetTextSize(text)
    
    -- Calculate pulse effect
    local pulse = (math.sin(self.AnimationTime * 2) * 0.15 + 0.85) * self.FlickerValue
    local glowSizeMod = glowSize * pulse
    
    -- Draw outer glow (color)
    for i = glowSizeMod, 1, -1 do
        local glowAlpha = (i / glowSizeMod) * 100 * glowIntensity * alpha
        surface.SetTextColor(color.r, color.g, color.b, glowAlpha)
        
        for offsetX = -i, i do
            for offsetY = -i, i do
                -- Skip center positions for better performance
                if math.abs(offsetX) + math.abs(offsetY) > 0 then
                    surface.SetTextPos(x + offsetX, y + offsetY)
                    surface.DrawText(text)
                end
            end
        end
    end
    
    -- Draw inner glow (white)
    local innerGlowSize = math.max(1, glowSizeMod * 0.3)
    for i = innerGlowSize, 1, -1 do
        local glowAlpha = (i / innerGlowSize) * 180 * alpha
        surface.SetTextColor(255, 255, 255, glowAlpha)
        
        for offsetX = -i, i do
            for offsetY = -i, i do
                if math.abs(offsetX) + math.abs(offsetY) > 0 then
                    surface.SetTextPos(x + offsetX, y + offsetY)
                    surface.DrawText(text)
                end
            end
        end
    end
    
    -- Draw the main text
    surface.SetTextColor(255, 255, 255, 255 * alpha)
    surface.SetTextPos(x, y)
    surface.DrawText(text)
    
    return textWidth, textHeight
end

-- Draw a DDI signature (small DDI logo)
function PANEL:DrawDDISignature(x, y, size, color)
    -- Draw a simplified DDI logo
    local radius = size / 2
    
    -- Draw circle
    surface.SetDrawColor(color.r, color.g, color.b, 150)
    surface.SafeDrawCircle(x, y, radius, 16)
    
    -- Draw D letters
    local letterSize = radius * 0.6
    local letterOffset = radius * 0.3
    
    -- First D
    self:DrawNeonLetter(x - letterOffset, y, 'D', letterSize, color, 2, 0.5)
    
    -- Second D
    self:DrawNeonLetter(x, y, 'D', letterSize, color, 2, 0.5)
    
    -- I
    self:DrawNeonLetter(x + letterOffset, y, 'I', letterSize, color, 2, 0.5)
end

-- Draw a neon letter
function PANEL:DrawNeonLetter(x, y, letter, size, color, glowSize, glowIntensity)
    surface.SetFont('DermaDefault')
    local tw, th = surface.GetTextSize(letter)
    
    self:DrawNeonText(letter, x - tw/2, y - th/2, 'DermaDefault', color, glowSize, glowIntensity, 1)
end

-- Paint the panel
function PANEL:Paint(w, h)
    -- Get current neon color
    local color = self:GetCurrentColor()
    local pulse = (math.sin(self.AnimationTime * 2) * 0.15 + 0.85) * self.FlickerValue
    
    -- Draw dimmed background
    if self.Config.BackgroundDim > 0 then
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 255 * self.Config.BackgroundDim))
    end
    
    -- Measure text
    surface.SetFont(self.FontName or self.Config.Font)
    local textWidth, textHeight = surface.GetTextSize(self.Config.Text)
    
    -- Center position
    local x = (w - textWidth) / 2
    local y = (h - textHeight) / 2
    
    -- Draw the neon text
    local width, height = self:DrawNeonText(
        self.Config.Text, 
        x, 
        y, 
        self.FontName or self.Config.Font, 
        color, 
        self.Config.GlowSize, 
        self.Config.GlowIntensity * pulse,
        1
    )
    
    -- Draw DDI signature if enabled
    if self.Config.DDISignature then
        local sigSize = 16
        local sigColor = Color(0, 150, 255)
        self:DrawDDISignature(w - sigSize - 5, h - sigSize - 5, sigSize, sigColor)
    end
    
    return true
end

vgui.Register('AnimatedNeon', PANEL, 'Panel')
return PANEL