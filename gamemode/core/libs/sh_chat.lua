--- Chat library
-- @module ow.chat

ow.chat = ow.chat or {}
ow.chat.classes = ow.chat.classes or {}

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
        chatData.OnChatAdd = function(this, speaker, text)
            chat.AddText(color_white, speaker:Name() .. " says \"" .. text .. "\"")
            chat.PlaySound()
        end
    end

    if ( chatData.Prefixes ) then
        ow.command:Register(uniqueID, {
            Description = chatData.Description or "",
            Prefixes = chatData.Prefixes,
            Callback = function(this, ply, arguments)
                local text = table.concat(arguments, " ")

                if ( !isstring(text) or #text < 1 ) then
                    ply:Notify("You must provide a message to send!")
                    return false
                end

                self:SendPlayer(ply, uniqueID, text)
            end
        })
    end

    self.classes[uniqueID] = chatData
end

function ow.chat:Get(uniqueID)
    return self.classes[uniqueID]
end