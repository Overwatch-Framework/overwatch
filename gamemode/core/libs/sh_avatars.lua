local STEAM_API_KEY = file.Read("overwatch/steam_api.txt", "DATA") or "YOUR_STEAM_API_KEY"
local format = "http://api.steampowered.com/%s/%s/v0002/?key=%s&steamids=%s&format=json"

ow.avatars = ow.avatars or {}
ow.avatars.stored = ow.avatars.stored or {}

file.CreateDir("overwatch/avatars")

if ( SERVER ) then
    util.AddNetworkString("ow.avatars.fetch")
else
    net.Receive("ow.avatars.fetch", function()
        local data = net.ReadString()
        if ( !data ) then return end

        local decoded, err = sfs.decode(data)
        print(decoded, type(decoded))
        if ( err ) then
            ow.util:PrintError("ow.avatars.fetch", " Failed to decode avatar data: " .. err)
            return
        end

        ow.avatars.stored = decoded

        for sID, avatarData in pairs(ow.avatars.stored) do
            if ( !istable(avatarData) or !isstring(avatarData.url) ) then continue end

            file.Write("overwatch/avatars/" .. sID .. ".png", avatarData.data)
        end
    end)
end

if ( SERVER ) then
    function ow.avatars:Sync()
        local encoded, err = sfs.encode(self.stored)
        if ( err ) then
            ow.util:PrintError("ow.avatars:Sync", "Failed to encode avatar data: " .. err)
            return
        end

        net.Start("ow.avatars.fetch")
            net.WriteString(encoded)
        net.Broadcast()
    end
end

function ow.avatars:GetAvatar(ply)
    local steamID = ply:SteamID64()
    local stored = self.stored[steamID]
    if ( stored ) then
        return stored
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
        stored = avatarURL
        http.Fetch(avatarURL, function(imageData)
            file.Write("overwatch/avatars/" .. steamID .. ".png", imageData)

            stored = {url = avatarURL, data = imageData}

            if ( SERVER ) then
                self:Sync()
            end

            return stored
        end)
    end)
end

function ow.avatars:Clear()
    ow.avatars.stored = {}

    for k, v in ipairs(file.Find("overwatch/avatars/*.png", "DATA")) do
        file.Delete("overwatch/avatars/" .. v)
    end

    self:Sync()
end

function ow.avatars:Delete(ply)
    local steamID = ply:SteamID64()

    ow.avatars.stored[steamID] = nil
    file.Delete("overwatch/avatars/" .. steamID)

    if ( SERVER ) then
        self:Sync()
    end
end

if ( SERVER ) then
    local avatarReloaded = false
    hook.Add("OnReloaded", "ow.avatars.OnReloaded", function()
        if ( avatarReloaded ) then return end
        avatarReloaded = true

        for _, ply in player.Iterator() do
            ow.avatars:GetAvatar(ply)
        end
    end)

    hook.Add("PlayerInitialSpawn", "ow.avatars.PlayerConnect", function(ply, ip)
        ow.avatars:GetAvatar(ply)
    end)

    hook.Add("OnShutdown", "ow.avatars.OnShutdown", function()
        ow.avatars.stored = {}

        for _, sID64 in ipairs(file.Find("overwatch/avatars/*.png", "DATA")) do
            file.Delete("overwatch/avatars/" .. sID64)
        end

        ow.avatars:Sync()
    end)

    hook.Add("PlayerDisconnected", "ow.avatars.PlayerDisconnected", function(ply)
        local steamID = ply:SteamID64()
        ow.avatars.stored[steamID] = nil

        file.Delete("overwatch/avatars/" .. steamID)
        ow.avatars:Sync()
    end)
end