--[[--
Physical representation of connected player.

`Player`s are a type of `Entity`. They are a physical representation of a `Character` - and can possess at most one `Character`
object at a time that you can interface with.

See the [Garry's Mod Wiki](https://wiki.garrysmod.com/page/Category:Player) for all other methods that the `Player` class has.
]]
-- @classmod Player

local PLAYER = FindMetaTable("Player")

function PLAYER:SetDBVar(key, value)
    if ( !self.owDatabase ) then
        self.owDatabase = {}
    end

    self.owDatabase[key] = value
end

function PLAYER:GetDBVar(key, default)
    if ( self.owDatabase ) then
        return self.owDatabase[key] or default
    end

    return default
end

function PLAYER:SaveDB()
    if ( self.owDatabase ) then
        ow.sqlite:SaveRow("ow_players", self.owDatabase, "steamid")
    end
end

function PLAYER:SetData(key, value)
    local data = self.owDatabase["data"] or {}

    if ( type(data) == "string" ) then
        data = util.JSONToTable(data) or {}
    else
        data = data or {}
    end

    data[key] = value

    self.owDatabase["data"] = util.TableToJSON(data)
end

function PLAYER:GetData(key, default)
    local data = self.owDatabase["data"] or {}

    if ( type(data) == "string" ) then
        data = util.JSONToTable(data) or {}
    else
        data = data or {}
    end

    return data[key] or default
end