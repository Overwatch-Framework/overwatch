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

timer.Remove("HintSystem_OpeningMenu")
timer.Remove("HintSystem_Annoy1")
timer.Remove("HintSystem_Annoy2")