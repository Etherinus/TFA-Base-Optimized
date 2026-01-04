function SWEP:FixProceduralReload()
	if self.DoProceduralReload then
		self.ProceduralReloadEnabled = true
	end
end

function SWEP:FixRPM()
	if not self.Primary.RPM then
		if self.Primary.Delay then
			self.Primary.RPM = 60 / self.Primary.Delay
		else
			self.Primary.RPM = 120
		end
	end
end

function SWEP:FixCone()
	if self.Primary.Cone then
		if (not self.Primary.Spread) or self.Primary.Spread <= 0 then
			self.Primary.Spread = self.Primary.Cone
		end
		self.Primary.Cone = nil
	end
end

function SWEP:FixIdles()
	if self.DisableIdleAnimations ~= nil and self.DisableIdleAnimations == true then
		self.Idle_Mode = TFA.Enum.IDLE_LUA
	end
end

function SWEP:FixIS()
	if self.SightsPos and (not self.IronSightsPos or (self.IronSightsPos.x ~= self.SightsPos.x and self.SightsPos.x ~= 0)) then
		self.IronSightsPos = self.SightsPos or Vector()
		self.IronSightsAng = self.SightsAng or Vector()
	end
end

local legacy_spread_cv = GetConVar("sv_tfa_spread_legacy")

function SWEP:AutoDetectSpread()
	if legacy_spread_cv and legacy_spread_cv:GetBool() then
		self:SetUpSpreadLegacy()
		return
	end

	local spread = self.Primary.Spread
	if not spread or spread <= 0 then
		spread = 0.01
		self.Primary.Spread = spread
	end

	local dmg = self.Primary.Damage or 30
	local rpm = self.Primary.RPM or 600

	if self.Primary.SpreadMultiplierMax == -1 or not self.Primary.SpreadMultiplierMax then
		self.Primary.SpreadMultiplierMax = math.Clamp(math.sqrt(math.sqrt(dmg / 35) * 10 / 5) * 5, 0.01 / spread, 0.1 / spread)
	end

	if self.Primary.SpreadIncrement == -1 or not self.Primary.SpreadIncrement then
		self.Primary.SpreadIncrement = self.Primary.SpreadMultiplierMax * 60 / rpm * 0.85 * 1.5
	end

	if self.Primary.SpreadRecovery == -1 or not self.Primary.SpreadRecovery then
		self.Primary.SpreadRecovery = math.max(self.Primary.SpreadMultiplierMax * math.pow(rpm / 600, 1 / 3) * 0.75, self.Primary.SpreadMultiplierMax / 1.5)
	end
end

function SWEP:AutoDetectMuzzle()
	if not self.MuzzleFlashEffect then
		local a = string.lower(self.Primary.Ammo or "")
		local cat = string.lower(self.Category and self.Category or "")

		if self.Silenced or self:GetSilenced() then
			self.MuzzleFlashEffect = "tfa_muzzleflash_silenced"
		elseif string.find(a, "357") or self.Revolver or string.find(cat, "revolver") then
			self.MuzzleFlashEffect = "tfa_muzzleflash_revolver"
		elseif self.Shotgun or a == "buckshot" or a == "slam" or a == "airboatgun" or string.find(cat, "shotgun") then
			self.MuzzleFlashEffect = "tfa_muzzleflash_shotgun"
		elseif string.find(a, "smg") or string.find(cat, "smg") or string.find(cat, "submachine") or string.find(cat, "sub-machine") then
			self.MuzzleFlashEffect = "tfa_muzzleflash_smg"
		elseif string.find(a, "sniper") or string.find(cat, "sniper") then
			self.MuzzleFlashEffect = "tfa_muzzleflash_sniper"
		elseif string.find(a, "pistol") or string.find(cat, "pistol") then
			self.MuzzleFlashEffect = "tfa_muzzleflash_pistol"
		elseif string.find(a, "ar2") or string.find(a, "rifle") or (string.find(cat, "revolver") and not string.find(cat, "rifle")) then
			self.MuzzleFlashEffect = "tfa_muzzleflash_rifle"
		else
			self.MuzzleFlashEffect = "tfa_muzzleflash_generic"
		end
	end
end

