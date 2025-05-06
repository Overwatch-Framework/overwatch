local MODULE = MODULE

local nextStamina = 0
function MODULE:Think()
    if ( !ow.config:Get("stamina", true) ) then return end

    if ( CurTime() >= nextStamina ) then
        local regen = ow.config:Get("stamina.regen", 20) / 10
        local drain = ow.config:Get("stamina.drain", 10) / 10
        nextStamina = CurTime() + ow.config:Get("stamina.tick", 0.1)

        for _, ply in player.Iterator() do
            if ( !IsValid(ply) or !ply:Alive() ) then continue end
            if ( ply:Team() == 0 ) then continue end

            local st = ply:GetRelay("stamina")
            if ( istable(st) ) then
                local isSprinting = ply:KeyDown(IN_SPEED) and ply:KeyDown(IN_FORWARD) and ply:OnGround()
                if ( isSprinting and ply:GetVelocity():Length2DSqr() > 1 ) then
                    if ( ow.stamina:Consume(ply, drain) ) then
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
                        ow.stamina:Set(ply, math.min(st.current + regen, st.max))
                    end
                end
            else
                -- Initialize stamina if it doesn't exist
                ow.stamina:Initialize(ply)
            end
        end
    end
end

function MODULE:OnPlayerHitGround(ply, inWater, onFloater, speed)
    if ( !ow.config:Get("stamina", true) ) then return end

    local st = ply:GetRelay("stamina")
    if ( st and st.current > 0 ) then
        ow.stamina:Consume(ply, speed / 64)
    end
end