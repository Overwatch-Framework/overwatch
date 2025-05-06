ow.flag = ow.flag or {}
ow.flag.stored = {}

function ow.flag:Register(flag, description, callback)
    if ( !isstring(flag) or #flag != 1 ) then
        ow.util:PrintError("Attempted to register a flag without a flag character!")
        return false
    end

    if ( self.stored[flag] ) then
        ow.util:PrintError("Attempted to register a flag that already exists!")
        return false
    end

    self.stored[flag] = {
        description = description or "No description provided",
        callback = callback or nil
    }

    return true
end

function ow.flag:Get(flag)
    return self.stored[flag]
end

ow.flag:Register("t", "flag.toolgun", function(char, has)
    local client = char:GetPlayer()
    if ( !IsValid(client) ) then return end

    if ( has ) then
        client:Give("gmod_tool")
    else
        local wep = client:GetActiveWeapon()
        if ( IsValid(wep) and wep:GetClass() == "gmod_tool" ) then
            client:SelectWeapon("ow_hands")
        end

        client:StripWeapon("gmod_tool")
    end
end)

ow.flag:Register("p", "flag.physgun", function(char, has)
    local client = char:GetPlayer()
    if ( !IsValid(client) ) then return end

    if ( has ) then
        client:Give("weapon_physgun")
    else
        local wep = client:GetActiveWeapon()
        if ( IsValid(wep) and wep:GetClass() == "weapon_physgun" ) then
            client:SelectWeapon("ow_hands")
        end

        client:StripWeapon("weapon_physgun")
    end
end)