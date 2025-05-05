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

ow.command:Register("CharGiveFlags", {
    Description = "Give a character a flag.",
    AdminOnly = true,
    Callback = function(info, ply, arguments)
        local target = ow.util:FindPlayer(arguments[1])
        if ( !IsValid(target) ) then
            ply:Notify("You must provide a valid player to give a flag to!")
            return
        end

        local flags = arguments[2]
        if ( !isstring(flags) or #flags == 0 ) then
            ply:Notify("You must provide either single flag or a set of flags!")
            return
        end

        local character = target:GetCharacter()
        if ( !character ) then
            ply:Notify("The targeted player does not have a character!")
            return
        end

        local given = {}
        for i = 1, #flags do
            local flag = flags[i]
            table.insert(given, flag)
        end

        -- Check if the flags are valid
        local validFlags = true
        for i = 1, #given do
            local flag = given[i]
            if ( !ow.flag:Get(flag) ) then
                validFlags = false
                break
            end
        end

        if ( !validFlags ) then
            ply:Notify("You must provide valid flags to give!")
            return
        end

        -- Check if we already have all the flags
        local hasAllFlags = true
        for k, v in ipairs(given) do
            if ( !character:HasFlag(v) ) then
                hasAllFlags = false
            end
        end

        if ( hasAllFlags ) then
            ply:Notify("They already have all the flags you are trying to give!")
            return
        end

        -- Give the flags to the character
        for k, v in ipairs(given) do
            character:GiveFlag(v)
        end

        local flagString = table.concat(given, ", ")
        ply:Notify("You have given " .. target:Nick() .. " the flag(s) \"" .. flagString .. "\".", NOTIFY_HINT)
        target:Notify("You have been given the flag(s) \"" .. flagString .. "\" for your character!", NOTIFY_HINT)
    end
})

ow.command:Register("CharTakeFlags", {
    Description = "Take a flag from a character.",
    AdminOnly = true,
    Arguments = {
        ow.type.player,
        ow.type.string,
        bit.bor(ow.type.number, ow.type.optional) -- TODO: Doesn't work
    },
    Callback = function(info, ply, target, flags, number)
        if ( !IsValid(target) ) then
            ply:Notify("You must provide a valid player to take a flag from!")
            return
        end

        if ( !isstring(flags) or #flags == 0 ) then
            ply:Notify("You must provide either single flag or a set of flags!")
            return
        end

        local character = target:GetCharacter()
        if ( !character ) then
            ply:Notify("The targeted player does not have a character!")
            return
        end

        local taken = {}
        for i = 1, #flags do
            local flag = flags[i]
            table.insert(taken, flag)
        end

        -- Check if the flags are valid
        local validFlags = true
        for i = 1, #taken do
            local flag = taken[i]
            if ( !ow.flag:Get(flag) ) then
                validFlags = false
                break
            end
        end

        if ( !validFlags ) then
            ply:Notify("You must provide valid flags to take!")
            return
        end

        -- Check if we already dont have the flags we are trying to take
        local hasNoFlags = true
        for k, v in ipairs(taken) do
            if ( character:HasFlag(v) ) then
                hasNoFlags = false
            end
        end

        if ( hasNoFlags ) then
            ply:Notify("They already don't have the flags you are trying to take!")
            return
        end

        -- Take the flags from the character
        for k, v in ipairs(taken) do
            character:TakeFlag(v)
        end

        local flagString = table.concat(taken, ", ")
        ply:Notify("You have taken the flag(s) \"" .. flagString .. "\" from " .. target:Nick() .. ".", NOTIFY_HINT)
        target:Notify("You have had the flag(s) \"" .. flagString .. "\" taken from your character!", NOTIFY_HINT)
    end
})

ow.command:Register("ToggleRaise", {
    Callback = function(info, ply)
        ply:ToggleWeaponRaise()
    end
})