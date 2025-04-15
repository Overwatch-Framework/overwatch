--- Item library
-- @module ow.item

ow.item = ow.item or {}
ow.item.stored = ow.item.stored or {}
ow.item.instances = ow.item.instances or {}
ow.item.bases = ow.item.bases or {}

function ow.item:Register(uniqueID, itemData)
    local bResult = hook.Run("PreItemRegistered", uniqueID, itemData)
    if ( bResult == false ) then return false end

    if ( istable(itemData.base) ) then
        for _, base in ipairs(itemData.base) do
            local baseData = ow.item.bases[base]
            if ( istable(baseData) ) then
                itemData = table.Inherit(itemData, baseData)
            end
        end
    elseif ( isstring(itemData.base) ) then
        local baseData = ow.item.bases[itemData.base]
        if ( istable(baseData) ) then
            itemData = table.Inherit(itemData, baseData)
        end
    end

    itemData.Name = itemData.Name or "Unknown Item"
    itemData.Description = itemData.Description or "No description provided."

    itemData.Model = itemData.Model or Model("models/props_junk/watermelon01.mdl")
    util.PrecacheModel(itemData.Model)

    itemData.Stackable = itemData.Stackable or false
    itemData.MaxStack = itemData.MaxStack or 1
    itemData.Weight = itemData.Weight or 1
    itemData.Category = itemData.Category or "Miscellaneous"

    hook.Run("PostItemRegistered", uniqueID, itemData)

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
    return self.stored
end

if ( CLIENT ) then
    function ow.item:Add(uniqueID, data, callback)
        -- Do networking for the inventory in the future here...
        -- For now, we'll just pretend we added the item.

        LocalPlayer():ChatPrint("Added item: " .. uniqueID)
    end
end