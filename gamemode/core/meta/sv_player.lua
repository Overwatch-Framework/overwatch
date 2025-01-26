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
    local data = self:GetData()

    local query = mysql:Update("overwatch_players")
        query:Update("data", util.TableToJSON(data))
        query:Where("steamid64", self:SteamID64())
    query:Execute()
end