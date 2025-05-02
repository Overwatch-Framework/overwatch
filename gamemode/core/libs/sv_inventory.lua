--- Inventory library
-- @module ow.inventory

--- Registers a new inventory for a character.
-- @realm server
-- @param data A table containing inventory data. Must include `characterID`.
-- @return table|boolean The created inventory object or false if registration failed.
function ow.inventory:Register(data)
    if ( !data or !data.characterID ) then return end

    local bResult = hook.Run("PreInventoryRegistered", data)
    if ( bResult == false ) then return false end

    local id
    ow.sqlite:Insert("ow_inventories", {
        character_id = data.characterID,
        name = data.name or "Main",
        max_weight = data.maxWeight or ow.config:Get("inventory.maxweight", 20),
        data = util.TableToJSON(data.data or {})
    }, function(result)
        if ( !result ) then
            ErrorNoHalt("Failed to insert inventory into database for character " .. data.characterID .. "\n")
            return false
        end

        id = result
    end)

    if ( !id ) then
        ErrorNoHalt("Failed to register inventory: " .. data.name .. "\n")
        return false
    end

    local inventory = self:CreateObject(data)
    if ( !inventory ) then
        ErrorNoHalt("Failed to create inventory object for ID " .. id .. "\n")
        return false
    end

    self.stored[id] = inventory

    local result = ow.sqlite:Select("ow_characters", nil, "id = " .. data.characterID)
    if ( result ) then
        local inventories = util.JSONToTable(result.inventories or "[]") or {}
        if ( !table.HasValue(inventories, id) ) then
            table.insert(inventories, id)
        end

        ow.sqlite:Update("ow_characters", {
            inventories = util.TableToJSON(inventories)
        }, "id = " .. data.characterID)
    end

    local receivers = {}
    local owner = ow.character:GetPlayerByCharacter(inventory.characterID)
    if ( IsValid(owner) ) then
        table.insert(receivers, owner)
    end

    for k, v in pairs(inventory.receivers or {}) do
        local receiver = ow.character:GetPlayerByCharacter(v)
        if ( IsValid(receiver) ) then
            table.insert(receivers, receiver)
        end
    end

    net.Start("ow.inventory.register")
        net.WriteTable(inventory)
    net.Send(receivers)

    hook.Run("PostInventoryRegistered", inventory)

    return inventory
end

--- Synchronizes an inventory with specified receivers.
-- @realm server
-- @param inventoryID The ID of the inventory to sync.
-- @param receivers A table of players to sync the inventory with.
function ow.inventory:Sync(inventoryID, receivers)
    if ( !inventoryID or !receivers ) then return end

    local inventory = self:Get(inventoryID)
    if ( !inventory ) then return end

    for k, v in pairs(receivers) do
        if ( IsValid(v) ) then
            net.Start("ow.inventory.sync")
                net.WriteTable(inventory)
            net.Send(v)
        end
    end
end

--- Caches an inventory for a player.
-- @realm server
-- @param ply The player to cache the inventory for.
-- @param inventoryID The ID of the inventory to cache.
-- @return boolean True if caching was successful, false otherwise.
function ow.inventory:Cache(ply, inventoryID)
    if ( !IsValid(ply) or !ply:IsPlayer() ) then
        ErrorNoHalt("Attempted to cache character for invalid player (" .. tostring(ply) .. ")\n")
        return false
    end

    local result = ow.sqlite:Select("ow_inventories", nil, "id = " .. inventoryID)
    if ( !result ) then
        ErrorNoHalt("Failed to select inventory from database for character " .. inventoryID .. "\n")
        return false
    end

    result = result[1]

    local inventory = self:CreateObject(result)
    if ( !inventory ) then
        ErrorNoHalt("Failed to create inventory object for ID " .. inventoryID .. "\n")
        return false
    end

    self.stored[inventoryID] = inventory

    -- Update the inventory list in the character in the database
    local characterID = inventory.CharacterID
    if ( !characterID ) then
        ErrorNoHalt("Failed to get character ID for inventory " .. inventoryID .. "\n")
        return false
    end

    result = ow.sqlite:Select("ow_characters", nil, "id = " .. characterID)
    result = result[1]
    if ( result ) then
        local inventories = util.JSONToTable(result.inventories or "[]") or {}
        if ( !table.HasValue(inventories, inventoryID) ) then
            table.insert(inventories, inventoryID)
        end

        -- Update the character's inventories in the database
        ow.sqlite:Update("ow_characters", {
            inventories = util.TableToJSON(inventories)
        }, "id = " .. characterID)

        local character = ow.character:Get(characterID)
        if ( character ) then
            character:SetInventories(inventories)
        end
    end

    -- Search through the item database for this characterID and cache them
    ow.item:Cache(characterID)

    -- Update the item list in the inventory object
    local itemIDs = {}
    for k, v in pairs(ow.item.instances) do
        if ( tonumber(v:GetOwner()) == characterID ) then
            table.insert(itemIDs, v.ID)
        end
    end

    inventory.Items = itemIDs

    net.Start("ow.inventory.cache")
        net.WriteTable(inventory)
    net.Send(ply)
end

--- Caches all inventories owned by a character.
-- @realm server
-- @param characterID The ID of the character to cache inventories for.
function ow.inventory:CacheAll(characterID)
    if ( !characterID ) then return end

    local result = ow.sqlite:Select("ow_characters", nil, "id = " .. characterID)
    if ( !result ) then return end

    result = result[1]
    if ( !result ) then return end

    local inventories = util.JSONToTable(result.inventories) or {}
    for k, v in pairs(inventories) do
        self:Cache(ow.character:GetPlayerByCharacter(characterID), v)
    end
end