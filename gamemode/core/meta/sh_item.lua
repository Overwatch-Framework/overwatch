local ITEM = ow.meta.item or {}
ITEM.__index = ITEM
ITEM.name = "Undefined"
ITEM.description = ITEM.description || "An item that is undefined."
ITEM.id = ITEM.id || 0
ITEM.uniqueID = "undefined"

function ITEM:Spawn(position, angles)
    if (ow.item.instances[self.id]) then
        local ply

        local entity = ents.Create("ow_item")
        entity:Spawn()
        entity:SetAngles(angles || angle_zero)
        entity:SetItemID(self.id)

        -- If the first argument is a player, then we will find a position to drop
        -- the item based off their aim.
        if (type(position) == "Player") then
            ply = position
            position = position:GetItemDropPos(entity)
        end

        entity:SetPos(position)

        if ( IsValid(ply) and ply:GetCharacter() ) then
            entity.ixCharID = ply:GetCharacter():GetID()
        end

        hook.Run("OnItemSpawned", entity)
        return entity
    end
end

ow.meta.item = ITEM