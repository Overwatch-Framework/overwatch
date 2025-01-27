--- Item library
-- @module ow.item

ow.item = ow.item or {}
ow.item.stored = ow.item.stored or {}
ow.item.instances = ow.item.instances or {}

function ow.item:Register(uniqueID, itemData)
    itemData.Name = itemData.Name or "Unknown Item"
    itemData.Description = itemData.Description or "No description provided."

    itemData.Model = itemData.Model or "models/props_junk/watermelon01.mdl"
    util.PrecacheModel(itemData.Model)

    itemData.Stackable = itemData.Stackable or false
    itemData.MaxStack = itemData.MaxStack or 1
    itemData.Weight = itemData.Weight or 1
    itemData.Category = itemData.Category or "Miscellaneous"

    self.instances[#self.instances + 1] = itemData
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

function ow.item:GetAll()
    return self.instances
end

if ( CLIENT ) then
    function ow.item:Add(uniqueID, data, callback)
        -- Do networking for the inventory in the future here...
        -- For now, we'll just pretend we added the item.

        LocalPlayer():ChatPrint("Added item: " .. uniqueID)
    end
end