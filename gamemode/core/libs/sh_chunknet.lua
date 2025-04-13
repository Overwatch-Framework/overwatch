--- Chunknet
-- Chunknet is a library for sending large data over the network in chunks.
-- It handles the serialization and deserialization of data, as well as the splitting
-- and compression of large payloads.
-- @module ow.chunknet

ow.chunknet = ow.chunknet or {}

local CHUNK_SIZE = 4096 -- 4KB

--- Splits a string into smaller chunks of a specified size.
-- @realm shared
-- @tparam string data The data to split
-- @tparam number size The size of each chunk
-- @treturn table A table containing the chunks
function ow.chunknet:SplitChunks(data, size)
    local chunks = {}
    for i = 1, #data, size do
        table.insert(chunks, data:sub(i, i + size - 1))
    end

    return chunks
end

--- Serializes data into a string format.
-- Automatically handles tables and strings.
-- @realm shared
-- @tparam any data The data to serialize (string or table)
-- @treturn string The serialized data
function ow.chunknet:Serialize(data)
    if ( istable(data) ) then
        return util.TableToJSON(data)
    elseif ( isstring(data) ) then
        return data
    else
        error("ow.chunknet:Serialize() only accepts tables or strings!")
    end
end

--- Deserializes data from a string format.
-- Automatically handles JSON strings and returns the original data.
-- @realm shared
-- @tparam string data The data to deserialize (string)
-- @treturn any The deserialized data (string or table)
function ow.chunknet:Deserialize(data)
    local tbl = util.JSONToTable(data)
    return tbl or data
end

--- Sends data to a player in chunks.
-- Automatically compresses data before sending.
-- @realm shared
-- @tparam Player ply The player to send the data to
-- @tparam string id The identifier for the data being sent
-- @tparam any data The data to send (string or table)
function ow.chunknet:Send(ply, id, data)
    local serialized = self:Serialize(data)
    local compressed = util.Compress(serialized)
    local encoded = util.Base64Encode(compressed)
    local chunks = self:SplitChunks(encoded, CHUNK_SIZE)

    for i, chunk in ipairs(chunks) do
        net.Start("ow.chunknet." .. id)
            net.WriteUInt(#chunks, 16)
            net.WriteUInt(i, 16)
            net.WriteString(chunk)
        if ( SERVER ) then
            net.Send(ply)
        else
            net.SendToServer()
        end
    end
end

--- Broadcasts data to all players in chunks.
-- Automatically compresses data before sending.
-- @realm server
-- @tparam string id The identifier for the data being sent
-- @tparam any data The data to send (string or table)
function ow.chunknet:Broadcast(id, data)
    if ( CLIENT ) then
        error("ow.chunknet:Broadcast() can only be called on the server!")
    end

    local serialized = self:Serialize(data)
    local compressed = util.Compress(serialized)
    local encoded = util.Base64Encode(compressed)
    local chunks = self:SplitChunks(encoded, CHUNK_SIZE)

    for i, chunk in ipairs(chunks) do
        net.Start("ow.chunknet." .. id)
            net.WriteUInt(#chunks, 16)
            net.WriteUInt(i, 16)
            net.WriteString(chunk)
        net.Broadcast()
    end
end

--- Receives data from a player in chunks.
-- Automatically decompresses and deserializes the result.
-- @realm shared
-- @tparam string id The identifier for the data being received
-- @tparam function callback The function to call when all chunks are received
function ow.chunknet:Receive(id, callback)
    local buffer = {}

    net.Receive("ow.chunknet." .. id, function(len, ply)
        local total = net.ReadUInt(16)
        local index = net.ReadUInt(16)
        local chunk = net.ReadString()

        local key = SERVER and ply:SteamID64() or "local"
        buffer[key] = buffer[key] or {}
        buffer[key][index] = chunk

        if ( table.Count(buffer[key]) == total ) then
            local fullData = table.concat(buffer[key])
            buffer[key] = nil

            local decoded = util.Base64Decode(fullData)
            local decompressed = util.Decompress(decoded)

            if ( decompressed == nil or !isstring(decompressed) ) then
                ErrorNoHalt("[ow.chunknet] Failed to decompress payload for id \"" .. id .. "\"\n")
                return
            end

            local result = self:Deserialize(decompressed)
            callback(result, ply)
        end
    end)
end