function SWEP:AutoDetectDamage()
	if self.Primary.Damage and self.Primary.Damage ~= -1 then return end

	if self.Primary.Round then
		local rnd = string.lower(self.Primary.Round)

		if string.find(rnd, ".50bmg") then
			self.Primary.Damage = 185
		elseif string.find(rnd, "5.45x39") then
			self.Primary.Damage = 22
		elseif string.find(rnd, "5.56x45") then
			self.Primary.Damage = 30
		elseif string.find(rnd, "338_lapua") then
			self.Primary.Damage = 120
		elseif string.find(rnd, "338") then
			self.Primary.Damage = 100
		elseif string.find(rnd, "7.62x51") then
			self.Primary.Damage = 100
		elseif string.find(rnd, "9x39") then
			self.Primary.Damage = 32
		elseif string.find(rnd, "9mm") then
			self.Primary.Damage = 22
		elseif string.find(rnd, "9x19") then
			self.Primary.Damage = 22
		elseif string.find(rnd, "9x18") then
			self.Primary.Damage = 20
		end

		if self.Primary.Damage and string.find(rnd, "ap") then
			self.Primary.Damage = self.Primary.Damage * 1.2
		end
	end

	if ((not self.Primary.Damage) or (self.Primary.Damage <= 0.01)) and self.Velocity then
		self.Primary.Damage = self.Velocity / 5
	end

	if (not self.Primary.Damage) or (self.Primary.Damage <= 0.01) then
		local ku = self.Primary.KickUp or 1
		local kd = self.Primary.KickDown or ku
		local kh = self.Primary.KickHorizontal or ku
		self.Primary.Damage = (ku + kd + kh) * 10
	end
end

function SWEP:AutoDetectDamageType()
	if self.Primary.DamageType == -1 or not self.Primary.DamageType then
		if self.DamageType and not self.Primary.DamageType then
			self.Primary.DamageType = self.DamageType
		else
			self.Primary.DamageType = DMG_BULLET
		end

		if (self.Primary.NumShots * self.Primary.Damage) >= 26 then
			self.Primary.DamageType = bit.bor(self.Primary.DamageType, DMG_AIRBOAT)
		elseif self.Primary.Damage >= 150 then
			self.Primary.DamageType = bit.bor(self.Primary.DamageType, DMG_AIRBOAT)
		end
	end
end

function SWEP:AutoDetectForce()
	if self.Primary.Force == -1 or not self.Primary.Force then
		local dmg = self.Primary.Damage or 30
		local ns = self.Primary.NumShots or 1
		if ns <= 0 then ns = 1 end
		self.Primary.Force = self.Force or (math.sqrt(dmg / 16) * 3 / math.sqrt(ns))
	end
end

function SWEP:AutoDetectKnockback()
	if self.Primary.Knockback == -1 or not self.Primary.Knockback then
		local force = self.Primary.Force or 1
		local ns = self.Primary.NumShots or 1
		if ns <= 0 then ns = 1 end
		self.Primary.Knockback = self.Knockback or math.max(math.pow(force - 3.25, 2), 0) * math.pow(ns, 1 / 3)
	end
end

local selicon_final = {}

function SWEP:IconFix()
	if not surface then return end
	self.Gun = self.ClassName or self.Folder

	if selicon_final[self.Gun] then
		self.WepSelectIcon = selicon_final[self.Gun]
		return
	end

	local proceed = true

	if self.WepSelectIcon and type(self.WepSelectIcon) == "string" then
		self.WepSelectIcon = surface.GetTextureID(self.WepSelectIcon)
		proceed = false
	end

	if proceed and self.ClassName and file.Exists("materials/vgui/hud/" .. self.ClassName .. ".vmt", "GAME") then
		self.WepSelectIcon = surface.GetTextureID("vgui/hud/" .. self.ClassName)
	end

	selicon_final[self.Gun] = self.WepSelectIcon
end

function SWEP:CorrectScopeFOV(fov)
	fov = fov or self.DefaultFOV

	if not self.Secondary.IronFOV or self.Secondary.IronFOV <= 0 then
		if self.Scoped then
			self.Secondary.IronFOV = fov / (self.Secondary.ScopeZoom and self.Secondary.ScopeZoom or 2)
		else
			self.Secondary.IronFOV = 32
		end
	end
end

SWEP.FireModeCache = {}

