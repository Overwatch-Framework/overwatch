ow.item = {}
ow.item.stored = {}
ow.item.instances = {}

function ow.item:Register(itemData)
    self.instances[#self.stored + 1] = itemData
    self.stored[itemData.uniqueID] = itemData
end

function ow.item:Get(look)
    if ( isstring(look) ) then
        return self.stored[look]
    elseif ( isnumber(look) ) then
        return self.instances[look]
    end

    return nil
end

--[[
function ow.item:Load()
    local baseDir = engine.ActiveGamemode()
    baseDir = baseDir .. "/"

    if ( SCHEMA and SCHEMA.Folder ) then
        baseDir = SCHEMA.Folder .. "/schema/"
    else
        baseDir = baseDir .. "/gamemode/"
    end

    if ( bFromLua ) then
        baseDir = ""
    end

    -- Load modules from the main folder
    for k, v in ipairs(file.Find(baseDir .. path .. "/*.lua", "LUA")) do
        local uniqueIDName = string.lower(string.gsub(v, ".lua", ""))
        uniqueIDName = string.gsub(uniqueIDName, "sh_", "")

        ITEM = { uniqueID = uniqueIDName }
            ow.util:LoadFile(path .. "/" .. v)
            self:Register(ITEM)
        ITEM = nil
    end

    return true
end
]]