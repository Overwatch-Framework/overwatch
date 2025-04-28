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

    if ( SERVER ) then
        local compressed = util.Compress(util.TableToJSON(self.stored))

        net.Start("ow.option.syncServer")
            net.WriteData(compressed, #compressed)
        net.SendToServer()
    end

    return true
end

if ( CLIENT ) then
    ow.option.localClient = ow.option.localClient or {}

    function ow.option:Load()
        hook.Run("PreOptionsLoad")

        for k, v in pairs(ow.data:Get("options", {}, true, false)) do
            if ( istable(self.stored[k]) ) then
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
            if ( v.Value != nil and v.Value != v.Default ) then
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

    function ow.option:GetDefault(key)
        local optionData = self.stored[key]
        if ( !istable(optionData) ) then
            ow.util:PrintError("Option \"" .. key .. "\" does not exist!")
            return nil
        end

        return optionData.Default
    end

    -- Set the option to the default value
    function ow.option:Reset(key)
        local optionData = self.stored[key]
        if ( !istable(optionData) ) then
            ow.util:PrintError("Option \"" .. key .. "\" does not exist!")
            return false
        end

        self:Set(key, optionData.Default)

        return true
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
end

local requiredFields = {
    "Name",
    "Description",
    "Default"
}

function ow.option:Register(key, data)
    local bResult = hook.Run("PreOptionRegistered", key, data)
    if ( bResult == false ) then return false end

    for _, v in pairs(requiredFields) do
        if ( data[v] == nil ) then
            ow.util:PrintError("Option \"" .. key .. "\" is missing required field \"" .. v .. "\"!\n")
            return false
        end
    end

    if ( data.Type == nil ) then
        data.Type = ow.util:GetTypeFromValue(data.Default)

        if ( data.Type == nil ) then
            ow.util:PrintError("Option \"" .. key .. "\" has an invalid type!")
            return false
        end
    end

    if ( data.Category == nil ) then
        data.Category = "misc"
    end

    if ( data.SubCategory == nil ) then
        data.SubCategory = "other"
    end

    data.UniqueID = key

    self.stored[key] = data
    hook.Run("PostOptionRegistered", key, data)

    return true
end