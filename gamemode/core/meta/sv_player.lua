--[[--
Physical representation of connected player.

`Player`s are a type of `Entity`. They are a physical representation of a `Character` - and can possess at most one `Character`
object at a time that you can interface with.

See the [Garry's Mod Wiki](https://wiki.garrysmod.com/page/Category:Player) for all other methods that the `Player` class has.
]]
-- @classmod Player

local PLAYER = FindMetaTable("Player")

function PLAYER:SetDBVar(key, value)
    local clientTable = self:GetTable()
    if ( !clientTable.owDatabase ) then
        clientTable.owDatabase = {}
    end

    clientTable.owDatabase[key] = value
end

function PLAYER:GetDBVar(key, default)
    local clientTable = self:GetTable()
    if ( clientTable.owDatabase ) then
        return clientTable.owDatabase[key] or default
    end

    return default
end

function PLAYER:SaveDB()
    local clientTable = self:GetTable()
    if ( clientTable.owDatabase ) then
        ow.sqlite:SaveRow("ow_players", clientTable.owDatabase, "steamid")

        -- Network the data to the client
        ow.net:Start(self, "database.save", clientTable.owDatabase or {})
    end
end

function PLAYER:GetData(key, default)
    local data = self:GetTable().owDatabase.data or {}

    if ( type(data) == "string" ) then
        data = util.JSONToTable(data) or {}
    else
        data = data or {}
    end

    return data[key] or default
end

function PLAYER:SetData(key, value)
    local clientTable = self:GetTable()
    local data = clientTable.owDatabase.data or {}

    if ( isstring(data) ) then
        data = util.JSONToTable(data) or {}
    else
        data = data or {}
    end

    data[key] = value
    clientTable.owDatabase.data = util.TableToJSON(data)
end