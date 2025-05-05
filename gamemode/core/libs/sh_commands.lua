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

    if ( !isfunction(info.GetDescription) ) then
        function info:GetDescription()
            return info.Description or "No description provided."
        end
    end

    info.UniqueID = commandName
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

    for k, v in pairs(self.stored) do
        if ( string.lower(k) == string.lower(identifier) ) then
            return v
        end
    end

    for _, v in pairs(self.stored) do
        if ( !istable(v.Prefixes) ) then continue end

        for _, v2 in ipairs(v.Prefixes) do
            if ( string.lower(v2) == string.lower(identifier) ) then
                return v
            end
        end
    end

    ow.util:PrintError("Attempted to get a command with invalid identifier!")
    return false
end

function ow.command:ParseArguments(arguments)
    local args = {}
    local bQuoted = false
    local buffer = ""

    for i = 1, #arguments do
        local char = arguments[i]

        if ( char == "\"" ) then
            bQuoted = !bQuoted
        elseif ( char == " " and !bQuoted ) then
            if ( buffer != "" ) then
                table.insert(args, buffer)
                buffer = ""
            end
        else
            buffer = buffer .. char
        end
    end

    if ( buffer != "" ) then
        table.insert(args, buffer)
    end

    for i, v in ipairs(args) do
        if ( string.sub(v, 1, 1) == "\"" and string.sub(v, -1) == "\"" ) then
            args[i] = string.sub(v, 2, -2)
        end
    end

    return args
end

function ow.command:SanitiseArguments(command, arguments)
    local commandInfo = self:Get(command)
    if ( !istable(commandInfo) ) then return false end

    local commandArgs = commandInfo.Arguments

    local sanitised = {}
    for k, v in ipairs(commandArgs) do
        if ( bit.band(v, ow.type.optional) == ow.type.optional ) then
            if ( arguments[k] == nil ) then
                sanitised[k] = nil
                continue
            end

            v = bit.band(v, bit.bnot(ow.type.optional))
        end

        sanitised[k] = ow.util:SanitizeType(v, arguments[k])
    end

    return sanitised
end