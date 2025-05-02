function ow.flag:Give(ply, flagChar)
    local flagData  = self:Get(flagChar)
    if ( !istable(flagData) ) then return end

    local character = ply:GetCharacter()
    if ( character ) then
        local flags = character:GetFlags()
        for i = 1, #flags do
            if ( flags[i] == flagChar ) then return false end

            character:SetFlags(flags .. flagChar)

            if ( isfunction(flagData.callback) ) then
                flagData:callback(ply, true)
            end

            hook.Run("OnFlagGiven", ply, flagChar)

            return true
        end
    end

    return false
end

function ow.flag:Take(ply, flagChar)
    local flagData  = self:Get(flagChar)
    if ( !istable(flagData) ) then return end

    local character = ply:GetCharacter()
    if ( character ) then
        local flags = character:GetFlags()
        for i = 1, #flags do
            if ( flags[i] == flagChar ) then
                character:SetFlags(string.gsub(flags, flagChar, ""))

                if ( isfunction(flagData.callback) ) then
                    flagData:callback(ply, false)
                end

                hook.Run("OnFlagTaken", ply, flagChar)

                return true
            end
        end
    end

    return false
end