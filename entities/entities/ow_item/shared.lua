ENT.Base            = "base_gmodentity"
ENT.Type            = "anim"
ENT.PrintName        = "Item"
ENT.Author            = "Overwatch Developers"
ENT.Purpose            = "Uh, item."
ENT.Instructions    = "Use to pickup or something else, idk"
ENT.Category         = "Overwatch"

ENT.Spawnable = false
ENT.AdminOnly = false

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "UniqueID")
    self:NetworkVar("Int", 0, "ItemID")
end

function ENT:GetItemData()
    return ow.item:Get(self:GetItemID())
end