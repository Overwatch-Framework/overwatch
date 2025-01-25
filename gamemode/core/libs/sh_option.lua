--- Options library
-- @module ow.optio

ow.option = {}
ow.option.stored = {}

function ow.option:Register(uniqueID, optionData)
    self.stored[uniqueID] = optionData
end

function ow.option:Get(uniqueID)
    return self.stored[uniqueID]
end