local MODULE = MODULE

function MODULE:DoPlayerDeath(ply, attacker, dmginfo)
    if ( !IsValid(ply) ) then return end

    local attackerName = IsValid(attacker) and attacker:IsPlayer() and attacker:Nick() or "World"
    local weaponName = "world"

    if ( IsValid(attacker) ) then
        if ( IsValid(attacker:GetActiveWeapon()) ) then
            weaponName = attacker:GetActiveWeapon():GetClass()
        elseif ( attacker:IsPlayer() and attacker:InVehicle() ) then
            weaponName = attacker:GetVehicle():GetClass()
        end
    end

    self:SendLog(Color(255, 0, 0), self:FormatPlayer(ply) .. " was killed by " .. attackerName .. " using " .. weaponName)
end

function MODULE:EntityTakeDamage(ent, dmginfo)
    if ( !IsValid(ent) or !ent:IsPlayer() ) then return end

    local attacker = dmginfo:GetAttacker()
    if ( !IsValid(attacker) or !attacker:IsPlayer() ) then return end

    self:SendLog(Color(255, 150, 0), self:FormatPlayer(ent) .. " took " .. dmginfo:GetDamage() .. " damage from " .. self:FormatPlayer(attacker))
end

function MODULE:PlayerInitialSpawn(ply)
    self:SendLog(self:FormatPlayer(ply) .. " connected")
end

function MODULE:PlayerDisconnected(ply)
    self:SendLog(self:FormatPlayer(ply) .. " disconnected")
end

function MODULE:PlayerSay(ply, text)
    self:SendLog(self:FormatPlayer(ply) .. " said: " .. text)
end

function MODULE:PlayerSpawn(ply)
    self:SendLog(self:FormatPlayer(ply) .. " spawned")
end