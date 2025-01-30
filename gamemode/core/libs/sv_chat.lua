--- Chat library
-- @module ow.chat

util.AddNetworkString("ow.chat.send")
function ow.chat:Send(speaker, uniqueID, text)
    local canHear = self:Get(uniqueID).CanHear or function(speaker, listener) return true end

    local players = {}
    for k, v in player.Iterator() do
        if ( canHear(speaker, v) and hook.Run("PlayerCanHearChat", speaker, v, uniqueID) != false ) then
            table.insert(players, v)
        end
    end

    net.Start("ow.chat.send")
        net.WritePlayer(speaker)
        net.WriteString(uniqueID)
        net.WriteString(text)
    net.Send(players)

    hook.Run("OnChatSent", speaker, uniqueID, text)
end