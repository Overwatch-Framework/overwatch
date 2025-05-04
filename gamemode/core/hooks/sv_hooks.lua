local time
local loadQueue = {}
function GM:PlayerInitialSpawn(ply)
    if ( ply:IsBot() ) then return end

    time = CurTime()
    ow.util:Print("Starting to load player " .. ply:SteamName() .. " (" .. ply:SteamID64() .. ")")

    ow.sqlite:LoadRow("ow_players", "steamid", ply:SteamID64(), function(data)
        if ( !IsValid(ply) ) then return end

        ply:GetTable().owDatabase = data or {}

        ply:SetDBVar("name", ply:SteamName())
        ply:SetDBVar("ip", ply:IPAddress())
        ply:SetDBVar("last_played", os.time())
        ply:SetDBVar("data", IsValid(data) and data.data or "[]")

        ply:SetTeam(0)
        ply:SetModel("models/player/kleiner.mdl")

        loadQueue[ply] = true

        -- Do not render the player, as we are in the main menu
        -- and we do not have a character loaded yet
        ply:SetNoDraw(true)
        ply:SetNotSolid(true)
        ply:SetMoveType(MOVETYPE_NONE)

        ply:KillSilent()

        ow.util:Print("Loaded player " .. ply:SteamName() .. " (" .. ply:SteamID64() .. ") in " .. math.Round(CurTime() - time, 2) .. " seconds.")
        time = CurTime()

        ow.config:Synchronize(ply)
    end)
end

function GM:StartCommand(ply, cmd)
    if ( loadQueue[ply] and !cmd:IsForced() ) then
        loadQueue[ply] = nil
        ow.character:CacheAll(ply)
        ow.util:SendChatText(nil, Color(25, 75, 150), ply:SteamName() .. " has joined the server.")

        net.Start("ow.mainmenu")
        net.Send(ply)

        ply:SaveDB()

        hook.Run("PostPlayerInitialSpawn", ply)

        ow.util:Print("Finished loading player " .. ply:SteamName() .. " (" .. ply:SteamID64() .. ") in " .. math.Round(CurTime() - time, 2) .. " seconds.")
        time = CurTime()
    end
end

function GM:PostPlayerInitialSpawn(ply)
    -- Do something here
end

function GM:PlayerDisconnected(ply)
    if ( !ply:IsBot() ) then
        ply:SetDBVar("play_time", ply:GetDBVar("play_time") + (os.time() - ply:GetDBVar("last_played")))
        ply:SetDBVar("last_played", os.time())
        ply:SaveDB()

        local character = ply:GetCharacter()
        if ( character ) then
            character:SetPlayTime(character:GetPlayTime() + (os.time() - character:GetLastPlayed()))
            character:SetLastPlayed(os.time())
            character:Save()
        end
    end
end

function GM:PlayerSpawn(ply)
    ow.stamina:Initialize(ply)

    hook.Run("PlayerLoadout", ply)
end

function GM:PlayerLoadout(ply)
    if ( hook.Run("PlayerGetToolgun", ply) ) then ply:Give("gmod_tool") end
    if ( hook.Run("PlayerGetPhysgun", ply) ) then ply:Give("weapon_physgun") end

    ply:Give("ow_hands")
    ply:SelectWeapon("ow_hands")

    ply:SetWalkSpeed(ow.config:Get("speed.walk", 80))
    ply:SetRunSpeed(ow.config:Get("speed.run", 180))
    ply:SetJumpPower(ow.config:Get("jump.power", 160))

    ply:SetupHands()

    hook.Run("PostPlayerLoadout", ply)

    return true
end

function GM:PostPlayerLoadout(ply)
end

function GM:PlayerDeathThink(ply)
    -- TODO: uh, some happy day this should be replaced
    if ( ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_ATTACK2) or ply:KeyPressed(IN_JUMP) or ply:IsBot() ) then
        ply:Spawn()
    end
end

function GM:PlayerSay(ply, text, teamChat)
    if ( string.sub(text, 1, 1) == "/" ) then
        -- TODO: Arguments such as "bloody cop" "bloody" cop, don't work correctly
        local arguments = string.Explode(" ", string.sub(text, 2))
        local command = arguments[1]
        table.remove(arguments, 1)

        ow.command:Run(ply, command, arguments)
    else
        ow.chat:Send(ply, "ic", text)
    end

    return ""
end

function GM:PlayerUseSpawnSaver(ply)
    return false
end

function GM:Initialize()
    ow.schema:Initialize()
end

function GM:SetupPlayerVisibility(ply, viewEntity)
    if ( ply:Team() == 0 ) then
        AddOriginToPVS(ow.config:Get("mainmenu.pos", vector_origin))
    end
end

function GM:PlayerSwitchFlashlight(ply, bEnabled)
    return true
end

function GM:GetFallDamage(ply, speed)
    if ( speed > 100 ) then
        ow.util:Print("I would ragdoll the player... but missing function!")
        -- TODO: Implement this in the future
        -- ply:Ragdoll()
    end

    return speed / 8
end

function GM:PlayerDeletedCharacter(ply, characterID)
    -- TODO: Empty hook, implement this in the future
end

function GM:PlayerLoadedCharacter(ply, character, previousCharacter)
    -- TODO: Empty hook, implement this in the future
