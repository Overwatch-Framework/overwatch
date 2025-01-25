ow.inventory = {}
ow.inventory.stored = {}

function ow.inventory:Get(index)
    return self.stored[index] 
end

function ow.inventory:Register(invData)
    invData.index = #self.stored + 1
    self.stored[invData.index] = invData

    return invData.index
end