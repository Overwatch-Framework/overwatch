--- Font library.
-- @module ow.font

ow.font = {}
ow.font.stored = {}

surface.owCreateFont = surface.owCreateFont or surface.CreateFont

--- Registers a new font.
-- @realm client
-- @string name The name of the font.
-- @tab data The font data.
function surface.CreateFont(name, data)
    if ( name:StartsWith("ow") ) then
        ow.font.stored[name] = data
    end

    surface.owCreateFont(name, data)
end

--- Returns a font by its name.
-- @realm shared
-- @string name The name of the font.
-- @return tab The font.
function ow.font:Get(name)
    return self.stored[name]
end

concommand.Add("ow_font_list", function(ply)
    for name, data in pairs(ow.font.stored) do
        ow.util:Print("Font: " .. name)
        PrintTable(data)
    end
end)