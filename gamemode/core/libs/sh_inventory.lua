ow.inventory = {}
ow.inventory.stored = {}

function ow.inventory.Get(index)
    return ow.inventory.stored[index] 
end

function ow.inventory.Register(invData)
    invData.index = #ow.inventory.stored + 1
    ow.inventory.stored[invData.index] = invData

    return invData.index
end