local MODULE = MODULE

function MODULE:PlayerNoClip(client, desiredState)
    if ( !hook.Run("CanPlayerObserve", client, desiredState) ) then
        return false
    end

    if ( desiredState ) then
        client:SetNoDraw(true)
        client:DrawShadow(false)
        client:SetNotSolid(true)
        client:SetNoTarget(true)
    else
        client:SetNoDraw(false)
        client:DrawShadow(true)
        client:SetNotSolid(false)
        client:SetNoTarget(false)
    end

    hook.Run("OnPlayerObserver", client, desiredState)
    return true
end

function MODULE:EntityTakeDamage(target, dmgInfo)
    if ( !IsValid(target) or !target:IsPlayer() ) then return end

    if ( CAMI.PlayerHasAccess(target, "Overwatch - Observer") and target:GetNoDraw() and target:GetMoveType() == MOVETYPE_NOCLIP ) then
        return true
    end
end

function MODULE:OnPlayerObserver(client, state)
    local logging = ow.module:Get("logging")
    if ( logging ) then
        logging:Send(client:Nick() .. " is now " .. (state and "observing" or "no longer observing") .. ".")
    end
end