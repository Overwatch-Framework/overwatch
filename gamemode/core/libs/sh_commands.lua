--- Commands library.
-- @module ow.commands

ow.commands = ow.commands or {}
ow.commands.stored = ow.commands.stored or {}

--- Registers a new command.
-- @realm shared
-- @param table info The command information.
-- @return table The command information.
function ow.commands.Register(info)
    if ( !info ) then
        ow.util.PrintError("Attempted to register an invalid command!")
        return
    end

    if ( !info.Name ) then
        ow.util.PrintError("Attempted to register a command with no name!")
        return
    end

    if ( !info.Callback ) then
        ow.util.PrintError("Attempted to register a command with no callback!")
        return
    end

    if ( !info.Prefixes ) then
        ow.util.PrintError("Attempted to register a command with no prefixes!")
        return
    end

    local uniqueID = string.lower(string.gsub(info.Name, "%s", "_"))
    uniqueID = info.uniqueID or uniqueID

    ow.commands.stored[uniqueID] = info

    return info
end

--- Unregisters a command.
-- @realm shared
-- @param string name The name of the command.
-- @internal
function ow.commands.UnRegister(name)
    ow.commands.stored[name] = nil
end

--- Returns a command by its unique identifier or prefix.
-- @realm shared
-- @param string identifier The unique identifier or prefix of the command.
-- @return table The command.
function ow.commands.Get(identifier)
    if ( !identifier ) then
        ow.util.PrintError("Attempted to get an invalid command!")
        return
    end

    if ( ow.commands.stored[identifier] ) then
        return ow.commands.stored[identifier]
    end

    for k, v in pairs(ow.commands.stored) do
        for k2, v2 in pairs(v.Prefixes) do
            if ( ow.util.FindString(v2, identifier) ) then
                return v
            end
        end
    end

    ow.util.PrintError("Attempted to get an invalid command!")

    return
end

if ( CLIENT ) then
    return
end

--- Runs a command.
-- @realm server
-- @param Player ply The player running the command.
-- @param string command The command to run.
-- @param table arguments The arguments of the command.
function ow.commands.Run(ply, command, arguments)
    if ( !IsValid(ply) ) then
        ow.util.PrintError("Attempted to run a command with no player!")
        return
    end

    if ( !command ) then
        ow.util.PrintError("Attempted to run a command with no command!", ply)
        return
    end

    local info = ow.commands.Get(command)
    if ( !info ) then
        ow.util.PrintError("Attempted to run an invalid command!", ply)
        return
    end

    if ( info.AdminOnly and !ply:IsAdmin() ) then
        ow.util.PrintError("Attempted to run an admin-only command!", ply)
        return
    end

    if ( info.SuperAdminOnly and !ply:IsSuperAdmin() ) then
        ow.util.PrintError("Attempted to run a superadmin-only command!", ply)
        return
    end

    info:Callback(ply, arguments)
end

concommand.Add("ms_command_run", function(ply, cmd, arguments)
    if ( !IsValid(ply) ) then
        ow.util.PrintError("Attempted to run a command with no player!")
        return
    end

    local command = arguments[1]
    table.remove(arguments, 1)

    ow.commands.Run(ply, command, arguments)

    ply.owNextCommand = CurTime() + 1
end)

concommand.Add("ms_command_list", function(ply, cmd, arguments)
    if ( !IsValid(ply) ) then
        ow.util.PrintError("Attempted to list commands with no player!")
        return
    end

    if ( ply.owNextCommand and ply.owNextCommand > CurTime() ) then
        return
    end

    ow.util.Print("Commands:")

    for k, v in pairs(ow.commands.stored) do
        if ( v.AdminOnly and !ply:IsAdmin() ) then
            continue
        end

        if ( v.SuperAdminOnly and !ply:IsSuperAdmin() ) then
            continue
        end

        if ( v.Description ) then
            ow.util.Print("/" .. v.Name .. " - " .. v.Description)
        else
            ow.util.Print("/" .. v.Name)
        end
    end

    ply.owNextCommand = CurTime() + 1
end)