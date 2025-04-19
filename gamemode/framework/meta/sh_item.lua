local ITEM = ow.meta.item or {}
ITEM.__index = ITEM
ITEM.Name = "Undefined"
ITEM.Description = ITEM.Description or "An item that is undefined."
ITEM.ID = ITEM.ID or 0

function ITEM:__tostring()
    return Format("Item: %s (%s)", self.Name, self.ID)
end


function ITEM:Spawn(position, angles)
    if (ow.item.instances[self.id]) then
        local ply

        local entity = ents.Create("ow_item")
        entity:Spawn()
        entity:SetAngles(angles or angle_zero)
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