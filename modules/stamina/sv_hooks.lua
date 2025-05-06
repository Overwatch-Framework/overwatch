local MODULE = MODULE

local nextStamina = 0
function MODULE:Think()
    if ( !ow.config:Get("stamina", true) ) then return end

    if ( CurTime() >= nextStamina ) then
        local regen = ow.config:Get("stamina.regen", 20) / 10
        local drain = ow.config:Get("stamina.drain", 10) / 10
        nextStamina = CurTime() + ow.config:Get("stamina.tick", 0.1)

        for _, client in player.Iterator() do
            if ( !IsValid(client) or !client:Alive() ) then continue end
            if ( client:Team() == 0 ) then continue end

            local st = client:GetRelay("stamina")
            if ( istable(st) ) then
                local isSprinting = client:KeyDown(IN_SPEED) and client:KeyDown(IN_FORWARD) and client:OnGround()
                if ( isSprinting and client:GetVelocity():Length2DSqr() > 1 ) then
                    if ( ow.stamina:Consume(client, drain) ) then
                        st.depleted = false
                        st.regenBlockedUntil = CurTime() + 2
                    else
                        if ( !st.depleted ) then
                            st.depleted = true
                            st.regenBlockedUntil = CurTime() + 10
                        end
                    end
                else
                    if ( st.regenBlockedUntil and CurTime() >= st.regenBlockedUntil ) then
                        ow.stamina:Set(client, math.min(st.current + regen, st.max))
                    end
                end
            else
                -- Initialize stamina if it doesn't exist
                ow.stamina:Initialize(client)
            end
        end
    end
end

function MODULE:OnPlayerHitGround(client, inWater, onFloater, speed)
    if ( !ow.config:Get("stamina", true) ) then return end

    local st = client:GetRelay("stamina")
    if ( st and st.current > 0 ) then
        ow.stamina:Consume(client, speed / 64)
    end
end

function MODULE:PlayerSpawn(client)
    if ( !ow.config:Get("stamina", true) ) then return end

    -- Initialize stamina when player spawns
    ow.stamina:Initialize(client)
end