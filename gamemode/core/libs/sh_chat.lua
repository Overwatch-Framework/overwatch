ow.chat = {}
ow.chat.classes = {}

function ow.chat:Register(chatData)
    self.classes[chatData.uniqueID] = chatData
end

function ow.chat:Get(uniqueID)
    return self.classes[uniqueID]
end