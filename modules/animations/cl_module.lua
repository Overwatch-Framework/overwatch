net.Receive("ow.animations.update", function(len)
    local ply = net.ReadPlayer()
    if ( !IsValid(ply) ) then return end

    local data = net.ReadTable()
    if ( !istable(data) ) then return end

    ply.owAnimations = data

    -- ew...
    ply:SetIK(false)
end)