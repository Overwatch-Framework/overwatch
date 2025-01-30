local MODULE = MODULE

function MODULE:CanPlayerObserve(ply, state)
    if ( !CAMI.PlayerHasAccess(ply, "Overwatch - Observer") ) then return false end

    return true
end

function MODULE:ShouldDrawObserverHUD(ply)
    return true
end

if ( CLIENT ) then
    function MODULE:DrawPhysgunBeam(ply, physgun, enabled, target, physBone, hitPos)
        if ( CAMI.PlayerHasAccess(ply, "Overwatch - Observer") and ply:GetNoDraw() and ply:GetMoveType() == MOVETYPE_NOCLIP ) then
            return false
        end
    end

    function MODULE:HUDPaint()
        local ply = LocalPlayer()
        if ( !IsValid(ply) or !CAMI.PlayerHasAccess(ply, "Overwatch - Observer") 
        or !ply:Alive() or ply:GetMoveType() != MOVETYPE_NOCLIP or !ply:GetNoDraw() ) then return end

        if ( !hook.Run("ShouldDrawObserverHUD", ply) ) then return end

        local playerCount = 0
        local admins = 0
        for k, v in player.Iterator() do
            if ( !IsValid(v) ) then continue end
            playerCount = playerCount + 1

            if ( v:IsAdmin() ) then
                admins = admins + 1
            end

            if ( v == ply ) then continue end

            local pos = v:GetPos():ToScreen()
            draw.SimpleText(v:Name(), "DermaDefault", pos.x, pos.y, color_white)

            local health = v:Health()
            local maxHealth = v:GetMaxHealth()
            local healthText = health .. "/" .. maxHealth
            draw.SimpleText(healthText, "DermaDefault", pos.x, pos.y + 10, color_white)
            
            local faction = ow.faction:Get(v:Team())
            if ( faction ) then
                draw.SimpleText(faction.Name, "DermaDefault", pos.x, pos.y + 20, color_white)
            end
        end

        draw.SimpleText("Players: " .. playerCount, "DermaDefault", 10, 10, color_white)
        draw.SimpleText("Admins: " .. admins, "DermaDefault", 10, 25, color_white)

        hook.Run("PostDrawObserverHUD", ply)
    end
end