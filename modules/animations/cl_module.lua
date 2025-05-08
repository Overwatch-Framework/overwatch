ow.net:Hook("animations.update", function(client, data)
    if ( !IsValid(client) or !istable(data) ) then return end

    client.owAnimations = data
    client.owLastAct = -1

    -- ew...
    client:SetIK(false)
end)