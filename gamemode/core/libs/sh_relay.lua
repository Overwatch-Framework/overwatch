--- Relay
-- A secure value distribution system using ow.crypto for packing and syncing values.
-- Provides shared (global), user (per-player), and entity (per-entity) scopes.
-- @module ow.relay

ow.relay = ow.relay or {}
ow.relay.shared = ow.relay.shared  or {}
ow.relay.user = ow.relay.user or {}
ow.relay.entity = ow.relay.entity or {}

local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")

if ( SERVER ) then
    util.AddNetworkString("ow.relay.shared")
    util.AddNetworkString("ow.relay.user")
    util.AddNetworkString("ow.relay.entity")
end

-- internal: pack and send a payload
local function sendPacked(msg, key, value, recipient)
    local blob = ow.crypto:Pack(value)

    net.Start(msg)
        net.WriteString(key)
        net.WriteUInt(#blob, 32)
        net.WriteData(blob, #blob)
    if ( SERVER ) then
        if ( recipient ) then
            net.Send(recipient)
        else
            net.Broadcast()
        end
    end
end

function ow.relay:SetRelay(key, value, recipient)
    if ( SERVER ) then
        self.shared[key] = value
        sendPacked("ow.relay.shared", key, value, recipient)
    end
end

function ow.relay:GetRelay(key, default)
    local v = self.shared[key]
    return v != nil and v or default
end

if ( CLIENT ) then
    net.Receive("ow.relay.shared", function()
        local key = net.ReadString()
        local len = net.ReadUInt(32)
        local payload = net.ReadData(len)
        if ( !payload ) then return end

        local value = ow.crypto:Unpack(payload)
        ow.relay.shared[key] = value
    end)
end

function playerMeta:SetRelay(key, value, recipient)
    if ( SERVER ) then
        ow.relay.user[self] = ow.relay.user[self] or {}
        ow.relay.user[self][key] = value
        sendPacked("ow.relay.user", key, value, recipient or self)
    end
end

function playerMeta:GetRelay(key, default)
    local t = ow.relay.user[self]
    return t != nil and t[key] or default
end

if ( CLIENT ) then
    net.Receive("ow.relay.user", function()
        local key = net.ReadString()
        local len = net.ReadUInt(32)
        local payload = net.ReadData(len)
        if ( !payload ) then return end

        local value = ow.crypto:Unpack(payload)
        local ply = ow.localClient

        ow.relay.user[ply] = ow.relay.user[ply] or {}
        ow.relay.user[ply][key] = value
    end)
end

function entityMeta:SetRelay(key, value, recipient)
    if ( SERVER ) then
        ow.relay.entity[self] = ow.relay.entity[self] or {}
        ow.relay.entity[self][key] = value

        local blob = ow.crypto:Pack(value)
        net.Start("ow.relay.entity")
            net.WriteUInt(self:EntIndex(), 16)
            net.WriteString(key)
            net.WriteUInt(#blob, 32)
            net.WriteData(blob, #blob)
        if ( recipient ) then
            net.Send(recipient)
        else
            net.Broadcast()
        end
    end
end

function entityMeta:GetRelay(key, default)
    local t = ow.relay.entity[self]
    return t != nil and t[key] or default
end

if ( CLIENT ) then
    net.Receive("ow.relay.entity", function()
        local entIndex = net.ReadUInt(16)
        local key = net.ReadString()
        local len = net.ReadUInt(32)
        local payload = net.ReadData(len)
        if ( !payload ) then return end

        local value = ow.crypto:Unpack(payload)
        local ent = Entity(entIndex)
        if ( IsValid(ent) ) then
            ow.relay.entity[ent] = ow.relay.entity[ent] or {}
            ow.relay.entity[ent][key] = value
        end
    end)
end