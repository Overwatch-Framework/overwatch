--- ow.stamina
-- Cross-realm stamina library.
-- Server handles regeneration/consumption; client reads synced relay.

ow.stamina = ow.stamina or {}

if ( SERVER ) then
    --- Initializes a stamina object for a player
    -- @param ply Player
    -- @param max number
    function ow.stamina:Initialize(ply, max)
        max = max or ow.config:Get("stamina.max", 100)

        ply:SetRelay("stamina", {
            max = max,
            current = max,
            regenRate = 5,
            regenDelay = 1.0,
            lastUsed = 0
        })
    end

    --- Consumes stamina from a player
    -- @param ply Player
    -- @param amount number
    -- @return boolean
    function ow.stamina:Consume(ply, amount)
        local st = ply:GetRelay("stamina")
        if ( !st ) then return false end

        st.current = math.Clamp(st.current - amount, 0, st.max)
        st.lastUsed = CurTime()
        ply:SetRelay("stamina", st)

        return true
    end

    --- Checks if player has enough stamina
    -- @param ply Player
    -- @param amount number
    -- @return boolean
    function ow.stamina:CanConsume(ply, amount)
        local st = ply:GetRelay("stamina")
        return st and st.current >= amount
    end

    --- Gets current stamina
    -- @param ply Player
    -- @return number
    function ow.stamina:Get(ply)
        local st = ply:GetRelay("stamina")
        return st and st.current or 0
    end

    --- Sets current stamina
    -- @param ply Player
    -- @param value number
    function ow.stamina:Set(ply, value)
        local st = ply:GetRelay("stamina")
        if ( !st ) then return end

        st.current = math.Clamp(value, 0, st.max)
        ply:SetRelay("stamina", st)
    end
end

if ( CLIENT ) then
    --- Gets the local player's stamina from relay
    -- @return number
    function ow.stamina:GetLocal()
        return ow.localClient:GetRelay("stamina").current
    end

    --- Gets the local player's stamina as a fraction [0–1]
    -- @return number
    function ow.stamina:GetFraction()
        local max = ow.localClient:GetRelay("stamina").max
        return self:GetLocal() / max
    end
end