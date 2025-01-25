local loadQueue = {}
function GM:PlayerInitialSpawn(ply)
    loadQueue[ply] = true
end

function GM:StartCommand(ply, cmd)
    if ( loadQueue[ply] and !cmd:IsForced() ) then
        loadQueue[ply] = nil
        
        hook.Call("PostPlayerInitialSpawn", ply)
    end
end

function GM:PostPlayerInitialSpawn(ply)
end

function GM:PlayerDisconnected(ply)
end

function GM:PlayerSpawn(ply)
    hook.Call("PlayerLoadout", ply)
end

function GM:PlayerLoadout(ply)
    ply:Give("weapon_physgun")
    ply:Give("gmod_tool")

    hook.Call("PostPlayerLoadout", ply)
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