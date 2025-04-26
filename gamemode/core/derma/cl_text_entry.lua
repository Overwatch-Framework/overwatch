DEFINE_BASECLASS("DTextEntry")

local PANEL = {}

function PANEL:Init()
    self:SetFont("ow.fonts.default")
    self:SetTextColor(color_white)
    self:SetExpensiveShadow(1, color_black)
    self:SetPaintBackground(false)
    self:SetUpdateOnType(true)
    self:SetCursorColor(color_white)
    self:SetHighlightColor(color_white)

    self:SetTall(ScreenScale(12))
end

function PANEL:SizeToContents()
    BaseClass.SizeToContents(self)

    local width, height = self:GetSize()
    self:SetSize(width + 8, height + 4)
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
    BaseClass.Paint(self, width, height)

    paint.startPanel(self)
        mask(function()
            paint.roundedBoxes.roundedBox(0, 0, 0, width, height, Color(0, 0, 0, 50))
        end,
        function()
            local ripple = self.rippleEffect
            if ( ripple == nil ) then return end

            local rippleX, rippleY, rippleStartTime = ripple[1], ripple[2], ripple[3]

            local percent = (RealTime() - rippleStartTime)  / RIPPLE_DIE_TIME
            if ( percent >= 1 ) then
                self.rippleEffect = nil
            else
                local alpha = RIPPLE_START_ALPHA * (1 - percent)
                local radius = math.max(width, height) * percent * math.sqrt(2)

                paint.roundedBoxes.roundedBox(0, rippleX - radius, rippleY - radius, radius * 2, radius * 2, ColorAlpha(self:GetTextColor(), alpha))
            end
        end)
    paint.endPanel()
end

function PANEL:OnMousePressed(key)
    BaseClass.OnMousePressed(self, key)

    local posX, posY = self:LocalCursorPos()
    self.rippleEffect = {posX, posY, RealTime()}
end

vgui.Register("ow.text.entry", PANEL, "DTextEntry")