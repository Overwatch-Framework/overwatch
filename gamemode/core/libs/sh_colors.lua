--- Colors library
-- @module ow.colors

ow.colors = {}
ow.colors.stored = ow.colors.stored or {}

--- Registers a new color.
-- @realm shared
-- @param info A table containing information about the color.
function ow.colors:Register(info)
    if ( !info.Name ) then
        ow.util.PrintError("Attempted to register a color without a name!")
        return
    end

    if ( !info.Color ) then
        ow.util.PrintError("Attempted to register a color without a color!")
        return
    end

    self.stored[info.Name] = info.Color
end

--- Gets a color by its name.
-- @realm shared
-- @param name The name of the color.
-- @return The color.
function ow.colors:Get(name)
    for k, v in pairs(self.stored) do
        if ( k == name ) then
            return v
        end
    end

    ow.util.PrintError("Attempted to get an invalid color!")

    return
end

-- Default colors
ow.colors:Register({Name = "white", Color = color_white})
ow.colors:Register({Name = "black", Color = color_black})
ow.colors:Register({Name = "red", Color = Color(255, 0, 0, 255)})
ow.colors:Register({Name = "green", Color = Color(0, 255, 0, 255)})
ow.colors:Register({Name = "blue", Color = Color(0, 0, 255, 255)})
ow.colors:Register({Name = "yellow", Color = Color(255, 255, 0, 255)})
ow.colors:Register({Name = "orange", Color = Color(255, 165, 0, 255)})
ow.colors:Register({Name = "purple", Color = Color(128, 0, 128, 255)})
ow.colors:Register({Name = "pink", Color = Color(255, 192, 203, 255)})
ow.colors:Register({Name = "cyan", Color = Color(0, 255, 255, 255)})
ow.colors:Register({Name = "brown", Color = Color(165, 42, 42, 255)})
ow.colors:Register({Name = "gray", Color = Color(128, 128, 128, 255)})
ow.colors:Register({Name = "light.gray", Color = Color(211, 211, 211, 255)})
ow.colors:Register({Name = "dark.gray", Color = Color(169, 169, 169, 255)})
ow.colors:Register({Name = "lime", Color = Color(0, 255, 0, 255)})
ow.colors:Register({Name = "maroon", Color = Color(128, 0, 0, 255)})
ow.colors:Register({Name = "navy", Color = Color(0, 0, 128, 255)})
ow.colors:Register({Name = "olive", Color = Color(128, 128, 0, 255)})
ow.colors:Register({Name = "silver", Color = Color(192, 192, 192, 255)})

-- Framework colors
ow.colors:Register({Name = "background", Color = Color(30, 30, 30, 255)})
ow.colors:Register({Name = "foreground", Color = Color(50, 50, 50, 255)})
ow.colors:Register({Name = "text", Color = Color(200, 200, 200, 255)})
ow.colors:Register({Name = "text.light", Color = Color(255, 255, 255, 255)})