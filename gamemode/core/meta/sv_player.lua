local PLAYER = FindMetaTable("Player")

function PLAYER:LoadData(callback)
    local query = mysql:Select("overwatch_players")
        query:Select("data")
        query:Where("steamid64", self:SteamID64())
    query:Callback(function(result)
        if ( result ) then
            local data = util.JSONToTable(result[1].data)
            if ( data ) then
                self:SetData(data)
            end
        end

        if ( callback ) then
            callback()
        end
    end)
    query:Execute()
end

function PLAYER:SaveData()
    local data = self.owData or {}

    local query = mysql:Update("overwatch_players")
        query:Update("data", util.TableToJSON(data))
        query:Where("steamid64", self:SteamID64())
    query:Execute()
end

function PLAYER:SetData(key, value, bNoNetworking)
    hook.Run("PrePlayerDataUpdated", self, key, value)

    self.owData = self.owData or {}
    self.owData[key] = value

    if ( !bNoNetworking ) then
        net.Start("ow.player.data.set")
            net.WriteString(key)
            net.WriteType(value)
        net.Send(self)
    end

    hook.Run("PostPlayerDataUpdated", self, key, value)
end

function PLAYER:GetData(key, default)
    if ( key == true ) then
        return self.owData
    end

    local data = self.owData and self.owData[key]
    if ( data == nil ) then
        return default
    else
        return data
    end
end