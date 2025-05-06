local time
local loadQueue = {}
function GM:PlayerInitialSpawn(client)
    if ( client:IsBot() ) then return end

    time = CurTime()
    ow.util:Print("Starting to load player " .. client:SteamName() .. " (" .. client:SteamID64() .. ")")

    ow.sqlite:LoadRow("ow_players", "steamid", client:SteamID64(), function(data)
        if ( !IsValid(client) ) then return end

        client:GetTable().owDatabase = data or {}

        client:SetDBVar("name", client:SteamName())
        client:SetDBVar("ip", client:IPAddress())
        client:SetDBVar("last_played", os.time())
        client:SetDBVar("data", IsValid(data) and data.data or "[]")

        client:SetTeam(0)
        client:SetModel("models/player/kleiner.mdl")

        loadQueue[client] = true

        -- Do not render the player, as we are in the main menu
        -- and we do not have a character loaded yet
        client:SetNoDraw(true)
        client:SetNotSolid(true)
        client:SetMoveType(MOVETYPE_NONE)

        client:KillSilent()

        ow.util:Print("Loaded player " .. client:SteamName() .. " (" .. client:SteamID64() .. ") in " .. math.Round(CurTime() - time, 2) .. " seconds.")
        time = CurTime()

        ow.config:Synchronize(client)
    end)
end

function GM:StartCommand(client, cmd)
    if ( loadQueue[client] and !cmd:IsForced() ) then
        loadQueue[client] = nil
        ow.character:CacheAll(client)
        ow.util:SendChatText(nil, Color(25, 75, 150), client:SteamName() .. " has joined the server.")

        net.Start("ow.mainmenu")
        net.Send(client)

        client:SaveDB()

        hook.Run("PostPlayerInitialSpawn", client)

        ow.util:Print("Finished loading player " .. client:SteamName() .. " (" .. client:SteamID64() .. ") in " .. math.Round(CurTime() - time, 2) .. " seconds.")
        time = CurTime()
    end
end

function GM:PostPlayerInitialSpawn(client)
    -- Do something here
end

function GM:PlayerDisconnected(client)
    if ( !client:IsBot() ) then
        client:SetDBVar("play_time", client:GetDBVar("play_time") + (os.time() - client:GetDBVar("last_played")))
        client:SetDBVar("last_played", os.time())
        client:SaveDB()

        local character = client:GetCharacter()
        if ( character ) then
            character:SetPlayTime(character:GetPlayTime() + (os.time() - character:GetLastPlayed()))
            character:SetLastPlayed(os.time())
            character:Save()
        end
    end
end

function GM:PlayerSpawn(client)
    hook.Run("PlayerLoadout", client)
end

function GM:PlayerLoadout(client)
    if ( hook.Run("PlayerGetToolgun", client) ) then client:Give("gmod_tool") end
    if ( hook.Run("PlayerGetPhysgun", client) ) then client:Give("weapon_physgun") end

    client:Give("ow_hands")
    client:SelectWeapon("ow_hands")

    client:SetWalkSpeed(ow.config:Get("speed.walk", 80))
    client:SetRunSpeed(ow.config:Get("speed.run", 180))
    client:SetJumpPower(ow.config:Get("jump.power", 160))

    client:SetupHands()

    hook.Run("PostPlayerLoadout", client)

    return true
end

function GM:PostPlayerLoadout(client)
end

function GM:PlayerDeathThink(client)
    -- TODO: uh, some happy day this should be replaced
    if ( client:KeyPressed(IN_ATTACK) or client:KeyPressed(IN_ATTACK2) or client:KeyPressed(IN_JUMP) or client:IsBot() ) then
        client:Spawn()
    end
end

function GM:PlayerSay(client, text, teamChat)
    if ( string.sub(text, 1, 1) == "/" ) then
        local arguments = string.Explode(" ", string.sub(text, 2))
        local command = arguments[1]
        table.remove(arguments, 1)

        ow.command:Run(client, command, table.concat(arguments, " "))
    else
        ow.chat:SendSpeaker(client, "ic", text)
    end

    return ""
end

function GM:PlayerUseSpawnSaver(client)
    return false
end

function GM:Initialize()
    ow.module:LoadFolder("overwatch/modules")
    ow.item:LoadFolder("overwatch/gamemode/items")
    ow.schema:Initialize()
end

function GM:SetupPlayerVisibility(client, viewEntity)
    if ( client:Team() == 0 ) then
        AddOriginToPVS(ow.config:Get("mainmenu.pos", vector_origin))
    end
end

