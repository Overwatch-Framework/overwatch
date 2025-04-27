--[[--
Physical representation of connected player.

`Player`s are a type of `Entity`. They are a physical representation of a `Character` - and can possess at most one `Character`
object at a time that you can interface with.

See the [Garry's Mod Wiki](https://wiki.garrysmod.com/page/Category:Player) for all other methods that the `Player` class has.
]]
-- @classmod Player

local PLAYER = FindMetaTable("Player")

function PLAYER:GetCharacter()
    return self.owCharacter
end

function PLAYER:GetCharacters()
    return self.owCharacters or {}
end

function PLAYER:GetCharacterID()
    if ( self.owCharacter ) then
        return self.owCharacter:GetID()
    end

    return self:EntIndex() -- Use index for now
end

PLAYER.SteamName = PLAYER.SteamName or PLAYER.Name

function PLAYER:Name()
    if ( self.owCharacter ) then
        return self.owCharacter:GetName()
    end

    return self:SteamName()
end

function PLAYER:ChatText(...)
    local args = {...}

    if ( SERVER ) then
        local compressed = util.Compress(util.TableToJSON(args))

        net.Start("ow.chat.text")
            net.WriteData(compressed, #compressed)
        net.Send(self)
    else
        chat.AddText(unpack(args))
    end
end

--- Plays a gesture animation on the player.
-- @realm shared
-- @string name The name of the gesture to play
-- @usage player:GesturePlay("taunt_laugh")
function PLAYER:GesturePlay(name)
    if ( SERVER ) then
        net.Start("ow.gesture.play")
            net.WritePlayer(self)
            net.WriteString(name)
        net.Broadcast()
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

function PLAYER:HasWhitelist(identifier, bSchema, bMap)
    if ( bSchema == nil ) then bSchema = true end
    if ( bMap == nil ) then bMap = false end

    local key = "whitelists"
    if ( bSchema ) then key = key .. "_" .. SCHEMA.Folder end
    if ( bMap ) then key = key .. "_" .. game.GetMap() end

    local whitelists = self:GetData(key, {}) or {}
    local whitelist = whitelists[identifier]

    return whitelist != nil and whitelist != false
end

function PLAYER:GetData(key, default)
    if ( key == true ) then
        return self.owData
    end

    local data = self.owData and self.owData[key]
    if ( data == nil ) then
        return default
    else
        return data
    end
end