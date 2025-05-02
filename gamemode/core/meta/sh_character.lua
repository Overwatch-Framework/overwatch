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
    local parsed = {}

    print("Parsing inventories for character " .. self:GetID())

    if ( isstring(self.Inventories) ) then
        print("Parsing inventories from string")
        parsed = util.JSONToTable(self.Inventories) or {}
        self.Inventories = parsed -- patch it for future use
    elseif ( istable(self.Inventories) ) then
        print("Parsing inventories from table")
        parsed = self.Inventories
    end

    return parsed
end

function CHAR:SetInventories(inventories)
    self.Inventories = inventories
end

function CHAR:GetInventory(name)
    name = name or "Main"

    local inventories = ow.inventory:GetByCharacterID(self:GetID())
    if ( !inventories or #inventories == 0 ) then return end

    for inventoryID, inventory in pairs(inventories) do
        if ( inventory:GetName() == name ) then
            return inventory
        end
    end

    return nil
end

function CHAR:GiveMoney(amount)
    if ( !self:GetPlayer() ) then return end

    local character = self:GetPlayer()
    if ( amount < 0 ) then
        amount = math.abs(amount)
        ow.util:PrintWarning("Character " .. self:GetID() .. " tried to give negative amount, converted to positive number. Call :TakeMoney instead!")
    end

    character:SetMoney(character:GetMoney() + amount)
end

function CHAR:TakeMoney(amount)
    if ( !self:GetPlayer() ) then return end

    local character = self:GetPlayer()
    if ( amount < 0 ) then
        amount = math.abs(amount)
        ow.util:PrintWarning("Character " .. self:GetID() .. " tried to take negative amount, converted to positive number. Call :GiveMoney instead!")
    end

    character:SetMoney(character:GetMoney() - amount)
end