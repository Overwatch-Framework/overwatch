function GM:CanDrive(ply, entity)
    return false 
end

function GM:CanPlayerBecomeFaction(ply, factionID)
    return true
end

function GM:CanPlayerHandsPickup(ply, ent)
    return true
end

function GM:CanPlayerHandsPush(ply, ent)
    return true
end

function GM:GetPlayerHandsPushForce(ply)
    return 128
end

function GM:GetPlayerHandsReachDistance(ply)
    return 96
end

function GM:GetPlayerHandsMaxMass(ply)
    return 64
end

function GM:GetFrameworkColor()
    return ow.config.color or Color(0, 100, 150)
end