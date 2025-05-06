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
        ow.net:Start(nil, "option.sync", self.stored)
    end

    return true
end

if ( CLIENT ) then
    function ow.option:Load()
        hook.Run("PreOptionsLoad")

        for k, v in pairs(ow.data:Get("options", {}, true, false)) do
            if ( istable(self.stored[k]) ) then
                self.stored[k].Value = v
            end
        end

        ow.net:Start(nil, "option.sync", self.stored)

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
        local stored = self.stored[key]
        if ( !istable(stored) ) then
            ow.util:PrintError("Option \"" .. key .. "\" does not exist!")
            return false
        end

        if ( value == nil ) then
            value = stored.Default
        end

        local client = ow.localClient
        local oldValue = stored.Value != nil and stored.Value or stored.Default
        local bResult = hook.Run("PreOptionChanged", client, key, value, oldValue)
        if ( bResult == false ) then return false end

        stored.Value = value

        if ( stored.NoNetworking != true ) then
            ow.net:Start(nil, "option.set", key, value)
        end

        if ( isfunction(stored.OnChange) ) then
            stored:OnChange(value, oldValue, client)
        end

        ow.data:Set("options", self:GetSaveData(), true, false)

        hook.Run("PostOptionChanged", client, key, value, oldValue)

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

    --- Set the option to the default value
    -- @realm client
    -- @string key The option key to reset
    -- @treturn boolean Returns true if the option was reset successfully, false otherwise
    -- @usage ow.option:Reset(key)
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
        ow.net:Start(nil, "option.sync", {})
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