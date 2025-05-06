ITEM.Name = "Weapon Base"
ITEM.Description = "A base for all weapons."
ITEM.Category = "Weapons"
ITEM.Model = Model("models/weapons/w_smg1.mdl")

ITEM.Weight = 5

ITEM.WeaponClass = "weapon_base"

ITEM.Actions.Equip = {
    Name = "Equip",
    Description = "Equip the pistol.",
    OnRun = function(this, item, ply)
        if ( !IsValid(ply) ) then return end

        local weapon = ply:Give(item.WeaponClass)
        if ( !IsValid(weapon) ) then return end

        local owWeapons = ply:GetRelay("weapons", {})
        owWeapons[item.WeaponClass] = item:GetID()
        ply:SetRelay("weapons", owWeapons)

        ply:SelectWeapon(item.WeaponClass)

        item:SetData("equipped", true)

        return true
    end,
    OnCanRun = function(this, item, ply)
        if ( !IsValid(ply) ) then return false end

        local owWeapons = ply:GetRelay("weapons", {})
        return !owWeapons[item.WeaponClass] and !ply:HasWeapon(item.WeaponClass)
    end
}

ITEM.Actions.EquipUn = {
    Name = "Unequip",
    Description = "Unequip the pistol.",
    OnRun = function(this, item, ply)
        if ( !IsValid(ply) ) then return end

        ply:StripWeapon(item.WeaponClass)
        ply:SelectWeapon("ow_hands")

        local owWeapons = ply:GetRelay("weapons", {})
        owWeapons[item.WeaponClass] = nil
        ply:SetRelay("weapons", owWeapons)

        item:SetData("equipped", false)

        return true
    end,
    OnCanRun = function(this, item, ply)
        if ( !IsValid(ply) ) then return false end

        local owWeapons = ply:GetRelay("weapons", {})
        local owWeaponID = owWeapons[item.WeaponClass]
        return tobool(owWeaponID and ply:HasWeapon(item.WeaponClass) and owWeaponID == item:GetID())
    end
}

ITEM:Hook("Drop", function(item, ply)
    if ( !IsValid(ply) ) then return end

    local owWeapons = ply:GetRelay("weapons", {})
    if ( ply:HasWeapon(item.WeaponClass) and owWeapons[item.WeaponClass] == item:GetID() ) then
        ply:StripWeapon(item.WeaponClass)
        ply:SelectWeapon("ow_hands")

        owWeapons[item.WeaponClass] = nil
        ply:SetRelay("weapons", owWeapons)

        item:SetData("equipped", false)
    end
end)

function ITEM:OnCache()
    self:SetData("equipped", self:GetData("equipped", false))
end