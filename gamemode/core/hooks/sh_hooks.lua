function GM:CanDrive(ply, entity)
    return false 
end

function GM:CanBecomeFaction(ply, factionID)
    return true
end

function GM:CanHandsPickup(ply, ent)
    return true
end

function GM:CanHandsPush(ply, ent)
    return true
end

function GM:GetHandsPushForce(ply)
    return 128
end

function GM:GetHandsReachDistance(ply)
    return 96
end

function GM:GetHandsMaxMass(ply)
    return 64
end