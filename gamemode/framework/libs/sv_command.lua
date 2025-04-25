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
        ow.util:PrintError("Attempted to run a command with no command!", ply)
        return false
    end

    local info = self:Get(command)
    if ( !istable(info) ) then
        ow.util:PrintError("Attempted to run an invalid command!", ply)
        return false
    end

    if ( CAMI == nil ) then
        if ( info.AdminOnly and !ply:IsAdmin() ) then
            ow.util:PrintError("Attempted to run an admin-only command!", ply)
            return false
        end

        if ( info.SuperAdminOnly and !ply:IsSuperAdmin() ) then
            ow.util:PrintError("Attempted to run a superadmin-only command!", ply)
            return false
        end
    else
        if ( !CAMI.PlayerHasAccess(ply, "Overwatch - Commands - " .. info.uniqueID) ) then
            return false
        end
    end

    info:Callback(ply, arguments)
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

    if ( ply.owNextCommand and ply.owNextCommand > CurTime() ) then
        return
    end

    ow.util:Print("Commands:")

    for k, v in pairs(ow.command.stored) do
        if ( !CAMI.PlayerHasAccess(ply, "Overwatch - Commands - " .. k) ) then
            continue
        end

        if ( v.Description ) then
            ow.util:Print("/" .. v.Name .. " - " .. v.Description)
        else
            ow.util:Print("/" .. v.Name)
        end
    end

    ply.owNextCommand = CurTime() + 1
end--[[, function(cmd, argStr, args)
    local commands = {}

    for k, v in pairs(ow.command.stored) do
        table.insert(commands, cmd .. " " .. v.Name)
    end

    return commands
end, "Lists all available commands."]])
-- TODO: Add auto-complete for commands