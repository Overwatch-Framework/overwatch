--- Utility functions
-- @module ow.util

--- A table of variable types that are used throughout the framework. It represents types as a table with the keys being the
-- name of the type, and the values being some number value. **You should never directly use these number values!** Using the
-- values from this table will ensure backwards compatibility if the values in this table change.
--
-- This table also contains the numerical values of the types as keys. This means that if you need to check if a type exists, or
-- if you need to get the name of a type, you can do a table lookup with a numerical value. Note that special types are not
-- included since they are not real types that can be compared with.
-- @table ow.type
-- @realm shared
-- @field string A regular string.
-- @field text A regular string that can contain newlines.
-- @field number Any number.
-- @field player Any player that matches the given query string in `ow.util.FindPlayer`.
-- @field steamid A string that matches the Steam ID format of `STEAM_X:X:XXXXXXXX`.
-- @field character Any player's character that matches the given query string in `ow.util.FindPlayer`.
-- @field bool A string representation of a bool - `false` and `0` will return `false`, anything else will return `true`.
-- @field color A color represented by its red/green/blue/alpha values.
-- @field vector A 3D vector represented by its x/y/z values.
-- @field optional This is a special type that can be bitwise OR'd with any other type to make it optional.
-- @field array This is a special type that can be bitwise OR'd with any other type to make it an array of that type.
-- @usage -- checking if type exists
-- print(ow.type[2] != nil)
-- > true
--
-- -- getting name of type
-- print(ow.type[ow.type.string])
-- > "string"

ow.type = ow.type or {
    [2] = "string",
    [4] = "text",
    [8] = "number",
    [16] = "player",
    [32] = "steamid",
    [64] = "character",
    [128] = "bool",
    [1024] = "color",
    [2048] = "vector",

    string = 2,
    text = 4,
    number = 8,
    player = 16,
    steamid = 32,
    character = 64,
    bool = 128,
    color = 1024,
    vector = 2048,
    angle = 4096,

    optional = 256,
    array = 512
}

--- Sanitizes an input value with the given type. This function ensures that a valid type is always returned. If a valid value
-- could not be found, it will return the default value for the type. This only works for simple types - e.g it does not work
-- for player, character, or Steam ID types.
-- @realm shared
-- @owtypes type Type to check for
-- @param input Value to sanitize
-- @return Sanitized value
-- @see ow.type
-- @usage print(ow.util:SanitizeType(ow.type.number, "123"))
-- > 123
-- print(ow.util:SanitizeType(ow.type.bool, 1))
-- > true
function ow.util:SanitizeType(type, input)
    if ( type == ow.type.string ) then
        return tostring(input)
    elseif ( type == ow.type.text ) then
        return tostring(input)
    elseif ( type == ow.type.number ) then
        return tonumber(input or 0) or 0
    elseif ( type == ow.type.bool ) then
        return tobool(input)
    elseif ( type == ow.type.color ) then
        return IsColor(input) and input or color_white
    elseif ( type == ow.type.vector ) then
        return isvector(input) and input or vector_origin
    elseif ( type == ow.type.angle ) then
        return isangle(input) and input or angle_zero
    elseif ( type == ow.type.array ) then
        return input
    elseif ( type == ow.type.player ) then
        if ( isstring(input) ) then
            return ow.util:FindPlayer(input)
        elseif ( isnumber(input) ) then
            return Player(input)
        elseif ( IsValid(input) and input:IsPlayer() ) then
            return input
        end

        return nil
    else
        error("attempted to sanitize " .. ( ow.type[type] and ( "invalid type " .. ow.type[type] ) or "unknown type " .. type ))
    end
end

local typeMap = {
    string = ow.type.string,
    number = ow.type.number,
    Player = ow.type.player,
    boolean = ow.type.bool,
    Vector = ow.type.vector,
    Angle = ow.type.angle,
}

