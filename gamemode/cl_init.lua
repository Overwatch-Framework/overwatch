DeriveGamemode("sandbox")

ow = ow or {util = {}, gui = {}, meta = {}, config = {}}

include("core/sh_util.lua")
include("shared.lua")

local oldLocalPlayer = LocalPlayer
function LocalPlayer()
    if ( IsValid(ow.localClient) ) then
        return ow.localClient
    end

    return oldLocalPlayer()
end

local cached = {
    width = {},
    height = {},
}

local scrW, scrH = ScrW() / 640, ScrH() / 480

function ScreenScale(width)
    cached.width[width] = cached.width[width] or width * scrW

    return cached.width[width]
end

function ScreenScaleH(height)
    cached.height[height] = cached.height[height] or height * scrH

    return cached.height[height]
end

hook.Add("OnScreenSizeChanged", "CachedScreenScale", function(oldWidth, oldHeight, newWidth, newHeight)
    scrW, scrH = newWidth / 640, newHeight / 480

    cached = {
        width = {},
        height = {},
    }
end)

timer.Remove("HintSystem_OpeningMenu")
timer.Remove("HintSystem_Annoy1")
timer.Remove("HintSystem_Annoy2")