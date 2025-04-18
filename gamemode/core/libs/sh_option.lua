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

        for k, v in pairs(ow.data:Get("options", {}, true, false)) do
            if ( self.stored[k] != nil ) then
                self.stored[k].Value = v
            end
        end

        local compressed = util.Compress(util.TableToJSON(self:GetSaveData()))

        net.Start("ow.option.syncServer")
            net.WriteData(compressed, #compressed)
        net.SendToServer()

        hook.Run("PostOptionsLoad", self.stored)
    end

    function ow.option:GetSaveData()
        local data = {}
        for k, v in pairs(self.stored) do
            if ( v.Value and v.Value != v.Default ) then
                data[k] = v.Value
            end
        end

        return data
    end

    function ow.option:Set(key, value)
        local ply = LocalPlayer()

        local bResult = hook.Run("PreOptionChanged", ply, key, value)
        if ( bResult == false ) then return false end

        local stored = self.stored[key]
        if ( !istable(stored) ) then
            ow.util:PrintError("Option \"" .. key .. "\" does not exist!")
            return false
        end

        if ( isfunction(stored.OnChange) ) then
            stored:OnChange(value, ply)
        end

        stored.Value = value

        if ( !stored.bNoNetworking ) then
            net.Start("ow.option.set")
                net.WriteString(key)
                net.WriteType(value)
            net.SendToServer()
        end

        ow.data:Set("options", self:GetSaveData(), true, false)

        hook.Run("PostOptionChanged", ply, key, value)

        return true
    end

    function ow.option:Get(key, fallback)
        local optionData = self.stored[key]
        if ( !istable(optionData) ) then
            ow.util:PrintError("Option \"" .. key .. "\" does not exist!")
            return fallback
        end

        return optionData.Value == nil and optionData.Default or optionData.Value
    end

    function ow.option:ResetAll()
        for k, v in pairs(self.stored) do
            v.Value = nil
        end

        ow.data:Set("options", {}, true, false)

        local compressed = util.Compress("[]")
        net.Start("ow.option.syncServer")
            net.WriteData(compressed, #compressed)
        net.SendToServer()
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

    local OPTION = table.Copy(data)
    for _, v in pairs(requiredFields) do
        if ( data[v] == nil ) then
            ow.util:PrintError("Option \"" .. key .. "\" is missing required field \"" .. v .. "\"!\n")
            return false
        end
    end

    self.stored[key] = OPTION
    hook.Run("PostOptionRegistered", key, data, OPTION)

    return true
end