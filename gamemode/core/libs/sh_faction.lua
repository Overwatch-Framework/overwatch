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
ow.faction.meta = {
    GetName = function(self)
        return self.Name or "Unknown Faction"
    end,
    GetDescription = function(self)
        return self.Description or "No description available."
    end,
    GetModels = function(self)
        return self.Models or DEFAULT_MODELS
    end,
    GetColor = function(self)
        return self.Color or color_white
    end,
    GetID = function(self)
        return self.ID or 0
    end,
    GetUniqueID = function(self)
        return self.UniqueID or "unknown_faction"
    end,
    GetIsDefault = function(self)
        return self.IsDefault or false
    end,
    GetClasses = function(self)
        return self.Classes or {}
    end,

    __tostring = function(self)
        return "faction[" .. self:GetUniqueID() .. "][" .. self:GetID() .. "]"
    end,
    __eq = function(self, other)
        if ( isstring(other) ) then
            return self:GetUniqueID() == other
        end

        if ( isnumber(other) ) then
            return self:Get() == other
        end

        if ( type(other) == "Player" ) then
            return self:Get() == other:GetFaction()
        end

        return false
    end,
}

ow.faction.meta.__index = ow.faction.meta

local default = {
    Name = "Unknown Faction",
    Description = "No description available.",
    Models = DEFAULT_MODELS,
    IsDefault = false,
    Color = color_white,
    Classes = {},
}

function ow.faction:Register(factionData)
    local FACTION = setmetatable(factionData, { __index = ow.faction.meta })

    for k, v in pairs(default) do
        if ( FACTION[k] == nil ) then
            FACTION[k] = v
        end
    end

    local bResult = hook.Run("PreFactionRegistered", FACTION)
    if ( bResult == false ) then return false end

    local uniqueID = string.lower(string.gsub(FACTION.Name, "%s+", "_"))
    FACTION.UniqueID = FACTION.UniqueID or uniqueID

    self.stored[FACTION.UniqueID] = FACTION
    self.instances[#self.instances + 1] = FACTION

    FACTION.ID = #self.instances

    team.SetUp(FACTION.ID, FACTION.Name, FACTION.Color, false)
    hook.Run("PostFactionRegistered", FACTION)

    return FACTION.ID
end

function ow.faction:Get(identifier)
    if ( identifier == nil ) then
        ow.util:PrintError("Attempted to get a faction without an identifier!")
        return false, "Attempted to get a faction without an identifier!"
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

    return nil
end

function ow.faction:CanSwitchTo(client, factionID, oldFactionID)
    if ( !IsValid(client) ) then return false end

    local faction = self:Get(factionID)
    if ( !faction ) then return false end

    if ( oldFactionID ) then
        local oldFaction = self:Get(oldFactionID)
        if ( oldFaction ) then
            if ( oldFaction.ID == faction.ID ) then return false end

            if ( oldFaction.CanLeave and !oldFaction:CanLeave(client) ) then
                return false
            end
        end
    end

    local hookRun = hook.Run("CanPlayerJoinFaction", client, factionID)
    if ( hookRun != nil and hookRun == false ) then return false end

    if ( faction.CanSwitchTo and !faction:CanSwitchTo(client) ) then
        return false
    end

    if ( !faction.IsDefault and !client:HasWhitelist(faction.UniqueID) ) then
        return false
    end

    return true
end

function ow.faction:GetAll()
    return self.instances
end