local CHAR = ow.character.meta or {}
CHAR.__index = CHAR
CHAR.id = 0
CHAR.variables = {}

function CHAR:__tostring()
    return "character[" .. self:GetID() .. "]"
end

function CHAR:__eq(other)
    return self.id == other.id
end

function CHAR:GetID()
    return self.id
end

function CHAR:GetPlayer()
    return self.player
end