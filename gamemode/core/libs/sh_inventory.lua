--- Inventory library
-- @module ow.inventory

ow.inventory = ow.inventory or {}
ow.inventory.meta = ow.inventory.meta or {}
ow.inventory.stored = ow.inventory.stored or {}

--- Returns a specific inventory by its index.
-- @realm shared
-- @tparam number index The index of the inventory to retrieve.
-- @treturn table The inventory object.
function ow.inventory:Get(index)
    return self.stored[index]
end

--- Returns all stored inventories in the system.
-- @realm shared
-- @treturn table A table containing all stored inventories.
function ow.inventory:GetAll()
    return self.stored
end

--- Returns all inventories for a given character ID.
-- @realm shared
-- @tparam number characterID The character ID to search for.
-- @treturn table A sequential table containing all inventories for the given character ID.
function ow.inventory:GetByCharacterID(characterID)
    local inventories = {}
    for k, v in pairs(self.stored) do
        if ( v:GetOwner() == characterID ) then
            table.insert(inventories, v)
            print("Found inventory for character ID " .. characterID .. ": " .. v:GetID())
        end
    end

    return inventories
end

local function ConvertTable(tbl)
    if ( !tbl ) then return {} end

    if ( isstring(tbl) ) then
        if ( tbl == "" or tbl == "[]" ) then return {} end

        tbl = util.JSONToTable(tbl) or {}
    end

    return tbl
end

function ow.inventory:CreateObject(data)
    print(data)
    if ( !data or !istable(data) ) then print("Invalid data for inventory object") return end

    local id = tonumber(data.ID) or tonumber(data.id) or 0
    local characterID = tonumber(data.CharacterID) or tonumber(data.character_id) or 0
    local receivers
    if ( data.Receivers ) then
        receivers = ConvertTable(data.Receivers)
    elseif ( data.receivers ) then
        receivers = ConvertTable(data.receivers)
    else
        receivers = {}
    end

    local name = data.Name or data.name or "Inventory"
    local maxWeight = tonumber(data.MaxWeight) or tonumber(data.max_weight) or ow.config:Get("inventory.maxweight", 20)
    local items
    if ( data.Items ) then
        items = ConvertTable(data.Items)
    elseif ( data.items ) then
        items = ConvertTable(data.items)
    else
        items = {}
    end

    local inventoryData
    if ( data.Data ) then
        inventoryData = ConvertTable(data.Data)
    elseif ( data.data ) then
        inventoryData = ConvertTable(data.data)
    else
        inventoryData = {}
    end

    local inventory = setmetatable({}, self.meta)
    inventory.ID = id
    inventory.CharacterID = characterID
    inventory.Receivers = receivers
    inventory.Name = name
    inventory.MaxWeight = maxWeight
    inventory.Items = items
    inventory.Data = inventoryData

    self.stored[id] = inventory

    return inventory
end

function ow.inventory:AddItem(itemID, uniqueID, data)
    if ( !itemID or !uniqueID ) then return end

    local item = ow.item:Get(itemID)
    if ( !item ) then return end

    table.insert(self.items, itemID)

    item:SetInventory(self.id)
end