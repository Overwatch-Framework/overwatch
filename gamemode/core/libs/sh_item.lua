-- Item management library.
-- @module ow.item

ow.item = ow.item or {}
ow.item.meta = ow.item.meta or {}
ow.item.stored = ow.item.stored or {}
ow.item.instances = ow.item.instances or {}

local ITEM = ow.item.meta
ITEM.__index = ITEM

local requiredFields = {
    "Name",
    "Description"
}

function ow.item:Register(uniqueID, itemData)
    if ( !uniqueID or !istable(itemData) ) then return false end

    local bResult = hook.Run("PreItemRegistered", uniqueID, itemData)
    if ( bResult == false ) then return false end

    for _, field in ipairs(requiredFields) do
        if ( itemData[field] == nil ) then
            ow.util:PrintError("Item '" .. uniqueID .. "' is missing required field '" .. field .. "'!")
            return false
        end
    end

    itemData.Weight = itemData.Weight or 0
    itemData.Category = itemData.Category or "Miscellaneous"

    itemData.Actions = itemData.Actions or {}
    itemData.Actions.Drop = itemData.Actions.Drop or {
        Name = "Drop",
        OnRun = function(_, item)
            item:Spawn(item:GetOwner())
        end,
        OnCanRun = function(_, item)
            return !IsValid(item:GetEntity())
        end
    }

    itemData.Actions.Take = itemData.Actions.Take or {
        Name = "Take",
        OnRun = function(_, item)
            local ply = ow.character:GetPlayerByCharacter(item:GetOwner())
            if ( !IsValid(ply) ) then return end

            local char = ow.character:Get(item:GetOwner())
            local inventoryMain = char and char:GetInventory()
            if ( !inventoryMain ) then return end

            local entity = item:GetEntity()
            if ( !IsValid(entity) ) then return end

            local weight = item:GetWeight()
            if ( inventoryMain:GetWeight() + weight > inventoryMain:GetMaxWeight() ) then
                ply:Notify("You cannot take this item, it is too heavy!")
                return
            end

            ow.item:Transfer(item:GetID(), 0, inventoryMain:GetID(), function(success)
                if ( success ) then
                    if ( item.OnTaken ) then
                        item:OnTaken(entity)
                    end

                    hook.Run("OnItemTaken", entity)
                    SafeRemoveEntity(entity)
                else
                    local ply = ow.character:GetPlayerByCharacter(item:GetOwner())
                    if ( IsValid(ply) ) then
                        ply:Notify("Failed to transfer item to inventory.")
                    end
                end
            end)
        end,
        OnCanRun = function(_, item)
            return true
        end
    }

    self.stored[uniqueID] = itemData

    hook.Run("PostItemRegistered", uniqueID, itemData)

    return true
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

function ow.item:CreateObject(data)
    if ( !istable(data) ) then return end

    local id = tonumber(data.ID or data.id)
    local uniqueID = data.UniqueID or data.unique_id
    local characterID = tonumber(data.CharacterID or data.character_id or 0)
    local inventoryID = tonumber(data.InventoryID or data.inventory_id or 0)
    local itemData = ow.util:SafeParseTable(data.Data or data.data)

    local base = self.stored[uniqueID]
    if ( !base ) then return end

    local item = setmetatable({}, self.meta)

    for k, v in pairs(base) do
        if ( k != "Actions" ) then
            item[k] = v
        end
    end

    item.ID = id
    item.UniqueID = uniqueID
    item.CharacterID = characterID
    item.InventoryID = inventoryID
    item.Data = itemData

    return item
end

-- client-side addition
if ( CLIENT ) then
    function ow.item:Add(itemID, inventoryID, uniqueID, data, callback)
        if ( !itemID or !uniqueID or !self.stored[uniqueID] ) then return end

        data = data or {}

        local item = self:CreateObject({
            ID = itemID,
            UniqueID = uniqueID,
            Data = data,
            InventoryID = inventoryID,
            CharacterID = ow.localClient and ow.localClient:GetCharacterID() or 0
        })

        if ( !item ) then return end

        self.instances[itemID] = item

        local inventory = ow.inventory:Get(inventoryID)
        if ( inventory ) then
            local items = inventory:GetItems()
            if ( !table.HasValue(items, itemID) ) then
                table.insert(items, itemID)
            end
        end

        if ( callback ) then
            callback(itemID, data)
        end

        return item
    end
end