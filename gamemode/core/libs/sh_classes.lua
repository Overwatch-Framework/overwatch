--- Class library
-- @module ow.class

ow.class = {}
ow.class.stored = {}
ow.class.instances = {}

function ow.class:Register(classData)
    if ( classData.faction == nil or !isnumber(classData.faction) ) then
        return ow.util:PrintError("Attempted to register a class without a valid faction!")
    end

    local faction = ow.faction:Get(classData.faction)
    if ( faction == nil ) then
        return ow.util:PrintError("Attempted to register a class for an invalid faction!")
    end

    classData.Name = classData.Name or "Unknown Faction"

    local uniqueID = string.lower(string.gsub(classData.Name, "%s", "_"))
    classData.UniqueID = classData.UniqueID or uniqueID

    classData.Color = classData.Color or Color(255, 255, 255)
    classData.Description = classData.Description or "No description provided."
    classData.IsDefault = classData.IsDefault or false
    
    self.stored[uniqueID] = classData
    self.instances[#self.instances + 1] = classData

    classData.Index = #self.instances

    faction.Classes = faction.Classes or {}
    faction.Classes[#faction.Classes + 1] = classData

    return classData.Index
end

function ow.class:Get(identifier)
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

function ow.class:CanSwitchTo(ply, classID)
    local class = self:Get(classID)
    if ( !class ) then return false end

    local hookRun = hook.Run("OWClassCanBecome", ply, classID)
    if ( hookRun != nil and hookRun == false ) then return false end

    if ( class.CanSwitchTo and !class:CanSwitchTo(ply) ) then
        return false
    end

    if ( !class.IsDefault ) then return false end

    return true
end