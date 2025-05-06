--- Character library.
-- @module ow.character

ow.character = ow.character or {} -- Character library.
ow.character.meta = ow.character.meta or {} -- All currently registered character meta functions.
ow.character.variables = ow.character.variables or {} -- All currently registered variables.
ow.character.fields = ow.character.fields or {} -- All currently registered fields.
ow.character.stored = ow.character.stored or {} -- All currently stored characters which are in use.

--- Registers a variable for the character.
-- @realm shared
function ow.character:RegisterVariable(key, data)
    data.Index = table.Count(self.variables) + 1

    if ( data.Alias != nil ) then
        if ( isstring(data.Alias) ) then
            data.Alias = { data.Alias }
        end

        for k, v in ipairs(data.Alias) do
            self.meta["Get" .. v] = function(character)
                return self:GetVariable(character:GetID(), key)
            end

            if ( SERVER ) then
                self.meta["Set" .. v] = function(character, value)
                    self:SetVariable(character:GetID(), key, value)
                end

                local field = data.Field
                if ( field ) then
                    ow.sqlite:RegisterVar("ow_characters", key, data.Default or nil)
                    self.fields[key] = field
                end
            end
        end
    else
        local upperKey = string.upper(key:sub(1, 1)) .. key:sub(2)

        self.meta["Get" .. upperKey] = function(character)
            return self:GetVariable(character:GetID(), key)
        end

        if ( SERVER ) then
            self.meta["Set" .. upperKey] = function(character, value)
                self:SetVariable(character:GetID(), key, value)
            end

            local field = data.Field
            if ( field ) then
                ow.sqlite:RegisterVar("ow_characters", key, data.Default or nil)
                self.fields[key] = field
            end
        end
    end

    self.variables[key] = data
end

function ow.character:SetVariable(id, key, value)
    if ( !self.variables[key] ) then print("Attempted to set a variable that does not exist!") return end

    local character = self.stored[id]
    if ( !character ) then return end

    local data = self.variables[key]
    if ( data.OnSet ) then
        data:OnSet(character, value)
    end

    character[key] = value

    if ( SERVER ) then
        ow.sqlite:Update("ow_characters", { [key] = value }, { id = id })

        if ( data.Field ) then
            local field = data.Field
            if ( field ) then
                ow.sqlite:Update("ow_characters", { [field] = value }, { id = id })
            end
        end

        if ( !data.NoNetworking ) then
            ow.net:Start(nil, "character.variable.set", id, key, value)
        end
    end
end

function ow.character:GetVariable(id, key)
    local character = self.stored[id]
    if ( !character ) then return end

    local variable = self.variables[key]
    if ( !variable ) then return end

    if ( variable.OnGet ) then
        return variable:OnGet(character, character[key])
    end

    return character[key]
end

function ow.character:CreateObject(characterID, data, client)
    if ( !characterID or !data ) then return false, "Invalid ID or data" end
    if ( self.stored[characterID] ) then return self.stored[characterID], "Character already exists" end

    characterID = tonumber(characterID)

    local character = setmetatable({}, self.meta)
    character.ID = characterID
    character.Player = client or NULL
    character.Schema = SCHEMA.Folder
    character.SteamID = client and client:SteamID64() or nil

    if ( istable(data.inventories) ) then
        character.Inventories = data.inventories
    elseif ( isstring(data.inventories) and data.inventories != "" ) then
        character.Inventories = util.JSONToTable(data.inventories) or {}
    else
        character.Inventories = {}
    end

    for k, v in pairs(self.variables) do
        if ( data[k] ) then
            character[k] = data[k]
        elseif ( v.Default ) then
            character[k] = v.Default
        end
    end

    self.stored[characterID] = character

    return character
end

function ow.character:GetPlayerByCharacter(id)
    for _, client in player.Iterator() do
        if ( client:GetCharacterID() == id ) then
            return client
        end
    end

    return false, "Player not found"
end

function ow.character:Get(id)
    return self.stored[id]
end

function ow.character:GetAll()
    return self.stored
end