--- ow.stamina
-- Cross-realm stamina library.
-- Server handles regeneration/consumption; client reads synced relay.

local MODULE = MODULE
MODULE.Name = "Stamina"
MODULE.Author = "Riggs"
MODULE.Description = "Stamina library."

ow.stamina = ow.stamina or {}

local deLocalization = {}
deLocalization["config.stamina"] = "Ausdauer"
deLocalization["config.stamina.drain"] = "Ausdauerabflussrate"
deLocalization["config.stamina.drain.help"] = "Die Rate, mit der die Ausdauer des Spielers abfließt."
deLocalization["config.stamina.help"] = "Aktivieren oder deaktivieren Sie die Ausdauer."
deLocalization["config.stamina.max"] = "Maximale Ausdauer"
deLocalization["config.stamina.max.help"] = "Die maximale Menge an Ausdauer, die der Spieler haben kann. Spieler müssen sich neu spawn, um dies anzuwenden."
deLocalization["config.stamina.regen"] = "Ausdauerregenerationsrate"
deLocalization["config.stamina.regen.help"] = "Die Rate, mit der die Ausdauer des Spielers regeneriert wird."
deLocalization["config.stamina.tick"] = "Ausdauer-Tickrate"
deLocalization["config.stamina.tick.help"] = "Die Rate, mit der die Ausdauer des Spielers aktualisiert wird."

local enLocalization = {}
enLocalization["config.stamina"] = "Stamina"
enLocalization["config.stamina.drain"] = "Stamina Drain Rate"
enLocalization["config.stamina.drain.help"] = "The rate at which the player's stamina drains."
enLocalization["config.stamina.help"] = "Enable or disable stamina."
enLocalization["config.stamina.max"] = "Max Stamina"
enLocalization["config.stamina.max.help"] = "The maximum amount of stamina the player can have, players need to respawn to apply this."
enLocalization["config.stamina.regen"] = "Stamina Regen Rate"
enLocalization["config.stamina.regen.help"] = "The rate at which the player's stamina regenerates."
enLocalization["config.stamina.tick"] = "Stamina Tick Rate"
enLocalization["config.stamina.tick.help"] = "The rate at which the player's stamina is updated."

ow.localization:RegisterLanguage("de", deLocalization)
ow.localization:RegisterLanguage("en", enLocalization)

ow.config:Register("stamina.drain", {
    Name = "config.stamina.drain",
    Description = "config.stamina.drain.help",
    Category = "config.stamina",
    Type = ow.type.number,
    Default = 5,
    Min = 0,
    Max = 100,
    Decimals = 1
})

ow.config:Register("stamina", {
    Name = "config.stamina",
    Description = "config.stamina.help",
    Category = "config.stamina",
    Type = ow.type.bool,
    Default = true
})

ow.config:Register("stamina.max", {
    Name = "config.stamina.max",
    Description = "config.stamina.max.help",
    Category = "config.stamina",
    Type = ow.type.number,
    Default = 100,
    Min = 0,
    Max = 1000,
    Decimals = 0
})

ow.config:Register("stamina.regen", {
    Name = "config.stamina.regen",
    Description = "config.stamina.regen.help",
    Category = "config.stamina",
    Type = ow.type.number,
    Default = 2,
    Min = 0,
    Max = 100,
    Decimals = 1
})

ow.config:Register("stamina.tick", {
    Name = "config.stamina.tick",
    Description = "config.stamina.tick.help",
    Category = "config.stamina",
    Type = ow.type.number,
    Default = 0.1,
    Min = 0,
    Max = 1,
    Decimals = 2
})

if ( SERVER ) then
    --- Initializes a stamina object for a player
    -- @param ply Player
    -- @param max number
    function ow.stamina:Initialize(ply, max)
        max = max or ow.config:Get("stamina.max", 100)

        ply:SetRelay("stamina", {
            max = max,
            current = max,
            regenRate = 5,
            regenDelay = 1.0,
            lastUsed = 0
        })
    end

    --- Consumes stamina from a player
    -- @param ply Player
    -- @param amount number
    -- @return boolean
    function ow.stamina:Consume(ply, amount)
        local st = ply:GetRelay("stamina")
        if ( !st ) then return false end

        st.current = math.Clamp(st.current - amount, 0, st.max)
        st.lastUsed = CurTime()
        ply:SetRelay("stamina", st)

        return true
    end

    --- Checks if player has enough stamina
    -- @param ply Player
    -- @param amount number
    -- @return boolean
    function ow.stamina:CanConsume(ply, amount)
        local st = ply:GetRelay("stamina")
        return st and st.current >= amount
    end

    --- Gets current stamina
    -- @param ply Player
    -- @return number
    function ow.stamina:Get(ply)
        local st = ply:GetRelay("stamina")
        return st and st.current or 0
    end

    --- Sets current stamina
    -- @param ply Player
    -- @param value number
    function ow.stamina:Set(ply, value)
        local st = ply:GetRelay("stamina")
        if ( !st ) then return end

        st.current = math.Clamp(value, 0, st.max)
        ply:SetRelay("stamina", st)
    end
end

if ( CLIENT ) then
    --- Gets the local player's stamina from relay
    -- @return number
    function ow.stamina:GetLocal()
        return ow.localClient:GetRelay("stamina").current
    end

    --- Gets the local player's stamina as a fraction [0–1]
    -- @return number
    function ow.stamina:GetFraction()
        local max = ow.localClient:GetRelay("stamina").max
        return self:GetLocal() / max
    end
end

ow.util:LoadFile("sv_hooks.lua")
ow.util:LoadFile("cl_hooks.lua")
ow.util:LoadFile("sh_hooks.lua")