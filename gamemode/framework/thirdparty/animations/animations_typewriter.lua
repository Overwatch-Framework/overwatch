--[[
    Typewriter Animation for Garry's Mod

    A text animation that types out characters one by one with customizable properties.
    Part of the DDI Modern UI Animations package.
]]

local PANEL = {}

-- Default configuration
local DefaultConfig = {
    Text = 'DDI Modern UI Animations',   -- Text to display
    Color = Color(255, 255, 255, 255),   -- Text color
    Font = 'DermaLarge',                 -- Font to use
    TypeSpeed = 0.05,                    -- Seconds per character
    BlinkCursor = true,                  -- Whether to blink cursor
    CursorColor = Color(255, 255, 255),  -- Cursor color
    BackgroundColor = Color(0, 0, 0, 0), -- Background color
    Delay = 0,                           -- Initial delay before starting
    Loop = false,                        -- Whether to loop the animation
    LoopDelay = 1,                       -- Delay before looping
    CursorChar = '|',                    -- Character to use as cursor
    SoundEnabled = false,                -- Play typing sounds
    DDIStyled = false                    -- Use DDI styling
}

-- DDI styling options
local DDIStyling = {
    Colors = {
        Primary = Color(70, 150, 255),    -- DDI Blue
        Secondary = Color(255, 70, 150),  -- DDI Pink
        Accent = Color(100, 255, 100)     -- DDI Green
    },
    Fonts = {
        'DermaLarge',
        'DermaDefaultBold',
        'CloseCaption_Bold'
    },
    CursorChars = {'|', '_', '▌', '■'}
}

-- Initialize the panel
function PANEL:Init()
    self.Config = table.Copy(DefaultConfig)
    self.CurrentIndex = 0
    self.LastTypeTime = 0
    self.IsTyping = false
    self.CursorVisible = true
    self.CursorBlinkTime = 0
    self.ResetQueued = false
    self.FinishedTime = 0

    -- Set up sounds if available
    if self.Config.SoundEnabled then
        self.TypeSounds = {
            Sound('typewriter1.wav'),
            Sound('typewriter2.wav'),
            Sound('typewriter3.wav')
        }
    end

    -- Default settings
    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(false)
end

-- Apply configuration options
function PANEL:Configure(config)
    table.Merge(self.Config, config or {})

    -- Apply DDI styling if enabled
    if self.Config.DDIStyled then
        if not config or not config.Color then
            self.Config.Color = DDIStyling.Colors.Primary
        end
        if not config or not config.CursorColor then
            self.Config.CursorColor = DDIStyling.Colors.Secondary
        end
        if not config or not config.Font then
            self.Config.Font = DDIStyling.Fonts[1]
        end
        if not config or not config.CursorChar then
            self.Config.CursorChar = DDIStyling.CursorChars[1]
        end
    end

    -- Reset animation
    self:Reset()
end

-- Manually start the animation
function PANEL:Start()
    self.IsTyping = true
    self.CurrentIndex = 0
    self.LastTypeTime = CurTime() + self.Config.Delay
end

-- Reset the animation
function PANEL:Reset()
    self.CurrentIndex = 0
    self.IsTyping = false
    self.CursorVisible = true
    self.ResetQueued = false
end

-- Update the animation
function PANEL:Think()
    local currentTime = CurTime()

    -- Handle cursor blinking
    if self.Config.BlinkCursor then
        if currentTime - self.CursorBlinkTime > 0.5 then
            self.CursorBlinkTime = currentTime
            self.CursorVisible = not self.CursorVisible
        end
    else
        self.CursorVisible = true
    end

    -- Handle typing animation
    if self.IsTyping then
        if currentTime - self.LastTypeTime > self.Config.TypeSpeed then
            -- Move to next character
            self.CurrentIndex = self.CurrentIndex + 1
            self.LastTypeTime = currentTime

            -- Play typing sound if enabled
            if self.Config.SoundEnabled and self.TypeSounds then
                local randomSound = self.TypeSounds[math.random(1, #self.TypeSounds)]
                surface.PlaySound(randomSound)
            end

            -- Check if we've finished typing
            if self.CurrentIndex >= string.len(self.Config.Text) then
                self.IsTyping = false
                self.FinishedTime = currentTime

                -- If looping, queue a reset
                if self.Config.Loop and not self.ResetQueued then
                    self.ResetQueued = true
                    timer.Simple(self.Config.LoopDelay, function()
                        if IsValid(self) then
                            self:Start()
                        end
                    end)
                end
            end
        end
    elseif not self.IsTyping and not self.ResetQueued and self.CurrentIndex == 0 then
        -- Auto-start on first display
        self:Start()
    end
end

-- Paint the panel
function PANEL:Paint(w, h)
    -- Draw background if needed
    if self.Config.BackgroundColor.a > 0 then
        draw.RoundedBox(0, 0, 0, w, h, self.Config.BackgroundColor)
    end

    -- Set up font
    surface.SetFont(self.Config.Font)

    -- Get current visible text
    local visibleText = string.sub(self.Config.Text, 1, self.CurrentIndex)

    -- Get text dimensions
    local textWidth, textHeight = surface.GetTextSize(visibleText)

    -- Draw the text
    draw.SimpleText(
        visibleText,
        self.Config.Font,
        w/2,
        h/2,
        self.Config.Color,
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )

    -- Draw cursor if visible
    if self.CursorVisible then
        local cursorX = w/2 + textWidth/2 + 2
        if textWidth == 0 then
            cursorX = w/2
        end

        draw.SimpleText(
            self.Config.CursorChar,
            self.Config.Font,
            cursorX,
            h/2,
            self.Config.CursorColor,
            TEXT_ALIGN_LEFT,
            TEXT_ALIGN_CENTER
        )
    end

    -- DDI-styled flourishes if enabled
    if self.Config.DDIStyled then
        -- Draw small accent line at bottom
        local accentHeight = 2
        local accentWidth = w / 3

        -- Draw gradient accent lines
        surface.SetDrawColor(DDIStyling.Colors.Primary)
        surface.DrawRect(0, h - accentHeight, accentWidth, accentHeight)

        surface.SetDrawColor(DDIStyling.Colors.Secondary)
        surface.DrawRect(accentWidth, h - accentHeight, accentWidth, accentHeight)

        surface.SetDrawColor(DDIStyling.Colors.Accent)
        surface.DrawRect(accentWidth * 2, h - accentHeight, accentWidth, accentHeight)

        -- Draw small DDI logo in corner if panel is large enough
        if w > 200 and h > 80 then
            local logoSize = 20
            local margin = 5

            draw.RoundedBox(4, margin, margin, logoSize, logoSize, Color(40, 40, 44, 150))
            draw.SimpleText('DDI', 'DermaDefaultBold', margin + logoSize/2, margin + logoSize/2, DDIStyling.Colors.Primary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    return true
end

vgui.Register('AnimatedTypeWriter', PANEL, 'Panel')
return PANEL