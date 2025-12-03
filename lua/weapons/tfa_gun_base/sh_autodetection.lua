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
		if ( not self.Primary.Spread ) or self.Primary.Spread <= 0  then
			self.Primary.Spread = self.Primary.Cone
		end
		self.Primary.Cone = nil
	end
end

function SWEP:FixIdles() --legacy compatibility
	if self.DisableIdleAnimations ~= nil and self.DisableIdleAnimations == true then
		self.Idle_Mode = TFA.Enum.IDLE_LUA
	end
end

function SWEP:FixIS()
	if self.SightsPos and ( not self.IronSightsPos or ( self.IronSightsPos.x ~= self.SightsPos.x and self.SightsPos.x ~= 0 ) ) then
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

	if self.Primary.SpreadMultiplierMax == -1 or not self.Primary.SpreadMultiplierMax then
		self.Primary.SpreadMultiplierMax = math.Clamp(math.sqrt(math.sqrt(self.Primary.Damage / 35) * 10 / 5) * 5, 0.01 / self.Primary.Spread, 0.1 / self.Primary.Spread)
	end
	if self.Primary.SpreadIncrement == -1 or not self.Primary.SpreadIncrement then
		self.Primary.SpreadIncrement = self.Primary.SpreadMultiplierMax * 60 / self.Primary.RPM * 0.85 * 1.5
	end
	if self.Primary.SpreadRecovery == -1 or not self.Primary.SpreadRecovery then
		self.Primary.SpreadRecovery = math.max(self.Primary.SpreadMultiplierMax * math.pow(self.Primary.RPM / 600, 1 / 3) * 0.75,self.Primary.SpreadMultiplierMax / 1.5)
	end
end

--[[
Function Name:  AutoDetectMuzzle
Syntax: self:AutoDetectMuzzle().  Call only once, or it's redundant.
Returns:  Nothing.
Notes:  Detects the proper muzzle flash effect if you haven't specified one.
Purpose:  Autodetection
]]--
function SWEP:AutoDetectMuzzle()
	if not self.MuzzleFlashEffect then
		local a = string.lower(self.Primary.Ammo)
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

--[[
Function Name:  AutoDetectDamage
Syntax: self:AutoDetectDamage().  Call only once.  Hopefully you call this only once on like SWEP:Initialize() or something.
Returns:  Nothing.
Notes:  Fixes the damage for GDCW.
Purpose:  Autodetection
]]--
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

		if string.find(rnd, "ap") then
			self.Primary.Damage = self.Primary.Damage * 1.2
		end
	end

	if (not self.Primary.Damage) or (self.Primary.Damage <= 0.01) and self.Velocity then
		self.Primary.Damage = self.Velocity / 5
	end

	if (not self.Primary.Damage) or (self.Primary.Damage <= 0.01) then
		self.Primary.Damage = (self.Primary.KickUp + self.Primary.KickUp + self.Primary.KickUp) * 10
	end
end

--[[
Function Name:  AutoDetectDamageType
Syntax: self:AutoDetectDamageType().  Call only once.  Hopefully you call this only once on like SWEP:Initialize() or something.
Returns:  Nothing.
Notes:  Sets a damagetype
Purpose:  Autodetection
]]--

function SWEP:AutoDetectDamageType()
	if self.Primary.DamageType == -1 or not self.Primary.DamageType then
		if self.DamageType and not self.Primary.DamageType then
			self.Primary.DamageType = self.DamageType
		else
			self.Primary.DamageType = DMG_BULLET
		end
		if  (self.Primary.NumShots * self.Primary.Damage) >= 26 then
			self.Primary.DamageType = bit.bor(self.Primary.DamageType, DMG_AIRBOAT)
		elseif self.Primary.Damage >= 150 then
			self.Primary.DamageType = bit.bor(self.Primary.DamageType, DMG_AIRBOAT)
		end
	end
end

--[[
Function Name:  AutoDetectForce
Syntax: self:AutoDetectForce().  Call only once.  Hopefully you call this only once on like SWEP:Initialize() or something.
Returns:  Nothing.
Notes:  Detects force from damage
Purpose:  Autodetection
]]--

function SWEP:AutoDetectForce()
	if self.Primary.Force == -1 or not self.Primary.Force then
		self.Primary.Force = self.Force or ( math.sqrt( self.Primary.Damage / 16 ) * 3 / math.sqrt( self.Primary.NumShots ) )
	end
end

