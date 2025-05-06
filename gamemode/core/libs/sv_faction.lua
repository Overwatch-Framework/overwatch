--- Faction library
-- @module ow.faction

function ow.faction:Join(client, factionID, bBypass)
    local faction = self:Get(factionID)
    if ( faction == nil or !istable(faction) ) then
        ow.util:PrintError("Attempted to join an invalid faction!")
        return false
    end

    if ( !bBypass and !self:CanSwitchTo(client, factionID) ) then
        return false
    end

    local oldFaction = self:Get(client:Team())
    if ( oldFaction.OnLeave ) then
        oldFaction:OnLeave(client)
    end

    client:SetTeam(faction:GetID())

    if ( faction.OnJoin ) then
        faction:OnJoin(client)
    end

    hook.Run("PlayerJoinedFaction", client, factionID, oldFaction.GetID and oldFaction:GetID())
    return true
end