local sp = game.SinglePlayer()
local l_CT = CurTime
local l_FrameNumber = FrameNumber

local function L(key)
	if TFA and TFA.GetLangString then
		return TFA.GetLangString(key)
	end
	return key
end

function SWEP:NZAnimationSpeed()
	return 1
end

function SWEP:GetSeed()
	local c1 = tonumber(self:Clip1()) or 0
	local a1 = tonumber(self:Ammo1()) or 0
	local c2 = tonumber(self:Clip2()) or 0
	local a2 = tonumber(self:Ammo2()) or 0
	local la = tonumber(self:GetLastActivity()) or 0
	local nia = tonumber(self:GetNextIdleAnim()) or 0
	local npf = tonumber(self:GetNextPrimaryFire()) or 0
	local nsf = tonumber(self:GetNextSecondaryFire()) or 0

	local sd = math.floor(c1 + a1 + c2 + a2 + la) + nia + npf + nsf
	return math.Round(sd)
end

function SWEP:Get3DSensitivity()
	local sec = self.Secondary or {}
	local zoom = tonumber(sec.ScopeZoom) or 0
	if zoom > 0 then
		return math.sqrt(1 / zoom)
	end

	local fov = tonumber(sec.IronFOV) or 90
	if fov <= 0 then fov = 90 end
	return math.sqrt(90 / fov)
end

SWEP.StatusLengthOverride = SWEP.StatusLengthOverride or {}
SWEP.SequenceLengthOverride = SWEP.SequenceLengthOverride or {}

function SWEP:GetActivityLength(tanim, status)
	if not self:VMIV() then return 0 end

	local vm = self.OwnerViewModel
	if not IsValid(vm) then return 0 end

	tanim = tonumber(tanim) or self:GetLastActivity()
	if not tanim or tanim < 0 then return 0 end

	local seq
	if tanim == vm:GetSequenceActivity(vm:GetSequence()) then
		seq = vm:GetSequence()
	else
		seq = vm:SelectWeightedSequenceSeeded(math.max(tanim, 1), self:GetSeed())
	end

	local nm = vm:GetSequenceName(seq)
	local sqlen = vm:SequenceDuration(seq)

	local slo = self.StatusLengthOverride[nm] or self.StatusLengthOverride[tanim]
	local sqlo = self.SequenceLengthOverride[nm] or self.SequenceLengthOverride[tanim]

	if status and slo then
		sqlen = slo
	elseif sqlo then
		sqlen = sqlo
	end

	return sqlen or 0
end

function SWEP:ClearStatCache()
	self._stat_path_cache = nil
end

function SWEP:GetStat(stat, default)
	if not stat or stat == "" then return default end

	local cache = self._stat_path_cache
	if not cache then
		cache = {}
		self._stat_path_cache = cache
	end

	local path = cache[stat]
	if not path then
		path = string.Explode(".", stat, false)
		cache[stat] = path
	end

	local t = self
	for i = 1, #path do
		local k = path[i]
		local v = t[k]
		if v == nil then
			return default
		end
		t = v
	end

	return t
end

function SWEP:ClearMaterialCache()
	self.MaterialCached = nil
end

function SWEP:Unload()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	local amm = tonumber(self:Clip1()) or 0
	if amm <= 0 then
		self:SetClip1(0)
		return
	end

	self:SetClip1(0)
	if owner.GiveAmmo then
		owner:GiveAmmo(amm, self:GetPrimaryAmmoType(), true)
	end
end

SWEP.Bodygroups_V = SWEP.Bodygroups_V or {}
SWEP.Bodygroups_W = SWEP.Bodygroups_W or {}

