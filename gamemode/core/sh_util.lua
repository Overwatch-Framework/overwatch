--- Utility functions
-- @module ow.util

--- Sends a chat message to the player.
-- @realm shared
-- @param ply Player The player to send the message to.
-- @param ... any The message to send.
function ow.util:SendChatText(ply, ...)
    if ( !IsValid(ply) ) then return end

    if ( SERVER ) then
        net.Start("ow.chat.text")
            net.WriteTable({...})
        net.Send(ply)
    else
        chat.AddText(...)
    end
end

--- Prepares a package for printing to either the chat or console. This is useful for chat messages that need to be colored.
-- @realm shared
-- @param ... any The package to prepare.
-- @return any The prepared package.
function ow.util:PreparePackage(...)
    local args = {...}
    local package = {}

    for k, v in ipairs(args) do
        if ( type(v) == "Player" ) then
            table.insert(package, team.GetColor(v:Team()))
            table.insert(package, v:Name())
        else
            table.insert(package, v)
        end
    end

    table.insert(package, "\n")

    return package
end

--- Prints a message to the console.
-- @realm shared
-- @param ... any The message to print.
function ow.util:Print(...)
    local args = self:PreparePackage(...)

    MsgC(hook.Run("GetFrameworkColor"), "Overwatch | ", unpack(args))

    return args
end

--- Prints an error message to the console.
-- @realm shared
-- @param ... any The message to print.
function ow.util:PrintError(...)
    local args = self:PreparePackage(...)

    MsgC(hook.Run("GetFrameworkColor"), "Overwatch | ", Color(200, 0, 0), "Error | ", color_white, unpack(args))

    return args
end

--- Prints a warning message to the console.
-- @realm shared
-- @param ... any The message to print.
function ow.util:PrintWarning(...)
    local args = self:PreparePackage(...)

    MsgC(hook.Run("GetFrameworkColor"), "Overwatch | ", Color(200, 100, 50), "Warning | ", color_white, unpack(args))

    return args
end

--- Loads a file based on the realm.
-- @realm shared
-- @param path string The path to the file.
-- @param realm string The realm to load the file in.
function ow.util:LoadFile(path, realm)
    if ( !path ) then
        self:PrintError("Failed to load file " .. path .. "!")
        return
    end

    if ( ( realm == "server" or string.find(path, "sv_") ) and SERVER ) then
        include(path)
    elseif ( realm == "shared" or string.find(path, "shared.lua") or string.find(path, "sh_") ) then
        if ( SERVER ) then
            AddCSLuaFile(path)
        end

        include(path)
    elseif ( realm == "client" or string.find(path, "cl_") ) then
        if ( SERVER ) then
            AddCSLuaFile(path)
        else
            include(path)
        end
    end
end

--- Loads all files in a folder based on the realm.
-- @realm shared
-- @param directory string The directory to load the files from.
-- @param bFromLua boolean Whether or not the files are being loaded from Lua.
function ow.util:LoadFolder(directory, bFromLua)
    local baseDir = debug.getinfo(2).source
    baseDir = string.sub(baseDir, 2, string.find(baseDir, "/[^/]*$"))
    baseDir = string.gsub(baseDir, "gamemodes/", "")

    if ( bFromLua ) then
        baseDir = ""
    end

    for k, v in ipairs(file.Find(baseDir .. directory .. "/*.lua", "LUA")) do
        if ( !file.Exists(baseDir .. directory .. "/" .. v, "LUA") ) then
            self:PrintError("Failed to load file " .. baseDir .. directory .. "/" .. v .. "!")
            continue
        end

        self:LoadFile(baseDir .. directory .. "/" .. v)
    end

    return true
end

--- Returns the type of a value.
-- @realm shared
-- @param value any The value to check.
-- @return string The type of the value.
function ow.util:FindString(str, find, bPatterns)
    if ( !str or !find ) then return false end
    if ( bPatterns == nil ) then bPatterns = true end

    return tobool(string.find(string.lower(str), string.lower(find), 1, bPatterns))
end

--- Searches a given text for the specified value.
-- @realm shared
-- @param txt string The text to search.
-- @param find string The value to search for.
-- @return boolean Whether or not the value was found.
function ow.util:FindText(txt, find)
    if ( !txt or !find ) then return end

    local words = string.Explode(" ", txt)
    for k, v in ipairs(words) do
        if ( self:FindString(v, find) ) then
            return true
        end
    end

    return false
end

