--[[-------------------------------------------------------------------------
    Shared player meta
---------------------------------------------------------------------------]]

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