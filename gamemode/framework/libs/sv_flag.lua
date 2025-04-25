function ow.flag:Give(ply, flagChar)
    local flagData = self:Get(flagChar)
    if ( !istable(flagData) ) then return end

    if ( isfunction(flagData.OnGive) ) then
        flagData:OnGive(ply, flagChar)
    end

    -- TODO: ply data saving for this

    hook.Run("OnFlagGiven", ply, flagChar)
end

function ow.flag:Take(ply, flagChar)
    local flagData = self:Get(flagChar)
    if ( !istable(flagData) ) then return end

    if ( isfunction(flagData.OnTake) ) then
        flagData:OnTake(ply, flagChar)
    end

    -- TODO: ply data saving for this

    hook.Run("OnFlagTaken", ply, flagChar)
end