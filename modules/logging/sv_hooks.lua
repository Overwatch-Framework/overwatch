local MODULE = MODULE

function MODULE:DoPlayerDeath(ply, attacker, dmginfo)
    if ( !IsValid(ply) ) then return end

    local attackerName = "world"
    local weaponName = "world"

    if ( IsValid(attacker) ) then
        if ( attacker:IsPlayer() ) then
            attackerName = self:FormatPlayer(attacker)
        else
            attackerName = attacker:GetClass()
        end

        if ( attacker.GetActiveWeapon and IsValid(attacker:GetActiveWeapon()) ) then
            weaponName = attacker:GetActiveWeapon():GetClass()
        elseif ( attacker:IsPlayer() and attacker:InVehicle() ) then
            weaponName = attacker:GetVehicle():GetClass()
        end
    end

    self:SendLog(ow.color:Get("red"), self:FormatPlayer(ply) .. " was killed by " .. attackerName .. " using " .. weaponName)
end

function MODULE:EntityTakeDamage(ent, dmginfo)
    if ( !IsValid(ent) or !ent:IsPlayer() ) then return end

    local attacker = dmginfo:GetAttacker()
    if ( !IsValid(attacker) ) then return end

    self:SendLog(ow.color:Get("orange"), self:FormatPlayer(ent) .. " took " .. dmginfo:GetDamage() .. " damage from " .. self:FormatEntity(attacker))
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

function MODULE:PlayerSpawnedProp(ply, model, entity)
    self:SendLog(self:FormatPlayer(ply) .. " spawned a prop (" .. self:FormatEntity(entity) .. ")")
end

function MODULE:PlayerSpawnedSENT(ply, model, entity)
    self:SendLog(self:FormatPlayer(ply) .. " spawned a SENT (" .. self:FormatEntity(entity) .. ")")
end

function MODULE:PlayerSpawnedRagdoll(ply, model, entity)
    self:SendLog(self:FormatPlayer(ply) .. " spawned a ragdoll (" .. self:FormatEntity(entity) .. ")")
end

function MODULE:PlayerSpawnedVehicle(ply, model, entity)
    self:SendLog(self:FormatPlayer(ply) .. " spawned a vehicle (" .. self:FormatEntity(entity) .. ")")
end

function MODULE:PlayerSpawnedEffect(ply, model, entity)
    self:SendLog(self:FormatPlayer(ply) .. " spawned an effect (" .. self:FormatEntity(entity) .. ")")
end

function MODULE:PlayerSpawnedNPC(ply, model, entity)
    self:SendLog(self:FormatPlayer(ply) .. " spawned an NPC (" .. self:FormatEntity(entity) .. ")")
end

function MODULE:PlayerSpawnedSWEP(ply, model, entity)
    self:SendLog(self:FormatPlayer(ply) .. " spawned a SWEP (" .. self:FormatEntity(entity) .. ")")
end

MODULE.PlayerGiveSWEP = MODULE.PlayerSpawnedSWEP

function MODULE:PostPlayerConfigChanged(ply, key, value, oldValue)
    if ( key == "logging" ) then
        if ( value == true ) then
            self:SendLog(ow.color:Get("green"), self:FormatPlayer(ply) .. " enabled logging")
        else
            self:SendLog(ow.color:Get("red"), self:FormatPlayer(ply) .. " disabled logging")
        end
    else
        self:SendLog(ow.color:Get("yellow"), self:FormatPlayer(ply) .. " changed config " .. key .. " from " .. tostring(oldValue) .. " to " .. tostring(value))
    end
end