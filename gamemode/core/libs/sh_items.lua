ow.items = {}
ow.items.stored = {}
ow.items.instances = ow.items.instances = {}

function ow.items.Register(itemData)
    ow.items.instances[#ow.items.stored + 1] = itemData
    ow.items.stored[itemData.uniqueID] = itemData
end

function ow.items.Get(look)
    if ( isstring(look) ) then
        return ow.items.stored[look]
    elseif ( isnumber(look) ) then
        return ow.items.instances[look]
    end

    return nil
end