function SWEP:NZMaxAmmo()
    local at = self:GetPrimaryAmmoType()
    if IsValid(self.Owner) then
    	if self.Primary.ClipSize <= 0 then
    		local count = math.Clamp(10, 300 / ( self.Primary.Damage / 30 ), 10, 300)
    		self.Owner:SetAmmo( count, at)
    	else
    		local count = math.Clamp( math.abs(self.Primary.ClipSize) * 10, 10, 300 )
    		self.Owner:SetAmmo( count, at)
    	end
    end
end