function SWEP:ProcessBodygroups()
	if not self.HasFilledBodygroupTables then
		if self:VMIV() then
			local vm = self.OwnerViewModel
			if IsValid(vm) and vm.GetNumBodyGroups then
				local n = vm:GetNumBodyGroups() or 0
				for i = 0, math.max(n - 1, 0) do
					self.Bodygroups_V[i] = self.Bodygroups_V[i] or 0
				end
			end
		end

		if self.GetNumBodyGroups then
			local n = self:GetNumBodyGroups() or 0
			for i = 0, math.max(n - 1, 0) do
				self.Bodygroups_W[i] = self.Bodygroups_W[i] or 0
			end
		end

		self.HasFilledBodygroupTables = true
	end

	if self:VMIV() then
		local vm = self.OwnerViewModel
		if IsValid(vm) then
			local bgtv = self:GetStat("Bodygroups_V", self.Bodygroups_V) or self.Bodygroups_V
			for k, v in pairs(bgtv) do
				local idx = (type(k) == "string") and tonumber(k) or k
				if idx and vm:GetBodygroup(idx) ~= v then
					vm:SetBodygroup(idx, v)
				end
			end
		end
	end

	local bgtw = self:GetStat("Bodygroups_W", self.Bodygroups_W) or self.Bodygroups_W
	for k, v in pairs(bgtw) do
		local idx = (type(k) == "string") and tonumber(k) or k
		if idx and self:GetBodygroup(idx) ~= v then
			self:SetBodygroup(idx, v)
		end
	end
end

local rlcv = GetConVar("sv_tfa_reloads_enabled")

function SWEP:ReloadCV()
	if not rlcv then return end
	if not self.Primary then return end

	if (not rlcv:GetBool()) and (not self.Primary.ClipSize_PreEdit) then
		self.Primary.ClipSize_PreEdit = self.Primary.ClipSize
		self.Primary.ClipSize = -1
	elseif rlcv:GetBool() and self.Primary.ClipSize_PreEdit then
		self.Primary.ClipSize = self.Primary.ClipSize_PreEdit
		self.Primary.ClipSize_PreEdit = nil
	end
end

function SWEP:OwnerIsValid()
	local fn
	if l_FrameNumber then
		fn = l_FrameNumber()
	else
		fn = math.floor(l_CT() * 100)
	end

	if self._oiv_fn ~= fn then
		self._oiv_fn = fn
		self._oiv_val = IsValid(self:GetOwner())
	end

	return self._oiv_val
end

function SWEP:NullifyOIV()
	self._oiv_fn = nil
	self._oiv_val = nil
	return self:VMIV()
end

function SWEP:VMIV()
	if not IsValid(self.OwnerViewModel) then
		local owner = self:GetOwner()
		if IsValid(owner) and owner.GetViewModel then
			self.OwnerViewModel = owner:GetViewModel()
		end
		return false
	end
	return self.OwnerViewModel
end

function SWEP:CanChamber()
	if self.C_CanChamber ~= nil then
		return self.C_CanChamber
	end

	self.C_CanChamber = not self.BoltAction and not self.Shotgun and not self.Revolver and not self.DisableChambering
	return self.C_CanChamber
end

function SWEP:GetPrimaryClipSize(calc)
	local prim = self.Primary or {}
	local targetclip = tonumber(prim.ClipSize) or -1

	if targetclip >= 0 then
		if self:CanChamber() and not (calc and (tonumber(self:Clip1()) or 0) <= 0) then
			targetclip = targetclip + (self.Akimbo and 2 or 1)
		end
	end

	return math.max(targetclip, -1)
end

function SWEP:TakePrimaryAmmo(num, pool)
	num = tonumber(num) or 0
	if num <= 0 then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if (self.Primary and self.Primary.ClipSize or -1) < 0 or pool then
		local a1 = tonumber(self:Ammo1()) or 0
		if a1 <= 0 then return end
		owner:RemoveAmmo(math.min(a1, num), self:GetPrimaryAmmoType())
		return
	end

	self:SetClip1(math.max((tonumber(self:Clip1()) or 0) - num, 0))
end

function SWEP:GetFireDelay()
	local prim = self.Primary or {}
	if self.GetMaxBurst and self:GetMaxBurst() > 1 and prim.RPM_Burst and prim.RPM_Burst > 0 then
		return 60 / prim.RPM_Burst
	elseif prim.RPM_Semi and not prim.Automatic and prim.RPM_Semi > 0 then
		return 60 / prim.RPM_Semi
	elseif prim.RPM and prim.RPM > 0 then
		return 60 / prim.RPM
	end
	return prim.Delay or 0.1
