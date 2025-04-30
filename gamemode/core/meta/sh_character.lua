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

function CHAR:GiveMoney(amount)
    if ( !self:GetPlayer() ) then return end

    local character = self:GetPlayer()
    if ( amount < 0 ) then
        amount = math.abs(amount)
        ow.util:PrintWarning("Character " .. self:GetID() .. " tried to give negative money, converted to positive number. use :TakeMoney instead!")
    end

    character:SetMoney(character:GetMoney() + amount)
end

function CHAR:TakeMoney(amount)
    if ( !self:GetPlayer() ) then return end

    local character = self:GetPlayer()
    if ( amount < 0 ) then
        amount = math.abs(amount)
        ow.util:PrintWarning("Character " .. self:GetID() .. " tried to give negative money, converted to positive number. use :TakeMoney instead!")
    end

    character:SetMoney(character:GetMoney() - amount)
end