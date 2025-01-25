SWEP.PrintName		= "Hands"
SWEP.Author			= "Overwatch"
SWEP.Contact		= ""
SWEP.Purpose		= "Grab and throw things"
SWEP.Instructions	= ""

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModel = Model("models/weapons/c_arms.mdl")
SWEP.WorldModel = ""

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

SWEP.UseHands		= true
SWEP.Spawnable		= true

SWEP.ViewModelFOV = 45
SWEP.ViewModelFlip = false
SWEP.AnimPrefix     = "rpg"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Primary.Damage = 5
SWEP.Primary.Delay = 0.75

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""
SWEP.Secondary.Delay = 0.5

SWEP.HoldType = "fist"

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
    if (!IsFirstTimePredicted()) then return end
end

function SWEP:SecondaryAttack()
    if (!IsFirstTimePredicted()) then return end
end