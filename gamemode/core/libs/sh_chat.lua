--- Chat library
-- @module ow.chat

ow.chat = {}
ow.chat.classes = {}

function ow.chat:Register(uniqueID, chatData)
    if ( !isstring(uniqueID) ) then
        ow.util:PrintError("Attempted to register a chat class without a unique ID!")
        return false
    end

    if ( !istable(chatData) ) then
        ow.util:PrintError("Attempted to register a chat class without data!")
        return false
    end

    if ( !isfunction(chatData.OnChatAdd) ) then
        chatData.OnChatAdd = function(speaker, text)
            chat.AddText(color_white, speaker:Name() .. " says \"" .. text .. "\"")
            chat.PlaySound()
        end
    end

    ow.command:Register(uniqueID, {
        Description = chatData.Description or "",
        Prefixes = chatData.Prefixes,
        Callback = function(info, ply, arguments)
            local text = table.concat(arguments, " ")

            if ( !isstring(text) or #text < 1 ) then
                ow.util:PrintError("Attempted to send an empty chat message!", ply)
                return false
            end

            self:Send(ply, uniqueID, text)
        end
    })

    self.classes[uniqueID] = chatData
end

function ow.chat:Get(uniqueID)
    return self.classes[uniqueID]
end