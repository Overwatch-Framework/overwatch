ow.chat:Register("ic", {
    CanHear = function(speaker, listener)
        return speaker:GetPos():DistToSqr(listener:GetPos()) < 384 ^ 2
    end,
    OnChatAdd = function(speaker, text)
        chat.AddText(ow.colour:Get("chat"), speaker:Name() .. " says \"" .. text .. "\"")
        chat.PlaySound()
    end
})

ow.chat:Register("whisper", {
    Prefixes = {"W", "Whisper"},
    CanHear = function(speaker, listener)
        return speaker:GetPos():DistToSqr(listener:GetPos()) < 96 ^ 2
    end,
    OnChatAdd = function(speaker, text)
        chat.AddText(ow.colour:Get("chat.whisper"), speaker:Name() .. " whispers \"" .. text .. "\"")
        chat.PlaySound()
    end
})

ow.chat:Register("yell", {
    Prefixes = {"Y", "Yell"},
    CanHear = function(speaker, listener)
        return speaker:GetPos():DistToSqr(listener:GetPos()) < 1024 ^ 2
    end,
    OnChatAdd = function(speaker, text)
        chat.AddText(ow.colour:Get("chat.yell"), speaker:Name() .. " yells \"" .. text .. "\"")
        chat.PlaySound()
    end
})

hook.Run("PostRegisterChatClasses")