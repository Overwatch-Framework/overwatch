include("shared.lua")

function SWEP:CheckYaw()
    local playerPitch = self:GetOwner():EyeAngles().p
    if ( playerPitch < -20 ) then
        if ( self.owHandsReset and self.owHandsReset > CurTime() ) then return end
        self.owHandsReset = CurTime() + 0.5

        ow.net:Start("hands.reset")
    end
end

function SWEP:Think()
    if ( self:GetOwner() ) then
        self:CheckYaw()
    end
end