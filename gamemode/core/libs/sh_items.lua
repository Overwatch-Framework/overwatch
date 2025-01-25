ow.items = {}
ow.items.stored = {}
ow.items.instances = {}

function ow.items:Register(itemData)
    self.instances[#self.stored + 1] = itemData
    self.stored[itemData.uniqueID] = itemData
end

function ow.items:Get(look)
    if ( isstring(look) ) then
        return self.stored[look]
    elseif ( isnumber(look) ) then
        return self.instances[look]
    end

    return nil
end

function ow.items:Load()
    --[[
    for k, v in ipairs(file.Find("ow/items/*.lua", "LUA")) do
        local path = "ow/items/" .. v
        local uniqueID = string.lower(string.gsub(v, ".lua", ""))

        ITEM = ow.items.Get(uniqueID) or {}
        ITEM.uniqueID = uniqueID

        if ( SERVER ) then
            AddCSLuaFile(path)
        end

        include(path)

        ow.items.Register(ITEM)
    end
    ]]
end