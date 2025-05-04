net.Receive("ow.animations.set.model", function(len)
    local plyIndex = net.ReadUInt(16)
    local ply = Entity(plyIndex)
    local model = net.ReadString()

    if ( !ply or !model ) then return end

    local class = ow.animations:GetModelClass(model)
    if ( !class ) then return end

    ply.owAnimations = ow.animations.stored[class] or {}
end)