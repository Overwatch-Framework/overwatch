local MODULE = MODULE

function GM:ShouldDrawStamina()
    if ( IsValid(ow.gui.mainmenu) ) then return false end
    if ( IsValid(ow.gui.tab) ) then return false end

    return true
end

local staminaLerp = 0
local staminaAlpha = 0
local staminaTime = 0
local staminaLast = 0
function MODULE:HUDPaint()
    local shouldDraw = hook.Run("ShouldDrawStamina")
    if ( shouldDraw != nil and shouldDraw != false ) then
        local staminaFraction = ow.stamina:GetFraction()
        staminaLerp = Lerp(FrameTime() * 5, staminaLerp, staminaFraction)

        if ( staminaLast != staminaFraction ) then
            staminaTime = CurTime() + 5
            staminaLast = staminaFraction
        elseif ( staminaTime < CurTime() ) then
            staminaAlpha = Lerp(FrameTime() * 5, staminaAlpha, 0)
        elseif ( staminaAlpha < 255 ) then
            staminaAlpha = Lerp(FrameTime() * 5, staminaAlpha, 255)
        end

        if ( staminaAlpha > 0 ) then
            local scrW, scrH = ScrW(), ScrH()

            local barWidth, barHeight = scrW / 3, ScreenScale(10)
            local barX, barY = scrW / 2 - barWidth / 2, scrH / 1.25 - barHeight / 2

            ow.util:DrawBlurRect(barX, barY, barWidth, barHeight, 2, nil, staminaAlpha)

            surface.SetDrawColor(ColorAlpha(ow.color:Get("background.transparent"), staminaAlpha / 2))
            surface.DrawRect(barX, barY, barWidth, barHeight)

            surface.SetDrawColor(ColorAlpha(ow.color:Get("white"), staminaAlpha))
            surface.DrawRect(barX, barY, barWidth * staminaLerp, barHeight)
        end
    end
end