ow.faction = {}
ow.faction.stored = {}
ow.faction.instances = {}

function ow.faction.Register(factionData)
    ow.faction.stored[factionData.uniqueID] = factionData
    ow.faction.instances[#ow.faction.instances + 1] = factionData

    team.SetUp(factionData.index, factionData.name, factionData.color, false)
    return factionData
end

function ow.faction.Get(factionID)
    return ow.faction.stored[factionID]
end