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

function ow.inventory:CreateObject(inventoryID, data)
    if ( !inventoryID or !data ) then return end

    inventoryID = tonumber(inventoryID)

    local inventory = setmetatable({}, self.meta)
    inventory.ID = inventoryID
    inventory.CharacterID = tonumber(data.CharacterID) or data.character_id or 0
    inventory.Receivers = data.Receivers or data.receivers or {}
    inventory.Name = data.Name or data.name or "Inventory"
    inventory.MaxWeight = tonumber(data.MaxWeight) or data.max_weight or ow.config:Get("inventory.maxweight", 20)
    inventory.Items = data.Items or util.JSONToTable(data.items or "[]") or {}
    inventory.Data = data.Data or util.JSONToTable(data.data or "[]") or {}

    self.stored[inventoryID] = inventory

    return inventory
end

function ow.inventory:AddItem(itemID, uniqueID, data)
    if ( !itemID or !uniqueID ) then return end

    local item = ow.item:Get(itemID)
    if ( !item ) then return end

    table.insert(self.items, itemID)

    item:SetInventory(self.id)
end