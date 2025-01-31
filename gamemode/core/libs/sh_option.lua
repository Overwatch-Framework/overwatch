--- Options library
-- @module ow.option

ow.option = {}
ow.option.stored = {}

if ( CLIENT ) then
    function ow.option:Load()
        hook.Run("PreOptionsLoad")

        local folder = SCHEMA and SCHEMA.Folder or "core"
        if ( file.Exists("overwatch/" .. folder .. "/options.txt", "DATA") ) then
            self.stored = util.JSONToTable(file.Read("overwatch/" .. folder .. "/options.txt", "DATA"))
        end

        hook.Run("PostOptionsLoad", self.stored)
    end

    ow.option:Load()

    function ow.option:Set(key, value)
        local stored = self.stored[key]
        if ( !stored ) then
            ow.util:PrintError("Option \"" .. key .. "\" does not exist!")
            return false
        end

        if ( stored.OnChange ) then
            stored:OnChange(value, stored.Value)
        end

        stored.Value = value

        if ( !stored.bNoNetworking ) then
            net.Start("ow.option.set")
                net.WriteString(key)
                net.WriteType(value)
            net.SendToServer()
        end

        local folder = SCHEMA and SCHEMA.Folder or "core"
        file.Write("overwatch/" .. folder .. "/options.txt", util.TableToJSON(self.stored))

        hook.Run("OnOptionChanged", key, value)

        return true
    end

    function ow.option:SetDefault(key, default)
        local stored = self.stored[key]
        if ( !stored ) then
            ow.util:PrintError("Option \"" .. key .. "\" does not exist!")
            return false
        end

        stored.Default = default

        local folder = SCHEMA and SCHEMA.Folder or "core"
        file.Write("overwatch/" .. folder .. "/options.txt", util.TableToJSON(self.stored))

        return true
    end

    function ow.option:Get(key, fallback)
        local optionData = self.stored[key]
        if ( !optionData ) then
            ow.util:PrintError("Option \"" .. key .. "\" does not exist!")
            return fallback or nil
        end

        if ( fallback == nil ) then
            fallback = optionData.Default
        end

        return optionData.Value or fallback
    end

    net.Receive("ow.option.set", function(len)
        local key = net.ReadString()
        local value = net.ReadType()

        local stored = ow.option.stored[key]
        if ( !stored ) then return end

        ow.option:Set(key, value)
    end)
end

function ow.option:Register(uniqueID, data)
    if ( !file.Exists("overwatch", "DATA") ) then
        file.CreateDir("overwatch")
    end

    local folder = SCHEMA and SCHEMA.Folder or "core"
    if ( !file.Exists("overwatch/" .. folder, "DATA") ) then
        file.CreateDir("overwatch/" .. folder)
    end

    hook.Run("PreOptionRegistered", uniqueID, data)

    self.stored[uniqueID] = {
        DisplayName = data.DisplayName,
        Description = data.Description,
        Type = data.Type,
        Default = data.Default,
        Value = self.stored[key] and self.stored[key].Value or data.Default
    }

    file.Write("overwatch/" .. folder .. "/options.txt", util.TableToJSON(self.stored))
    hook.Run("PostOptionRegistered", uniqueID, data)
end