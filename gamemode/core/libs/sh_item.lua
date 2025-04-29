--- Item library
-- @module ow.item

ow.item = ow.item or {}
ow.item.meta = ow.item.meta or {}
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

    -- TODO: Add Inheritance Support in Future

    for _, field in ipairs(requiredFields) do
        if ( itemData[field] == nil ) then
            ow.util:PrintError("Item \"" .. uniqueID .. "\" is missing required field \"" .. field .. "\"!\n")
            return false
        end
    end

    itemData.Weight = itemData.Weight or 0
    itemData.Category = itemData.Category or "Miscellaneous"

    itemData.Functions = itemData.Functions or {}
    itemData.Functions.Drop = itemData.Functions.Drop or {
        Name = "Drop",
        OnRun = function(item)
            -- TODO: Yeah yeah, this
        end,
        OnCanRun = function(item)
        end
    }

    itemData.Functions.Take = itemData.Functions.Take or {
        Name = "Take",
        OnRun = function(item)
            -- TODO: Yeah yeah, this
        end,
        OnCanRun = function(item)
        end
    }

    self.stored[uniqueID] = itemData

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

function ow.item:GetInstances()
    return self.instances
end

function ow.item:CreateObject(itemID, uniqueID, data)
    if ( !itemID or !uniqueID or !self.stored[uniqueID] ) then return end
    if ( self.instances[itemID] ) then return self.instances[itemID] end

    local item = setmetatable({}, self.meta)
    item.ID = itemID
    item.UniqueID = uniqueID
    item.Data = data or {}

    local itemData = self.stored[uniqueID]

    for k, v in pairs(itemData) do
        if ( isfunction(v) ) then
            item[k] = v(item)
        else
            item[k] = v
        end
    end

    return item
end

if ( CLIENT ) then
    function ow.item:Add(itemID, inventoryID, uniqueID, data, callback)
        if ( !itemID or !uniqueID or !self.stored[uniqueID] ) then return end

        if ( !data ) then data = {} end

        local item = self:CreateObject(itemID, uniqueID, data)
        if ( !item ) then return end

        item.InventoryID = inventoryID
        item.CharacterID = ow.localClient:GetCharacterID()

        self.instances[itemID] = item

        local inventory = ow.inventory:Get(inventoryID)
        if ( inventory ) then
            local items = inventory:GetItems()
            if ( items and !table.HasValue(items, item.ID) ) then
                table.insert(items, item.ID)
            end
        end

        if ( callback ) then
            callback(itemID, data)
        end

        return item
    end
end