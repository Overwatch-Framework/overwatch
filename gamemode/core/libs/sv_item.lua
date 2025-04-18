--- Item library
-- @module ow.item

--- Adds a new item to a character's inventory.
-- @realm server
-- @param number ownerID The ID of the character who owns the item.
-- @param string uniqueID The uniqueID of the item.
-- @param table data The data to save with the item.
-- @param function callback The callback function.
-- @return table The item table.
function ow.item:Add(ownerID, uniqueID, data, callback)
    if ( !ownerID or !uniqueID ) then return end
    if ( !self.stored[uniqueID] ) then return end

    local item = table.Copy(self.stored[uniqueID])
    if ( !item ) then return end

    item.Data = data.Data

    ow.sqlite:Insert("items", {
        owner_id = ownerID,
        unique_id = uniqueID,
        data = util.TableToJSON(data or {})
    }, function(dataReceived)
        local receiver = ow.character:GetPlayerByCharacter(ownerID)
        if ( IsValid(receiver) ) then
            local compressed = util.Compress(util.TableToJSON(dataReceived))

            net.Start("ow.item.add")
                net.WriteString(uniqueID)
                net.WriteData(compressed, #compressed)
            net.Send(receiver)
        end

        if ( callback ) then
            callback(item)
        end
    end)

    hook.Run("OnItemAdded", item, ownerID, uniqueID, data)

    return item
end

--- Spawns an item entity with the given uniqueID, position and angles.
-- @realm server
-- @param string uniqueID The uniqueID of the item.
-- @param Vector pos The position of the item.
-- @param Angle angles The angles of the item.
-- @param function callback The callback function.
function ow.item:Spawn(uniqueID, position, angles, callback, data)
    self:Instance(0, uniqueID, data or {}, 1, 1, function(item)
        local entity = item:Spawn(position, angles)

        if ( callback ) then
            callback(item, entity)
        end
    end)
end

function ow.item:Instance(index, uniqueID, data, callback, charID)
    if ( !self.stored[uniqueID] ) then return end

    local itemTable = table.Copy(self.stored[uniqueID])
    if ( !itemTable ) then return end

    ow.sqlite:Insert("items", {
        unique_id = uniqueID,
        data = util.TableToJSON(data or {}),
        owner_id = charID,
        inv_id = index,
    }, function(dataReceived)
        local item = ow.item:New(uniqueID, dataReceived)
        if ( item ) then
            item.Data = data
            item.InvID = index
            item.charID = charID

            if ( isfunction(callback) ) then
                callback(item)
            end

            if ( isfunction(item.OnInstanced) ) then
                item:OnInstanced(dataReceived)
            end
        end
    end)

    return item
end

function ow.item:New(uniqueID, id)
    if ( ow.item.instances[id] and ow.item.instances[id].uniqueID == uniqueID ) then
        return ow.item.instances[id]
    end

    local itemTable = table.Copy(self.stored[uniqueID])
    if ( !itemTable ) then return end

    local ITEM = setmetatable({
        ID = id,
        Data = {},
    }, {
        __index = itemTable,
        __tostring = itemTable.__tostring,
        __eq = itemTable.__eq,
    })

    ow.item.instances[id] = ITEM

    return ITEM
end

ow.character:RegisterVariable("inventory", {
    bNoNetworking = true,
    bNoDisplay = true,
    --[[OnGet = function(character, index) -- TODO, we need the bloody OnGet and OnSet support
        if (index and !isnumber(index)) then
            return character.vars.inv or {}
        end

        return character.vars.inv and character.vars.inv[index or 1]
    end,]]
    alias = "Inv"
})