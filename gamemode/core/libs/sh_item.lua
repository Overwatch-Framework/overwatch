--- Item library
-- @module ow.item

ow.item = ow.item or {}
ow.item.stored = ow.item.stored or {}
ow.item.instances = ow.item.instances or {}
ow.item.bases = ow.item.bases or {}

local requiredFields = {
    "Name",
    "Description",
}

-- TODO: Base Items support
function ow.item:Register(uniqueID, itemData)
    local bResult = hook.Run("PreItemRegistered", uniqueID, itemData)
    if ( bResult == false ) then return false end

    local ITEM = {}

    -- TODO: Add Inheritance Support in Future

    ITEM = table.Copy(itemData)
    for _, field in ipairs(requiredFields) do
        if ( ITEM[field] == nil ) then
            ow.util:PrintError("Item \"" .. uniqueID .. "\" is missing required field \"" .. field .. "\"!\n")
            return false
        end
    end

    ITEM.Weight = ITEM.Weight or 0
    ITEM.Category = ITEM.Category or "Miscellaneous"

    ITEM.functions = ITEM.functions or {}
    ITEM.functions.drop = ITEM.functions.drop or {
        Name = "Drop",
        OnRun = function(item)
            -- TODO: Yeah yeah, this
        end,
        OnCanRun = function(item)
        end
    }

    ITEM.functions.take = ITEM.functions.take or {
        Name = "Take",
        OnRun = function(item)
            -- TODO: Yeah yeah, this
        end,
        OnCanRun = function(item)
        end
    }

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