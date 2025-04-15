--- Options library
-- @module ow.option

ow.option = {}
ow.option.stored = {}

function ow.option:SetDefault(key, default)
    local stored = self.stored[key]
    if ( !istable(stored) ) then
        ow.util:PrintError("Option \"" .. key .. "\" does not exist!")
        return false
    end

    stored.Default = default

    return true
end

if ( CLIENT ) then
    ow.option.localClient = ow.option.localClient or {}

    function ow.option:Load()
        hook.Run("PreOptionsLoad")

        local folder = SCHEMA and SCHEMA.Folder or "core"
        if ( file.Exists("overwatch/" .. folder .. "/options.json", "DATA") ) then
            self.localClient = util.JSONToTable(file.Read("overwatch/" .. folder .. "/options.json", "DATA"))
        end

        local compressed = util.Compress(util.TableToJSON(self.localClient))

        net.Start("ow.option.syncServer")
            net.WriteData(compressed, #compressed)
        net.SendToServer()

        hook.Run("PostOptionsLoad", self.stored)
    end

    function ow.option:Set(key, value)
        local stored = self.stored[key]
        if ( !istable(stored) ) then
            ow.util:PrintError("Option \"" .. key .. "\" does not exist!")
            return false
        end

        if ( stored.OnChange ) then
            stored:OnChange(value, stored.Value)
        end

        self.localClient[key] = value

        if ( !stored.bNoNetworking ) then
            net.Start("ow.option.set")
                net.WriteString(key)
                net.WriteType(value)
            net.SendToServer()
        end

        local folder = SCHEMA and SCHEMA.Folder or "core"

        if ( file.Exists("overwatch/" .. folder .. "/options.json", "DATA") ) then
            file.Write("overwatch/" .. folder .. "/options.json", util.TableToJSON(self.localClient))
        end

        hook.Run("OnOptionChanged", LocalPlayer(), key, value)

        return true
    end

    function ow.option:Get(key, fallback)
        local optionData = self.stored[key]
        if ( !istable(optionData) ) then
            ow.util:PrintError("Option \"" .. key .. "\" does not exist!")
            return fallback or nil
        end

        if ( fallback == nil ) then
            fallback = optionData.Default
        end

        return self.localClient[key] or fallback
    end

    function ow.option:ResetAll()
        self.localClient = {}
    end

    net.Receive("ow.option.set", function(len)
        local key = net.ReadString()
        local value = net.ReadType()

        local stored = ow.option.stored[key]
        if ( !istable(stored) ) then return end

        ow.option:Set(key, value)
    end)
end

local requiredFields = {
    "DisplayName",
    "Description",
    "Type",
    "Default"
}

function ow.option:Register(key, data)
    local bResult = hook.Run("PreOptionRegistered", key, data)
    if ( bResult == false ) then return false end

    if ( !file.Exists("overwatch", "DATA") ) then
        file.CreateDir("overwatch")
    end

    local folder = SCHEMA and SCHEMA.Folder or "core"
    if ( !file.Exists("overwatch/" .. folder, "DATA") ) then
        file.CreateDir("overwatch/" .. folder)
    end

    if ( !file.Exists("overwatch/" .. folder .. "/options.json", "DATA") ) then
        file.Write("overwatch/" .. folder .. "/options.json", "[]")
    end

    local OPTION = data
    for _, v in pairs(requiredFields) do
        if ( data[v] == nil ) then
            print("Option \"" .. key .. "\" is missing required field \"" .. v .. "\"!")
            ow.util:PrintError("Option \"" .. key .. "\" is missing required field \"" .. v .. "\"!\n")
            return false
        end
    end

    print("Defining", key)
    self.stored[key] = OPTION
    hook.Run("PostOptionRegistered", key, data, OPTION)

    return true
end