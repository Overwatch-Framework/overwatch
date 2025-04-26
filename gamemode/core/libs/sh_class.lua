--- Class library
-- @module ow.class

ow.class = {}
ow.class.stored = {}
ow.class.instances = {}

local default = {
    Name = "Unknown",
    Description = "No description available.",
    IsDefault = false,
    CanSwitchTo = nil,
    OnSwitch = nil
}

function ow.class:Register(classData)
    if ( classData.faction == nil or !isnumber(classData.faction) ) then
        ow.util:PrintError("Attempted to register a class without a valid faction!")
        return false
    end

    local faction = ow.faction:Get(classData.faction)
    if ( faction == nil or !istable(faction) ) then
        ow.util:PrintError("Attempted to register a class for an invalid faction!")
        return false
    end

    for k, v in pairs(default) do
        if ( classData[k] == nil ) then
            classData[k] = v
        end
    end

    local bResult = hook.Run("PreClassRegistered", classData)
    if ( bResult == false ) then return false end

    local uniqueID = string.lower(string.gsub(classData.Name, "%s", "_"))
    classData.UniqueID = classData.UniqueID or uniqueID

    self.stored[classData.UniqueID] = classData
    self.instances[#self.instances + 1] = classData

    classData.Index = #self.instances

    hook.Run("PostClassRegistered", classData)

    faction.Classes = faction.Classes or {}
    faction.Classes[#faction.Classes + 1] = classData

    return classData.Index
end

function ow.class:Get(identifier)
    if ( !identifier ) then
        ow.util:PrintError("Attempted to get an invalid faction!")
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