--- Faction library
-- @module ow.faction

local DEFAULT_MODELS = {
    "models/player/group01/female_01.mdl",
    "models/player/group01/female_02.mdl",
    "models/player/group01/female_03.mdl",
    "models/player/group01/female_04.mdl",
    "models/player/group01/female_05.mdl",
    "models/player/group01/female_06.mdl",
    "models/player/group01/male_01.mdl",
    "models/player/group01/male_02.mdl",
    "models/player/group01/male_03.mdl",
    "models/player/group01/male_04.mdl",
    "models/player/group01/male_05.mdl",
    "models/player/group01/male_06.mdl",
    "models/player/group01/male_07.mdl",
    "models/player/group01/male_08.mdl",
    "models/player/group01/male_09.mdl"
}

ow.faction = {}
ow.faction.stored = {}
ow.faction.instances = {}

local default = {
    Name = "Unknown",
    Description = "No description available.",
    Models = DEFAULT_MODELS,
    IsDefault = false,
    Color = color_white,
    CanSwitchTo = nil
    OnSwitch = nil
}

function ow.faction:Register(factionData)
    for k, v in pairs(default) do
        if ( factionData[k] == nil ) then
            factionData[k] = v
        end
    end

    local uniqueID = string.lower(string.gsub(factionData.Name, "%s", "_"))
    factionData.UniqueID = factionData.UniqueID or uniqueID

    self.stored[uniqueID] = factionData
    self.instances[#self.instances + 1] = factionData

    factionData.Index = #self.instances

    team.SetUp(factionData.Index, factionData.Name, factionData.Color, false)
    return factionData.Index
end

function ow.faction:Get(identifier)
    if ( !identifier ) then
        return ow.util:PrintError("Attempted to get an invalid faction!")
    end

    if ( self.stored[identifier] ) then
        return self.stored[identifier]
    end

    if ( isnumber(identifier) ) then
        return self.instances[identifier]
    end

    for k, v in ipairs(self.instances) do
        if ( ow.util:FindString(v.Name, identifier) or ow.util:FindString(v.UniqueID, identifier) ) then
            return v
        end
    end
end

function ow.faction:CanSwitchTo(ply, factionID)
    local faction = self:Get(factionID)
    if ( !faction ) then return false end

    local hookRun = hook.Run("CanPlayerBecomeFaction", ply, factionID)
    if ( hookRun != nil and hookRun == false ) then return false end

    if ( faction.CanSwitchTo and !faction:CanSwitchTo(ply) ) then
        return false
    end

    if ( !faction.IsDefault ) then return false end

    return true
end