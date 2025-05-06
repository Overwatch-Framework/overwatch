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

    ow.net:Start(players, "ow.chat.send", {
        Speaker = speaker:EntIndex(),
        UniqueID = uniqueID,
        Text = text
    })

    hook.Run("OnChatMessageSent", speaker, players, uniqueID, text)
end

function ow.chat:SendTo(players, uniqueID, text)
    players = players or select(2, player.Iterator())

    ow.net:Start(players, "ow.chat.send", {
        UniqueID = uniqueID,
        Text = text
    })
end