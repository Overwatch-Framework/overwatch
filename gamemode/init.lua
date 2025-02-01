DeriveGamemode("sandbox")

ow = ow or {util = {}, meta = {}, config = {}}

AddCSLuaFile("cl_init.lua")

AddCSLuaFile("core/sh_util.lua")
include("core/sh_util.lua")

AddCSLuaFile("shared.lua")
include("shared.lua")

for k, v in ipairs(engine.GetAddons()) do
    if ( v.downloaded and v.mounted ) then
        resource.AddWorkshop(v.wsid)
    end
end