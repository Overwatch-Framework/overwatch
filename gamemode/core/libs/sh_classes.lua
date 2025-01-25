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
    
    self.stored[classData.uniqueID] = classData
    self.instances[#self.instances + 1] = classData

    classData.index = #self.instances

    local faction = ow.faction:Get(classData.faction)
    if ( faction == nil ) then
        ow.util:PrintError("Attempted to register a class for an invalid faction!")
        return
    end

    faction.classes = faction.classes or {}
    faction.classes[#faction.classes + 1] = classData

    return classData.index
end