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

    if ( isstring(self.Inventories) ) then
        parsed = util.JSONToTable(self.Inventories) or {}
        self.Inventories = parsed
    elseif ( istable(self.Inventories) ) then
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
    if ( amount < 0 ) then
        amount = math.abs(amount)
        ow.util:PrintWarning("Character " .. self:GetID() .. " tried to give negative amount, converted to positive number. Call :TakeMoney instead!")
    end

    self:SetMoney(self:GetMoney() + amount)
    hook.Run("OnCharacterGiveMoney", self, amount)
end

function CHAR:TakeMoney(amount)
    if ( amount < 0 ) then
        amount = math.abs(amount)
        ow.util:PrintWarning("Character " .. self:GetID() .. " tried to take negative amount, converted to positive number. Call :GiveMoney instead!")
    end

    self:SetMoney(self:GetMoney() - amount)
    hook.Run("OnCharacterTakeMoney", self, amount)
end

function CHAR:HasFlag(flag)
    if ( !ow.flag:Get(flag) ) then return false end

    local flags = self:GetFlags()
    if ( !isstring(flags) or flags == "" ) then return false end

    if ( string.find(flags, flag) ) then return true end

    return false
end

if ( SERVER ) then
    function CHAR:GiveFlag(flag)
        if ( !ow.flag:Get(flag) ) then return end

        local hasFlag = self:HasFlag(flag)
        if ( hasFlag ) then return end

        local flags = self:GetFlags()
        if ( !isstring(flags) or flags == "" ) then
            flags = flag
        else
            flags = flags .. flag
        end

        self:SetFlags(flags)

        local flagInfo = ow.flag:Get(flag)
        if ( flagInfo and flagInfo.callback ) then
            flagInfo.callback(self, true)
        end
    end

    function CHAR:TakeFlag(flag)
        if ( !ow.flag:Get(flag) ) then return end

        local hasFlag = self:HasFlag(flag)
        if ( !hasFlag ) then return end

        local flags = self:GetFlags()
        if ( !flags or flags == "" ) then return end

        flags = string.Replace(flags, flag, "")
        flags = string.Trim(flags)
        self:SetFlags(flags)

        local flagInfo = ow.flag:Get(flag)
        if ( flagInfo and flagInfo.callback ) then
            flagInfo.callback(self, false)
        end
    end
end