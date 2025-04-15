--- Item library
-- @module ow.item

ow.item = ow.item or {}
ow.item.stored = ow.item.stored or {}
ow.item.instances = ow.item.instances or {}
ow.item.bases = ow.item.bases or {}

function ow.item:Register(uniqueID, itemData)
    local bResult = hook.Run("PreItemRegistered", uniqueID, itemData)
    if ( bResult == false ) then return false end

    local ITEM = {}

    -- TODO: Add Inheritance Support in Future

    ITEM.Name = itemData.Name or "Unknown Item"
    ITEM.Description = itemData.Description or "No description provided."

    ITEM.Model = itemData.Model or Model("models/props_junk/watermelon01.mdl")
    util.PrecacheModel(itemData.Model)

    ITEM.Stackable = itemData.Stackable or false
    ITEM.MaxStack = itemData.MaxStack or 1
    ITEM.Weight = itemData.Weight or 1
    ITEM.Category = itemData.Category or "Miscellaneous"

    self.stored[uniqueID] = ITEM
    hook.Run("PostItemRegistered", uniqueID, itemData)
end

function ow.item:Get(identifier)
    if ( isstring(identifier) ) then
        return self.stored[identifier]
    elseif ( isnumber(identifier) ) then
        return self.instances[identifier]
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