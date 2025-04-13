function GM:CanDrive(ply, entity)
    return false
end

function GM:CanPlayerBecomeFaction(ply, factionID)
    return true
end

function GM:CanPlayerHandsPickup(ply, ent)
    return true
end

function GM:CanPlayerHandsPush(ply, ent)
    return true
end

function GM:GetPlayerHandsPushForce(ply)
    return 128
end

function GM:GetPlayerHandsReachDistance(ply)
    return 64
end

function GM:GetPlayerHandsMaxMass(ply)
    return 64
end

function GM:GetFrameworkColor()
    return ow.config:Get("frameworkColor", Color(0, 100, 150))
end

function GM:GetSchemaColor()
    return ow.config:Get("schemaColor", Color(0, 150, 100))
end

function GM:GetMainMenuMusic()
    return ow.config:Get("mainMenuMusic", "music/hl2_song20_submix0.mp3")
end

function GM:PlayerGetToolgun(ply)
    return CAMI.PlayerHasAccess(ply, "Overwatch - Toolgun", nil)
end

function GM:PlayerGetPhysgun(ply)
    return CAMI.PlayerHasAccess(ply, "Overwatch - Physgun", nil)
end

function GM:PlayerCanCreateCharacter(ply, character)
    return true
end

function GM:PlayerCanDeleteCharacter(ply, character)
    return true
end

function GM:PlayerCanLoadCharacter(ply, character, currentCharacter)
    return true
end

function GM:CanPlayerTakeItem(ply, item)
    return true
end

function GM:ItemCanBeDestroyed(item, damageInfo)
    return true
end

local folder
function GM:PreModuleLoad(moduleName, moduleTable)
    print("PreModuleLoad", moduleName, moduleTable)
    if ( folder == nil ) then
        folder = SCHEMA and SCHEMA.Folder or "core"
    end

    local disabledPlugins = file.Read("overwatch/" .. folder .. "/disabled_modules.txt", "DATA")
    disabledPlugins = util.JSONToTable(disabledPlugins or "[]")
    if ( disabledPlugins[moduleName] ) then
        ow.util:PrintWarning("Module \"" .. moduleName .. "\" is disabled.")
        return false
    end
end