end

function GM:PlayerCreatedCharacter(ply, character)
    -- TODO: Empty hook, implement this in the future
end

local nextThink = 0
local nextStamina = 0
local nextSave = 0
local playerVoiceListeners = {}
function GM:Think()
    if ( CurTime() >= nextThink ) then
        nextThink = CurTime() + 1

        for _, ply in player.Iterator() do
            if ( !IsValid(ply) or !ply:Alive() ) then continue end
            if ( ply:Team() == 0 ) then continue end

            -- Voice chat listeners
            local voiceListeners = {}

            for _, listener in player.Iterator() do
                if ( listener == ply ) then continue end
                if ( listener:EyePos():DistToSqr(ply:EyePos()) > ow.config:Get("voice.distance", 384) ^ 2 ) then continue end

                voiceListeners[listener] = true
            end

            -- Overwrite the voice listeners if the config is disabled
            if ( ow.config:Get("voice", true) ) then
                playerVoiceListeners[ply] = voiceListeners
            else
                playerVoiceListeners = {}
            end
        end
    end

    if ( CurTime() >= nextStamina ) then
        local regen = ow.config:Get("stamina.regen", 20) / 10
        local drain = ow.config:Get("stamina.drain", 10) / 10
        nextStamina = CurTime() + ow.config:Get("stamina.tick", 0.1)

        for _, ply in player.Iterator() do
            if ( !IsValid(ply) or !ply:Alive() ) then continue end
            if ( ply:Team() == 0 ) then continue end

            if ( ply.owStamina ) then
                local st = ply.owStamina
                local isSprinting = ply:KeyDown(IN_SPEED) and ply:KeyDown(IN_FORWARD) and ply:OnGround()

                if ( isSprinting and ply:GetVelocity():Length2DSqr() > 1 ) then
                    if ( ow.stamina:Consume(ply, drain) ) then
                        st.depleted = false
                        st.regenBlockedUntil = CurTime() + 2
                    else
                        if ( !st.depleted ) then
                            st.depleted = true
                            st.regenBlockedUntil = CurTime() + 10
                        end
                    end
                else
                    if ( st.regenBlockedUntil and CurTime() >= st.regenBlockedUntil ) then
                        ow.stamina:Set(ply, math.min(st.current + regen, st.max))
                    end
                end
            end
        end
    end

    if ( CurTime() >= nextSave ) then
        nextSave = CurTime() + ow.config:Get("save.interval", 300)
        hook.Run("SaveData")
    end
end

function GM:SaveData()
    ow.util:Print("Saving data...")

    -- TODO: Empty hook, implement this in the future

    ow.util:Print("Data saved.")
end

function GM:PlayerCanHearPlayersVoice(listener, talker)
    if ( !playerVoiceListeners[listener] ) then return false end
    if ( !playerVoiceListeners[listener][talker] ) then return false end

    return true, true
end

function GM:CanPlayerSuicide(ply)
    return false
end

function GM:PlayerDeathSound(ply)
    return true
end

function GM:PlayerHurt(ply, attacker, healthRemaining, damageTaken)
    local painSound = hook.Run("GetPlayerPainSound", ply, attacker, healthRemaining, damageTaken)
    if ( painSound and painSound != "" and !ply:InObserver() ) then
        if ( !file.Exists("sound/" .. painSound, "GAME") ) then
            ow.util:PrintWarning("PlayerPainSound: Sound file does not exist! " .. painSound)
            return false
        end

        ply:EmitSound(painSound, 75, 100, 1, CHAN_VOICE)
    end
end

function GM:PlayerDeath(ply, inflictor, attacker) -- Test
    local deathSound = hook.Run("GetPlayerDeathSound", ply, inflictor, attacker)
    if ( deathSound and deathSound != "" and !ply:InObserver() ) then
        if ( !file.Exists("sound/" .. deathSound, "GAME") ) then
            ow.util:PrintWarning("PlayerDeathSound: Sound file does not exist! " .. deathSound)
            return false
        end

        ply:EmitSound(deathSound, 75, 100, 1, CHAN_VOICE)
    end
end

function GM:PostPlayerDropItem(ply, item, entity)
    if ( !item or !IsValid(entity) ) then return end

    entity:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 4) .. ".wav", 75, math.random(90, 110), 1, CHAN_ITEM)
end

function GM:PostPlayerTakeItem(ply, item, entity)
    if ( !item or !IsValid(entity) ) then return end

    entity:EmitSound("physics/body/body_medium_impact_soft" .. math.random(5, 7) .. ".wav", 75, math.random(90, 110), 1, CHAN_ITEM)
end

local function IsAdmin(_, ply)
    return ply:IsAdmin()
end

GM.PlayerSpawnEffect = IsAdmin
GM.PlayerSpawnNPC = IsAdmin
GM.PlayerSpawnObject = IsAdmin
GM.PlayerSpawnProp = IsAdmin
GM.PlayerSpawnRagdoll = IsAdmin
GM.PlayerSpawnSENT = IsAdmin
GM.PlayerSpawnSWEP = IsAdmin
GM.PlayerGiveSWEP = IsAdmin
GM.PlayerSpawnVehicle = IsAdmin