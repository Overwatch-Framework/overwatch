--- Command library
-- @module ow.command

--- Runs a command.
-- @realm server
-- @player ply The player running the command.
-- @string command The command to run.
-- @tab arguments The arguments of the command.
function ow.command:Run(ply, command, arguments)
    if ( !IsValid(ply) ) then
        ow.util:PrintError("Attempted to run a command with no player!")
        return false
    end

    if ( !isstring(command) ) then
        ply:Notify("You must provide a command to run!")
        return false
    end

    local info = self:Get(command)
    if ( !istable(info) ) then
        ply:Notify("This command does not exist!")
        return false
    end

    if ( CAMI == nil ) then
        if ( info.AdminOnly and !ply:IsAdmin() ) then
            ply:Notify("You must be an admin to run this command!")
            return false
        end

        if ( info.SuperAdminOnly and !ply:IsSuperAdmin() ) then
            ply:Notify("You must be a superadmin to run this command!")
            return false
        end
    else
        if ( !CAMI.PlayerHasAccess(ply, "Overwatch - Commands - " .. info.UniqueID) ) then
            return false
        end
    end

    local argumentTable = self:ParseArguments(arguments)
    if ( #argumentTable != #info.Arguments ) then
        ply:Notify("You must provide " .. #info.Arguments .. " arguments!")
        return false
    end

    local argumentVarArgs = self:SanitiseArguments(command, argumentTable)

    info:Callback(ply, unpack(argumentVarArgs))
    hook.Run("OnCommandRan", ply, command, arguments)
    return true, arguments
end

concommand.Add("ow_command_run", function(ply, cmd, arguments)
    if ( !IsValid(ply) ) then
        ow.util:PrintError("Attempted to run a command with no player!")
        return
    end

    local command = arguments[1]
    table.remove(arguments, 1)

    ow.command:Run(ply, command, arguments)

    ply.owNextCommand = CurTime() + 1
end)

concommand.Add("ow_command", function(ply, cmd, arguments)
    if ( !IsValid(ply) ) then
        ow.util:PrintError("Attempted to list commands with no player!")
        return
    end

    local plyTable = ply:GetTable()
    if ( plyTable.owNextCommand and plyTable.owNextCommand > CurTime() ) then
        return
    end

    ow.util:Print("Commands:")

    for k, v in pairs(ow.command.stored) do
        if ( !CAMI.PlayerHasAccess(ply, "Overwatch - Commands - " .. k) ) then
            continue
        end

        ow.util:Print("/" .. v.Name .. (v.Description and " - " .. v.Description or ""))
    end

    plyTable.owNextCommand = CurTime() + 1
end--[[, function(cmd, argStr, args)
    local commands = {}

    for k, v in pairs(ow.command.stored) do
        table.insert(commands, cmd .. " " .. v.Name)
    end

    return commands
end, "Lists all available commands."]])
-- TODO: Add auto-complete for commands