SWEP.AnimCycle = SWEP.ViewModelFlip and 0 or 1

function SWEP:FixAkimbo()
	if self.Akimbo and self.Secondary.ClipSize > 0 then
		self.Primary.ClipSize = self.Primary.ClipSize + self.Secondary.ClipSize
		self.Secondary.ClipSize = -1
		self.Primary.RPM = self.Primary.RPM * 2
		self.Akimbo_Inverted = self.ViewModelFlip
		self.AnimCycle = self.ViewModelFlip and 0 or 01
		timer.Simple(FrameTime(),function()
				timer.Simple(0.01,function()
				if IsValid(self) and self:OwnerIsValid() then
					self:SetClip1(self.Primary.ClipSize)
				end
			end)
		end)
	end
end

function SWEP:ToggleAkimbo(arg1)
	if self.Akimbo and ( IsFirstTimePredicted() or ( arg1 and arg1 == "asdf" ) ) then
		if type(self.AnimCycle) ~= "number" then self.AnimCycle = 0 end
		self.AnimCycle = 1 - self.AnimCycle
	end
	if SERVER and game.SinglePlayer() then
		self:SetNW2Int("AnimCycle",self.AnimCycle)
	end
end