function GM:PlayerSwitchFlashlight(client, bEnabled)
    return true
end

function GM:GetFallDamage(client, speed)
    if ( speed > 100 ) then
        ow.util:Print("I would ragdoll the player... but missing function!")
        -- TODO: Implement this in the future
        -- client:Ragdoll()
    end

    return speed / 8
end

function GM:PostPlayerLoadedCharacter(client, character, previousCharacter)
    -- Restore the bodygroups of the character
    local groups = character:GetData("groups", {})
    for name, value in pairs(groups) do
        local id = client:FindBodygroupByName(name)
        if ( id == -1 ) then continue end

        client:SetBodygroup(id, value)
    end
end

local nextThink = 0
local nextSave = 0
local playerVoiceListeners = {}
function GM:Think()
    if ( CurTime() >= nextThink ) then
        nextThink = CurTime() + 1

        for _, client in player.Iterator() do
            if ( !IsValid(client) or !client:Alive() ) then continue end
            if ( client:Team() == 0 ) then continue end

            -- Voice chat listeners
            local voiceListeners = {}

            for _, listener in player.Iterator() do
                if ( listener == client ) then continue end
                if ( listener:EyePos():DistToSqr(client:EyePos()) > ow.config:Get("voice.distance", 384) ^ 2 ) then continue end

                voiceListeners[listener] = true
            end

            -- Overwrite the voice listeners if the config is disabled
            if ( ow.config:Get("voice", true) ) then
                playerVoiceListeners[client] = voiceListeners
            else
                playerVoiceListeners = {}
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

function GM:CanPlayerSuicide(client)
    return false
end

function GM:PlayerDeathSound(client)
    return true
end

function GM:PlayerHurt(client, attacker, healthRemaining, damageTaken)
    local painSound = hook.Run("GetPlayerPainSound", client, attacker, healthRemaining, damageTaken)
    if ( painSound and painSound != "" and !client:InObserver() ) then
        if ( !file.Exists("sound/" .. painSound, "GAME") ) then
            ow.util:PrintWarning("PlayerPainSound: Sound file does not exist! " .. painSound)
            return false
        end

        client:EmitSound(painSound, 75, 100, 1, CHAN_VOICE)
    end
end

local painSounds = {
    Sound("vo/npc/male01/pain01.wav"),
    Sound("vo/npc/male01/pain02.wav"),
    Sound("vo/npc/male01/pain03.wav"),
    Sound("vo/npc/male01/pain04.wav"),
    Sound("vo/npc/male01/pain05.wav"),
    Sound("vo/npc/male01/pain06.wav")
}

local drownSounds = {
    Sound("player/pl_drown1.wav"),
    Sound("player/pl_drown2.wav"),
    Sound("player/pl_drown3.wav"),
}

function GM:GetPlayerPainSound(client, attacker, healthRemaining, damageTaken)
    if ( client:Health() <= 0 ) then return end

    if ( client:WaterLevel() >= 3 ) then
        return drownSounds[math.random(#drownSounds)]
    end

    if ( damageTaken > 0 ) then
        return painSounds[math.random(#painSounds)]
    end
end

function GM:PlayerDeath(client, inflictor, attacker)
    local deathSound = hook.Run("GetPlayerDeathSound", client, inflictor, attacker)
    if ( deathSound and deathSound != "" and !client:InObserver() ) then
        if ( !file.Exists("sound/" .. deathSound, "GAME") ) then
            ow.util:PrintWarning("PlayerDeathSound: Sound file does not exist! " .. deathSound)
            return false
        end

        client:EmitSound(deathSound, 75, 100, 1, CHAN_VOICE)
    end
end

local deathSounds = {
    Sound("vo/npc/male01/pain07.wav"),
    Sound("vo/npc/male01/pain08.wav"),
    Sound("vo/npc/male01/pain09.wav")
}

function GM:GetPlayerDeathSound(client, inflictor, attacker)
    return deathSounds[math.random(#deathSounds)]
end

function GM:PostPlayerDropItem(client, item, entity)
    if ( !item or !IsValid(entity) ) then return end

    entity:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 4) .. ".wav", 75, math.random(90, 110), 1, CHAN_ITEM)
end

function GM:PostPlayerTakeItem(client, item, entity)
    if ( !item or !IsValid(entity) ) then return end

    entity:EmitSound("physics/body/body_medium_impact_soft" .. math.random(5, 7) .. ".wav", 75, math.random(90, 110), 1, CHAN_ITEM)
end

local function IsAdmin(_, client)
    return client:IsAdmin()
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