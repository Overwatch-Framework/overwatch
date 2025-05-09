--- Utility functions
-- @module ow.util

-- Most utility functions were imported from Minerva's edit of Helix and some from the original.
-- https://github.com/riggs9162/helix/blob/riggs9162/gamemode/core/sh_util.lua
-- https://github.com/NebulousCloud/helix/blob/master/gamemode/core/sh_util.lua

--- Converts and sanitizes input data into the specified type.
-- This supports simple type coercion and fallback defaults.
-- @param typeID number A type constant from ow.types
-- @param value any The raw value to sanitize
-- @return any A validated and converted result
-- @usage ow.util:CoerceType(ow.types.number, "123") -- returns 123
function ow.util:CoerceType(typeID, value)
    if ( typeID == ow.types.string or typeID == ow.types.text ) then
        return tostring(value)

    elseif ( typeID == ow.types.number ) then
        return tonumber(value) or 0

    elseif ( typeID == ow.types.bool ) then
        return tobool(value)

    elseif ( typeID == ow.types.vector ) then
        return isvector(value) and value or vector_origin

    elseif ( typeID == ow.types.angle ) then
        return isangle(value) and value or angle_zero

    elseif ( typeID == ow.types.color ) then
        return IsColor(value) and value or color_white

    elseif ( typeID == ow.types.player ) then
        if ( isstring(value) ) then
            return ow.util:FindPlayer(value)
        elseif ( isnumber(value) ) then
            return Player(value)
        elseif ( IsValid(value) and value:IsPlayer() ) then
            return value
        end

    elseif ( typeID == ow.types.character ) then
        if ( istable(value) and getmetatable(value) == ow.character.meta ) then
            return value
        end

    elseif ( typeID == ow.types.steamid ) then
        if ( isstring(value) and #value == 17 and value:match("^%d+$") ) then
            return value
        end
    end

    return nil
end

local basicTypeMap = {
    string  = ow.types.string,
    number  = ow.types.number,
    boolean = ow.types.bool,
    Vector  = ow.types.vector,
    Angle   = ow.types.angle
}

local checkTypeMap = {
    [ow.types.color] = function(val) return IsColor(val) end,
    [ow.types.character] = function(val) return getmetatable(val) == ow.character.meta end,
    [ow.types.steamid] = function(val) return isstring(val) and #val == 17 and val:match("^%d+$") end
}

--- Attempts to identify the framework type of a given value.
-- @param value any The value to analyze
-- @return number|nil A type constant from ow.types or nil if unknown
-- @usage local t = ow.util:DetectType(Color(255,0,0)) -- returns ow.types.color
function ow.util:DetectType(value)
    local luaType = type(value)
    local mapped = basicTypeMap[luaType]

    if ( mapped ) then return mapped end

    for typeID, validator in pairs(checkTypeMap) do
        if ( validator(value) ) then
            return typeID
        end
    end

    if ( IsValid(value) and value:IsPlayer() ) then
        return ow.types.player
    end
end

--- Sends a chat message to the player.
-- @realm shared
-- @param client Player The player to send the message to.
-- @param ... any The message to send.
function ow.util:SendChatText(client, ...)
    if ( SERVER ) then
        ow.net:Start(client, "chat.text", {...})
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

local basePathFix = SoundDuration("npc/metropolice/pain1.wav") > 0 and "" or "../../hl2/sound/"

--- Queues and plays multiple sounds from an entity with spacing and optional offsets.
-- @param ent Entity Entity to emit sounds from.
-- @param sounds table List of sound paths or tables: { "sound.wav", preDelay, postDelay }.
-- @param startDelay number Optional delay before first sound (default 0).
-- @param gap number Delay between each sound (default 0.1).
-- @param volume number Sound volume (default 75).
-- @param pitch number Sound pitch (default 100).
-- @return number Total time taken for the entire sequence.
-- @usage ow.util:QueueSounds(ply, { "sound1.wav", { "sound2.wav", 0.1, 0.2 } }, 0.5, 0.2)
function ow.util:QueueSounds(ent, sounds, startDelay, gap, volume, pitch)
    if ( !IsValid(ent) or !istable(sounds) ) then return 0 end

    local currentDelay = startDelay or 0
    local spacing = gap or 0.1
    local vol = volume or 75
    local pit = pitch or 100

    for _, soundData in ipairs(sounds) do
        local path, preDelay, postDelay = soundData, 0, 0

        if ( istable(soundData) ) then
            path = soundData[1]
            preDelay = soundData[2] or 0
            postDelay = soundData[3] or 0
        end

        local length = SoundDuration(basePathFix .. path)

        currentDelay = currentDelay + preDelay

        timer.Simple(currentDelay, function()
            if ( IsValid(ent) ) then
                ent:EmitSound(path, vol, pit)
            end
        end)

        currentDelay = currentDelay + length + postDelay + spacing
    end

    return currentDelay
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

    local blurMaterial = ow.util:GetMaterial("pp/blurscreen")
    local scrW, scrH = ScrW(), ScrH()

    --- Draws a blur within a panel’s bounds. Falls back to a dim overlay if blur is disabled.
    -- @param panel Panel Panel to apply blur to.
    -- @param intensity number Blur strength (0–10 suggested).
    -- @param steps number Blur quality/steps. Defaults to 0.2.
    -- @param alpha number Overlay alpha (default 255).
    -- @usage ow.util:DrawBlur(panel, 6, 0.2, 200)
    function ow.util:DrawBlur(panel, intensity, steps, alpha)
        if ( !IsValid(panel) ) then return end

        if ( ow.option:Get("performance.blur") != true ) then
            surface.SetDrawColor(30, 30, 30, alpha or (intensity or 5) * 20)
            surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
            return
        end

        local x, y = panel:LocalToScreen(0, 0)
        local blurAmount = intensity or 5
        local passStep = steps or 0.2
        local overlayAlpha = alpha or 255

        surface.SetMaterial(blurMaterial)
        surface.SetDrawColor(255, 255, 255, overlayAlpha)

        for i = -passStep, 1, passStep do
            blurMaterial:SetFloat("$blur", i * blurAmount)
            blurMaterial:Recompute()

            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
        end
    end

    --- Draws a blur within an arbitrary screen rectangle. Not intended for panels.
    -- @param x number X position.
    -- @param y number Y position.
    -- @param width number Width.
    -- @param height number Height.
    -- @param intensity number Blur strength (0–10 suggested).
    -- @param steps number Blur quality/steps. Defaults to 0.2.
    -- @param alpha number Overlay alpha (default 255).
    -- @usage ow.util:DrawBlurRect(0, 0, 512, 256, 8, 0.2, 180)
    function ow.util:DrawBlurRect(x, y, width, height, intensity, steps, alpha)
        if ( ow.option:Get("performance.blur") != true ) then
            surface.SetDrawColor(30, 30, 30, (intensity or 5) * 20)
            surface.DrawRect(x, y, width, height)
            return
        end

        local blurAmount = intensity or 5
        local passStep = steps or 0.2
        local overlayAlpha = alpha or 255

        local u0, v0 = x / scrW, y / scrH
        local u1, v1 = (x + width) / scrW, (y + height) / scrH

        surface.SetMaterial(blurMaterial)
        surface.SetDrawColor(255, 255, 255, overlayAlpha)

        for i = -passStep, 1, passStep do
            blurMaterial:SetFloat("$blur", i * blurAmount)
            blurMaterial:Recompute()

            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRectUV(x, y, width, height, u0, v0, u1, v1)
        end
    end
end