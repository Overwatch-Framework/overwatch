--- Class library
-- @module ow.class

ow.class = {}
ow.class.stored = {}
ow.class.instances = {}

ow.class.meta = {
    GetName = function(self)
        return self.Name or "Unknown Class"
    end,
    GetDescription = function(self)
        return self.Description or "No description available."
    end,
    GetID = function(self)
        return self.ID or 0
    end,
    GetUniqueID = function(self)
        return self.UniqueID or "unknown_class"
    end,
    GetIsDefault = function(self)
        return self.IsDefault or false
    end,
    GetFaction = function(self)
        return self.Faction or 0
    end,

    __tostring = function(self)
        return "class [" .. self:GetUniqueID() .. "][" .. self:GetID() .. "]"
    end,
    __eq = function(self, other)
        if ( isstring(other) ) then
            return self:GetUniqueID() == other
        end

        if ( isnumber(other) ) then
            return self:GetID() == other
        end

        if ( type(other) == "Player" ) then
            return self:GetID() == other:GetFaction()
        end

        return false
    end,
}

ow.class.meta.__index = ow.class.meta

local default = {
    Name = "Unknown",
    Description = "No description available.",
    IsDefault = false,
    CanSwitchTo = nil,
    OnSwitch = nil
}

function ow.class:Register(classData)
    local CLASS = setmetatable(classData, { __index = ow.class.meta })
    if ( !isnumber(CLASS.Faction) ) then
        ow.util:PrintError("Attempted to register a class without a valid faction!")
        return false
    end

    local faction = ow.faction:Get(CLASS.Faction)
    if ( faction == nil or !istable(faction) ) then
        ow.util:PrintError("Attempted to register a class for an invalid faction!")
        return false
    end

    for k, v in pairs(default) do
        if ( CLASS[k] == nil ) then
            CLASS[k] = v
        end
    end

    local bResult = hook.Run("PreClassRegistered", CLASS)
    if ( bResult == false ) then return false end

    local uniqueID = string.lower(string.gsub(CLASS.Name, "%s", "_"))
    CLASS.UniqueID = CLASS.UniqueID or uniqueID

    self.stored[CLASS.UniqueID] = CLASS
    self.instances[#self.instances + 1] = CLASS

    CLASS.ID = #self.instances

    hook.Run("PostClassRegistered", CLASS)

    faction.Classes = faction.Classes or {}
    faction.Classes[#faction.Classes + 1] = CLASS

    return CLASS.ID
end

function ow.class:Get(identifier)
    if ( identifier == nil ) then
        ow.util:PrintError("Attempted to get a faction with an invalid identifier!")
        return false
    end

    if ( tonumber(identifier) ) then
        return self.instances[identifier]
    end

    if ( self.stored[identifier] ) then
        return self.stored[identifier]
    end

    for k, v in ipairs(self.instances) do
        if ( ow.util:FindString(v.Name, identifier) or ow.util:FindString(v.UniqueID, identifier) ) then
            return v
        end
    end

    return nil
end

function ow.class:CanSwitchTo(ply, classID)
    local class = self:Get(classID)
    if ( !class ) then return false end

    local hookRun = hook.Run("PreClassBecome", ply, classID)
    if ( hookRun == false ) then return false end

    if ( isfunction(class.CanSwitchTo) and !class:CanSwitchTo(ply) ) then
        return false
    end

    if ( !class.IsDefault ) then
        return false
    end

    return true
end