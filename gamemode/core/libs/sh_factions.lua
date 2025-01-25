ow.faction = {}
ow.faction.stored = {}
ow.faction.instances = {}

function ow.faction:Register(factionData)
    self.stored[factionData.uniqueID] = factionData
    self.instances[#self.instances + 1] = factionData

    team.SetUp(factionData.index, factionData.name, factionData.color, false)
    return factionData
end

function ow.faction:Get(factionID)
    return self.stored[factionID]
end