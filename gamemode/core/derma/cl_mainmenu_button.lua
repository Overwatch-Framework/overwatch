DEFINE_BASECLASS("DButton")

local PANEL = {}

function PANEL:Init()
    self:SetFont("ow.fonts.button")
    self:SetTextColorProperty(color_white)
    self:SetContentAlignment(4)
    self:SetTall(ScreenScale(18))
    self:SetTextInset(ScreenScale(2), 0)

    self.inertia = 0
    self.inertiaTarget = 0

    self.baseHeight = self:GetTall()
    self.baseTextColor = self:GetTextColor()
    self.height = 0
    self.heightTarget = self.baseHeight
    self.textColor = color_white
    self.textColorTarget = color_white
    self.textInset = {0, 0}
    self.textInsetTarget = {0, 0}
end

function PANEL:SetTextColorProperty(color)
    self.baseTextColor = color
    self:SetTextColor(color)
end

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

local RIPPLE_DIE_TIME = 1
local RIPPLE_START_ALPHA = 50

function PANEL:Paint(width, height)
    local ft = FrameTime()
    local time = ft * 10

    self.inertia = Lerp(time, self.inertia, self.inertiaTarget)
    self.height = Lerp(time, self.height, self.heightTarget)
    self.textColor = self.textColor:Lerp(self.textColorTarget, time)

    self.textInset[1] = Lerp(time, self.textInset[1], self.textInsetTarget[1])
    self.textInset[2] = Lerp(time, self.textInset[2], self.textInsetTarget[2])

    paint.startPanel(self)
        mask(function()
            paint.roundedBoxes.roundedBox(0, 0, 0, width, height, Color(0, 0, 0, 50 * self.inertia))
        end,
        function()
            local ripple = self.rippleEffect
            if ( ripple == nil ) then return end

            local rippleX, rippleY, rippleStartTime = ripple[1], ripple[2], ripple[3]

            local percent = (RealTime() - rippleStartTime)  / RIPPLE_DIE_TIME
            if ( percent >= 1 ) then
                self.rippleEffect = nil
            else
                local alpha = RIPPLE_START_ALPHA * (1 - percent) * self.inertia
                local radius = math.max(width, height) * percent * math.sqrt(2)

                paint.roundedBoxes.roundedBox(0, rippleX - radius, rippleY - radius, radius * 2, radius * 2, ColorAlpha(self.textColor, alpha))
            end
        end)
    paint.endPanel()

    surface.SetDrawColor(self.textColor.r, self.textColor.g, self.textColor.b, 200 * self.inertia)
    surface.DrawRect(0, 0, ScreenScale(4) * self.inertia, height)
end

function PANEL:Think()
    if ( !self:IsHovered() and ( self.textColorTarget != self.baseTextColor or self.heightTarget != self.baseHeight) ) then
        self.textColorTarget = self.baseTextColor
        self.textInsetTarget = {ScreenScale(2), 0}
        self.heightTarget = self.baseHeight
    end

    if ( self.inertia > 0 ) then
        self:SetTall(self.height)
        self:SetTextColor(self.textColor)
        self:SetTextInset(self.textInset[1], self.textInset[2])
    end
end

function PANEL:OnCursorEntered()
    self:SetFont("ow.fonts.button.hover")

    self.heightTarget = self.baseHeight * 1.25
    self.textColorTarget = hook.Run("GetSchemaColor")
    self.textInsetTarget = {ScreenScale(8), 0}

    surface.PlaySound("ow.button.enter")

    self.inertiaTarget = 1
end

function PANEL:OnCursorExited()
    self:SetFont("ow.fonts.button")

    self.heightTarget = self.baseHeight
    self.textColorTarget = self.baseTextColor or color_white
    self.textInsetTarget = {ScreenScale(2), 0}

    self.inertiaTarget = 0
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

vgui.Register("ow.mainmenu.button", PANEL, "DButton")

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