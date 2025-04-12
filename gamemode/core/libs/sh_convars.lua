--- Convars library for Overwatch gamemode
-- This library is responsible for creating and managing console variables (convars) used in the Overwatch gamemode.

-- @module ow.convars

ow.convars = ow.convars or {}
ow.convars.stored = ow.convars.stored or {}

function ow.convars:Get(name)
    return self.stored[name]
end

function ow.convars:Create(name, default, flags, help, min, max)
    if ( self.stored[name] ) then return false end

    local convar = CreateConVar(name, default, flags, help, min, max)
    self.stored[name] = convar
end

function ow.convars:CreateClient(name, default, shouldsave, userinfo, helptext, min, max)
    if ( self.stored[name] ) then return false end

    local convar = CreateClientConVar(name, default, shouldsave, userinfo, helptext, min, max)
    self.stored[name] = convar
end

ow.convars:Create("ow_debug", "0", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Enable debug mode.", 0, 1)