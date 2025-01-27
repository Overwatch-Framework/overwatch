--- Commands library.
-- @module ow.command

ow.command = {}
ow.command.stored = {}

--- Registers a new command.
-- @realm shared
-- @param table info The command information.
-- @return table The command information.
function ow.command:Register(info)
    if ( !info ) then
        ow.util:PrintError("Attempted to register an invalid command!")
        return
    end

    if ( !info.Name ) then
        ow.util:PrintError("Attempted to register a command with no name!")
        return
    end

    if ( !info.Callback ) then
        ow.util:PrintError("Attempted to register a command with no callback!")
        return
    end

    if ( !info.Prefixes ) then
        ow.util:PrintError("Attempted to register a command with no prefixes!")
        return
    end

    local uniqueID = string.lower(string.gsub(info.Name, "%s", "_"))
    uniqueID = info.UniqueID or uniqueID

    self.stored[uniqueID] = info

    if ( CAMI ) then
        CAMI.RegisterPrivilege({
            Name = "Overwatch - Commands - " .. info.Name,
            MinAccess = info.MinAccess or "user"
        })
    end
end

--- Unregisters a command.
-- @realm shared
-- @param string name The name of the command.
-- @internal
function ow.command:UnRegister(name)
    self.stored[name] = nil
end

--- Returns a command by its unique identifier or prefix.
-- @realm shared
-- @param string identifier The unique identifier or prefix of the command.
-- @return table The command.
function ow.command:Get(identifier)
    if ( !identifier ) then
        ow.util:PrintError("Attempted to get an invalid command!")
        return
    end

    if ( self.stored[identifier] ) then
        return self.stored[identifier]
    end

    for k, v in pairs(self.stored) do
        for k2, v2 in ipairs(v.Prefixes) do
            if ( ow.util:FindString(v2, identifier) ) then
                return v
            end
        end
    end

    ow.util:PrintError("Attempted to get an invalid command!")

    return
end