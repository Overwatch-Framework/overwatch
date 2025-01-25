ow.chat:Register("ic", {
    CanHear = function(speaker, listener)
        return speaker:GetPos():DistToSqr(listener:GetPos()) < 384 ^ 2
    end,
    OnChatAdd = function(speaker, text)
        chat.AddText(ow.color:Get("chat"), speaker:Name() .. " says \"" .. text .. "\"")
    end
})

ow.chat:Register("whisper", {
    Prefixes = {"W", "Whisper"},
    CanHear = function(speaker, listener)
        return speaker:GetPos():DistToSqr(listener:GetPos()) < 96 ^ 2
    end,
    OnChatAdd = function(speaker, text)
        chat.AddText(ow.color:Get("chat.whisper"), speaker:Name() .. " whispers \"" .. text .. "\"")
    end
})

ow.chat:Register("yell", {
    Prefixes = {"Y", "Yell"},
    CanHear = function(speaker, listener)
        return speaker:GetPos():DistToSqr(listener:GetPos()) < 1024 ^ 2
    end,
    OnChatAdd = function(speaker, text)
        chat.AddText(ow.color:Get("chat.yell"), speaker:Name() .. " yells \"" .. text .. "\"")
    end
})