--- Faction library
-- @module ow.faction

function ow.faction:Join(ply, factionID, bBypass)
    local faction = self:Get(factionID)
    if ( !faction ) then return ow.util:PrintError("Attempted to join an invalid faction!") end

    if ( !bBypass and !self:CanSwitchTo(ply, factionID) ) then
        return false
    end

    local oldFaction = self:Get(ply:Team())
    if ( oldFaction.OnLeave ) then
        oldFaction:OnLeave(ply)
    end

    ply:SetTeam(faction.Index)

    if ( faction.OnJoin ) then
        faction:OnJoin(ply)
    end

    hook.Run("PlayerJoinedFaction", ply, factionID, oldFaction.Index)
    return true
end