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
        if ( !IsValid(ply) or !ply:InObserver() or !ply:Alive() or !ply:GetNoDraw() ) then return end

        if ( hook.Run("ShouldDrawObserverHUD", ply) == false ) then return end

        local playerCount = 0
        local admins = 0
        for k, v in player.Iterator() do
            if ( !IsValid(v) ) then continue end
            playerCount = playerCount + 1

            if ( v:IsAdmin() ) then
                admins = admins + 1
            end

            if ( v == ply or !v:Alive() ) then continue end

            local headBone = v:LookupBone("ValveBiped.Bip01_Head1")
            if ( !headBone ) then continue end

            local headPos = v:GetBonePosition(headBone)
            if ( !headPos ) then continue end

            local screenPos = headPos:ToScreen()
            if ( !screenPos.visible ) then continue end

            local y = screenPos.y
            local _, h = draw.SimpleText(v:Name(), "DermaDefault", screenPos.x, y, color_white)
            y = y + h + 2

            local health = v:Health()
            local maxHealth = v:GetMaxHealth()
            local healthText = health .. "/" .. maxHealth
            if ( health <= 0 ) then
                healthText = "DEAD"
            end

            _, h = draw.SimpleText(healthText, "DermaDefault", screenPos.x, y, color_white)
            y = y + h + 2

            local faction = ow.faction:Get(v:Team())
            if ( faction ) then
                _, h = draw.SimpleText(faction.Name, "DermaDefault", screenPos.x, y, faction.Color)
                y = y + h + 2
            end
        end

        local y = 10

        local _, h = draw.SimpleText("Players: " .. playerCount, "DermaDefault", 10, y, color_white)
        y = y + h + 2

        _, h = draw.SimpleText("Admins: " .. admins, "DermaDefault", 10, y, color_white)
        y = y + h + 2

        hook.Run("PostDrawObserverHUD", ply)
    end
end