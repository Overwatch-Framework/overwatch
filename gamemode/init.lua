DeriveGamemode("sandbox")

ow = ow or {util = {}, meta = {}, config = {}}

AddCSLuaFile("cl_init.lua")

AddCSLuaFile("core/sh_util.lua")
include("core/sh_util.lua")

AddCSLuaFile("shared.lua")
include("shared.lua")