ow.net:Hook("animations.update", function(client, data)
    if ( !IsValid(client) or !istable(data) ) then return end

    client.owAnimations = data

    -- ew...
    client:SetIK(false)
end)