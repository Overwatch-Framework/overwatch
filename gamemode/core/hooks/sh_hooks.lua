function GM:CanDrive(client, entity)
    return false
end

function GM:CanPlayerJoinFaction(client, factionID)
    return true
end

function GM:PrePlayerHandsPickup(client, ent)
    return true
end

function GM:PrePlayerHandsPush(client, ent)
    return true
end

function GM:GetPlayerHandsPushForce(client)
    return 128
end

function GM:GetPlayerHandsReachDistance(client)
    return 64
end

function GM:GetPlayerHandsMaxMass(client)
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

function GM:PlayerGetToolgun(client)
    local character = client:GetCharacter()
    return CAMI.PlayerHasAccess(client, "Overwatch - Toolgun", nil) or character and character:HasFlag("t")
end

function GM:PlayerGetPhysgun(client)
    return CAMI.PlayerHasAccess(client, "Overwatch - Physgun", nil)
end

function GM:PlayerCanCreateCharacter(client, character)
    return true
end

function GM:PlayerCanDeleteCharacter(client, character)
    return true
end

function GM:PlayerCanLoadCharacter(client, character, currentCharacter)
    return true
end

function GM:CanPlayerTakeItem(client, item)
    return true
end

function GM:ItemCanBeDestroyed(item, damageInfo)
    return true
end

function GM:GetPlayerPainSound(client)
end

function GM:GetPlayerDeathSound(client)
end

function GM:PreOptionChanged(client, key, value)
end

function GM:PostOptionChanged(client, key, value)
end

function GM:PlayerCanHearChat(client, listener, uniqueID, text)
    local canHear = ow.chat:Get(uniqueID).CanHear
    if ( isbool(canHear) ) then
        return canHear
    elseif ( isfunction(canHear) ) then
        return ow.chat:Get(uniqueID):CanHear(client, listener, text)
    end

    return true
end

function GM:PreConfigChanged(key, value, oldValue, client)
end

function GM:PostConfigChanged(key, value, oldValue, client)
end

function GM:SetupMove(client, mv, cmd)
end

local KEY_SHOOT = IN_ATTACK + IN_ATTACK2
function GM:StartCommand(client, cmd)
    local weapon = client:GetActiveWeapon()
    if ( !IsValid(weapon) or !weapon:IsWeapon() ) then return end

    if ( !weapon.FireWhenLowered and !client:IsWeaponRaised() ) then
        cmd:RemoveKey(KEY_SHOOT)
    end
end

function GM:KeyPress(client, key)
    if ( SERVER and key == IN_RELOAD ) then
        timer.Create("ow.wepRaise." .. client:SteamID64(), ow.config:Get("wepraise.time", 1), 1, function()
            if ( IsValid(client) ) then
                client:ToggleWeaponRaise()
            end
        end)
    end
end

function GM:KeyRelease(client, key)
    if ( SERVER and key == IN_RELOAD ) then
        timer.Remove("ow.wepRaise." .. client:SteamID64())
    end
end

function GM:PlayerSwitchWeapon(client, hOldWeapon, hNewWeapon)
    if ( SERVER ) then
        timer.Simple(0.1, function()
            if ( IsValid(client) and IsValid(hNewWeapon) ) then
                client:SetWeaponRaised(false)
            end
        end)
    end
end

function GM:PreSpawnClientRagdoll(client)

end