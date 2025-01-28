--- Chat library
-- @module ow.chat

ow.chat = {}
ow.chat.classes = {}

function ow.chat:Register(uniqueID, chatData)
    if ( !uniqueID ) then
        ow.util:PrintError("Attempted to register a chat class without a unique ID!")
        return
    end

    if ( !chatData ) then
        ow.util:PrintError("Attempted to register a chat class without data!")
        return
    end

    if ( !chatData.OnChatAdd ) then
        chatData.OnChatAdd = function(speaker, text)
            chat.AddText(color_white, speaker:Name() .. " says \"" .. text .. "\"")
            chat.PlaySound()
        end
    end

    if ( chatData.Prefixes ) then
        ow.command:Register({
            Name = uniqueID,
            Prefixes = chatData.Prefixes,
            Callback = function(info, ply, arguments)
                local text = table.concat(arguments, " ")

                if ( !text or text == "" ) then
                    ow.util:PrintError("Attempted to send an empty chat message!", ply)
                    return
                end

                self:Send(ply, uniqueID, text)
            end
        })
    end

    self.classes[uniqueID] = chatData
end

function ow.chat:Get(uniqueID)
    return self.classes[uniqueID]
end

if ( CLIENT ) then
    net.Receive("ow.chat", function(len)
        local speaker = net.ReadPlayer()
        local uniqueID = net.ReadString()
        local text = net.ReadString()

        local chatData = ow.chat:Get(uniqueID)
        if ( chatData ) then
            chatData.OnChatAdd(speaker, text)
        end
    end)
end