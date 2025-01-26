local loadQueue = {}
function GM:PlayerInitialSpawn(ply)
    loadQueue[ply] = true
end

function GM:StartCommand(ply, cmd)
    if ( loadQueue[ply] and !cmd:IsForced() ) then
        loadQueue[ply] = nil
        
        hook.Run("PostPlayerInitialSpawn", ply)
    end
end

function GM:PostPlayerInitialSpawn(ply)
end

function GM:PlayerDisconnected(ply)
end

function GM:PlayerSpawn(ply)
    hook.Run("PlayerLoadout", ply)
end

function GM:PlayerLoadout(ply)
    if ( ply:IsAdmin() ) then
        ply:Give("weapon_physgun")
        ply:Give("gmod_tool")
    end

    ply:Give("ow_hands")
    ply:SelectWeapon("ow_hands")

    ply:SetWalkSpeed(ow.config.walkSpeed or 80)
    ply:SetRunSpeed(ow.config.runSpeed or 180)
    ply:SetJumpPower(ow.config.jumpPower or 160)

    ply:SetupHands()

    hook.Run("PostPlayerLoadout", ply)

    return true
end

function GM:PostPlayerLoadout(ply)
end

function GM:PlayerDeathThink(ply)
    if ( ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_ATTACK2) or ply:KeyPressed(IN_JUMP) ) then
        ply:Spawn()
    end
end

function GM:PlayerSay(ply, text, teamChat)
    if ( string.sub(text, 1, 1) == "/" ) then
        local arguments = string.Explode(" ", string.sub(text, 2))
        local command = arguments[1]
        table.remove(arguments, 1)

        ow.command:Run(ply, command, arguments)
    else
        ow.chat:Send(ply, "ic", text)

    end

    return ""
end

function GM:PlayerUseSpawnSaver(ply)
    return false
end

function GM:Initialize()
    ow.database:Initialize()
end

function GM:SetupPlayerVisibility(ply, viewEntity)
    if ( ply:Team() == 0 and ow.config.menuCamPos ) then
        AddOriginToPVS(ow.config.menuCamPos)
    end
end