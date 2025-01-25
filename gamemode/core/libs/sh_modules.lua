--- A library for managing modules in the gamemode.
-- @module ow.module

ow.module = {}
ow.module.stored = {}

--- Registers a module.
-- @realm shared
-- @param table info The module information.
-- @return string The unique identifier of the module.
function ow.module:Register(info)
    if ( !info ) then
        ow.util:PrintError("Attempted to register an invalid module!")
        return
    end

    if ( !info.Name ) then
        info.Name = "Unknown"
    end

    if ( !info.Description ) then
        info.Description = "No description provided."
    end

    if ( !info.Author ) then
        info.Author = "Unknown"
    end

    local uniqueID = string.lower(string.gsub(info.Name, "%s", "-")) 
    info.UniqueID = uniqueID

    self.stored[uniqueID] = info

    return uniqueID
end

--- Returns a module by its unique identifier or name.
-- @realm shared
-- @param string identifier The unique identifier or name of the module.
-- @return table The module.
function ow.module:Get(identifier)
    if ( !identifier ) then
        ow.util:PrintError("Attempted to get an invalid module!")
        return
    end

    if ( self.stored[identifier] ) then
        return self.stored[identifier]
    end

    for k, v in pairs(self.stored) do
        if ( ow.util:FindString(v.Name, identifier) ) then
            return v
        elseif ( ow.util:FindString(v.UniqueID, identifier) ) then
            return v
        end
    end
end