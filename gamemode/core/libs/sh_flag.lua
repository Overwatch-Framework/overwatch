ow.flag = ow.flag or {}
ow.flag.stored = {}

function ow.flag:Register(flagChar, giveFunction, takeFunction)
    if ( flagChar == nil or !isstring(flagChar) ) then
        ow.util:PrintError("Attempted to register a flag without a flag character!")
        return false
    end

    if ( self.stored[flagChar] ) then
        ow.util:PrintError("Attempted to register a flag that already exists!")
        return false
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