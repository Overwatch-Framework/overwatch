ow.flag = ow.flag or {}
ow.flag.stored = {}

function ow.flag:Register(flagChar, giveFunction, takeFunction)
    if ( flagChar == nil or !isstring(flagChar) ) then
        ow.util:PrintError("Attempted to register a flag without a flag character!")
        return
    end

    if ( self.stored[flagChar] ) then
        ow.util:PrintError("Attempted to register a flag that already exists!")
        return
    end

    self.stored[flagChar] = {
        Give = giveFunction or nil,
        Take = takeFunction or nil
    }

    hook.Run("OnFlagRegistered", flagChar, giveFunction, takeFunction)
end

function ow.flag:Get(flagChar)
    return self.stored[flagChar]
end

function ow.flag:Give(ply, flagChar)
    local flagData = self:Get(flagChar)
    if ( !flagData or !flagData.Give ) then return end

    if ( isfunction(flagData.Give) ) then
        flagData:Give(ply, flagChar)
    end

    hook.Run("OnFlagGiven", ply, flagChar)
end

function ow.flag:Take(ply, flagChar)
    local flagData = self:Get(flagChar)
    if ( !flagData or !flagData.Take ) then return end

    if ( isfunction(flagData.Take) ) then
        flagData:Take(ply, flagChar)
    end

    hook.Run("OnFlagTaken", ply, flagChar)
end