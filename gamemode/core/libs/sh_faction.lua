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
    CanSwitchTo = nil,
    OnSwitch = nil
}

local metaFaction = {
    GetName = function(self)
        return self.Name or "Unknown Faction"
    end,
    GetDescription = function(self)
        return self.Description or "No description available."
    end,
    GetModels = function(self)
        return self.Models or DEFAULT_MODELS
    end,
}

metaFaction.__index = metaFaction

function ow.faction:Register(factionData)
    local FACTION = setmetatable(factionData, { __index = metaFaction })

    for k, v in pairs(default) do
        if ( FACTION[k] == nil ) then
            FACTION[k] = v
        end
    end


    local bResult = hook.Run("PreFactionRegistered", FACTION)
    if ( bResult == false ) then return false end

    local uniqueID = string.lower(string.gsub(FACTION.Name, "%s", "_"))
    FACTION.UniqueID = FACTION.UniqueID or uniqueID

    self.stored[FACTION.UniqueID] = FACTION
    self.instances[#self.instances + 1] = FACTION

    FACTION.Index = #self.instances

    FACTION["GetName"] = function(self)
        return self.Name
    end

    team.SetUp(FACTION.Index, FACTION.Name, FACTION.Color, false)
    hook.Run("PostFactionRegistered", FACTION)

    return FACTION.Index
end

function ow.faction:Get(identifier)
    if ( self.stored[identifier] ) then
        return self.stored[identifier]
    end

    if ( isnumber(identifier) ) then
        print("Getting faction by index: " .. identifier)
        return self.instances[identifier]
    end

    for k, v in ipairs(self.instances) do
        if ( ow.util:FindString(v.Name, identifier) or ow.util:FindString(v.UniqueID, identifier) ) then
            return v
        end
    end

    return nil
end

function ow.faction:CanSwitchTo(ply, factionID)
    if ( !IsValid(ply) ) then return false end

    local faction = self:Get(factionID)
    if ( !faction ) then return false end

    local oldFaction = self:Get(ply:Team())
    if ( oldFaction ) then
        if ( oldFaction.Index == faction.Index ) then return false end

        if ( oldFaction.CanLeave and !oldFaction:CanLeave(ply) ) then
            return false
        end
    end

    local hookRun = hook.Run("CanPlayerBecomeFaction", ply, factionID)
    if ( hookRun != nil and hookRun == false ) then return false end

    if ( faction.CanSwitchTo and !faction:CanSwitchTo(ply) ) then
        return false
    end

    if ( !faction.IsDefault and !ply:HasWhitelist(faction.UniqueID) ) then
        return false
    end

    return true
end

function ow.faction:GetAll()
    return self.instances
end