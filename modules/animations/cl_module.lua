net.Receive("ow.animations.update", function(len)
    local client = net.ReadPlayer()
    if ( !IsValid(client) ) then return end

    local data = net.ReadTable()
    if ( !istable(data) ) then return end

    client.owAnimations = data

    -- ew...
    client:SetIK(false)
end)