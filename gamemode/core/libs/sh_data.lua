ow.data = ow.data or {}
ow.data.stored = ow.data.stored or {}

file.CreateDir("overwatch")

function ow.data:Set(key, value, bGlobal, bMap)
    local directory = "overwatch/" .. ( ( bGlobal and "" or SCHEMA and SCHEMA.Folder ) .. "/") .. (!bMap and "" or game.GetMap() .. "/")

    if ( !bGlobal ) then
        file.CreateDir("overwatch/" .. SCHEMA.Folder .. "/")
    end

    file.CreateDir(directory)
    file.Write(directory .. key .. ".json", util.TableToJSON({value}))

    self.stored[key] = value

    return directory
end

function ow.data:Get(key, fallback, bGlobal, bMap, bRefresh)
    local stored = self.stored[key]
    if ( !bRefresh and stored != nil ) then
        return stored
    end

    local path = "overwatch/" .. ( ( bGlobal and "" or SCHEMA and SCHEMA.Folder ) .. "/") .. (!bMap and "" or game.GetMap() .. "/")
    local data = file.Read(path .. key .. ".json", "DATA")
    if ( data != nil ) then
        print(data)
        data = util.JSONToTable(data)

        self.stored[key] = data[1]
        return data[1]
    end

    return fallback
end