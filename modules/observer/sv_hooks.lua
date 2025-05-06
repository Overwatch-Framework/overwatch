local MODULE = MODULE

function MODULE:PlayerNoClip(ply, desiredState)
    if ( !hook.Run("CanPlayerObserve", ply, desiredState) ) then
        return false
    end

    if ( desiredState ) then
        ply:SetNoDraw(true)
        ply:DrawShadow(false)
        ply:SetNotSolid(true)
        ply:SetNoTarget(true)
    else
        ply:SetNoDraw(false)
        ply:DrawShadow(true)
        ply:SetNotSolid(false)
        ply:SetNoTarget(false)
    end

    hook.Run("OnPlayerObserver", ply, desiredState)
    return true
end

function MODULE:EntityTakeDamage(target, dmgInfo)
    if ( !IsValid(target) or !target:IsPlayer() ) then return end

    if ( CAMI.PlayerHasAccess(target, "Overwatch - Observer") and target:GetNoDraw() and target:GetMoveType() == MOVETYPE_NOCLIP ) then
        return true -- bloodycop: better than GodEnable imo.
    end
end

function MODULE:OnPlayerObserver(ply, state)
    local logging = ow.module:Get("logging")
    if ( logging ) then
        logging:Send(ply:Nick() .. " is now " .. (state and "observing" or "no longer observing") .. ".")
    end
end