--- Relay
-- A secure value distribution system using SFS for packing and syncing values.
-- Provides shared (global), user (per-player), and entity (per-entity) scopes.
-- @module ow.relay

ow.relay = ow.relay or {}
ow.relay.shared = ow.relay.shared  or {}
ow.relay.user = ow.relay.user or {}
ow.relay.entity = ow.relay.entity or {}

local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")

function ow.relay:SetRelay(key, value, recipient)
    self.shared[key] = value

    if ( SERVER ) then
        ow.net:Start(recipient, "relay.shared", key, value)
    end
end

function ow.relay:GetRelay(key, default)
    local v = self.shared[key]
    return v != nil and v or default
end

if ( CLIENT ) then
    ow.net:Hook("relay.shared", function(key, value)
        if ( value == nil ) then return end

        ow.relay.shared[key] = value
    end)
end

function playerMeta:SetRelay(key, value, recipient)
    if ( SERVER ) then
        ow.relay.user[self] = ow.relay.user[self] or {}
        ow.relay.user[self][key] = value

        ow.net:Start(recipient, "relay.user", key, value)
    end
end

function playerMeta:GetRelay(key, default)
    local t = ow.relay.user[self]
    if ( t == nil ) then
        return default
    end

    return t[key] == nil and default or t[key]
end

if ( CLIENT ) then
    ow.net:Hook("relay.user", function(key, value)
        if ( value == nil ) then return end

        local client = LocalPlayer()

        ow.relay.user[client] = ow.relay.user[client] or {}
        ow.relay.user[client][key] = value
    end)
end

function entityMeta:SetRelay(key, value, recipient)
    if ( SERVER ) then
        ow.relay.entity[self] = ow.relay.entity[self] or {}
        ow.relay.entity[self][key] = value

        ow.net:Start(recipient, "relay.entity", self:EntIndex(), key, value)
    end
end

function entityMeta:GetRelay(key, default)
    local t = ow.relay.entity[self]
    if ( t == nil ) then
        return default
    end

    return t[key] == nil and default or t[key]
end

if ( CLIENT ) then
    ow.net:Hook("relay.entity", function(index, key, value)
        if ( value == nil ) then return end

        local ent = Entity(index)
        if ( IsValid(ent) ) then
            ow.relay.entity[ent] = ow.relay.entity[ent] or {}
            ow.relay.entity[ent][key] = value
        end
    end)
end