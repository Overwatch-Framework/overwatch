--- Commands library.
-- @module ow.command

ow.command = {}
ow.command.stored = {}

--- Registers a new command.
-- @realm shared
-- @tab info The information of the command.
-- @field string Name The name of the command.
-- @field func Callback The callback of the command.
-- @field tab Prefixes The prefixes of the command.
-- @field string MinAccess The minimum access of the command.
-- @field bool AdminOnly Whether the command is admin only.
-- @field bool SuperAdminOnly Whether the command is super admin only.
-- @field string UniqueID The unique identifier of the command.
-- @usage ow.command:Register({
--     Name = "example",
--     Callback = function(ply, args)
--         print("Example command executed!")
--     end,
--     Prefixes = {"example", "ex"},
--     MinAccess = "user"
-- })
function ow.command:Register(commandName, info)
    if ( !isstring(commandName) ) then
        ow.util:PrintError("Attempted to register an invalid command!")
        return
    end

    commandName = string.gsub(commandName, "%s+", " ")

    if ( !isfunction(info.Callback) ) then
        ow.util:PrintError("Attempted to register a command with no callback!")
        return
    end

    if ( !istable(info.Prefixes) ) then
        info.Prefixes = { commandName }
    end

    info.uniqueID = commandName
    self.stored[commandName] = info

    if ( CAMI != nil ) then
        CAMI.RegisterPrivilege({
            Name = "Overwatch - Commands - " .. commandName,
            MinAccess = ( info.SuperAdminOnly and "superadmin" ) or ( info.AdminOnly and "admin" ) or ( info.MinAccess or "user" )
        })
    end

    hook.Run("OnCommandRegistered", commandName, info)
end

--- Unregisters a command.
-- @realm shared
-- @string name The name of the command.
-- @internal
function ow.command:UnRegister(name)
    self.stored[name] = nil
    hook.Run("OnCommandUnRegistered", name)
end

--- Returns a command by its unique identifier or prefix.
-- @realm shared
-- @string identifier The unique identifier or prefix of the command.
-- @return table The command.
function ow.command:Get(identifier)
    if ( !isstring(identifier) ) then
        ow.util:PrintError("Attempted to get a command with invalid identifier!")
        return false
    end

    if ( self.stored[identifier] ) then
        return self.stored[identifier]
    end

    for _, v in pairs(self.stored) do
        for _, v2 in ipairs(v.Prefixes) do
            if ( ow.util:FindString(v2, identifier) ) then
                return v
            end
        end
    end

    ow.util:PrintError("Attempted to get a command with invalid identifier!")
    return false
end