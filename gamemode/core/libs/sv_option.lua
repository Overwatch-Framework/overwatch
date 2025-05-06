--- Options library
-- @module ow.option

ow.option.clients = {}

function ow.option:Set(client, key, value)
    local stored = ow.option.stored[key]
    if ( !istable(stored) ) then
        ow.util:PrintError("Option \"" .. key .. "\" does not exist!")
        return false
    end

    if ( !IsValid(client) ) then return false end

    if ( ow.util:GetTypeFromValue(value) != stored.Type ) then
        ow.util:PrintError("Attempted to set option \"" .. key .. "\" with invalid type!")
        return false
    end

    if ( isnumber(value) ) then
        if ( isnumber(stored.Min) && value < stored.Min ) then
            ow.util:PrintError("Option \"" .. key .. "\" is below minimum value!")
            return false
        end

        if ( isnumber(stored.Max) && value > stored.Max ) then
            ow.util:PrintError("Option \"" .. key .. "\" is above maximum value!")
            return false
        end
    end

    ow.net:Start(nil, "option.set", key, value)

    if ( isfunction(stored.OnChange) ) then
        stored:OnChange(value, client)
    end

    if ( !stored.NoNetworking ) then
        if ( ow.option.clients[client] == nil ) then
            ow.option.clients[client] = {}
        end

        ow.option.clients[client][key] = value
    end

    return true
end

function ow.option:Get(client, key, default)
    if ( !IsValid(client) ) then return default end

    local stored = ow.option.stored[key]
    if ( !istable(stored) ) then
        ow.util:PrintError("Option \"" .. key .. "\" does not exist!")
        return default
    end

    if ( stored.NoNetworking ) then
        ow.util:PrintWarning("Option \"" .. key .. "\" is not networked!")
        return nil
    end

    local plyStored = ow.option.clients[client]
    if ( !istable(plyStored) ) then
        return stored.Value or default
    end

    return plyStored[key] or stored.Default
end