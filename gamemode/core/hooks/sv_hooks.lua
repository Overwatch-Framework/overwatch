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
    hook.Run("PostPlayerLoadout", ply)
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

        ow.commands.Run(ply, command, arguments)

        return ""
    end
end

function GM:PlayerUseSpawnSaver(ply)
    return false
end