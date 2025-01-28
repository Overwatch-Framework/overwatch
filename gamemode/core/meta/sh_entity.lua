--[[--
Physical object in the game world.

Entities are physical representations of objects in the game world. Helix extends the functionality of entities to interface
between Helix's own classes, and to reduce boilerplate code.

See the [Garry's Mod Wiki](https://wiki.garrysmod.com/page/Category:Entity) for all other methods that the `Player` class has.
]]
-- @classmod Entity

local ENTITY = FindMetaTable("Entity")

local CHAIR_CACHE = {}
for _, v in ipairs(list.Get("Vehicles")) do
    if (v.Category == "Chairs") then
        CHAIR_CACHE[v.Model] = true
    end
end

--- Returns `true` if this entity is a chair.
-- @realm shared
-- @treturn bool Whether or not this entity is a chair
function ENTITY:IsChair()
    return CHAIR_CACHE[self:GetModel()]
end

--- Returns `true` if this entity is a door. Internally, this checks to see if the entity's class has `door` in its name.
-- @realm shared
-- @treturn bool Whether or not the entity is a door
function ENTITY:IsDoor()
    local class = self:GetClass()

    return (class and class:find("door") != nil)
end

-- Inherits the bodygroups of the given entity.
-- @realm shared
function ENTITY:InheritBodygroups(entity)
    for _, v in ipairs(entity:GetBodyGroups() or {}) do
        self:SetBodygroup(v.id, entity:GetBodygroup(v.id))
    end
end

-- Inherits the materials of the given entity.
-- @realm shared
function ENTITY:InheritMaterials(entity)
    self:SetMaterial(entity:GetMaterial())

    for k, v in ipairs(entity:GetMaterials()) do
        self:SetSubMaterial(k - 1, entity:GetSubMaterial(k - 1))
    end
end

--- Resets all bodygroups this player's model has to their defaults (`0`).
-- @realm shared
function ENTITY:ResetBodygroups()
    for i = 0, (self:GetNumBodyGroups() - 1) do
        self:SetBodygroup(i, 0)
    end
end

--- Resets all bone manipulations this player's model has to their defaults.
-- @realm shared
function ENTITY:ResetBoneMatrix()
    for i = 0, self:GetBoneCount() - 1 do
        self:ManipulateBoneScale(i, Vector(1, 1, 1))
        self:ManipulateBoneAngles(i, angle_zero)
        self:ManipulateBonePosition(i, vector_origin)
    end
end

--- Sets the bodygroup of this player's model by its name.
-- @realm shared
-- @string name Name of the bodygroup
-- @number value Value to set the bodygroup to
-- @usage client:SetBodygroupName("head", 1)
function ENTITY:SetBodygroupName(name, value)
    local index = self:FindBodygroupByName(name)
    if ( index > -1 ) then
        self:SetBodygroup(index, value)
    end
end

--- Returns the bodygroup value of this player's model by its name.
-- @realm shared
-- @string name Name of the bodygroup
-- @treturn number Value of the bodygroup
-- @usage local headGroup = client:GetBodygroupByName("head")
function ENTITY:GetBodygroupByName(name)
    local index = self:FindBodygroupByName(name)
    if ( index > -1 ) then
        return self:GetBodygroup(index)
    end

    return -1
end

--- Returns `true` if the given entity is a button or door and is locked.
-- @realm shared
-- @treturn bool Whether or not this entity is locked; `false` if this entity cannot be locked at all
-- (e.g not a button or door)
function ENTITY:IsLocked()
    if (SERVER) then
        if (self:IsVehicle()) then
            return self:GetInternalVariable("VehicleLocked")
        else
            return self:GetInternalVariable("m_bLocked")
        end
    else
        return self:GetNetVar("locked", false)
    end

    return false
end