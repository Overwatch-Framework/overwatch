--[[
    Animations - Fade Effects
    Modern UI fade animations for Garry's Mod
    
    This module provides customizable fade in/out animations
    for panels, text, and other UI elements.
]]

local PANEL = {}

-- Default configuration
PANEL.FadeInTime = 0.5         -- Time in seconds for fade in
PANEL.FadeOutTime = 0.3        -- Time in seconds for fade out
PANEL.HoldTime = 1.0           -- Time to hold at full opacity
PANEL.StartDelay = 0.0         -- Delay before starting animation
PANEL.RepeatDelay = 0.0        -- Delay before repeating
PANEL.Color = Color(255, 255, 255, 255) -- Base color
PANEL.Text = ''                -- Text to display (if any)
PANEL.TextAlign = 'center'     -- Text alignment: 'left', 'center', 'right'
PANEL.TextOffset = {x=0, y=0}  -- Text position offset
PANEL.Font = 'DermaLarge'      -- Font to use for text
PANEL.AutoPlay = true          -- Start playing automatically
PANEL.Loop = false             -- Whether to loop the animation
PANEL.FadeStyle = 'smooth'     -- Fade style: 'smooth', 'linear', 'bounce'
PANEL.Direction = 'horizontal' -- Direction: 'horizontal', 'vertical', 'both'
PANEL.DrawPanel = true         -- Whether to draw the panel itself

-- Initialize the panel
function PANEL:Init()
    self.Time = 0
    self.State = 'hidden'  -- States: 'hidden', 'fadein', 'visible', 'fadeout'
    self.Alpha = 0
    self.TargetAlpha = 0
    self.ProcessingTime = 0
    self.DrawOffset = {x=0, y=0}
    
    -- Set default size
    self:SetSize(200, 100)
    
    -- Start the animation if AutoPlay is enabled
    if self.AutoPlay then
        self:Play()
    end
end

-- Play the animation
function PANEL:Play()
    self.Time = 0
    self.ProcessingTime = 0
    self.State = 'delay'
    return self
end

-- Set the text
function PANEL:SetText(text)
    self.Text = text or ''
    return self
end

-- Think is called every frame
function PANEL:Think()
    local dt = FrameTime()
    self.Time = self.Time + dt
    
    -- Process animation state
    if self.State == 'delay' then
        if self.Time >= self.StartDelay then
            self.State = 'fadein'
            self.ProcessingTime = 0
        end
        
    elseif self.State == 'fadein' then
        self.ProcessingTime = self.ProcessingTime + dt
        local progress = math.Clamp(self.ProcessingTime / self.FadeInTime, 0, 1)
        
        -- Apply easing based on style
        if self.FadeStyle == 'smooth' then
            progress = self:SmoothEasing(progress)
        elseif self.FadeStyle == 'bounce' then
            progress = self:BounceEasing(progress)
        end
        
        self.Alpha = progress
        
        -- Apply directional offset
        self:CalculateOffset(progress)
        
        if self.ProcessingTime >= self.FadeInTime then
            self.State = 'visible'
            self.ProcessingTime = 0
        end
        
    elseif self.State == 'visible' then
        self.Alpha = 1
        self.DrawOffset = {x=0, y=0}
        
        if self.ProcessingTime >= self.HoldTime then
            self.State = 'fadeout'
            self.ProcessingTime = 0
        else
            self.ProcessingTime = self.ProcessingTime + dt
        end
        
    elseif self.State == 'fadeout' then
        self.ProcessingTime = self.ProcessingTime + dt
        local progress = 1 - math.Clamp(self.ProcessingTime / self.FadeOutTime, 0, 1)
        
        -- Apply easing based on style
        if self.FadeStyle == 'smooth' then
            progress = self:SmoothEasing(progress)
        elseif self.FadeStyle == 'bounce' then
            progress = self:BounceEasing(progress)
        end
        
        self.Alpha = progress
        
        -- Apply directional offset
        self:CalculateOffset(progress)
        
        if self.ProcessingTime >= self.FadeOutTime then
            if self.Loop then
                self.State = 'repeat_delay'
                self.ProcessingTime = 0
            else
                self.State = 'hidden'
            end
        end
        
    elseif self.State == 'repeat_delay' then
        if self.ProcessingTime >= self.RepeatDelay then
            self.State = 'fadein'
            self.ProcessingTime = 0
        else
            self.ProcessingTime = self.ProcessingTime + dt
        end
        
    elseif self.State == 'hidden' then
        self.Alpha = 0
    end
