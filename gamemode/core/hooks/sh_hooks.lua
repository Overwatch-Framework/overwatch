function GM:CanDrive(ply, entity)
    return false 
end

function GM:OWFactionCanBecome(ply, factionID)
    return true
end

function GM:OWCanHandsPickup(ply, ent)
    return true
end

function GM:OWCanHandsPush(ply, ent)
    return true
end

function GM:OWGetHandsPushForce(ply)
    return 128
end

function GM:OWGetHandsReachDistance(ply)
    return 96
end

function GM:OWGetMaxHandsMass(ply)
    return 64
end