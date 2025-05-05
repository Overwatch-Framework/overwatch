net.Receive("ow.animations.update", function(len)
    local plyIndex = net.ReadUInt(16)
    local ply = Entity(plyIndex)
    local data = net.ReadTable()
    if ( !IsValid(ply) ) then return end
    if ( !data ) then return end

    ply.owAnimations = data
end)