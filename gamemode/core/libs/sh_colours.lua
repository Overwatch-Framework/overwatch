--- Colours library
-- @module ow.colour

ow.colour = {}
ow.colour.stored = {}

--- Registers a new colour.
-- @realm shared
-- @param info A table containing information about the colour.
function ow.colour:Register(name, colour)
    if ( !isstring(name) or #name == 0 ) then
        ow.util:PrintError("Attempted to register a colour without a name!")
        return false
    end

    if ( !IsColor(colour) ) then
        ow.util:PrintError("Attempted to register a colour without a colour!")
        return false
    end

    local bResult = hook.Run("PreColorRegistered", name, colour)
    if ( bResult == false ) then return false end

    self.stored[name] = colour
    hook.Run("OnColorRegistered", name, colour)
end

--- Gets a colour by its name.
-- @realm shared
-- @param name The name of the colour.
-- @param copy boolean Whether to return a copy of the colour (default: false).
-- @return The colour.
function ow.colour:Get(name, copy)
    if ( copy == nil ) then copy = false end

    local storedColour = self.stored[name]
    -- Copy ONLY if you intend to modify the colour
    if ( IsColor(storedColour) ) then
        return copy and Color(storedColour.r, storedColour.g, storedColour.b, storedColour.a) or storedColour
    end

    ow.util:PrintError("Attempted to get an invalid colour!")
    return false
end

--- Dims a colour by a specified fraction.
-- @realm shared
-- @param col Color The colour to dim.
-- @param frac number The fraction to dim the colour by.
-- @return Color The dimmed colour.
function ow.colour:Dim(col, frac)
    return Color(col.r * frac, col.g * frac, col.b * frac, col.a)
end

if ( CLIENT ) then
    concommand.Add("ow_list_colours", function(ply, cmd, args)
        for k, v in pairs(ow.colour.stored) do
            ow.util:Print("Colour: " .. k .. " >> ", ow.colour:Get("cyan"), v, " Colour Sample")
        end
    end)
end