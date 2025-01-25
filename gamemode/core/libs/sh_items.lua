ow.item = {}
ow.item.stored = {}
ow.item.instances = {}

function ow.item:Register(uniqueID, itemData)
    self.instances[#self.stored + 1] = itemData
    self.stored[uniqueID] = itemData
end

function ow.item:Get(look)
    if ( isstring(look) ) then
        return self.stored[look]
    elseif ( isnumber(look) ) then
        return self.instances[look]
    end

    return nil
end