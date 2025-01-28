--[[--
Physical representation of connected player.

`Player`s are a type of `Entity`. They are a physical representation of a `Character` - and can possess at most one `Character`
object at a time that you can interface with.

See the [Garry's Mod Wiki](https://wiki.garrysmod.com/page/Category:Player) for all other methods that the `Player` class has.
]]
-- @classmod Player

local PLAYER = FindMetaTable("Player")

PLAYER.SteamName = PLAYER.SteamName or PLAYER.Name

function PLAYER:ChatText(...)
    local args = {...}

    if ( SERVER ) then
        net.Start("ow.chat.text")
            net.WriteTable(args)
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

function PLAYER:HasWhitelist(identifier, bSchema, bMap)
    if ( bSchema == nil ) then bSchema = true end
    if ( bMap == nil ) then bMap = false end

    return true -- DATABVASESAEAEE
end