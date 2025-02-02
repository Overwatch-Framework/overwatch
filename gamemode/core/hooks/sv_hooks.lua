function GM:PlayerInitialSpawn(ply)
    ply:LoadData(function()
        if ( !IsValid(ply) ) then return end

        ply:SetTeam(0)
        ply:SetModel("models/player/kleiner.mdl")

        -- Do not render the player, as we are in the main menu
        -- and we do not have a character loaded yet
        ply:SetNoDraw(true)
        ply:SetNotSolid(true)
        ply:SetMoveType(MOVETYPE_NONE)

        ply:KillSilent()
        ply:SendLua("vgui.Create(\"ow.mainmenu\")")

        ow.config:Synchronize(ply)

        ow.util:SendChatText(nil, Color(25, 75, 150), ply:SteamName() .. " has joined the server.")

        hook.Run("PostPlayerInitialSpawn", ply)
    end)
end

function GM:PostPlayerInitialSpawn(ply)
    -- Do something here
end

function GM:PlayerDisconnected(ply)
    -- Do something here
end

function GM:PlayerSpawn(ply)
    hook.Run("PlayerLoadout", ply)
end

function GM:PlayerLoadout(ply)
    if ( hook.Run("PlayerGetToolgun", ply) ) then ply:Give("gmod_tool") end
    if ( hook.Run("PlayerGetPhysgun", ply) ) then ply:Give("weapon_physgun") end

    ply:Give("ow_hands")
    ply:SelectWeapon("ow_hands")

    ply:SetWalkSpeed(ow.config:Get("walkSpeed", 80))
    ply:SetRunSpeed(ow.config:Get("runSpeed", 180))
    ply:SetJumpPower(ow.config:Get("jumpPower", 160))

    ply:SetupHands()

    hook.Run("PostPlayerLoadout", ply)

    return true
end

function GM:PostPlayerLoadout(ply)
end

function GM:PlayerDeathThink(ply)
    if ( ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_ATTACK2) or ply:KeyPressed(IN_JUMP) or ply:IsBot() ) then
        ply:Spawn()
    end
end

function GM:PlayerSay(ply, text, teamChat)
    if ( string.sub(text, 1, 1) == "/" ) then
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
        AddOriginToPVS(ow.config:Get("menuCamPos", vector_origin))
    end
end

function GM:PlayerSwitchFlashlight(ply, bEnabled)
    return true
end

function GM:GetFallDamage(ply, speed)
    if ( speed > 100 ) then
        ow.util:Print("I would ragdoll the player... but missing function!")
        -- ply:Ragdoll()
    end

    return speed / 8
end

function GM:PlayerDeletedCharacter(ply, characterID)
    -- Do something here
end

function GM:PlayerLoadedCharacter(ply, character, previousCharacter)
    -- Do something here
end

function GM:PlayerCreatedCharacter(ply, character)
    -- Do something here
end

local nextThink = 0
local nextSave = 0
local playerVoiceListeners = {}
function GM:Think()
    if ( CurTime() < nextThink ) then return end
    nextThink = CurTime() + 1

    for _, ply in player.Iterator() do
        if ( !IsValid(ply) or !ply:Alive() ) then continue end

        local voiceListeners = {}
        for _, listener in player.Iterator() do
            if ( listener == ply ) then continue end
            if ( listener:EyePos():DistToSqr(ply:EyePos()) > ow.config:Get("voiceDistance", 384) ^ 2 ) then continue end

            voiceListeners[listener] = true
        end

        playerVoiceListeners[ply] = voiceListeners
    end

    if ( CurTime() < nextSave ) then return end
    nextSave = CurTime() + ow.config:Get("saveInterval", 300)

    hook.Run("SaveData")
end

function GM:SaveData()
    for _, ply in player.Iterator() do
        if ( !IsValid(ply) ) then continue end

        ply:SaveData()
    end
end

function GM:PlayerCanHearPlayersVoice(listener, talker)
    if ( !playerVoiceListeners[listener] ) then return false end
    if ( !playerVoiceListeners[listener][talker] ) then return false end

    return true, true
end