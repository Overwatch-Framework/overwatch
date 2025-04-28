--[[--
Physical representation of connected player.

`Player`s are a type of `Entity`. They are a physical representation of a `Character` - and can possess at most one `Character`
object at a time that you can interface with.

See the [Garry's Mod Wiki](https://wiki.garrysmod.com/page/Category:Player) for all other methods that the `Player` class has.
]]
-- @classmod Player

local PLAYER = FindMetaTable("Player")

function PLAYER:SetDBVar(key, value)
    local selfTable = self:GetTable()
    if ( !selfTable.owDatabase ) then
        selfTable.owDatabase = {}
    end

    selfTable.owDatabase[key] = value
end

function PLAYER:GetDBVar(key, default)
    local selfTable = self:GetTable()
    if ( selfTable.owDatabase ) then
        return selfTable.owDatabase[key] or default
    end

    return default
end

function PLAYER:SaveDB()
    local selfTable = self:GetTable()
    if ( selfTable.owDatabase ) then
        ow.sqlite:SaveRow("ow_players", self.owDatabase, "steamid")

        -- Network it to the client so they can update their local copy of the database
        -- This is useful for when the player is in the main menu and we want to retrieve something from the database
        -- via the client

        local compressed = util.Compress(util.TableToJSON(selfTable.owDatabase))

        net.Start("ow.database.save")
            net.WriteData(compressed, #compressed)
        net.Send(self)
    end
end

function PLAYER:SetData(key, value)
    local selfTable = self:GetTable()
    local data = selfTable.owDatabase["data"] or {}

    if ( type(data) == "string" ) then
        data = util.JSONToTable(data) or {}
    else
        data = data or {}
    end

    data[key] = value

    selfTable.owDatabase["data"] = util.TableToJSON(data)
end

function PLAYER:GetData(key, default)
    local selfTable = self:GetTable()
    local data = selfTable.owDatabase["data"] or {}

    if ( type(data) == "string" ) then
        data = util.JSONToTable(data) or {}
    else
        data = data or {}
    end

    return data[key] or default
end