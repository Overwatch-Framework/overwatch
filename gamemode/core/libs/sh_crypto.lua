--- Crypto
-- A pure Lua library for length-prefix serialization, compression, and encryption.
-- No ambiguous delimiters—safe for any data.
-- @module ow.crypto

ow.crypto = ow.crypto or {}

ow.crypto.DefaultKey = "ltPjQ96MXCVC8Awo"

-- write a 2-byte big-endian integer
local function write_u16(n)
    local hi = bit.band(bit.rshift(n, 8), 0xFF)
    local lo = bit.band(n, 0xFF)
    return string.char(hi, lo)
end

-- read a 2-byte big-endian integer
local function read_u16(s, i)
    local b1, b2 = s:byte(i, i + 1)
    local num = bit.bor(bit.lshift(b1, 8), b2)
    return num, i + 2
end

--- Serializes any supported Lua value into a byte-string.
-- @realm shared
-- @tparam any data The data to serialize (table, string, number, boolean)
-- @treturn string The serialized byte-string
function ow.crypto:Serialize(data)
    local t = type(data)

    if ( t == "table" ) then
        local parts = { "T" }
        local count = 0
        for _ in pairs(data) do count = count + 1 end
        parts[#parts + 1] = string.char(bit.rshift(count, 8), bit.band(count, 0xFF))
        for k, v in pairs(data) do
            parts[#parts + 1] = self:Serialize(k)
            parts[#parts + 1] = self:Serialize(v)
        end
        return table.concat(parts)
    elseif ( t == "string" ) then
        local len = #data
        return "S" .. string.char(bit.rshift(len, 8), bit.band(len, 0xFF)) .. data
    elseif ( t == "number" ) then
        local str = tostring(data)
        local len = #str
        return "N" .. string.char(bit.rshift(len, 8), bit.band(len, 0xFF)) .. str
    elseif ( t == "boolean" ) then
        return "B" .. ( data and "\1" or "\0" )
    elseif ( t == "Entity" or IsEntity(data) ) then
        return "E" .. string.char(bit.rshift(data:EntIndex(), 8), bit.band(data:EntIndex(), 0xFF))
    else
        error("ow.crypto:Serialize() unsupported type: " .. t)
    end
end

--- Deserializes a byte-string back into Lua values.
-- @realm shared
-- @tparam string blob The serialized byte-string
-- @treturn any The original Lua value
function ow.crypto:Deserialize(data)
    local i = 1

    local function read_u16()
        local a, b = data:byte(i, i + 1)
        i = i + 2
        return bit.bor(bit.lshift(a, 8), b)
    end

    local function parse()
        local tag = data:sub(i, i)
        i = i + 1

        if ( tag == "T" ) then
            local count = read_u16()
            local out = {}
            for _ = 1, count do
                local k = parse()
                local v = parse()
                out[k] = v
            end
            return out
        elseif ( tag == "S" ) then
            local len = read_u16()
            local str = data:sub(i, i + len - 1)
            i = i + len
            return str
        elseif ( tag == "N" ) then
            local len = read_u16()
            local str = data:sub(i, i + len - 1)
            i = i + len
            return tonumber(str)
        elseif ( tag == "B" ) then
            local val = data:sub(i, i) == "\1"
            i = i + 1
            return val
        elseif ( tag == "E" ) then
            local entIndex = read_u16()
            return Entity(entIndex)
        else
            error("ow.crypto:Deserialize() unknown tag: " .. tostring(tag))
        end
    end

    return parse()
end

--- Compresses a string using run-length encoding.
-- @realm shared
-- @tparam string str The input string
-- @treturn string The compressed string
function ow.crypto:Compress(str)
    local out = {}
    local len = #str
    local p = 1

    while ( p <= len ) do
        local c = str:sub(p, p)
        local cnt = 1

        while ( p + cnt <= len and str:sub(p + cnt, p + cnt) == c and cnt < 255 ) do
            cnt = cnt + 1
        end

        out[#out + 1] = string.char(cnt)
        out[#out + 1] = c
        p = p + cnt
    end

    return table.concat(out)
end

--- Decompresses a run-length encoded string.
-- @realm shared
-- @tparam string data The compressed string
-- @treturn string The decompressed string
function ow.crypto:Decompress(data)
    local out = {}
    local len = #data
    local i = 1

    while ( i < len ) do
        local cnt = data:byte(i)
        local c = data:sub(i + 1, i + 1)
        out[#out + 1] = string.rep(c, cnt)
        i = i + 2
    end

    return table.concat(out)
end

--- Encrypts a string using XOR with a repeating key.
-- @realm shared
-- @tparam string str The input data
-- @tparam string key The encryption key
-- @treturn string The encrypted data
function ow.crypto:Encrypt(str, key)
    local out = {}
    local klen = #key

    for i = 1, #str do
        local b = str:byte(i)
        local kb = key:byte(((i - 1) % klen) + 1)
        out[i] = string.char(bit.bxor(b, kb))
    end

    return table.concat(out)
end

--- Decrypts XOR-encrypted data (same as Encrypt).
-- @realm shared
-- @tparam string str The encrypted data
-- @tparam string key The encryption key
-- @treturn string The decrypted data
function ow.crypto:Decrypt(str, key)
    return self:Encrypt(str, key)
end

--- Packs data into a compressed, encrypted blob.
-- @realm shared
-- @tparam any data The Lua value to pack
-- @tparam string key (optional) The encryption key
-- @treturn string The final blob
function ow.crypto:Pack(data, key)
    key = key or self.DefaultKey
    local raw = self:Serialize(data)
    local cmp = self:Compress(raw)
    return self:Encrypt(cmp, key)
end

--- Unpacks a blob back into original data.
-- @realm shared
-- @tparam string blob The packed blob
-- @tparam string key (optional) The encryption key
-- @treturn any The original Lua value
function ow.crypto:Unpack(blob, key)
    key = key or self.DefaultKey
    local dec = self:Decrypt(blob, key)
    local raw = self:Decompress(dec)
    return self:Deserialize(raw)
end

/*
local big = {
    name = "Riggs",
    flags = { super = true, vip = false },
    scores = {100,200,300,100,100,100},
}

local secretKey = "MyUltraSecretKey"
local payload = ow.crypto:Pack(big, secretKey)
print("Packed Payload:")
print(payload)

local received = ow.crypto:Unpack(payload, secretKey)
print("Unpacked Payload:")
PrintTable(received)
*/