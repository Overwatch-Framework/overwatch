--- ow.net
-- Compact, efficient NetStream-like networking using sfs serialization.

ow.net = ow.net or {}
ow.net.handlers = {}

local net = net
local sfs = sfs

if ( SERVER ) then
    util.AddNetworkString("ow.net.msg")
end

--- Registers a network message handler.
-- @string id Identifier for the message.
-- @func callback Function called with (client, payload) on server or (nil, payload) on client.
function ow.net:Receive(id, callback)
    self.handlers[id] = callback
end

--- Internal receive hook.
net.Receive("ow.net.msg", function(len, ply)
    local idLen = net.ReadUInt(8)
    local id = net.ReadString(idLen)
    local payloadLen = net.ReadUInt(16)
    local payloadData = net.ReadData(payloadLen)

    local payload, err = sfs.decode(payloadData)
    if ( !payload ) then
        ErrorNoHalt("[ow.net] Failed to decode message: " .. tostring(err) .. "\n")
        return
    end

    local handler = ow.net.handlers[id]
    if ( handler ) then
        handler(ply or nil, payload)
    end
end)

--- Sends a network message.
-- @string id Identifier string.
-- @table data Table to send.
-- @param[opt=nil] target Player, table of players, or nil to broadcast.
function ow.net:Send(id, data, target)
    local encoded = sfs.encode(data)
    if ( !encoded ) then return end

    net.Start("ow.net.msg")
    net.WriteUInt(#id, 8)
    net.WriteString(id)
    net.WriteUInt(#encoded, 16)
    net.WriteData(encoded, #encoded)

    if ( SERVER ) then
        if ( istable(target) or IsValid(target) ) then
            net.Send(target)
        else
            net.Broadcast()
        end
    else
        net.SendToServer()
    end
end

/*
--- Example usage:
-- Server
ow.net:Receive("Ping", function(ply, payload)
	print(ply:Nick() .. " pinged with:", payload.time)
	ow.net:Send("Pong", { ack = true }, ply)
end)

-- Client
ow.net:Send("Ping", { time = CurTime() })
ow.net:Receive("Pong", function(_, payload)
	print("Pong received:", payload.ack)
end)
*/