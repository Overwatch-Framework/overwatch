--- Chat library
-- @module ow.chat

util.AddNetworkString("ow.chat.send")
function ow.chat:Send(speaker, uniqueID, text)
    local players = {}
    for k, v in player.Iterator() do
        if ( !IsValid(v) or !v:Alive() ) then continue end

        if ( hook.Run("PlayerCanHearChat", speaker, v, uniqueID, text) != false ) then
            table.insert(players, v)
        end
    end

    net.Start("ow.chat.send")
        net.WritePlayer(speaker)
        net.WriteString(uniqueID)
        net.WriteString(text)
    net.Send(players)

    hook.Run("OnChatMessageSent", speaker, players, uniqueID, text)
end