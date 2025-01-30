--- Options library
-- @module ow.option

ow.option.stored = {}

util.AddNetworkString("ow.option.set")
net.Receive("ow.option.set", function(len, ply)
    if ( !IsValid(ply) ) then return end

    local key = net.ReadString()
    local value = net.ReadType()

    local stored = ow.option.stored[key]
    if ( !stored ) then 
        ow.util:PrintError("Option \"" .. key .. "\" does not exist!") 
        return 
    end

    if ( stored.OnChange ) then
        stored:OnChange(value, stored.Value, ply)
    end

    if ( !stored.bNoNetworking ) then
        ow.option.stored[ply] = ow.option.stored[ply] or {}
        ow.option.stored[ply][key] = value
    end
end)

function ow.option:Set(ply, key, value)
    local stored = ow.option.stored[key]
    if ( !stored ) then 
        ow.util:PrintError("Option \"" .. key .. "\" does not exist!") 
        return false 
    end

    if ( !IsValid(ply) ) then return false end
    
    net.Start("ow.option.set")
        net.WriteString(key)
        net.WriteType(value)
    net.Send(ply)
    
    return true
end