--- Colors library
-- @module ow.color

ow.color = {}
ow.color.stored = {}

--- Registers a new color.
-- @realm shared
-- @param info A table containing information about the color.
function ow.color:Register(name, color)
    if ( name == nil or !isstring(name) or #name < 1 ) then
        ow.util:PrintError("Attempted to register a color without a name!")
        return false
    end

    if ( color == nil or !IsColor(color) ) then
        ow.util:PrintError("Attempted to register a color without a color!")
        return false
    end

    hook.Run("PreColorRegistered", name, color)
    self.stored[name] = color
    hook.Run("OnColorRegistered", name, color)
end

--- Gets a color by its name.
-- @realm shared
-- @param name The name of the color.
-- @return The color.
function ow.color:Get(name)
    if ( self.stored[name] ) then
        return table.Copy(self.stored[name])
    end

    ow.util:PrintError("Attempted to get an invalid color!")
    return
end

--- Dims a color by a specified fraction.
-- @realm shared
-- @param col Color The color to dim.
-- @param frac number The fraction to dim the color by.
-- @return Color The dimmed color.
function ow.color:Dim(col, frac)
    return Color(col.r * frac, col.g * frac, col.b * frac, col.a)
end