local MODULE = MODULE

function MODULE:DoPlayerDeath(client, attacker, dmginfo)
    if ( !IsValid(client) ) then return end

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

    self:Send(ow.color:Get("red"), self:FormatPlayer(client) .. " was killed by " .. attackerName .. " using " .. weaponName)
end

function MODULE:EntityTakeDamage(ent, dmginfo)
    if ( !IsValid(ent) or !ent:IsPlayer() ) then return end

    local attacker = dmginfo:GetAttacker()
    if ( !IsValid(attacker) ) then return end

    self:Send(ow.color:Get("orange"), self:FormatPlayer(ent) .. " took " .. dmginfo:GetDamage() .. " damage from " .. self:FormatEntity(attacker))
end

function MODULE:PlayerInitialSpawn(client)
    self:Send(self:FormatPlayer(client) .. " connected")
end

function MODULE:PlayerDisconnected(client)
    self:Send(self:FormatPlayer(client) .. " disconnected")
end

function MODULE:PlayerSay(client, text)
    self:Send(self:FormatPlayer(client) .. " said: " .. text)
end

function MODULE:PlayerSpawn(client)
    self:Send(self:FormatPlayer(client) .. " spawned")
end

function MODULE:PlayerSpawnedProp(client, model, entity)
    self:Send(self:FormatPlayer(client) .. " spawned a prop (" .. self:FormatEntity(entity) .. ")")
end

function MODULE:PlayerSpawnedSENT(client, model, entity)
    self:Send(self:FormatPlayer(client) .. " spawned a SENT (" .. self:FormatEntity(entity) .. ")")
end

function MODULE:PlayerSpawnedRagdoll(client, model, entity)
    self:Send(self:FormatPlayer(client) .. " spawned a ragdoll (" .. self:FormatEntity(entity) .. ")")
end

function MODULE:PlayerSpawnedVehicle(client, model, entity)
    self:Send(self:FormatPlayer(client) .. " spawned a vehicle (" .. self:FormatEntity(entity) .. ")")
end

function MODULE:PlayerSpawnedEffect(client, model, entity)
    self:Send(self:FormatPlayer(client) .. " spawned an effect (" .. self:FormatEntity(entity) .. ")")
end

function MODULE:PlayerSpawnedNPC(client, model, entity)
    self:Send(self:FormatPlayer(client) .. " spawned an NPC (" .. self:FormatEntity(entity) .. ")")
end

function MODULE:PlayerSpawnedSWEP(client, model, entity)
    self:Send(self:FormatPlayer(client) .. " spawned a SWEP (" .. self:FormatEntity(entity) .. ")")
end

MODULE.PlayerGiveSWEP = MODULE.PlayerSpawnedSWEP

function MODULE:PostPlayerConfigChanged(client, key, value, oldValue)
    if ( key == "logging" ) then
        if ( value == true ) then
            self:Send(ow.color:Get("green"), self:FormatPlayer(client) .. " enabled logging")
        else
            self:Send(ow.color:Get("red"), self:FormatPlayer(client) .. " disabled logging")
        end
    else
        self:Send(ow.color:Get("yellow"), self:FormatPlayer(client) .. " changed config \"" .. key .. "\" from \"" .. tostring(oldValue) .. "\" to \"" .. tostring(value) .. "\"")
    end
end

function MODULE:PostPlayerConfigReset(client, key)
    self:Send(ow.color:Get("yellow"), self:FormatPlayer(client) .. " reset config \"" .. key .. "\"")
end