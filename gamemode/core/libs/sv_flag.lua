function ow.flag:Give(ply, flagChar)
    local flagData = self:Get(flagChar)
    if ( !flagData or !flagData.Give ) then return end

    if ( isfunction(flagData.Give) ) then
        flagData:Give(ply, flagChar)
    end

    -- TODO: ply data saving for this

    hook.Run("OnFlagGiven", ply, flagChar)
end

function ow.flag:Take(ply, flagChar)
    local flagData = self:Get(flagChar)
    if ( !flagData or !flagData.Take ) then return end

    if ( isfunction(flagData.Take) ) then
        flagData:Take(ply, flagChar)
    end

    -- TODO: ply data saving for this

    hook.Run("OnFlagTaken", ply, flagChar)
end