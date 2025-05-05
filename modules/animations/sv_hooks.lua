local MODULE = MODULE

function MODULE:PostEntitySetModel(ent, model)
    if ( !IsValid(ent) or !ent:IsPlayer() ) then return end
    if ( !model ) then return end

    local ply = ent
    local plyTable = ply:GetTable()
    if ( !plyTable ) then return end

    local class = ow.animations:GetModelClass(model)
    if ( !class or class == "player" ) then
        net.Start("ow.animations.update")
            net.WritePlayer(ply)
            net.WriteTable({})
        net.Broadcast()
    end

    local weapon = ply:GetActiveWeapon()
    if ( !IsValid(weapon) ) then return end

    local holdType = weapon:GetHoldType()
    if ( !holdType ) then return end

    holdType = HOLDTYPE_TRANSLATOR[holdType] or holdType

    local animTable = ow.animations.stored[class]
    if ( animTable and animTable[holdType] ) then
        ply.owAnimations = animTable[holdType]
    else
        ply.owAnimations = {}
    end

    net.Start("ow.animations.update")
        net.WritePlayer(ply)
        net.WriteTable(ply.owAnimations)
    net.Broadcast()
end

function MODULE:PlayerSpawn(ply)
    if ( !IsValid(ply) ) then return end

    local model = ply:GetModel()
    if ( !model ) then return end

    local class = ow.animations:GetModelClass(model)
    if ( !class or class == "player" ) then
        net.Start("ow.animations.update")
            net.WritePlayer(ply)
            net.WriteTable({})
        net.Broadcast()
    end

    local weapon = ply:GetActiveWeapon()
    if ( !IsValid(weapon) ) then return end

    local holdType = weapon:GetHoldType()
    if ( !holdType ) then return end

    holdType = HOLDTYPE_TRANSLATOR[holdType] or holdType

    local animTable = ow.animations.stored[class]
    if ( animTable and animTable[holdType] ) then
        ply.owAnimations = animTable[holdType]
    else
        ply.owAnimations = {}
    end

    net.Start("ow.animations.update")
        net.WritePlayer(ply)
        net.WriteTable(ply.owAnimations)
    net.Broadcast()
end

function MODULE:PlayerSwitchWeapon(ply, oldWeapon, newWeapon)
    if ( !IsValid(ply) ) then return end
    if ( !IsValid(newWeapon) ) then return end

    local model = ply:GetModel()
    if ( !model ) then return end

    local class = ow.animations:GetModelClass(model)
    if ( !class or class == "player" ) then
        net.Start("ow.animations.update")
            net.WritePlayer(ply)
            net.WriteTable({})
        net.Broadcast()
    end

    local holdType = newWeapon:GetHoldType()
    if ( !holdType ) then return end

    holdType = HOLDTYPE_TRANSLATOR[holdType] or holdType

    local animTable = ow.animations.stored[class]
    if ( animTable and animTable[holdType] ) then
        ply.owAnimations = animTable[holdType]
    else
        ply.owAnimations = {}
    end

    net.Start("ow.animations.update")
        net.WritePlayer(ply)
        net.WriteTable(ply.owAnimations)
    net.Broadcast()
end