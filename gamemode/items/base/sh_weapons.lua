ITEM.Name = "Weapon Base"
ITEM.Description = "A base for all weapons."
ITEM.Category = "Weapons"
ITEM.Model = Model("models/weapons/w_smg1.mdl")

ITEM.Weight = 5

ITEM.WeaponClass = "weapon_base"

ITEM.Actions.Equip = {
    Name = "Equip",
    Description = "Equip the pistol.",
    OnRun = function(this, item, client)
        if ( !IsValid(client) ) then return end

        local weapon = client:Give(item.WeaponClass)
        if ( !IsValid(weapon) ) then return end

        local owWeapons = client:GetRelay("weapons", {})
        owWeapons[item.WeaponClass] = item:GetID()
        client:SetRelay("weapons", owWeapons)

        client:SelectWeapon(item.WeaponClass)

        item:SetData("equipped", true)

        return true
    end,
    OnCanRun = function(this, item, client)
        if ( !IsValid(client) ) then return false end

        local owWeapons = client:GetRelay("weapons", {})
        return !owWeapons[item.WeaponClass] and !client:HasWeapon(item.WeaponClass)
    end
}

ITEM.Actions.EquipUn = {
    Name = "Unequip",
    Description = "Unequip the pistol.",
    OnRun = function(this, item, client)
        if ( !IsValid(client) ) then return end

        client:StripWeapon(item.WeaponClass)
        client:SelectWeapon("ow_hands")

        local owWeapons = client:GetRelay("weapons", {})
        owWeapons[item.WeaponClass] = nil
        client:SetRelay("weapons", owWeapons)

        item:SetData("equipped", false)

        return true
    end,
    OnCanRun = function(this, item, client)
        if ( !IsValid(client) ) then return false end

        local owWeapons = client:GetRelay("weapons", {})
        local owWeaponID = owWeapons[item.WeaponClass]
        return tobool(owWeaponID and client:HasWeapon(item.WeaponClass) and owWeaponID == item:GetID())
    end
}

ITEM:Hook("Drop", function(item, client)
    if ( !IsValid(client) ) then return end

    local owWeapons = client:GetRelay("weapons", {})
    if ( client:HasWeapon(item.WeaponClass) and owWeapons[item.WeaponClass] == item:GetID() ) then
        client:StripWeapon(item.WeaponClass)
        client:SelectWeapon("ow_hands")

        owWeapons[item.WeaponClass] = nil
        client:SetRelay("weapons", owWeapons)

        item:SetData("equipped", false)
    end
end)

function ITEM:OnCache()
    self:SetData("equipped", self:GetData("equipped", false))
end