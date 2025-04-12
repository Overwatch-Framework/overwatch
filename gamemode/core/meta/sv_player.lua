--[[--
Physical representation of connected player.

`Player`s are a type of `Entity`. They are a physical representation of a `Character` - and can possess at most one `Character`
object at a time that you can interface with.

See the [Garry's Mod Wiki](https://wiki.garrysmod.com/page/Category:Player) for all other methods that the `Player` class has.
]]
-- @classmod Player

local PLAYER = FindMetaTable("Player")

function PLAYER:SetDBVar(key, value)
    if ( self.owDatabase ) then
        self.owDatabase[key] = value
    end
end

function PLAYER:GetDBVar(key)
    return self.owDatabase and self.owDatabase[key]
end

function PLAYER:SaveDB()
    if ( self.owDatabase ) then
        ow.sqlite:SaveRow("users", self.owDatabase, "steamid")
    end
end