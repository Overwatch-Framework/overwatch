ow.commands:Register({
    Name = "Respawn",
    Prefixes = {"Respawn"},
    AdminOnly = true,
    Callback = function(info, ply, arguments)
        local target = ow.util:FindPlayer(arguments[1])
        if ( !IsValid(target) ) then
            ow.util:PrintError("Attempted to respawn an invalid player!", ply)
            return
        end

        target:KillSilent()
        target:Spawn()

        ow.util:Print(ply, " respawned ", target)
    end
})