ow.chat:Register("ic", {
    CanHear = function(self, speaker, listener)
        local radius = ow.config:Get("chat.radius.ic", 384)
        return speaker:GetPos():DistToSqr(listener:GetPos()) < radius ^ 2
    end,
    OnChatAdd = function(self, speaker, text)
        chat.AddText(ow.color:Get("chat"), speaker:Name() .. " says \"" .. text .. "\"")
        chat.PlaySound()
    end
})

ow.chat:Register("whisper", {
    Prefixes = {"W", "Whisper"},
    CanHear = function(self, speaker, listener)
        local radius = ow.config:Get("chat.radius.whisper", 96)
        return speaker:GetPos():DistToSqr(listener:GetPos()) < radius ^ 2
    end,
    OnChatAdd = function(self, speaker, text)
        chat.AddText(ow.color:Get("chat.whisper"), speaker:Name() .. " whispers \"" .. text .. "\"")
        chat.PlaySound()
    end
})

ow.chat:Register("yell", {
    Prefixes = {"Y", "Yell"},
    CanHear = function(self, speaker, listener)
        local radius = ow.config:Get("chat.radius.yell", 1024)
        return speaker:GetPos():DistToSqr(listener:GetPos()) < radius ^ 2
    end,
    OnChatAdd = function(self, speaker, text)
        chat.AddText(ow.color:Get("chat.yell"), speaker:Name() .. " yells \"" .. text .. "\"")
        chat.PlaySound()
    end
})

ow.chat:Register("me", {
    Prefixes = {"Me", "Action"},
    CanHear = function(self, speaker, listener)
        local radius = ow.config:Get("chat.radius.me", 512)
        return speaker:GetPos():DistToSqr(listener:GetPos()) < radius ^ 2
    end,
    OnChatAdd = function(self, speaker, text)
        chat.AddText(ow.color:Get("chat.action"), speaker:Name() .. " " .. text)
    end
})

ow.chat:Register("it", {
    Prefixes = {"It"},
    CanHear = function(self, speaker, listener)
        local radius = ow.config:Get("chat.radius.it", 512)
        return speaker:GetPos():DistToSqr(listener:GetPos()) < radius ^ 2
    end,
    OnChatAdd = function(self, speaker, text)
        chat.AddText(ow.color:Get("chat.action"), text)
    end
})

ow.chat:Register("ooc", {
    Prefixes = {"/", "OOC"},
    CanHear = function(self, speaker, listener)
        return ow.config:Get("chat.ooc")
    end,
    OnChatAdd = function(self, speaker, text)
        chat.AddText(ow.color:Get("chat.ooc"), "(OOC) ", ow.color:Get("text"), speaker:SteamName() .. ": " .. text)
    end
})

ow.chat:Register("looc", {
    Prefixes = {"LOOC"},
    CanHear = function(self, speaker, listener)
        local radius = ow.config:Get("chat.radius.looc", 512)
        return speaker:GetPos():DistToSqr(listener:GetPos()) < radius ^ 2
    end,
    OnChatAdd = function(self, speaker, text)
        chat.AddText(ow.color:Get("chat.ooc"), "(LOOC) ", ow.color:Get("text"), speaker:SteamName() .. ": " .. text)
    end
})

hook.Run("PostRegisterChatClasses")