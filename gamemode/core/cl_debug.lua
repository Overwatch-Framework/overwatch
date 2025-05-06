concommand.Add("ow_debug_pos", function(ply, cmd, args)
    if ( !ply:IsAdmin() ) then return end

    local value = ply:GetPos()

    if ( isstring(args[1]) ) then
        if ( args[1] == "trace" ) then
            value = ply:GetEyeTrace().HitPos
        elseif ( args[1] == "eye" ) then
            value = ply:EyePos()
        elseif ( args[1] == "entity" ) then
            local entity = ply:GetEyeTrace().Entity

            if ( IsValid(entity) ) then
                value = entity:GetPos()
            end
        end
    end

    return value
end, function(cmd, argStr, args)
    return {cmd .. "[trace|eye|entity]"}
end)

concommand.Add("ow_debug_ang", function(ply, cmd, args)
    if ( !ply:IsAdmin() ) then return end

    local value = ply:GetAngles()

    if ( isstring(args[1]) ) then
        if ( args[1] == "trace" ) then
            value = ply:GetEyeTrace().HitNormal:Angle()
        elseif ( args[1] == "eye" ) then
            value = ply:EyeAngles()
        elseif ( args[1] == "entity" ) then
            local entity = ply:GetEyeTrace().Entity

            if ( IsValid(entity) ) then
                value = entity:GetAngles()
            end
        end
    end

    return value
end, function(cmd, argStr, args)
    return {cmd .. "[trace|eye|entity]"}
end)