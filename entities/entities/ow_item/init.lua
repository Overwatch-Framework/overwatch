AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()

end

function ENT:SetItem(uniqueID)
    local itemData = ow.item:Get(uniqueID)
    if ( !itemData ) then return false end

    self:SetModel(Model(itemData.Model))
    self:SetSkin(itemData.Skin or 0)
    self:SetColor(itemData.Color or color_white)
    self:SetMaterial(itemData.Material or "")

    for k, v in pairs(itemData.Bodygroups) do
        if ( isstring(k) ) then
            self:SetBodygroup(self:GetBodygroupByName(k), v)
        elseif ( isnumber(k) ) then
            self:SetBodygroup(k, v)
        end
    end
    
    -- bloodycop: Something like netvar or smth in the future
    --self:SetInternalVariable("m_iOWItemUniqueID", uniqueID)
end