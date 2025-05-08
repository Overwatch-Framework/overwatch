--[[--
Physical representation of connected player.

`Player`s are a type of `Entity`. They are a physical representation of a `Character` - and can possess at most one `Character`
object at a time that you can interface with.

See the [Garry's Mod Wiki](https://wiki.garrysmod.com/page/Category:Player) for all other methods that the `Player` class has.
]]
-- @classmod Player

local PLAYER = FindMetaTable("Player")

function PLAYER:GetCharacter()
    return self:GetTable().owCharacter
end

PLAYER.GetChar = PLAYER.GetCharacter

function PLAYER:GetCharacters()
    return self:GetTable().owCharacters or {}
end

PLAYER.GetChars = PLAYER.GetCharacters

function PLAYER:GetCharacterID()
    local character = self:GetCharacter()
    if ( character ) then
        return character:GetID()
    end

    return nil
end

PLAYER.GetCharID = PLAYER.GetCharacterID

PLAYER.SteamName = PLAYER.SteamName or PLAYER.Name

function PLAYER:Name()
    local character = self:GetCharacter()
    if ( character ) then
        return character:GetName()
    end

    return self:SteamName()
end

PLAYER.Nick = PLAYER.Name

function PLAYER:ChatText(...)
    local args = {ow.color:Get("text"), ...}

    if ( SERVER ) then
        ow.net:Start(self, "chat.text", args)
    else
        chat.AddText(unpack(args))
    end
end

PLAYER.ChatPrint = PLAYER.ChatText

--- Plays a gesture animation on the player.
-- @realm shared
-- @string name The name of the gesture to play
-- @usage player:GesturePlay("taunt_laugh")
function PLAYER:GesturePlay(name)
    if ( SERVER ) then
        ow.net:Start(self, "gesture.play", name)
    else
        self:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, self:LookupSequence(name), 0, true)
    end
end

function PLAYER:GetDropPosition(offset)
    if ( offset == nil ) then offset = 64 end

    local trace = util.TraceLine({
        start = self:GetShootPos(),
        endpos = self:GetShootPos() + self:GetAimVector() * offset,
        filter = self
    })

    return trace.HitPos + trace.HitNormal
end

function PLAYER:HasWhitelist(identifier)
    if ( bSchema == nil ) then bSchema = true end

    local whitelists = self:GetData("whitelists_" .. SCHEMA.Folder, {}) or {}
    local whitelist = whitelists[identifier]

    return whitelist != nil and whitelist != false
end

function PLAYER:SetWhitelisted(factionID, bWhitelisted)
    local key = "whitelists_" .. SCHEMA.Folder
    local whitelists = self:GetData(key, {}) or {}

    if ( bWhitelisted == nil ) then bWhitelisted = true end

    whitelists[factionID] = bWhitelisted
    self:SetData(key, whitelists)

    self:SaveDB()
end

function PLAYER:Notify(text, iType, length)
    if ( !text or text == "" ) then return end

    if ( !iType and string.EndsWith(text, "!") ) then
        iType = NOTIFY_ERROR
    elseif ( !iType and string.EndsWith(text, "?") ) then
        iType = NOTIFY_HINT
    else
        iType = iType or NOTIFY_GENERIC
    end

    duration = duration or 3

    ow.notification:Send(self, text, iType, length)
end

ow.alwaysRaised = ow.alwaysRaised or {}
ow.alwaysRaised["gmod_tool"] = true
ow.alwaysRaised["gmod_camera"] = true
ow.alwaysRaised["weapon_physgun"] = true

function PLAYER:IsWeaponRaised()
    if ( ow.config:Get("wepraise.alwaysraised", false) ) then return true end

    local weapon = self:GetActiveWeapon()
    if ( IsValid(weapon) and ( ow.alwaysRaised[weapon:GetClass()] or weapon.AlwaysRaised ) ) then return true end

    return self:GetRelay("bWeaponRaised", false)
end

if ( CLIENT ) then
    function PLAYER:InDarkness(factor)
        if ( factor == nil ) then factor = 0.5 end

        local lightLevel = render.GetLightColor(self:GetPos()):Length()
        return lightLevel < factor
    end
end

function PLAYER:IsOverwatchDeveloper() -- Official Overwatch Developers
    return self:SteamID64() == "76561197963057641" or self:SteamID64() == "76561198373309941"
end