local CHAR = ow.character.meta or {}
CHAR.__index = CHAR
CHAR.ID = 0
CHAR.variables = {}

function CHAR:__tostring()
    return "character[" .. self:GetID().. "]"
end

function CHAR:__eq(other)
    return self.ID == other.ID
end

function CHAR:GetID()
    return self.ID
end

function CHAR:GetPlayer()
    return self.Player
end