-- ow.net
-- Streaming data layer using sfs. NetStream-style API.
-- @realm shared

ow.net = ow.net or {}
ow.net.stored = ow.net.stored or {}

if ( SERVER ) then
    util.AddNetworkString("ow.net.msg")
end

--- Hooks a network message.
-- @string name Unique identifier.
-- @func callback Callback with player, unpacked args.
function ow.net:Hook(name, callback)
    self.stored[name] = callback
end

--- Starts a stream.
-- @param target Player, table, vector or nil (nil = broadcast or to server).
-- @string name Hook name.
-- @vararg Arguments to send.
function ow.net:Start(target, name, ...)
    local args = {...}
    local encoded = sfs.encode(args)
    if ( !encoded or #encoded < 1 ) then return end

    if ( CLIENT and isstring(target) and name == nil ) then
        ErrorNoHaltWithStack("[ow.net] WARNING: You likely forgot to include a nil target. Use :Start(nil, \"hook\", ...)\n")
    end

    if ( CLIENT ) then
        net.Start("ow.net.msg")
            net.WriteString(name)
            net.WriteData(encoded, #encoded)
        net.SendToServer()

        return
    end

    local recipients = {}
    local sendPVS = false

    if ( type(target) == "Vector" ) then
        sendPVS = true
    elseif ( istable(target) ) then
        for _, v in ipairs(target) do
            if ( IsValid(v) and v:IsPlayer() ) then
                recipients[#recipients + 1] = v
            end
        end
    elseif ( IsValid(target) and target:IsPlayer() ) then
        recipients[1] = target
    else
        recipients = select(2, player.Iterator())
    end

    net.Start("ow.net.msg")
        net.WriteString(name)
        net.WriteData(encoded, #encoded)

    if ( sendPVS ) then
        net.SendPVS(target)
    else
        net.Send(recipients)
    end

    ow.util:Print("[ow.net] Sent '" .. name .. "' to " .. (SERVER and #recipients .. " players" or "server"))
end

net.Receive("ow.net.msg", function(len, ply)
    local name = net.ReadString()
    local raw = net.ReadData(len / 8)

    local ok, decoded = pcall(sfs.decode, raw)
    if ( !ok or type(decoded) != "table" ) then
        ErrorNoHalt("[ow.net] Decode failed for '" .. name .. "'\n")
        return
    end

    local callback = ow.net.stored[name]
    if ( !callback ) then
        ErrorNoHalt("[ow.net] No handler for '" .. name .. "'\n")
        return
    end

    if ( SERVER ) then
        callback(ply, unpack(decoded))
    else
        callback(unpack(decoded))
    end

    ow.util:Print("[ow.net] Received '" .. name .. "' from " .. (SERVER and ply:Nick() or "server"))
end)

/*
--- Example usage:
if ( SERVER ) then
    ow.net:Hook("test", function(client, val, val2)
        print(client, "sent:", val, val2)
    end)
end

if ( CLIENT ) then
    ow.net:Start(nil, "test", {89})
    ow.net:Start(nil, "test", "hello", "world")
end
*/