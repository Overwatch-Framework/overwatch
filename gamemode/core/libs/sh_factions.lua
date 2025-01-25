ow.faction = {}
ow.faction.stored = {}
ow.faction.instances = {}

function ow.faction:Register(uniqueID, factionData)
    self.stored[uniqueID] = factionData
    self.instances[#self.instances + 1] = factionData

    factionData.index = #self.instances

    team.SetUp(factionData.index, factionData.name, factionData.color, false)
    return factionData.index
end

function ow.faction:Get(factionID)
    return self.stored[factionID]
end