ENT.Base			= "base_gmodentity"
ENT.Type			= "anim"
ENT.PrintName		= "Currency"
ENT.Author			= "Overwatch Developers"
ENT.Purpose			= "Moneyyyyy."
ENT.Instructions	= "Use to get money."
ENT.Category 		= "Overwatch"

ENT.Spawnable = false
ENT.AdminOnly = false

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "Amount")
end