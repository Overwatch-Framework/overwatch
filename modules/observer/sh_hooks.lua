local MODULE = MODULE

function MODULE:CanPlayerObserve(ply, state)
    if ( !CAMI.PlayerHasAccess(ply, "Overwatch - Observer") ) then return false end

    return true
end

if ( CLIENT ) then
    function MODULE:DrawPhysgunBeam(ply, physgun, enabled, target, physBone, hitPos)
        if ( CAMI.PlayerHasAccess(ply, "Overwatch - Observer") and ply:GetNoDraw() and ply:GetMoveType() == MOVETYPE_NOCLIP ) then
            return false
        end
    end

    function MODULE:HUDPaint()
        local ply = LocalPlayer()
        if ( !IsValid(ply) or !CAMI.PlayerHasAccess(ply, "Overwatch - Observer") 
        or !ply:Alive() or ply:GetMoveType() != MOVETYPE_NOCLIP or !ply:GetNoDraw() ) then return end
    end
end