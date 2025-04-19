--[[
    Animations - Progress Bar
    Modern UI progress bar animations for Garry's Mod
    
    This module provides customizable animated progress bars.
]]

local PANEL = {}

-- Default configuration
PANEL.Color = Color(70, 150, 255)       -- Base color
PANEL.BackgroundColor = Color(40, 40, 40, 200) -- Background color
PANEL.BorderColor = Color(100, 100, 100, 100) -- Border color
PANEL.Progress = 0.5                    -- Progress value (0-1)
PANEL.TargetProgress = 0.5              -- Target progress value for smooth transitions
PANEL.SmoothSpeed = 3                   -- Speed of progress transitions
PANEL.Height = 8                        -- Height of the progress bar
PANEL.Style = 'default'                 -- Style: 'default', 'segments', 'gradient', 'pulse'
PANEL.Rounded = true                    -- Use rounded corners
PANEL.Animated = true                   -- Enable internal animations
PANEL.SegmentCount = 10                 -- Number of segments (for 'segments' style)
PANEL.SegmentGap = 3                    -- Gap between segments
PANEL.GlowFactor = 0.3                  -- Glow intensity

-- Initialize the panel
function PANEL:Init()
    self.Time = 0
    self.InternalProgress = 0
    self.ActualProgress = 0
    
    -- Set default size
    self:SetSize(200, 20)
end

-- Think is called every frame
function PANEL:Think()
    self.Time = self.Time + FrameTime()
    
    -- Smooth progress transition
    self.ActualProgress = Lerp(FrameTime() * self.SmoothSpeed, self.ActualProgress, self.Progress)
    
    -- Update internal animation progress
    if self.Animated then
        if self.Style == 'pulse' then
            -- Pulse animation moves independently
            self.InternalProgress = (self.InternalProgress + FrameTime() * 0.5) % 1
        else
            -- Other animations follow the actual progress
            self.InternalProgress = (self.InternalProgress + FrameTime() * 0.2) % 1
        end
    end
end

-- Set progress value (0-1)
function PANEL:SetProgress(progress)
    self.Progress = math.Clamp(progress, 0, 1)
    return self
end