--- Searches for a player based on the given identifier.
-- @realm shared
-- @param identifier any The identifier to search for.
-- @return Player The player that was found.
function ow.util:FindPlayer(identifier)
    if ( !identifier ) then return end

    if ( type(identifier) == "Player" ) then
        return identifier
    end

    if ( type(identifier) == "string" ) then
        for k, v in player.Iterator() do
            if ( self:FindString(v:Name(), identifier) or self:FindString(v:SteamID(), identifier) or self:FindString(v:SteamID64(), identifier) ) then
                return v
            end
        end
    end

    if ( type(identifier) == "number" ) then
        return Player(identifier)
    end

    if ( type(identifier) == "table" ) then
        for k, v in ipairs(identifier) do
            return self:FindPlayer(v)
        end
    end
end

--- Gets the bounds of a box, providing the center, minimum, and maximum points.
-- @realm shared
-- @param startpos Vector The starting position of the box.
-- @param endpos Vector The ending position of the box.
-- @return Vector The center of the box.
function ow.util:GetBounds(startpos, endpos)
	local center = LerpVector(0.5, startpos, endpos)
	local min = WorldToLocal(startpos, angle_zero, center, angle_zero)
	local max = WorldToLocal(endpos, angle_zero, center, angle_zero)

    return center, min, max
end

--- Converts a vector to a color.
-- @realm shared
-- @param vec Vector The vector to convert.
-- @param alpha number The alpha value of the color.
-- @return Color The color that was created.
function ow.util:VectorToColor(vec, alpha)
    return Color(vec.x * 255, vec.y * 255, vec.z * 255, alpha or 255)
end

--- Converts a color to a vector.
-- @realm shared
-- @param col Color The color to convert.
-- @return Vector The vector that was created.
function ow.util:ColorToVector(col)
    return Vector(col.r / 255, col.g / 255, col.b / 255)
end

--- Dims a color by a specified fraction.
-- @realm shared
-- @param col Color The color to dim.
-- @param frac number The fraction to dim the color by.
-- @return Color The dimmed color.
function ow.util:ColorDim(col, frac)
    return Color(col.r * frac, col.g * frac, col.b * frac, col.a)
end

--- Randomizes a color within a specified range.
-- @realm shared
-- @param min number The minimum value of the color.
-- @param max number The maximum value of the color.
-- @return Color The randomized color.
function ow.util:ColorRandom(min, max)
    min = min or 0
    max = max or 255

    return Color(math.random(min, max), math.random(min, max), math.random(min, max))
end

if ( CLIENT ) then
    local blur = Material("pp/blurscreen")
    local defaultAmount = 1
    local defaultPasses = 0.1

    --- Draws blur on a panel.
    -- @realm client
    -- @param panel Panel The panel to draw the blur on.
    -- @param amount number The amount of blur to apply.
    -- @param passes number The number of passes to apply.
    function ow.util:DrawBlur(panel, amount, passes)
        amount = amount or defaultAmount
        passes = passes or defaultPasses

        local x, y = panel:LocalToScreen(0, 0)
        local scrW, scrH = ScrW(), ScrH()

        surface.SetDrawColor(color_white)
        surface.SetMaterial(blur)

        for i = -passes, 1, 0.2 do
            blur:SetFloat("$blur", ( i / passes ) * amount)
            blur:Recompute()

            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
        end
    end

    --- Draws a blurred rectangle.
    -- @realm client
    -- @param x number The x position of the rectangle.
    -- @param y number The y position of the rectangle.
    -- @param w number The width of the rectangle.
    -- @param h number The height of the rectangle.
    -- @param amount number The amount of blur to apply.
    -- @param passes number The number of passes to apply.
    function ow.util:DrawBlurRect(x, y, w, h, amount, passes)
        amount = amount or defaultAmount
        passes = passes or defaultPasses

        surface.SetDrawColor(color_white)
        surface.SetMaterial(blur)

        for i = -passes, 1, 0.2 do
            blur:SetFloat("$blur", ( i / passes ) * amount)
            blur:Recompute()

            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
        end
    end

    --- Returns the given text's width.
    -- @realm client
    -- @param font string The font to use.
    -- @param text string The text to measure.
    -- @return number The width of the text.
    function ow.util:GetTextWidth(font, text)
        surface.SetFont(font)
        return select(1, surface.GetTextSize(text))
    end

    --- Returns the given text's height.
    -- @realm client
    -- @param font string The font to use.
    -- @return number The height of the text.
    function ow.util:GetTextHeight(font)
        surface.SetFont(font)
        return select(2, surface.GetTextSize("W"))
    end

    --- Returns the given text's size.
    -- @realm client
    -- @param font string The font to use.
    -- @param text string The text to measure.
    -- @return number The width of the text.
    -- @return number The height of the text.
    function ow.util:GetTextSize(font, text)
        surface.SetFont(font)
        return surface.GetTextSize(text)
    end
end