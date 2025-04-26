--- Options library
-- @module ow.option

ow.option.clients = {}

function ow.option:Set(ply, key, value)
    local stored = ow.option.stored[key]
    if ( stored == nil or !istable(stored) ) then
        ow.util:PrintError("Option \"" .. key .. "\" does not exist!")
        return false
    end

    if ( !IsValid(ply) ) then return false end

    net.Start("ow.option.set")
        net.WriteString(key)
        net.WriteType(value)
    net.Send(ply)

    if ( isfunction(stored.OnChange) ) then
        stored:OnChange(value, ply)
    end

    if ( !stored.bNoNetworking ) then
        if ( ow.option.clients[ply] == nil ) then
            ow.option.clients[ply] = {}
        end

        ow.option.clients[ply][key] = value
    end

    hook.Run("OnOptionChanged", ply, key, value)

    return true
end

function ow.option:Get(ply, key, default)
    if ( !IsValid(ply) ) then return default end

    local stored = ow.option.stored[key]
    if ( !istable(stored) ) then
        ow.util:PrintError("Option \"" .. key .. "\" does not exist!")
        return default
    end

    if ( stored.bNoNetworking ) then
        ow.util:PrintWarning("Option \"" .. key .. "\" is not networked!")
        return nil
    end

    local plyStored = ow.option.clients[ply]
    if ( !istable(plyStored) ) then
        return stored.Value or default
    end

    return plyStored[key] or stored.Default
end