--- Class library
-- @module ow.class

ow.class = {}
ow.class.stored = {}
ow.class.instances = {}

function ow.class:Register(classData)
    if ( classData.faction == nil or !isnumber(classData.faction) ) then
        ow.util:PrintError("Attempted to register a class without a valid faction!")
        return
    end

    local faction = ow.faction:Get(classData.faction)
    if ( faction == nil ) then
        ow.util:PrintError("Attempted to register a class for an invalid faction!")
        return
    end

    local uniqueID = string.lower(string.gsub(classData.Name, "%s", "_"))
    classData.UniqueID = uniqueID

    classData.Name = classData.Name or "Unknown Faction"
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