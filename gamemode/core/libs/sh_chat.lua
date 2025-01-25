ow.chat = {}
ow.chat.classes = {}

function ow.chat.Register(chatData)
    ow.chat.classes[chatData.uniqueID] = chatData
end

function ow.chat.Get(uniqueID)
    return ow.chat.classes[uniqueID]
end