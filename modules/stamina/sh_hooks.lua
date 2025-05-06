local MODULE = MODULE

function MODULE:SetupMove(client, mv, cmd)
    if ( !ow.config:Get("stamina", true) ) then return end

    local st = client:GetRelay("stamina")
    if ( istable(st) and st.current <= 0 ) then
        -- Prevent sprinting input
        if ( mv:KeyDown(IN_SPEED) ) then
            mv:SetButtons(mv:GetButtons() - IN_SPEED)
        end

        -- Prevent jumping input
        if ( mv:KeyDown(IN_JUMP) ) then
            mv:SetButtons(mv:GetButtons() - IN_JUMP)
        end

        -- Reduce max speed (e.g., 25% slower)
        mv:SetMaxSpeed(mv:GetMaxSpeed() * 0.75)
        mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * 0.75)
    end
end