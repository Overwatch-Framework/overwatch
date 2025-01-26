--- Colors library
-- @module ow.color

ow.color = {}
ow.color.stored = ow.color.stored or {}

--- Registers a new color.
-- @realm shared
-- @param info A table containing information about the color.
function ow.color:Register(info)
    if ( !info.Name ) then
        ow.util:PrintError("Attempted to register a color without a name!")
        return
    end

    if ( !info.Color ) then
        ow.util:PrintError("Attempted to register a color without a color!")
        return
    end

    self.stored[info.Name] = info.Color
end

--- Gets a color by its name.
-- @realm shared
-- @param name The name of the color.
-- @return The color.
function ow.color:Get(name)
    if ( self.stored[name] ) then
        return self.stored[name]
    end

    ow.util:PrintError("Attempted to get an invalid color!")
    return
end