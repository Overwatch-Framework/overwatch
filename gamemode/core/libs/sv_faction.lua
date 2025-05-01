--- Faction library
-- @module ow.faction

function ow.faction:Join(ply, factionID, bBypass)
    local faction = self:Get(factionID)
    if ( faction == nil or !istable(faction) ) then
        ow.util:PrintError("Attempted to join an invalid faction!")
        return false
    end

    if ( !bBypass and !self:CanSwitchTo(ply, factionID) ) then
        return false
    end

    local oldFaction = self:Get(ply:Team())
    if ( oldFaction.OnLeave ) then
        oldFaction:OnLeave(ply)
    end

    ply:SetTeam(faction:GetID())

    if ( faction.OnJoin ) then
        faction:OnJoin(ply)
    end

    hook.Run("PlayerJoinedFaction", ply, factionID, oldFaction.GetID and oldFaction:GetID())
    return true
end