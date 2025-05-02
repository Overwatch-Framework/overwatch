ow.flag = ow.flag or {}
ow.flag.stored = {}

function ow.flag:Register(flag, description, callback)
    if ( !isstring(flag) or #flag != 1 ) then
        ow.util:PrintError("Attempted to register a flag without a flag character!")
        return false
    end

    if ( self.stored[flag] ) then
        ow.util:PrintError("Attempted to register a flag that already exists!")
        return false
    end

    self.stored[flag] = {
        description = description or "No description provided",
        callback = callback or nil
    }

    return true
end

function ow.flag:Get(flag)
    return self.stored[flag]
end

ow.flag:Register("t", "flag.toolgun", function(char, has)
    local ply = char:GetPlayer()
    if ( !IsValid(ply) ) then return end

    if ( has ) then
        ply:Give("gmod_tool")
    else
        ply:StripWeapon("gmod_tool")
    end
end)