end

-- Calculate offset based on direction and progress
function PANEL:CalculateOffset(progress)
    local w, h = self:GetSize()
    local offset = {x=0, y=0}
    
    if self.Direction == 'horizontal' then
        offset.x = (1 - progress) * w * 0.2
    elseif self.Direction == 'vertical' then
        offset.y = (1 - progress) * h * 0.2
    elseif self.Direction == 'both' then
        offset.x = (1 - progress) * w * 0.1
        offset.y = (1 - progress) * h * 0.1
    end
    
    self.DrawOffset = offset
end

-- Smooth easing function (cubic)
function PANEL:SmoothEasing(t)
    return t * t * (3 - 2 * t)
end

-- Bounce easing function
function PANEL:BounceEasing(t)
    if t < 0.5 then
        return 4 * t * t * t
    else
        return (t - 1) * (2 * t - 2) * (2 * t - 2) + 1
    end
end

-- Draw the panel
function PANEL:Paint(w, h)
    local alpha = self.Alpha * self.Color.a
    
    if alpha < 1 or self.State == 'hidden' then return end
    
    if self.DrawPanel then
        -- Draw panel background
        surface.SetDrawColor(
            self.Color.r, 
            self.Color.g, 
            self.Color.b, 
            alpha
        )
        surface.DrawRect(self.DrawOffset.x, self.DrawOffset.y, w - self.DrawOffset.x, h - self.DrawOffset.y)
    end
    
    -- Draw text if provided
    if self.Text and self.Text ~= '' then
        local textX = self.TextOffset.x
        local textY = self.TextOffset.y
        local textColor = Color(255, 255, 255, alpha)
        
        -- Set text position based on alignment
        if self.TextAlign == 'center' then
            textX = w / 2 + self.DrawOffset.x / 2
            textY = h / 2 + self.DrawOffset.y / 2
        elseif self.TextAlign == 'right' then
            textX = w - 10 + self.DrawOffset.x
            textY = h / 2 + self.DrawOffset.y / 2
        elseif self.TextAlign == 'left' then
            textX = 10 + self.DrawOffset.x
            textY = h / 2 + self.DrawOffset.y / 2
        end
        
        -- Determine text alignment mode
        local alignX = TEXT_ALIGN_LEFT
        if self.TextAlign == 'center' then
            alignX = TEXT_ALIGN_CENTER
        elseif self.TextAlign == 'right' then
            alignX = TEXT_ALIGN_RIGHT
        end
        
        draw.SimpleText(
            self.Text,
            self.Font,
            textX,
            textY,
            textColor,
            alignX,
            TEXT_ALIGN_CENTER
        )
    end
end

-- Configure the animation settings
function PANEL:Configure(config)
    config = config or {}
    
    if config.FadeInTime then self.FadeInTime = config.FadeInTime end
    if config.FadeOutTime then self.FadeOutTime = config.FadeOutTime end
    if config.HoldTime then self.HoldTime = config.HoldTime end
    if config.StartDelay then self.StartDelay = config.StartDelay end
    if config.RepeatDelay then self.RepeatDelay = config.RepeatDelay end
    if config.Color then self.Color = config.Color end
    if config.Text then self:SetText(config.Text) end
    if config.TextAlign then self.TextAlign = config.TextAlign end
    if config.TextOffset then self.TextOffset = config.TextOffset end
    if config.Font then self.Font = config.Font end
    if config.AutoPlay ~= nil then self.AutoPlay = config.AutoPlay end
    if config.Loop ~= nil then self.Loop = config.Loop end
    if config.FadeStyle then self.FadeStyle = config.FadeStyle end
    if config.Direction then self.Direction = config.Direction end
    if config.DrawPanel ~= nil then self.DrawPanel = config.DrawPanel end
    
    -- Start animation if AutoPlay is true
    if self.AutoPlay then
        self:Play()
    end
    
    return self
end

vgui.Register('AnimatedFade', PANEL, 'DPanel')

-- Return the panel so it can be used elsewhere
return PANEL
