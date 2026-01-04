SWEP.AnimCycle = SWEP.ViewModelFlip and 0 or 1

function SWEP:FixAkimbo()
	if not self.Akimbo then return end
	if self._tfa_akimbo_fixed then return end

	local sec = self.Secondary
	local pri = self.Primary
	if not sec or not pri then return end

	local secClip = tonumber(sec.ClipSize) or 0
	if secClip <= 0 then return end

	local priClip = tonumber(pri.ClipSize) or 0
	local priRPM = tonumber(pri.RPM) or 0

	self._tfa_akimbo_fixed = true

	pri.ClipSize = priClip + secClip
	sec.ClipSize = -1

	if priRPM > 0 then
		pri.RPM = priRPM * 2
	end

	self.Akimbo_Inverted = self.ViewModelFlip
	self.AnimCycle = self.ViewModelFlip and 0 or 1

	if SERVER then
		timer.Simple(0, function()
			if not IsValid(self) then return end
			if not self:OwnerIsValid() then return end
			self:SetClip1(self.Primary.ClipSize)
		end)
	end
end

function SWEP:ToggleAkimbo(arg1)
	if self.Akimbo and (IsFirstTimePredicted() or (arg1 and arg1 == "asdf")) then
		if type(self.AnimCycle) ~= "number" then
			self.AnimCycle = 0
		end

		self.AnimCycle = 1 - self.AnimCycle
	end

	if SERVER and game.SinglePlayer() then
		self:SetNW2Int("AnimCycle", self.AnimCycle)
	end
end