--[[
Function Name:  AutoDetectKnockback
Syntax: self:AutoDetectKnockback().  Call only once.  Hopefully you call this only once on like SWEP:Initialize() or something.
Returns:  Nothing.
Notes:  Detects knockback from force
Purpose:  Autodetection
]]--

function SWEP:AutoDetectKnockback()
	if self.Primary.Knockback == -1 or not self.Primary.Knockback then
		self.Primary.Knockback = self.Knockback or math.max(math.pow(self.Primary.Force - 3.25, 2), 0) * math.pow(self.Primary.NumShots, 1 / 3)
	end
end

--[[
Function Name:  IconFix
Syntax: self:IconFix().  Call only once.  Hopefully you call this only once on like SWEP:Initialize() or something.
Returns:  Nothing.
Notes:  Fixes the icon.  Call this if you give it a texture path, or just nothing.
Purpose:  Autodetection
]]--
local selicon_final = {}

function SWEP:IconFix()
	if not surface then return end
	self.Gun = self.ClassName or self.Folder
	local tselicon
	local proceed = true

	if selicon_final[self.Gun] then
		self.WepSelectIcon =  selicon_final[self.Gun]
		return
	end

	if self.WepSelectIcon then
		tselicon = type(self.WepSelectIcon)
	end

	if self.WepSelectIcon and tselicon == "string" then
		self.WepSelectIcon = surface.GetTextureID(self.WepSelectIcon)
		proceed = false
	end

	if proceed and file.Exists("materials/vgui/hud/" .. self.ClassName .. ".vmt", "GAME") then
		self.WepSelectIcon = surface.GetTextureID("vgui/hud/" .. self.ClassName)
	end

	selicon_final[self.Gun] = self.WepSelectIcon
end

