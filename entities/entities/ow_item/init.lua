AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()

end

function ENT:SetItem(uniqueID)
    local itemData = ow.item:Get(uniqueID)
end