ENT.Base			= "base_gmodentity" 
ENT.Type			= "anim"
ENT.PrintName		= "Item"
ENT.Author			= "Overwatch Developers"
ENT.Purpose			= "Uh, item."
ENT.Instructions	= "Use to pickup or something else, idk"
ENT.Category 		= "Overwatch"

ENT.Spawnable = false
ENT.AdminOnly = false

function ENT:GetItemID()
    -- bloodycop: Should be implemented when we get the database working and each item has a unique index.
    --return self:GetInternalVariable("m_iOWItemID") or nil
end