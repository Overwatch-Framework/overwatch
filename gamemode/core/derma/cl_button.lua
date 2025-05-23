local function mask(drawMask, draw)
    render.ClearStencil()
    render.SetStencilEnable(true)

    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)

    render.SetStencilFailOperation(STENCIL_REPLACE)
    render.SetStencilPassOperation( STENCIL_REPLACE)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilReferenceValue(1)

    drawMask()

    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.SetStencilReferenceValue(1)

    draw()

    render.SetStencilEnable(false)
    render.ClearStencil()
end

local RIPPLE_DIE_TIME = 0.4
local RIPPLE_START_ALPHA = 50

DEFINE_BASECLASS("DButton")

local PANEL = {}

AccessorFunc(PANEL, "inertia", "Inertia", FORCE_NUMBER)
AccessorFunc(PANEL, "doRippleEffect", "DoRippleEffect", FORCE_BOOL)

function PANEL:Init()
    self:SetFont("ow.fonts.button")
    self:SetTextColorProperty(color_white)
    self:SetContentAlignment(4)
    self:SetTall(ScreenScale(18))
    self:SetTextInset(ScreenScale(2), 0)

    self.inertia = 0
    self.inertiaTarget = 0

    self.doRippleEffect = true

    self.baseHeight = self:GetTall()
    self.baseTextColor = self:GetTextColor()

    self.height = self.baseHeight
    self.heightTarget = self.baseHeight

    self.textColor = color_white
    self.textColorTarget = color_white

    self.textInset = {ScreenScale(2), 0}
    self.textInsetTarget = {ScreenScale(2), 0}
end

function PANEL:SetText(text, bNoTranslate, bNoSizeToContents, bNoUppercase)
    if ( !text ) then return end

    if ( !bNoTranslate ) then
        text = ow.localization:GetPhrase(text)
    end

    if ( !bNoUppercase ) then
        text = string.upper(text)
    end

    BaseClass.SetText(self, text)

    if ( !bNoSizeToContents ) then
        self:SizeToContents()
    end
end

function PANEL:SetTextColorProperty(color)
    self.baseTextColor = color
    self:SetTextColor(color)
end

function PANEL:SizeToContents()
    BaseClass.SizeToContents(self)
end

function PANEL:Paint(width, height)
    local ft = FrameTime()
    local time = ft * 10

    local performanceAnimations = ow.option:Get("performance.animations", true)
    if ( !performanceAnimations ) then
        time = 1
    end

    self.inertia = Lerp(time, self.inertia, self.inertiaTarget)
    self.height = Lerp(time, self.height, self.heightTarget)
    self.textColor = self.textColor:Lerp(self.textColorTarget, time)

    self.textInset[1] = Lerp(time, self.textInset[1], self.textInsetTarget[1])
    self.textInset[2] = Lerp(time, self.textInset[2], self.textInsetTarget[2])

    local backgroundColor = Color(self.textColor.r / 8, self.textColor.g / 8, self.textColor.b / 8)
    draw.RoundedBox(0, 0, 0, width, height, ColorAlpha(backgroundColor, 100 * self.inertia))

    paint.startPanel(self)
        mask(function()
            paint.roundedBoxes.roundedBox(0, 0, 0, width, height, Color(0, 0, 0, 0))
        end,
        function()
            if ( !self.doRippleEffect or performanceAnimations == false ) then return end

            local ripple = self.rippleEffect
            if ( ripple == nil ) then return end

            local rippleX, rippleY, rippleStartTime = ripple[1], ripple[2], ripple[3]

            local percent = (RealTime() - rippleStartTime)  / RIPPLE_DIE_TIME
            if ( percent >= 1 ) then
                self.rippleEffect = nil
            else
                local alpha = RIPPLE_START_ALPHA * (1 - percent) * self.inertia
                local radius = math.max(width, height) * percent * math.sqrt(2)

                paint.roundedBoxes.roundedBox(radius, rippleX - radius, rippleY - radius, radius * 2, radius * 2, ColorAlpha(self.textColor, alpha))
            end
        end)
    paint.endPanel()

    surface.SetDrawColor(self.textColor.r, self.textColor.g, self.textColor.b, 200 * self.inertia)
    surface.DrawRect(0, 0, ScreenScale(4) * self.inertia, height)

    return false
end

function PANEL:Think()
    if ( !self:IsHovered() and ( self.textColorTarget != self.baseTextColor or self.heightTarget != self.baseHeight) ) then
        self:SetFont("ow.fonts.button")

        self.heightTarget = self.baseHeight
        self.textColorTarget = self.baseTextColor or color_white
        self.textInsetTarget = {ScreenScale(2), 0}

        self.inertiaTarget = 0

        if ( self.OnUnHovered ) then
            self:OnUnHovered()
        end
    end

    self:SetTall(self.height)
    self:SetTextColor(self.textColor)
    self:SetTextInset(self.textInset[1], self.textInset[2])
