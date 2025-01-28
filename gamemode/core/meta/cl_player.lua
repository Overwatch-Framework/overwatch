local PLAYER = FindMetaTable("Player")

function PLAYER:GetData(key, default)
    local data = ow.localData and ow.localData[key]
    if ( data == nil ) then
        return default
    else
        return data
    end
end