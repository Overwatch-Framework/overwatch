ow.command:Register("Respawn", {
    Description = "Respawn a player.",
    AdminOnly = true,
    Callback = function(info, ply, arguments)
        local target = ow.util:FindPlayer(arguments[1])
        if ( !IsValid(target) ) then
            ow.util:PrintError("Attempted to respawn an invalid player!", ply)
            ply:Notify("You must provide a valid player to respawn!")
            return
        end

        if ( target:GetCharacter() == nil ) then
            ply:Notify("The targeted player does not have a character!")
            return
        end

        target:KillSilent()
        target:Spawn()

        ply:Notify("You have respawned " .. target:Nick() .. ".", NOTIFY_HINT)
    end
})

ow.command:Register("SetModel", {
    Description = "Set the model of a player.",
    AdminOnly = true,
    AutoComplete = function(ply, split)
        local suggestions = {}
        for _, v in player.Iterator() do
            table.insert(suggestions, "/SetModel " .. v:Nick())
        end

        return suggestions
    end,
    Callback = function(info, ply, arguments)
        local target = ow.util:FindPlayer(arguments[1])
        if ( !IsValid(target) ) then
            ply:Notify("You must provide a valid player to set the model of!")
            return
        end

        local model = arguments[2]
        if ( !isstring(model) or model == "" or !string.StartsWith(model, "models/") ) then
            ply:Notify("You must provide a valid model to set!")
            return
        end

        if ( string.lower(model) == string.lower(target:GetModel()) ) then
            ply:Notify("The targeted player already has that model!")
            return
        end

        local character = target:GetCharacter()
        if ( !character ) then
            ply:Notify("The targeted player does not have a character!")
            return
        end

        character:SetModel(model)

        ply:Notify("You have set the model of " .. target:Nick() .. " to " .. model .. ".", NOTIFY_HINT)
    end
})

ow.command:Register("SetFaction", {
    Description = "Set the faction of a player.",
    AdminOnly = true,
    Callback = function(info, ply, arguments)
        local target = ow.util:FindPlayer(arguments[1])
        if ( !IsValid(target) ) then
            ply:Notify("You must provide a valid player to set the faction of!")
            return
        end

        local factionIdentifier = arguments[2]
        local faction = ow.faction:Get(factionIdentifier)
        if ( !faction ) then
            ply:Notify("You must provide a valid faction to set!")
            return
        end

        local character = target:GetCharacter()
        if ( !character ) then
            ply:Notify("The targeted player does not have a character!")
            return
        end

        character:SetFaction(faction:GetID())
        ow.faction:Join(target, faction:GetID(), true)

        ply:Notify("You have set the faction of " .. target:Nick() .. " to " .. faction.Name .. ".", NOTIFY_HINT)
    end
})