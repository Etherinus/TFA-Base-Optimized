function SWEP:NZMaxAmmo()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	local at = self:GetPrimaryAmmoType()

	local prim = self.Primary or {}
	local clipSize = tonumber(prim.ClipSize) or -1
	local dmg = tonumber(prim.Damage) or 30

	local count
	if clipSize <= 0 then
		local denom = dmg / 30
		if denom <= 0 then denom = 1 end
		count = math.Clamp(300 / denom, 10, 300)
	else
		count = math.Clamp(math.abs(clipSize) * 10, 10, 300)
	end

	owner:SetAmmo(count, at)
end
