local STEAM_API_KEY = file.Read("overwatch/steam_api.txt", "DATA") or "YOUR_STEAM_API_KEY"
local format = "http://api.steampowered.com/%s/%s/v0002/?key=%s&steamids=%s&format=json"

ow.avatars = ow.avatars or {}
ow.avatars.stored = ow.avatars.stored or {}

file.CreateDir("overwatch/avatars")

function ow.avatars:GetAvatar(ply)
    local steamID = ply:SteamID64()
    if ( ow.avatars.stored[steamID] ) then
        return ow.avatars.stored[steamID]
    end

    http.Fetch(format:format("ISteamUser", "GetPlayerSummaries", STEAM_API_KEY, steamID), function(body, len, headers, code)
        if ( !IsValid(ply) ) then return end -- cunt disconnected

        if ( code != 200 ) then
            ow.util:PrintError("ow.avatars:GetAvatar", "Failed to fetch avatar for " .. steamID .. ": " .. code)
            return
        end

        local data = util.JSONToTable(body)
        if ( !istable(data) or !istable(data.response) or !istable(data.response.players) ) then return end

        local playerData = data.response.players[1]
        if ( !istable(playerData) or !isstring(playerData.avatarfull) ) then return end

        local avatarURL = playerData.avatarfull
        ow.avatars.stored[steamID] = avatarURL
        http.Fetch(avatarURL, function(imageData)
            file.Write("overwatch/avatars/" .. steamID .. ".png", imageData)

            ow.avatars.stored[steamID] = {url = avatarURL, data = imageData}

            return ow.avatars.stored[steamID]
        end)
    end)
end

function ow.avatars:Clear()
    ow.avatars.stored = {}

    for k, v in ipairs(file.Find("overwatch/avatars/*.png", "DATA")) do
        file.Delete("overwatch/avatars/" .. v)
    end
end

function ow.avatars:Delete(ply)
    local steamID = ply:SteamID64()

    ow.avatars.stored[steamID] = nil
    file.Delete("overwatch/avatars/" .. steamID)
end

hook.Add("PlayerConnect", "ow.avatars.PlayerConnect", function(ply, ip)
    ow.avatars:GetAvatar(ply)
end)

local avatarReloaded = false
hook.Add("OnReloaded", "ow.avatars.OnReloaded", function()
    if ( avatarReloaded ) then return end
    avatarReloaded = true
    ow.avatars:Clear()

    for _, ply in player.Iterator() do
        ow.avatars:GetAvatar(ply)
    end
end)

hook.Add("OnShutdown", "ow.avatars.OnShutdown", function()
    ow.avatars.stored = {}

    for _, sID64 in ipairs(file.Find("overwatch/avatars/*.png", "DATA")) do
        file.Delete("overwatch/avatars/" .. sID64)
    end
end)

hook.Add("PlayerDisconnected", "ow.avatars.PlayerDisconnected", function(ply)
    local steamID = ply:SteamID64()
    ow.avatars.stored[steamID] = nil

    file.Delete("overwatch/avatars/" .. steamID)
end)