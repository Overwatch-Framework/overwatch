ow.faction = {}
ow.faction.stored = {}
ow.faction.instances = {}

function ow.faction:Register(factionData)
    self.stored[factionData.uniqueID] = factionData
    self.instances[#self.instances + 1] = factionData

    team.SetUp(factionData.index, factionData.name, factionData.color, false)
    return factionData
end

function ow.faction:Get(factionID)
    return self.stored[factionID]
end

--[[
function ow.faction:LoadFolder(path, bFromLua)
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

        FACTION = { index = #self.instances + 1, uniqueID = uniqueIDName }
            ow.util:LoadFile(path .. "/" .. v)
            self:Register(FACTION)
        FACTION = nil
    end

    return true
end
]]