end

function PANEL:OnCursorEntered()
    surface.PlaySound("ow.button.enter")

    self:SetFont("ow.fonts.button.hover")

    self.heightTarget = self.baseHeight * 1.25
    self.textColorTarget = hook.Run("GetSchemaColor")
    self.textInsetTarget = {ScreenScale(8), 0}

    self.inertiaTarget = 1

    if ( self.OnHovered ) then
        self:OnHovered()
    end
end

function PANEL:OnMousePressed(key)
    surface.PlaySound("ow.button.click")

    local posX, posY = self:LocalCursorPos()
    self.rippleEffect = {posX, posY, RealTime()}

    if ( key == MOUSE_LEFT ) then
        self:DoClick()
    else
        self:DoRightClick()
    end
end

vgui.Register("ow.button", PANEL, "DButton")

DEFINE_BASECLASS("ow.button")

PANEL = {}

AccessorFunc(PANEL, "backgroundAlphaHovered", "BackgroundAlphaHovered", FORCE_NUMBER)
AccessorFunc(PANEL, "backgroundAlphaUnHovered", "BackgroundAlphaUnHovered", FORCE_NUMBER)
AccessorFunc(PANEL, "backgroundColor", "BackgroundColor")

function PANEL:Init()
    self:SetFont("ow.fonts.button.small")
    self:SetTextColorProperty(color_white)
    self:SetContentAlignment(5)
    self:SetTall(ScreenScale(12))
    self:SetTextInset(0, 0)

    self:SetWide(ScreenScale(64))

    self.backgroundAlphaHovered = 1
    self.backgroundAlphaUnHovered = 0

    self.inertia = 0
    self.inertiaTarget = 0

    self.doRippleEffect = true
    self.rippleEffect = nil

    self.baseHeight = self:GetTall()
    self.baseTextColor = self:GetTextColor()

    self.baseTextColorTarget = color_black
    self.textColorTarget = color_black

    self.backgroundColor = color_white
end

function PANEL:SizeToContents()
    BaseClass.SizeToContents(self)

    self:SetSize(self:GetWide() + ScreenScale(16), self:GetTall() + ScreenScale(16))
end

function PANEL:Paint(width, height)
    local ft = FrameTime()
    local time = ft * 10

    local performanceAnimations = ow.option:Get("performance.animations", true)
    if ( !performanceAnimations ) then
        time = 1
    end

    self.inertia = Lerp(time, self.inertia, self.inertiaTarget)
    self.textColor = self.textColor:Lerp(self.textColorTarget, time)

    draw.RoundedBox(0, 0, 0, width, height, ColorAlpha(self.backgroundColor, 255 * self.inertia))

    paint.startPanel(self)
        mask(function()
            paint.roundedBoxes.roundedBox(0, 0, 0, width, height, color_transparent)
        end,
        function()
            local ripple = self.rippleEffect
            if ( ripple == nil or performanceAnimations == false ) then return end

            local rippleX, rippleY, rippleStartTime = ripple[1], ripple[2], ripple[3]

            local percent = (RealTime() - rippleStartTime)  / RIPPLE_DIE_TIME
            if ( percent >= 1 ) then
                self.rippleEffect = nil
            else
                local alpha = (RIPPLE_START_ALPHA * 2) * (1 - percent) * self.inertia
                local radius = math.max(width, height) * percent * math.sqrt(2)

                paint.roundedBoxes.roundedBox(radius, rippleX - radius, rippleY - radius, radius * 2, radius * 2, Color(0, 0, 0, alpha))
            end
        end)
    paint.endPanel()

    return false
end

function PANEL:Think()
    if ( !self:IsHovered() and ( self.textColorTarget != self.baseTextColor ) ) then
        self:SetFont("ow.fonts.button.small")

        self.textColorTarget = self.baseTextColor or color_white

        self.inertiaTarget = self.backgroundAlphaUnHovered or 0

        if ( self.OnUnHovered ) then
            self:OnUnHovered()
        end
    end

    self:SetTextColor(self.textColor)
end

function PANEL:OnCursorEntered()
    surface.PlaySound("ow.button.enter")

    self:SetFont("ow.fonts.button.small.hover")

    self.textColorTarget = self.baseTextColorTarget or color_black

    self.inertiaTarget = self.backgroundAlphaHovered or 1

    if ( self.OnHovered ) then
        self:OnHovered()
    end
end

vgui.Register("ow.button.small", PANEL, "ow.button")

sound.Add({
    name = "ow.button.click",
    channel = CHAN_STATIC,
    volume = 0.2,
    level = 80,
    pitch = 120,
    sound = "ui/buttonclickrelease.wav"
})

sound.Add({
    name = "ow.button.enter",
    channel = CHAN_STATIC,
    volume = 0.1,
    level = 80,
    pitch = 120,
    sound = "ui/buttonrollover.wav"
})