--[[
Function Name:  CorrectScopeFOV
Syntax: self:CorrectScopeFOV( fov ).  Call only once.  Hopefully you call this only once on like SWEP:Initialize() or something.
Returns:  Nothing.
Notes:  If you're using scopezoom instead of FOV, this translates it.
Purpose:  Autodetection
]]--
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
--[[
Function Name:  CreateFireModes
Syntax: self:CreateFireModes( is first draw).  Call as much as you like.  isfirstdraw controls whether the default fire mode is set.
Returns:  Nothing.
Notes:  Autodetects fire modes depending on what params you set up.
Purpose:  Autodetection
]]--

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

	if not self.FireModeCache or #self.FireModeCache <= 0 then
		for k,v in ipairs(self.FireModes) do
			self.FireModeCache[v] = k
		end

		if type(self.DefaultFireMode) == "number" then
			self:SetFireMode(self.DefaultFireMode or (self.Primary.Automatic and 1 or #self.FireModes - 1) )
		else
			self:SetFireMode( self.FireModeCache[self.DefaultFireMode] or (self.Primary.Automatic and 1 or #self.FireModes - 1) )
		end
	end
end

--[[
Function Name:  CacheAnimations
Syntax: self:CacheAnimations( ).  Call as much as you like.
Returns:  Nothing.
Notes:  This is what autodetects animations for the SWEP.SequenceEnabled and SWEP.SequenceLength tables.
Purpose:  Autodetection
]]--

SWEP.actlist = {ACT_VM_DRAW, ACT_VM_DRAW_EMPTY, ACT_VM_DRAW_SILENCED, ACT_VM_DRAW_DEPLOYED, ACT_VM_HOLSTER, ACT_VM_HOLSTER_EMPTY, ACT_VM_IDLE, ACT_VM_IDLE_EMPTY, ACT_VM_IDLE_SILENCED, ACT_VM_PRIMARYATTACK, ACT_VM_PRIMARYATTACK_1, ACT_VM_PRIMARYATTACK_EMPTY, ACT_VM_PRIMARYATTACK_SILENCED, ACT_VM_SECONDARYATTACK, ACT_VM_RELOAD, ACT_VM_RELOAD_EMPTY, ACT_VM_RELOAD_SILENCED, ACT_VM_ATTACH_SILENCER, ACT_VM_RELEASE, ACT_VM_DETACH_SILENCER, ACT_VM_FIDGET, ACT_VM_FIDGET_EMPTY, ACT_SHOTGUN_RELOAD_START}
--If you really want, you can remove things from SWEP.actlist and manually enable animations and set their lengths.
SWEP.SequenceEnabled = {}
SWEP.SequenceLength = {}
SWEP.SequenceLengthOverride = {} --Override this if you want to change the length of a sequence but not the next idle

SWEP.ActCache = {}

local vm,seq

function SWEP:CacheAnimations()

	table.Empty(self.ActCache)

	if self.CanBeSilenced and self.SequenceEnabled[ACT_VM_IDLE_SILENCED] == nil then
		self.SequenceEnabled[ACT_VM_IDLE_SILENCED] = true
	end

	if not self:VMIV() then return end
	vm = self.OwnerViewModel

	if IsValid(vm) then

		for k, v in ipairs(self.actlist) do
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
	else
		return false
	end

	if self.ProceduralHolsterEnabled == nil then
		if self.SequenceEnabled[ACT_VM_HOLSTER] then
			self.ProceduralHolsterEnabled = false
		else
			self.ProceduralHolsterEnabled = true
		end
	end

	if string.find(self:GetClass(),"nmrih") then
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

		return self:GetType()
	end

	if self.Pistol or (at == "pistol" and ht == "pistol") then
		self.Type = "Pistol"

		return self:GetType()
	end

	if self.SMG or (at == "smg1" and (ht == "smg" or ht == "pistol")) then
		self.Type = "Sub-Machine Gun"

		return self:GetType()
	end

	if self.Revolver or (at == "357" and ht == "revolver") then
		self.Type = "Revolver"

		return self:GetType()
	end

	--Detect Sniper Type
	if (self.Scoped or self.Scoped_3D) and rpm < 600 then
		if rpm > 180 then
			self.Type = "Designated Marksman Rifle"

			return self:GetType()
		else
			self.Type = "Sniper Rifle"

			return self:GetType()
		end
	end

	--Detect based on holdtype
	if ht == "pistol" then
		self.Type = "Pistol"

		return self:GetType()
	end

	if ht == "revolver" then
		self.Type = "Revolver"

		return self:GetType()
	end

	if ht == "duel" then
		if at == "pistol" then
			self.Type = "Dual Pistols"

			return self:GetType()
		elseif at == "357" then
			self.Type = "Dual Revolvers"

			return self:GetType()
		elseif at == "smg1" then
			self.Type = "Dual Sub-Machine Guns"

			return self:GetType()
		else
			self.Type = "Dual Guns"

			return self:GetType()
		end
	end

	--If it's using rifle ammo, it's a rifle or a carbine
	if at == "ar2" then
		if ht == "ar2" or ht == "shotgun" then
			self.Type = "Rifle"

			return self:GetType()
		else
			self.Type = "Carbine"

			return self:GetType()
		end
	end

	--Check SMG one last time
	if ht == "smg" or at == "smg1" then
		self.Type = "Sub-Machine Gun"

		return self:GetType()
	end

	--Fallback to generic
	self.Type = "Weapon"

	return self:GetType()
end

function SWEP:SetUpSpreadLegacy()
	local ht = self.DefaultHoldType and self.DefaultHoldType or self.HoldType

	if not self.Primary.SpreadMultiplierMax or self.Primary.SpreadMultiplierMax <= 0 or self.AutoDetectSpreadMultiplierMax then
		self.Primary.SpreadMultiplierMax = 2.5 * math.max(self.Primary.RPM, 400) / 600 * math.sqrt(self.Primary.Damage / 30 * self.Primary.NumShots) --How far the spread can expand when you shoot.

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
		self.Primary.SpreadIncrement = 1 * math.Clamp(math.sqrt(self.Primary.RPM) / 24.5, 0.7, 3) * math.sqrt(self.Primary.Damage / 30 * self.Primary.NumShots) --What percentage of the modifier is added on, per shot.

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
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement * (math.Clamp((self.Primary.RPM - 650) / 150, 0, 1) + 1)
		end

		if ht == "pistol" and self.Primary.Automatic == true then
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement * 1.5
		end

		if self.Scoped then
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement * 1.25
		end

		self.Primary.SpreadIncrement = self.Primary.SpreadIncrement * math.sqrt(self.Primary.Recoil * (self.Primary.KickUp + self.Primary.KickDown + self.Primary.KickHorizontal)) * 0.8
	end

	if not self.Primary.SpreadRecovery or self.Primary.SpreadRecovery <= 0 or self.AutoDetectSpreadRecovery then
		self.AutoDetectSpreadRecovery = true
		self.Primary.SpreadRecovery = math.sqrt(math.max(self.Primary.RPM, 300)) / 29 * 4 --How much the spread recovers, per second.

		if ht == "smg" then
			self.Primary.SpreadRecovery = self.Primary.SpreadRecovery * (1 - math.Clamp((self.Primary.RPM - 600) / 200, 0, 1) * 0.33)
		end
	end
end