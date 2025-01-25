ow.command:Register({
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

ow.command:Register({
    Name = "SetModel",
    Prefixes = {"SetModel"},
    AdminOnly = true,
    Callback = function(info, ply, arguments)
        local target = ow.util:FindPlayer(arguments[1])
        if ( !IsValid(target) ) then
            ow.util:PrintError("Attempted to set the model of an invalid player!", ply)
            return
        end

        local model = arguments[2]
        if ( !util.IsValidModel(model) ) then
            ow.util:PrintError("Attempted to set an invalid model!", ply)
            return
        end

        target:SetModel(model)

        ow.util:Print(ply, " set the model of ", target, " to ", model)
    end
})

ow.command:Register({
    Name = "SetFaction",
    Prefixes = {"SetFaction"},
    AdminOnly = true,
    Callback = function(info, ply, arguments)
        local target = ow.util:FindPlayer(arguments[1])
        if ( !IsValid(target) ) then
            ow.util:PrintError("Attempted to set the faction of an invalid player!", ply)
            return
        end

        local factionIdentifier = arguments[2]
        local faction = ow.faction:Get(factionIdentifier)
        if ( !faction ) then
            ow.util:PrintError("Attempted to set an invalid faction!", ply)
            return
        end

        --target:SetFaction(faction.Index)
        target:SetTeam(faction.Index)

        ow.util:Print(ply, " set the faction of ", target, " to ", faction.Name)
    end
})