-- Draw the panel
function PANEL:Paint(w, h)
    local barHeight = self.Height
    local barY = (h - barHeight) / 2
    local cornerRadius = self.Rounded and math.floor(barHeight / 2) or 0
    
    -- Draw background and border
    if self.BackgroundColor.a > 0 then
        -- Draw background
        draw.RoundedBox(
            cornerRadius,
            0, 
            barY, 
            w, 
            barHeight, 
            self.BackgroundColor
        )
    end
    
    if self.BorderColor.a > 0 then
        -- Draw border
        surface.SetDrawColor(self.BorderColor)
        surface.DrawOutlinedRect(0, barY, w, barHeight, 1)
    end
    
    -- Calculate progress width
    local progressWidth = w * self.ActualProgress
    
    -- Draw progress based on style
    if self.Style == 'default' then
        -- Simple progress bar with optional glow
        local color = self.Color
        
        -- Glow effect for the progress bar
        if self.GlowFactor > 0 then
            local glowSteps = 3
            for i = 1, glowSteps do
                local glowAlpha = color.a * (self.GlowFactor / i)
                local spread = i * 2
                
                surface.SetDrawColor(color.r, color.g, color.b, glowAlpha)
                draw.RoundedBox(
                    cornerRadius,
                    spread, 
                    barY + spread, 
                    progressWidth - spread * 2, 
                    barHeight - spread * 2, 
                    Color(color.r, color.g, color.b, glowAlpha)
                )
            end
        end
        
        -- Main progress bar
        draw.RoundedBox(
            cornerRadius,
            0, 
            barY, 
            progressWidth, 
            barHeight, 
            color
        )
        
        -- Highlight/shine effect
        if self.Animated then
            local shinePos = (self.InternalProgress * 2 - 0.5) * w
            local shineWidth = w * 0.2
            
            -- Only draw if within the progress area
            if shinePos > -shineWidth and shinePos < progressWidth then
                surface.SetDrawColor(255, 255, 255, 30)
                draw.RoundedBox(
                    cornerRadius,
                    math.max(0, shinePos), 
                    barY, 
                    math.min(shineWidth, progressWidth - shinePos), 
                    barHeight, 
                    Color(255, 255, 255, 30)
                )
            end
        end
        
    elseif self.Style == 'segments' then
        -- Segmented progress bar
        local color = self.Color
        local segmentWidth = (w - (self.SegmentCount - 1) * self.SegmentGap) / self.SegmentCount
        local completedSegments = math.floor(self.ActualProgress * self.SegmentCount)
        
        for i = 0, self.SegmentCount - 1 do
            local segX = i * (segmentWidth + self.SegmentGap)
            local alpha = (i < completedSegments) and color.a or (color.a * 0.2)
            
            -- Animated current segment
            if i == completedSegments and self.Animated then
                alpha = color.a * (0.3 + 0.7 * (math.sin(self.Time * 5) * 0.5 + 0.5))
            end
            
            surface.SetDrawColor(color.r, color.g, color.b, alpha)
            draw.RoundedBox(
                math.floor(barHeight / 3),
                segX, 
                barY, 
                segmentWidth, 
                barHeight, 
                Color(color.r, color.g, color.b, alpha)
            )
        end
        
    elseif self.Style == 'gradient' then
        -- Gradient progress bar
        local color = self.Color
        local segments = 15
        local segWidth = progressWidth / segments
        
        for i = 0, segments - 1 do
            local brightnessFactor = 0.7 + 0.3 * (i / segments)
            local segX = i * segWidth
            local segColor = Color(
                math.min(255, color.r * brightnessFactor),
                math.min(255, color.g * brightnessFactor),
                math.min(255, color.b * brightnessFactor),
                color.a
            )
            
            draw.RoundedBox(
                (i == 0) and cornerRadius or 0,
                segX, 
                barY, 
                segWidth + 1, -- +1 to avoid gaps
                barHeight, 
                segColor
            )
        end
        
        -- Add moving highlight
        if self.Animated then
            local highlightPos = (self.InternalProgress * 2 - 0.5) * progressWidth
            local highlightWidth = progressWidth * 0.1
            
            if highlightPos > -highlightWidth and highlightPos < progressWidth then
                surface.SetDrawColor(255, 255, 255, 40)
                draw.RoundedBox(
                    0,
                    math.max(0, highlightPos), 
                    barY, 
                    math.min(highlightWidth, progressWidth - highlightPos), 
                    barHeight, 
                    Color(255, 255, 255, 40)
                )
            end
        end
        
    elseif self.Style == 'pulse' then
        -- Pulsing progress bar
        local color = self.Color
        local pulseWidth = w * 0.1
        local pulsePos = (self.InternalProgress * 1.4) * w
        
        -- Draw base progress
        draw.RoundedBox(
            cornerRadius,
            0, 
            barY, 
            progressWidth, 
            barHeight, 
            color
        )
        
        -- Draw pulse highlight
        if pulsePos <= progressWidth then
            local pulseAlpha = 100 * (1 - math.abs(2 * self.InternalProgress - 1))
            local actualPulseWidth = math.min(pulseWidth, progressWidth - pulsePos)
            
            if actualPulseWidth > 0 then
                surface.SetDrawColor(255, 255, 255, pulseAlpha)
                draw.RoundedBox(
                    0,
                    pulsePos, 
                    barY, 
                    actualPulseWidth, 
                    barHeight, 
                    Color(255, 255, 255, pulseAlpha)
                )
            end
        end
    end
    
    -- Draw text if there's enough space
    if h > 15 and w > 40 then
        local text = math.floor(self.ActualProgress * 100) .. '%'
        draw.SimpleText(
            text, 
            'DermaDefault', 
            w / 2, 
            h / 2, 
            Color(255, 255, 255, 200), 
            TEXT_ALIGN_CENTER, 
            TEXT_ALIGN_CENTER
        )
    end
end

-- Configure the animation settings
function PANEL:Configure(config)
    config = config or {}
    
    if config.Color then self.Color = config.Color end
    if config.BackgroundColor then self.BackgroundColor = config.BackgroundColor end
    if config.BorderColor then self.BorderColor = config.BorderColor end
    if config.Progress then self:SetProgress(config.Progress) end
    if config.SmoothSpeed then self.SmoothSpeed = config.SmoothSpeed end
    if config.Height then self.Height = config.Height end
    if config.Style then self.Style = config.Style end
    if config.Rounded ~= nil then self.Rounded = config.Rounded end
    if config.Animated ~= nil then self.Animated = config.Animated end
    if config.SegmentCount then self.SegmentCount = config.SegmentCount end
    if config.SegmentGap then self.SegmentGap = config.SegmentGap end
    if config.GlowFactor ~= nil then self.GlowFactor = config.GlowFactor end
    
    return self
end

vgui.Register('AnimatedProgressBar', PANEL, 'DPanel')

-- Return the panel so it can be used elsewhere
return PANEL
