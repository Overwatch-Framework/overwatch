--- Colours library
-- @module ow.color

ow.color = {}
ow.color.stored = {}

--- Registers a new color.
-- @realm shared
-- @param info A table containing information about the color.
function ow.color:Register(name, color)
    if ( !isstring(name) or #name == 0 ) then
        ow.util:PrintError("Attempted to register a color without a name!")
        return false
    end

    if ( !IsColor(color) ) then
        ow.util:PrintError("Attempted to register a color without a color!")
        return false
    end

    local bResult = hook.Run("PreColorRegistered", name, color)
    if ( bResult == false ) then return false end

    self.stored[name] = color
    hook.Run("OnColorRegistered", name, color)
end

--- Gets a color by its name.
-- @realm shared
-- @param name The name of the color.
-- @param copy boolean Whether to return a copy of the color (default: false).
-- @return The color.
function ow.color:Get(name, copy)
    if ( copy == nil ) then copy = false end

    local storedColour = self.stored[name]
    -- Copy ONLY if you intend to modify the color
    if ( IsColor(storedColour) ) then
        return copy and Color(storedColour.r, storedColour.g, storedColour.b, storedColour.a) or storedColour
    end

    ow.util:PrintError("Attempted to get an invalid color!")
    return false
end

--- Dims a color by a specified fraction.
-- @realm shared
-- @param col Color The color to dim.
-- @param frac number The fraction to dim the color by.
-- @return Color The dimmed color.
function ow.color:Dim(col, frac)
    return Color(col.r * frac, col.g * frac, col.b * frac, col.a)
end

if ( CLIENT ) then
    concommand.Add("ow_list_colours", function(ply, cmd, args)
        for k, v in pairs(ow.color.stored) do
            ow.util:Print("Colour: " .. k .. " >> ", ow.color:Get("cyan"), v, " Colour Sample")
        end
    end)
end