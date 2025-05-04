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

        ply.owStamina = {
            max = max,
            current = max,
            regenRate = 5,
            regenDelay = 1.0,
            lastUsed = 0
        }

        ply:SetRelay("stamina", ply.owStamina.current)
    end

    --- Updates the player's stamina
    -- @param ply Player
    -- @param dt number
    function ow.stamina:Update(ply, dt)
        local st = ply.owStamina
        if ( !st ) then return end

        if CurTime() - st.lastUsed >= st.regenDelay then
            st.current = math.min(st.current + (st.regenRate * dt), st.max)
            ply:SetRelay("stamina", st.current)
        end
    end

    --- Consumes stamina from a player
    -- @param ply Player
    -- @param amount number
    -- @return boolean
    function ow.stamina:Consume(ply, amount)
        local st = ply.owStamina
        if ( !st or st.current < amount ) then return false end

        st.current = st.current - amount
        st.lastUsed = CurTime()
        ply:SetRelay("stamina", st.current)

        return true
    end

    --- Checks if player has enough stamina
    -- @param ply Player
    -- @param amount number
    -- @return boolean
    function ow.stamina:CanConsume(ply, amount)
        local st = ply.owStamina
        return st and st.current >= amount
    end

    --- Gets current stamina
    -- @param ply Player
    -- @return number
    function ow.stamina:Get(ply)
        local st = ply.owStamina
        return st and st.current or 0
    end

    --- Sets current stamina
    -- @param ply Player
    -- @param value number
    function ow.stamina:Set(ply, value)
        local st = ply.owStamina
        if ( !st ) then return end

        st.current = math.Clamp(value, 0, st.max)
        ply:SetRelay("stamina", st.current)
    end
end

if ( CLIENT ) then
    --- Gets the local player's stamina from relay
    -- @return number
    function ow.stamina:GetLocal()
        return ow.localClient:GetRelay("stamina") or 0
    end

    --- Gets the local player's stamina as a fraction [0–1]
    -- @return number
    function ow.stamina:GetFraction()
        local max = 100
        return self:GetLocal() / max
    end
end