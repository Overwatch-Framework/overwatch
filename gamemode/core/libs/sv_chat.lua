--- Chat library
-- @module ow.chat

function ow.chat:SendSpeaker(speaker, uniqueID, text)
    local players = {}
    for k, v in player.Iterator() do
        if ( !IsValid(v) or !v:Alive() ) then continue end

        if ( hook.Run("PlayerCanHearChat", speaker, v, uniqueID, text) != false ) then
            table.insert(players, v)
        end
    end

    net.Start("ow.chat.send")
        net.WriteTable({
            Speaker = speaker:EntIndex(),
            UniqueID = uniqueID,
            Text = text
        })
    net.Send(players)

    hook.Run("OnChatMessageSent", speaker, players, uniqueID, text)
end

function ow.chat:SendTo(players, uniqueID, text)
    players = players or select(2, player.Iterator())

    net.Start("ow.chat.send")
        net.WriteTable({
            UniqueID = uniqueID,
            Text = text
        })
    net.Send(players)
end