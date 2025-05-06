local MODULE = MODULE

function MODULE:PostEntitySetModel(ent, model)
    if ( !IsValid(ent) or !ent:IsPlayer() ) then return end
    if ( !model ) then return end

    local client = ent
    local clientTable = client:GetTable()
    if ( !clientTable ) then return end

    local class = ow.animations:GetModelClass(model)
    if ( !class or class == "player" ) then
        net.Start("ow.animations.update")
            net.WritePlayer(client)
            net.WriteTable({})
        net.Broadcast()
    end

    local weapon = client:GetActiveWeapon()
    if ( !IsValid(weapon) ) then return end

    local holdType = weapon:GetHoldType()
    if ( !holdType ) then return end

    holdType = HOLDTYPE_TRANSLATOR[holdType] or holdType

    local animTable = ow.animations.stored[class]
    if ( animTable and animTable[holdType] ) then
        client.owAnimations = animTable[holdType]
    else
        client.owAnimations = {}
    end

    net.Start("ow.animations.update")
        net.WritePlayer(client)
        net.WriteTable(client.owAnimations)
    net.Broadcast()
end

function MODULE:PlayerSpawn(client)
    if ( !IsValid(client) ) then return end

    local model = client:GetModel()
    if ( !model ) then return end

    local class = ow.animations:GetModelClass(model)
    if ( !class or class == "player" ) then
        net.Start("ow.animations.update")
            net.WritePlayer(client)
            net.WriteTable({})
        net.Broadcast()
    end

    local weapon = client:GetActiveWeapon()
    if ( !IsValid(weapon) ) then return end

    local holdType = weapon:GetHoldType()
    if ( !holdType ) then return end

    holdType = HOLDTYPE_TRANSLATOR[holdType] or holdType

    local animTable = ow.animations.stored[class]
    if ( animTable and animTable[holdType] ) then
        client.owAnimations = animTable[holdType]
    else
        client.owAnimations = {}
    end

    net.Start("ow.animations.update")
        net.WritePlayer(client)
        net.WriteTable(client.owAnimations)
    net.Broadcast()
end

function MODULE:PlayerSwitchWeapon(client, oldWeapon, newWeapon)
    if ( !IsValid(client) ) then return end
    if ( !IsValid(newWeapon) ) then return end

    local model = client:GetModel()
    if ( !model ) then return end

    local class = ow.animations:GetModelClass(model)
    if ( !class or class == "player" ) then
        net.Start("ow.animations.update")
            net.WritePlayer(client)
            net.WriteTable({})
        net.Broadcast()
    end

    local holdType = newWeapon:GetHoldType()
    if ( !holdType ) then return end

    holdType = HOLDTYPE_TRANSLATOR[holdType] or holdType

    local animTable = ow.animations.stored[class]
    if ( animTable and animTable[holdType] ) then
        client.owAnimations = animTable[holdType]
    else
        client.owAnimations = {}
    end

    net.Start("ow.animations.update")
        net.WritePlayer(client)
        net.WriteTable(client.owAnimations)
    net.Broadcast()
end