end

function SWEP:GetBurstDelay(bur)
	if not bur then
		bur = self:GetMaxBurst()
	end

	bur = tonumber(bur) or 1
	if bur <= 1 then return 0 end

	local prim = self.Primary or {}
	if prim.BurstDelay then return prim.BurstDelay end

	return self:GetFireDelay() * 3
end

function SWEP:IsSafety()
	if not self.FireModes then return false end
	local fm = self.FireModes[self:GetFireMode()] or self.FireModes[1]
	local fmn = fm and string.lower(tostring(fm)) or ""
	return (fmn == "safe" or fmn == "holster")
end

function SWEP:UpdateMuzzleAttachment()
	if not self:VMIV() then return end

	local vm = self.OwnerViewModel
	if not IsValid(vm) then return end

	self.MuzzleAttachmentRaw = nil

	if not self.MuzzleAttachment then
		self.MuzzleAttachment = "muzzle"
	end

	if not self.MuzzleAttachmentSilenced then
		local has = vm:LookupAttachment("muzzle_silenced")
		self.MuzzleAttachmentSilenced = (has and has > 0) and "muzzle_silenced" or self.MuzzleAttachment
	end

	if self.GetSilenced and self:GetSilenced() and self.MuzzleAttachmentSilenced then
		local raw = vm:LookupAttachment(self.MuzzleAttachmentSilenced)
		if raw and raw > 0 then
			self.MuzzleAttachmentRaw = raw
			return
		end
	end

	local raw = vm:LookupAttachment(self.MuzzleAttachment)
	if not raw or raw <= 0 then
		raw = 1
	end
	self.MuzzleAttachmentRaw = raw
end

function SWEP:UpdateConDamage()
	if not IsValid(self) then return end

	if not self.DamageConVar then
		self.DamageConVar = GetConVar("sv_tfa_damage_multiplier")
	end

	if self.DamageConVar and self.DamageConVar.GetFloat then
		self.ConDamageMultiplier = self.DamageConVar:GetFloat()
	end
end

function SWEP:IsCurrentlyScoped()
	local thr = tonumber(self.ScopeOverlayThreshold) or 0.8
	return (tonumber(self.IronSightsProgress) or 0) > thr and self.Scoped
end

function SWEP:GetHidden()
	if not self:VMIV() then return true end
	if self.DrawViewModel ~= nil and not self.DrawViewModel then return true end
	if self.ShowViewModel ~= nil and not self.ShowViewModel then return true end
	return self:IsCurrentlyScoped()
end

function SWEP:IsFirstPerson()
	if not IsValid(self) or not self:OwnerIsValid() then return false end

	local owner = self:GetOwner()
	if not IsValid(owner) then return false end

	if SERVER then
		if sp then return true end
		return false
	end

	if owner.ShouldDrawLocalPlayer and owner:ShouldDrawLocalPlayer() then return false end

	local gmsdlp = false
	if hook and hook.Call then
		gmsdlp = hook.Call("ShouldDrawLocalPlayer", GAMEMODE, owner) or false
	end

	if gmsdlp then return false end
	return true
end

function SWEP:GetMuzzlePos(ignorepos)
	local fp = self:IsFirstPerson()

	local vm = self.OwnerViewModel
	if not IsValid(vm) then
		vm = self
	end

	local att = self.MuzzleAttachmentRaw
	if not att or att <= 0 then
		att = vm:LookupAttachment(self.MuzzleAttachment or "muzzle")
	end

	att = math.Clamp(att or 1, 1, 128)

	if fp and IsValid(self.OwnerViewModel) then
		return self.OwnerViewModel:GetAttachment(att)
	end

	return self:GetAttachment(att)
end

