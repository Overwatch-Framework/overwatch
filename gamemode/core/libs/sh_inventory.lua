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

function ow.inventory:AddItem(inventoryID, itemID, uniqueID, data)
    if ( !inventoryID or !itemID or !uniqueID ) then return end

    local item = ow.item:Get(itemID)
    if ( !item ) then return end

    local inventory = self:Get(inventoryID)
    if ( !inventory ) then return end

    local receivers = inventory:GetReceivers()
    if ( !receivers or !istable(receivers) ) then receivers = {} end

    local items = inventory:GetItems()
    if ( !items or !istable(items) ) then items = {} end

    if ( !table.HasValue(items, itemID) ) then
        table.insert(items, itemID)
    end

    item:SetInventory(inventoryID)

    if ( SERVER ) then
        data = data or {}

        ow.sqlite:Update("ow_items", {
            inventory_id = inventoryID,
            data = util.TableToJSON(data)
        }, "id = " .. itemID)

        net.Start("ow.inventory.item.add")
            net.WriteUInt(inventoryID, 32)
            net.WriteUInt(itemID, 32)
            net.WriteString(uniqueID)
            net.WriteTable(data)
        net.Send(receivers or {})
    end
end

function ow.inventory:RemoveItem(inventoryID, itemID)
    if ( !inventoryID or !itemID ) then return end

    local item = ow.item:Get(itemID)
    if ( !item ) then return end

    item:SetInventory(0)

    local inventory = self:Get(inventoryID)
    if ( inventory ) then
        local items = inventory:GetItems()
        if ( items and table.HasValue(items, itemID) ) then
            table.RemoveByValue(items, itemID)
        end
    end

    local receivers = inventory:GetReceivers()
    if ( !receivers or !istable(receivers) ) then receivers = {} end

    if ( item:GetOwner() == ow.localClient:GetCharacterID() ) then
        net.Start("ow.inventory.item.remove")
            net.WriteUInt(inventoryID, 32)
            net.WriteUInt(itemID, 32)
        net.Send(receivers or {})
    end

    if ( SERVER ) then
        ow.sqlite:Update("ow_items", {
            inventory_id = 0
        }, "id = " .. itemID)
    end
end

function ow.inventory:HasItem(itemID)
    if ( !itemID ) then return false end

    local item = ow.item:Get(itemID)
    if ( !item ) then return false end

    return table.HasValue(self.items, itemID)
end

function ow.inventory:SetName(inventoryID, name)
    if ( !inventoryID or !name ) then return end

    local inventory = self:Get(inventoryID)
    if ( !inventory ) then return end

    inventory.Name = name

    if ( SERVER ) then
        ow.sqlite:Update("ow_inventories", {
            name = name
        }, "id = " .. inventoryID)
    end

    return inventory
end