local tableMap = {
    [ow.type.character] = function(value)
        return getmetatable(value) == ow.character.meta
    end,

    [ow.type.color] = function(value)
        return IsColor(value)
    end,

    [ow.type.steamid] = function(value)
        return isstring(value) and ( value:match("^%d+$") and #value == 17 )
    end
}

--- Returns the `ow.type` of the given value.
-- @realm shared
-- @param value Value to get the type of
-- @treturn ow.type Type of value
-- @see ow.type
-- @usage print(ow.util:GetTypeFromValue("hello"))
-- > 2 -- i.e the value of ow.type.string
function ow.util:GetTypeFromValue(value)
    local result = typeMap[type(value)]
    if ( result ) then
        return result
    end

    if ( istable(value) ) then
        for k, v in pairs(tableMap) do
            if ( v(value) ) then
                return k
            end
        end
    end
end

--- Sends a chat message to the player.
-- @realm shared
-- @param client Player The player to send the message to.
-- @param ... any The message to send.
function ow.util:SendChatText(client, ...)
    if ( SERVER ) then

        local encoded, err = sfs.encode({...})
        if ( err ) then
            ow.util:PrintError("Failed to encode chat text: " .. err)
            return
        end

        net.Start("ow.chat.text")
            net.WriteData(encoded, #encoded)
        if ( IsValid(client) ) then
            net.Send(client)
        else
            net.Broadcast()
        end
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

local serverErrorColour = Color(136, 221, 255, 255)
local clientErrorColour = Color(255, 221, 102, 255)

local serverMsgColour = Color(156, 241, 255, 200)
local clientMsgColour = Color(255, 241, 122, 200)

--- Prints a message to the console.
-- @realm shared
-- @param ... any The message to print.
function ow.util:Print(...)
    local args = self:PreparePackage(...)

    MsgC(hook.Run("GetFrameworkColor"), "Overwatch >> ", SERVER and serverMsgColour or clientMsgColour, unpack(args))

    return args
end

--- Prints an error message to the console.
-- @realm shared
-- @param ... any The message to print.
function ow.util:PrintError(...)
    local args = self:PreparePackage(...)

    local realmColor = SERVER and serverErrorColour or clientErrorColour
    MsgC(realmColor, "[ERROR] ", hook.Run("GetFrameworkColor"), "Overwatch >> ", realmColor, unpack(args))

    if ( SERVER ) then
        for k, v in player.Iterator() do
            if ( v:IsAdmin() ) then
                v:Notify("An error has occurred in the server. Check the console for more information.", NOTIFY_ERROR)
            end
        end
    else
        if ( IsValid(ow.localClient) ) then
            ow.localClient:Notify("An error has occurred in the client. Check the console for more information.", NOTIFY_ERROR)
        end

        chat.AddText(realmColor, "[ERROR] ", hook.Run("GetFrameworkColor"), "Overwatch >> ", realmColor, unpack(args))
    end

    return args
end

--- Prints a warning message to the console.
-- @realm shared
-- @param ... any The message to print.
local colorWarning = Color(255, 200, 120)
function ow.util:PrintWarning(...)
    local args = self:PreparePackage(...)

    MsgC(colorWarning, "[WARNING] ", hook.Run("GetFrameworkColor"), "Overwatch >> ", colorWarning, unpack(args))

    return args
end

--- Loads a file based on the realm.
-- @realm shared
-- @param path string The path to the file.
-- @param realm string The realm to load the file in.
function ow.util:LoadFile(path, realm)
    if ( !isstring(path) ) then
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
-- @string str The value to get the type of.
-- @string find The type to search for.
-- @return string The type of the value.
function ow.util:FindString(str, find)
    if ( !isstring(str) or !isstring(find) ) then
        ow.util:PrintError("Attempted to find a string with no value", str, find)
        return false
    end

    str = string.lower(str)
    find = string.lower(find)

    return string.find(str, find) != nil
end

--- Searches a given text for the specified value.
-- @realm shared
-- @string txt The text to search in.
-- @string find The value to search for.
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
    if ( identifier == nil ) then return nil end

    local identifierType = type(identifier)
    if ( identifierType == "Player" ) then
        return identifier
    end

    if ( isnumber(identifier) ) then
        return Player(identifier)
    end

    if ( isstring(identifierType) ) then
        for _, v in player.Iterator() do
            if ( self:FindString(v:Name(), identifier) or self:FindString(v:SteamID(), identifier) or self:FindString(v:SteamID64(), identifier) ) then
                return v
            end
        end
    end

    if ( self:FindString(identifierType, "table") ) then
        for k, v in ipairs(identifier) do
            local foundPlayer = self:FindPlayer(v)  -- Update to call FindPlayer recursively
            if foundPlayer then
                return foundPlayer
            end
        end
    end

    return nil
end

--- Wraps text to fit within a specified width.
-- @realm shared
-- @param text string The text to wrap.
-- @param font string The font to use for wrapping.
-- @param maxWidth number The maximum width of the text.
-- @return table A table containing the wrapped lines of text.
-- @usage local lines = ow.util:WrapText("This is a long line of text that needs to be wrapped.", "Default", 200)
-- > lines = {"This is a long line of text", "that needs to be wrapped."}
function ow.util:WrapText(text, font, maxWidth)
    surface.SetFont(font)

    local words = string.Explode(" ", text)
    local lines = {}
    local line = ""

    for k, v in ipairs(words) do
        local w = surface.GetTextSize(v)
        local lw = surface.GetTextSize(line)

        if ( lw + w > maxWidth ) then
            table.insert(lines, line)
            line = ""
        end

        line = line .. v .. " "
    end

    table.insert(lines, line)

    return lines
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

function ow.util:GetCharacters()
    local characters = {}
    for k, v in player.Iterator() do
        if ( v:GetCharacter() ) then
            table.insert(characters, v:GetCharacter())
        end
    end

    return characters
end

function ow.util:IsPlayerReceiver(obj)
    return IsValid(obj) and obj:IsPlayer()
end

function ow.util:SafeParseTable(input)
    if ( istable(input) ) then
        return input
    elseif ( isstring(input) and input != "" and input != "[]" ) then
        return util.JSONToTable(input) or {}
    end

    return {}
end

local ADJUST_SOUND = SoundDuration("npc/metropolice/pain1.wav") > 0 and "" or "../../hl2/sound/"

--- Emits sounds one after the other from an entity.
-- @realm shared
-- @entity entity Entity to play sounds from
-- @tab sounds Sound paths to play
-- @number delay[opt=0] How long to wait before starting to play the sounds
-- @number spacing[opt=0.1] How long to wait between playing each sound
-- @number level[opt=75] The sound level of each sound
-- @number pitch[opt=100] Pitch percentage of each sound
-- @number volume[opt=1] Volume of each sound
-- @number channel[opt=CHAN_AUTO] Channel of each sound
-- @treturn number How long the entire sequence of sounds will take to play
-- @usage -- Play a sequence of sounds with a delay between each sound
-- ow.util:EmitQueuedSounds(entity, {"sound1.wav", "sound2.wav", "sound3.wav"}, 0.5, 0.1, 75, 100, 1, CHAN_AUTO)
function ow.util:EmitQueuedSounds(entity, sounds, delay, spacing, level, pitch, volume, channel)
    -- Let there be a delay before any sound is played.
    delay = delay or 0
    spacing = spacing or 0.1

    -- Loop through all of the sounds.
    for _, v in ipairs(sounds) do
        local postSet, preSet = 0, 0

        -- Determine if this sound has special time offsets.
        if ( istable(v) ) then
            postSet, preSet = v[2] or 0, v[3] or 0
            v = v[1]
        end

        -- Get the length of the sound.
        local length = SoundDuration(ADJUST_SOUND .. v)
        -- If the sound has a pause before it is played, add it here.
        delay = delay + preSet

        -- Have the sound play in the future.
        timer.Simple(delay, function()
            -- Check if the entity still exists and play the sound.
            if ( IsValid(entity) ) then
                entity:EmitSound(v, level, pitch)
            end
        end)

        -- Add the delay for the next sound.
        delay = delay + length + postSet + spacing
    end

    -- Return how long it took for the whole thing.
    return delay
end

if ( CLIENT ) then
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

    local stored = {}

    --- Returns a material with the given path and parameters.
    -- @realm client
    -- @param path string The path to the material.
    -- @param parameters string The parameters to apply to the material.
    -- @return Material The material that was created.
    -- @usage local vignette = ow.util:GetMaterial("overwatch/overlay_vignette.png")
    -- surface.SetMaterial(vignette)
    function ow.util:GetMaterial(path, parameters)
        if ( !tostring(path) ) then
            ow.util:PrintError("Attempted to get a material with no path", path, parameters)
            return false
        end

        parameters = tostring(parameters or "")
        local uniqueID = Format("ow.mat.%s.%s", path, parameters)

        if ( stored[uniqueID] ) then
            return stored[uniqueID]
        end

        local mat = Material(path, parameters)
        stored[uniqueID] = mat

        return mat
    end

    local blur = ow.util:GetMaterial("pp/blurscreen")
    local surface = surface
    local render = render

    --- Draws blur on a panel.
    -- @realm client
    -- @param panel Panel The panel to draw the blur on.
    -- @param amount number The amount of blur to apply.
    -- @param passes number The number of passes to apply.
    -- @param alpha number The alpha value of the blur.
    function ow.util:DrawBlur(panel, amount, passes, alpha)
        amount = amount or 5

        if ( ow.option:Get("performance.blur") == true ) then
            surface.SetMaterial(blur)
            surface.SetDrawColor(255, 255, 255, alpha or 255)

            local x, y = panel:LocalToScreen(0, 0)

            for i = -( passes or 0.2 ), 1, 0.2 do
                -- Do things to the blur material to make it blurry.
                blur:SetFloat("$blur", i * amount)
                blur:Recompute()

                -- Draw the blur material over the screen.
                render.UpdateScreenEffectTexture()
                surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
            end
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
    -- @param alpha number The alpha value of the blur.
    function ow.util:DrawBlurRect(x, y, width, height, amount, passes, alpha)
        amount = amount or 5

        if ( ow.option:Get("performance.blur") == true ) then
            surface.SetMaterial(blur)
            surface.SetDrawColor(255, 255, 255, alpha or 255)

            local scrW, scrH = ScrW(), ScrH()
            local x2, y2 = x / scrW, y / scrH
            local w2, h2 = (x + width) / scrW, (y + height) / scrH

            for i = -( passes or 0.2 ), 1, 0.2 do
                blur:SetFloat("$blur", i * amount)
                blur:Recompute()

                render.UpdateScreenEffectTexture()
                surface.DrawTexturedRectUV(x, y, width, height, x2, y2, w2, h2)
            end
        end
    end
end