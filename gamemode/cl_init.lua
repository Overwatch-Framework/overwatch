DeriveGamemode("sandbox")

ow = ow or {util = {}, gui = {}, meta = {}, config = {}}

include("framework/sh_util.lua")
include("shared.lua")

local oldLocalPlayer = LocalPlayer
function LocalPlayer()
    if ( IsValid(ow.localClient) ) then
        return ow.localClient
    end

    return oldLocalPlayer()
end