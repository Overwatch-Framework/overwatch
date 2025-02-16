ENT.Base			= "base_gmodentity"
ENT.Type			= "anim"
ENT.PrintName		= "Item"
ENT.Author			= "Overwatch Developers"
ENT.Purpose			= "Uh, item."
ENT.Instructions	= "Use to pickup or something else, idk"
ENT.Category 		= "Overwatch"

ENT.Spawnable = false
ENT.AdminOnly = false

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "ItemID")
    self:NetworkVar("String", 0, "ItemUniqueID")
end