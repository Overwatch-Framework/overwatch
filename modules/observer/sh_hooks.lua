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

        if ( !hook.Run("ShouldDrawObserverHUD", ply) ) then return end

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

            local pos = v:GetPos():ToScreen()
            draw.SimpleText(v:Name(), "DermaDefault", screenPos.x, screenPos.y, color_white)

            local health = v:Health()
            local maxHealth = v:GetMaxHealth()
            local healthText = health .. "/" .. maxHealth
            draw.SimpleText(healthText, "DermaDefault", screenPos.x, screenPos.y + 10, color_white)

            local faction = ow.faction:Get(v:Team())
            if ( faction ) then
                draw.SimpleText(faction.Name, "DermaDefault", screenPos.x, screenPos.y + 20, faction.Color)
            end
        end

        draw.SimpleText("Players: " .. playerCount, "DermaDefault", 10, 10, color_white)
        draw.SimpleText("Admins: " .. admins, "DermaDefault", 10, 25, color_white)

        hook.Run("PostDrawObserverHUD", ply)
    end
end