function SWEP:CreateFireModes(isfirstdraw)
	if not self.FireModes then
		self.FireModes = {}

		local burstcnt = self:FindEvenBurstNumber()

		if self.SelectiveFire then
			if self.OnlyBurstFire then
				if burstcnt then
					self.FireModes[1] = burstcnt .. "Burst"
					self.FireModes[2] = "Single"
				else
					self.FireModes[1] = "Single"
				end
			else
				self.FireModes[1] = "Automatic"

				if self.DisableBurstFire then
					self.FireModes[2] = "Single"
				else
					if burstcnt then
						self.FireModes[2] = burstcnt .. "Burst"
						self.FireModes[3] = "Single"
					else
						self.FireModes[2] = "Single"
					end
				end
			end
		else
			if self.Primary.Automatic then
				self.FireModes[1] = "Automatic"

				if self.OnlyBurstFire and burstcnt then
					self.FireModes[1] = burstcnt .. "Burst"
				end
			else
				self.FireModes[1] = "Single"
			end
		end
	end

	if self.FireModes[#self.FireModes] ~= "Safe" then
		self.FireModes[#self.FireModes + 1] = "Safe"
	end

	self.FireModeCache = self.FireModeCache or {}
	for k in pairs(self.FireModeCache) do
		self.FireModeCache[k] = nil
	end

	for k, v in ipairs(self.FireModes) do
		self.FireModeCache[v] = k
	end

	if isfirstdraw then
		if type(self.DefaultFireMode) == "number" then
			self:SetFireMode(self.DefaultFireMode or (self.Primary.Automatic and 1 or #self.FireModes - 1))
		else
			self:SetFireMode(self.FireModeCache[self.DefaultFireMode] or (self.Primary.Automatic and 1 or #self.FireModes - 1))
		end
	end
end

SWEP.actlist = {
	ACT_VM_DRAW,
	ACT_VM_DRAW_EMPTY,
	ACT_VM_DRAW_SILENCED,
	ACT_VM_DRAW_DEPLOYED,
	ACT_VM_HOLSTER,
	ACT_VM_HOLSTER_EMPTY,
	ACT_VM_IDLE,
	ACT_VM_IDLE_EMPTY,
	ACT_VM_IDLE_SILENCED,
	ACT_VM_PRIMARYATTACK,
	ACT_VM_PRIMARYATTACK_1,
	ACT_VM_PRIMARYATTACK_EMPTY,
	ACT_VM_PRIMARYATTACK_SILENCED,
	ACT_VM_SECONDARYATTACK,
	ACT_VM_RELOAD,
	ACT_VM_RELOAD_EMPTY,
	ACT_VM_RELOAD_SILENCED,
	ACT_VM_ATTACH_SILENCER,
	ACT_VM_RELEASE,
	ACT_VM_DETACH_SILENCER,
	ACT_VM_FIDGET,
	ACT_VM_FIDGET_EMPTY,
	ACT_SHOTGUN_RELOAD_START
}

SWEP.SequenceEnabled = {}
SWEP.SequenceLength = {}
SWEP.SequenceLengthOverride = {}
SWEP.ActCache = {}

local vm, seq

function SWEP:CacheAnimations()
	table.Empty(self.ActCache)

	if self.CanBeSilenced and self.SequenceEnabled[ACT_VM_IDLE_SILENCED] == nil then
		self.SequenceEnabled[ACT_VM_IDLE_SILENCED] = true
	end

	if not self:VMIV() then return end
	vm = self.OwnerViewModel

	if not IsValid(vm) then
		return false
	end

	for _, v in ipairs(self.actlist) do
		seq = vm:SelectWeightedSequence(v)

		if seq ~= -1 and vm:GetSequenceActivity(seq) == v and not self.ActCache[seq] then
			self.SequenceEnabled[v] = true
			self.SequenceLength[v] = vm:SequenceDuration(seq)
			self.ActCache[seq] = v
		else
			self.SequenceEnabled[v] = false
			self.SequenceLength[v] = 0.0
		end
	end

	if self.ProceduralHolsterEnabled == nil then
		if self.SequenceEnabled[ACT_VM_HOLSTER] then
			self.ProceduralHolsterEnabled = false
		else
			self.ProceduralHolsterEnabled = true
		end
	end

	if string.find(self:GetClass(), "nmrih") then
		self.ShotgunEmptyAnim = false
	end

	self.HasDetectedValidAnimations = true
	return true
end

function SWEP:GetType()
	if self.Type then return self.Type end

	local at = string.lower(self.Primary.Ammo or "")
	local ht = string.lower((self.DefaultHoldType or self.HoldType) or "")
	local rpm = self.Primary.RPM or 600

	if self.Shotgun or at == "buckshot" then
		self.Type = "Shotgun"
		return self.Type
	end

	if self.Pistol or (at == "pistol" and ht == "pistol") then
		self.Type = "Pistol"
		return self.Type
	end

	if self.SMG or (at == "smg1" and (ht == "smg" or ht == "pistol")) then
		self.Type = "Sub-Machine Gun"
		return self.Type
	end

	if self.Revolver or (at == "357" and ht == "revolver") then
		self.Type = "Revolver"
		return self.Type
	end

	if (self.Scoped or self.Scoped_3D) and rpm < 600 then
		if rpm > 180 then
			self.Type = "Designated Marksman Rifle"
			return self.Type
		end

		self.Type = "Sniper Rifle"
		return self.Type
	end

	if ht == "pistol" then
		self.Type = "Pistol"
		return self.Type
	end

	if ht == "revolver" then
		self.Type = "Revolver"
		return self.Type
	end

	if ht == "duel" then
		if at == "pistol" then
			self.Type = "Dual Pistols"
			return self.Type
		elseif at == "357" then
			self.Type = "Dual Revolvers"
			return self.Type
		elseif at == "smg1" then
			self.Type = "Dual Sub-Machine Guns"
			return self.Type
		end

		self.Type = "Dual Guns"
		return self.Type
	end

	if at == "ar2" then
		if ht == "ar2" or ht == "shotgun" then
			self.Type = "Rifle"
			return self.Type
		end

		self.Type = "Carbine"
		return self.Type
	end

	if ht == "smg" or at == "smg1" then
		self.Type = "Sub-Machine Gun"
		return self.Type
	end

	self.Type = "Weapon"
	return self.Type
end

function SWEP:SetUpSpreadLegacy()
	local ht = self.DefaultHoldType and self.DefaultHoldType or self.HoldType
	ht = ht or "ar2"

	if not self.Primary.SpreadMultiplierMax or self.Primary.SpreadMultiplierMax <= 0 or self.AutoDetectSpreadMultiplierMax then
		self.Primary.SpreadMultiplierMax = 2.5 * math.max(self.Primary.RPM or 400, 400) / 600 * math.sqrt((self.Primary.Damage or 30) / 30 * (self.Primary.NumShots or 1))

		if ht == "smg" then
			self.Primary.SpreadMultiplierMax = self.Primary.SpreadMultiplierMax * 0.8
		end

		if ht == "revolver" then
			self.Primary.SpreadMultiplierMax = self.Primary.SpreadMultiplierMax * 2
		end

		if self.Scoped then
			self.Primary.SpreadMultiplierMax = self.Primary.SpreadMultiplierMax * 1.5
		end

		self.AutoDetectSpreadMultiplierMax = true
	end

	if not self.Primary.SpreadIncrement or self.Primary.SpreadIncrement <= 0 or self.AutoDetectSpreadIncrement then
		self.AutoDetectSpreadIncrement = true

		self.Primary.SpreadIncrement = 1 * math.Clamp(math.sqrt(self.Primary.RPM or 600) / 24.5, 0.7, 3) * math.sqrt((self.Primary.Damage or 30) / 30 * (self.Primary.NumShots or 1))

		if ht == "revolver" then
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement * 2
		end

		if ht == "pistol" then
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement * 1.35
		end

		if ht == "ar2" or ht == "rpg" then
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement * 0.65
		end

		if ht == "smg" then
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement * 1.75
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement * (math.Clamp(((self.Primary.RPM or 600) - 650) / 150, 0, 1) + 1)
		end

		if ht == "pistol" and self.Primary.Automatic == true then
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement * 1.5
		end

		if self.Scoped then
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement * 1.25
		end

		local recoil = self.Primary.Recoil or 1
		local ku = self.Primary.KickUp or 1
		local kd = self.Primary.KickDown or 1
		local kh = self.Primary.KickHorizontal or 1
		self.Primary.SpreadIncrement = self.Primary.SpreadIncrement * math.sqrt(recoil * (ku + kd + kh)) * 0.8
	end

	if not self.Primary.SpreadRecovery or self.Primary.SpreadRecovery <= 0 or self.AutoDetectSpreadRecovery then
		self.AutoDetectSpreadRecovery = true
		self.Primary.SpreadRecovery = math.sqrt(math.max(self.Primary.RPM or 600, 300)) / 29 * 4

		if ht == "smg" then
			self.Primary.SpreadRecovery = self.Primary.SpreadRecovery * (1 - math.Clamp(((self.Primary.RPM or 600) - 600) / 200, 0, 1) * 0.33)
		end
	end
end
