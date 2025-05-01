ow.flag = ow.flag or {}
ow.flag.stored = {}

function ow.flag:Register(flagChar, description, callback)
    if ( !isstring(flagChar) or #flagChar != 1 ) then
        ow.util:PrintError("Attempted to register a flag without a flag character!")
        return false
    end

    if ( self.stored[flagChar] ) then
        ow.util:PrintError("Attempted to register a flag that already exists!")
        return false
    end

    self.stored[flagChar] = {
        description = description or "No description provided",
        callback = callback or nil
    }

    hook.Run("OnFlagRegistered", flagChar, callback)
    return true
end

function ow.flag:Get(flagChar)
    return self.stored[flagChar]
end

do
    ow.flag:Register("t", "Toolgun", function(ply, hasFlag)
        if ( hasFlag ) then
            ply:Give("gmod_tool")
        else
            ply:StripWeapon("gmod_tool")
        end
    end)
end