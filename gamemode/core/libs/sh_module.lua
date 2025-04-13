--- A library for managing modules in the gamemode.
-- @module ow.module

ow.module = {}
ow.module.stored = {}
ow.module.disabled = {}

--- Returns a module by its unique identifier or name.
-- @realm shared
-- @string identifier The unique identifier or name of the module.
-- @return table The module.
function ow.module:Get(identifier)
    if ( identifier == nil or !isstring(identifier) ) then
        ow.util:PrintError("Attempted to get an invalid module!")
        return false
    end

    if ( self.stored[identifier] ) then
        return self.stored[identifier]
    end

    for k, v in pairs(self.stored) do
        if ( ow.util:FindString(v.Name, identifier) ) then
            return v
        end
    end

    return false
end