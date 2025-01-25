ow.options = {}
ow.options.stored = {}

function ow.options:Register(uniqueID, optionData)
    self.stored[uniqueID] = optionData
end

function ow.options:Get(uniqueID)
    return self.stored[uniqueID]
end