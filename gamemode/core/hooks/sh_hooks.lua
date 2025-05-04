function GM:CanDrive(ply, entity)
    return false
end

function GM:CanPlayerJoinFaction(ply, factionID)
    return true
end

function GM:PrePlayerHandsPickup(ply, ent)
    return true
end

function GM:PrePlayerHandsPush(ply, ent)
    return true
end

function GM:GetPlayerHandsPushForce(ply)
    return 128
end

function GM:GetPlayerHandsReachDistance(ply)
    return 64
end

function GM:GetPlayerHandsMaxMass(ply)
    return 64
end

function GM:GetFrameworkColor()
    return ow.config:Get("color.framework", Color(95, 255, 220))
end

function GM:GetSchemaColor()
    return ow.config:Get("color.schema", Color(0, 150, 100))
end

function GM:GetMainMenuMusic()
    return ow.config:Get("mainmenu.music", "music/hl2_song20_submix0.mp3")
end

function GM:PlayerGetToolgun(ply)
    local character = ply:GetCharacter()
    return CAMI.PlayerHasAccess(ply, "Overwatch - Toolgun", nil) or character and character:HasFlag("t")
end

function GM:PlayerGetPhysgun(ply)
    return CAMI.PlayerHasAccess(ply, "Overwatch - Physgun", nil)
end

function GM:PlayerCanCreateCharacter(ply, character)
    return true
end

function GM:PlayerCanDeleteCharacter(ply, character)
    return true
end

function GM:PlayerCanLoadCharacter(ply, character, currentCharacter)
    return true
end

function GM:CanPlayerTakeItem(ply, item)
    return true
end

function GM:ItemCanBeDestroyed(item, damageInfo)
    return true
end

function GM:GetPlayerPainSound(ply)
end

function GM:GetPlayerDeathSound(ply)
end

function GM:PreOptionChanged(ply, key, value)
end

function GM:PostOptionChanged(ply, key, value)
end

function GM:PlayerCanHearChat(ply, listener, uniqueID, text)
    local canHear = ow.chat:Get(uniqueID).CanHear
    if ( isbool(canHear) ) then
        return canHear
    elseif ( isfunction(canHear) ) then
        return ow.chat:Get(uniqueID):CanHear(ply, listener, text)
    end

    return true
end

function GM:PreConfigChanged(key, value, oldValue, ply)
end

function GM:PostConfigChanged(key, value, oldValue, ply)
end

function GM:SetupMove(ply, mv, cmd)
    local st = ply:GetRelay("stamina")
    if ( st and st.current <= 0 ) then
        -- Prevent sprinting input
        if ( mv:KeyDown(IN_SPEED) ) then
            mv:SetButtons(mv:GetButtons() - IN_SPEED)
        end

        -- Prevent jumping input
        if ( mv:KeyDown(IN_JUMP) ) then
            mv:SetButtons(mv:GetButtons() - IN_JUMP)
        end

        -- Reduce max speed (e.g., 25% slower)
        mv:SetMaxSpeed(mv:GetMaxSpeed() * 0.75)
        mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * 0.75)
    end
end

function GM:OnPlayerHitGround(ply, inWater, onFloater, speed)
    if ( CLIENT ) then return end

    local st = ply:GetRelay("stamina")
    if ( st and st.current > 0 ) then
        ow.stamina:Consume(ply, speed / 64)
    end
end