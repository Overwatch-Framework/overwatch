local MODULE = MODULE

function MODULE:PostPlayerSetModel(ply, model)
    if ( !ply or !model ) then return end

    local plyTable = ply:GetTable()
    if ( !plyTable ) then return end

    local class = ow.animations:GetModelClass(model)
    if ( !class ) then return end

    plyTable.owAnimations = ow.animations.stored[class] or {}

    net.Start("ow.animations.set.model")
        net.WriteUInt(ply:EntIndex(), 16)
        net.WriteString(model)
    net.Broadcast()
end