function SWEP:FindEvenBurstNumber()
	local prim = self.Primary or {}
	local cs = tonumber(prim.ClipSize) or 0
	if cs == 0 then return nil end

	if cs % 3 == 0 then
		return 3
	elseif cs % 2 == 0 then
		return 2
	end

	local i = 4
	while i <= 7 do
		if cs % i == 0 then return i end
		i = i + 1
	end

	return nil
end

function SWEP:GetFireModeName()
	local fm = self:GetFireMode()
	local fireModeEntry = self.FireModes and self.FireModes[fm]
	if not fireModeEntry then
		return L("hud_firemode_auto")
	end

	local fmn = string.lower(tostring(fireModeEntry))
	if fmn == "safe" or fmn == "holster" then return L("hud_firemode_safety") end
	if self.FireModeName then return L(self.FireModeName) end
	if fmn == "auto" or fmn == "automatic" then return L("hud_firemode_full_auto") end

	if fmn == "semi" or fmn == "single" then
		if self.Revolver then
			if self.BoltAction then
				return L("hud_firemode_single_action")
			end
			return L("hud_firemode_double_action")
		end

		if self.BoltAction then
			return L("hud_firemode_bolt_action")
		end

		if self.Shotgun and (self.Primary and self.Primary.RPM or 0) < 250 then
			return L("hud_firemode_pump_action")
		end

		return L("hud_firemode_semi_auto")
	end

	local bpos = string.find(fmn, "burst", 1, true)
	if bpos then
		local count = string.Trim(string.sub(fmn, 1, bpos - 1))
		return string.format(L("hud_firemode_burst"), count)
	end

	return ""
end

SWEP.BurstCountCache = SWEP.BurstCountCache or {}

function SWEP:GetMaxBurst()
	local fm = self:GetFireMode() or 1
	local cacheKey = fm

	if not self.BurstCountCache[cacheKey] then
		local fmEntry
		if istable(self.FireModes) then
			fmEntry = self.FireModes[fm] or self.FireModes[1]
		end

		local fmn = fmEntry and string.lower(tostring(fmEntry)) or nil
		local bpos = fmn and string.find(fmn, "burst", 1, true) or nil
		if bpos then
			self.BurstCountCache[cacheKey] = tonumber(string.sub(fmn, 1, bpos - 1)) or 1
		else
			self.BurstCountCache[cacheKey] = 1
		end
	end

	return self.BurstCountCache[cacheKey]
end

function SWEP:CycleFireMode()
	if not istable(self.FireModes) or #self.FireModes <= 1 then return end

	local fm = (self:GetFireMode() or 1) + 1
	if fm >= #self.FireModes then
		fm = 1
	end

	self:SetFireMode(fm)
	self:EmitSound("Weapon_AR2.Empty")

	local ct = l_CT()
	self:SetNextPrimaryFire(ct + math.max(self:GetFireDelay(), 0.25))

	self.BurstCount = 0
end

function SWEP:CycleSafety()
	if not istable(self.FireModes) or #self.FireModes <= 0 then return end

	local ct = l_CT()
	local fm = self:GetFireMode() or 1

	if fm ~= #self.FireModes then
		self.LastFireMode = fm
		self:SetFireMode(#self.FireModes)
	else
		self:SetFireMode(self.LastFireMode or 1)
	end

	self:EmitSound("Weapon_AR2.Empty")
	self:SetNextPrimaryFire(ct + math.max(self:GetFireDelay(), 0.25))
	self.BurstCount = 0
end

function SWEP:ProcessFireMode()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if owner:KeyPressed(IN_RELOAD) and owner:KeyDown(IN_USE) and self:GetStatus() == TFA.Enum.STATUS_IDLE and (SERVER or not sp) then
		if self.SelectiveFire and not owner:KeyDown(IN_SPEED) then
			self:CycleFireMode()
		elseif owner:KeyDown(IN_SPEED) then
			self:CycleSafety()
		end
	end

	local fm = self.FireModes and self.FireModes[self:GetFireMode()]
	if not self.Primary then self.Primary = {} end

	if fm == "Automatic" or fm == "Auto" then
		self.Primary.Automatic = true
	else
		self.Primary.Automatic = false
	end
end
