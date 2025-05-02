-- Inventory management library.
-- @module ow.inventory

ow.inventory = ow.inventory or {}
ow.inventory.meta = ow.inventory.meta or {}
ow.inventory.stored = ow.inventory.stored or {}

-- Create an inventory object
function ow.inventory:CreateObject(data)
    if ( !data or !istable(data) ) then
        ow.util:PrintError("Invalid data passed to CreateObject")
        return
    end

    local inventory = setmetatable({}, self.meta)

    inventory.ID = tonumber(data.ID or data.id or 0)
    inventory.CharacterID = tonumber(data.CharacterID or data.character_id or 0)
    inventory.Name = data.Name or data.name or "Inventory"
    inventory.MaxWeight = tonumber(data.MaxWeight or data.max_weight) or ow.config:Get("inventory.maxweight", 20)
    inventory.Items = ow.util:SafeParseTable(data.Items or data.items)
    inventory.Data = ow.util:SafeParseTable(data.Data or data.data)
    inventory.Receivers = ow.util:SafeParseTable(data.Receivers or data.receivers)

    self.stored[inventory.ID] = inventory

    return inventory
end

function ow.inventory:Get(index)
    return self.stored[index]
end

function ow.inventory:GetAll()
    return self.stored
end

function ow.inventory:GetByCharacterID(characterID)
    local inventories = {}

    for _, inv in pairs(self.stored) do
        if ( inv:GetOwner() == characterID ) then
            table.insert(inventories, inv)
        end
    end

    return inventories
end