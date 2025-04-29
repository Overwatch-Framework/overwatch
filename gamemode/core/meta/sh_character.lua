local CHAR = ow.character.meta or {}
CHAR.__index = CHAR
CHAR.ID = 0
CHAR.Variables = {}

function CHAR:__tostring()
    return "character[" .. self:GetID() .. "]"
end

function CHAR:__eq(other)
    return self.ID == other.ID
end

function CHAR:GetID()
    return self.ID
end

function CHAR:GetSteamID()
    return self.SteamID
end

function CHAR:GetPlayer()
    return self.Player
end

function CHAR:GetInventories()
    return isstring(self.Inventories) and util.JSONToTable(self.Inventories) or self.Inventories or {}
end

function CHAR:SetInventories(inventories)
    self.Inventories = inventories
end