local oiv = nil

function SWEP:NZAnimationSpeed()
	return 1
end

function SWEP:GetSeed()
	local sd = math.floor(self:Clip1() + self:Ammo1() + self:Clip2() + self:Ammo2() + self:GetLastActivity()) + self:GetNextIdleAnim() + self:GetNextPrimaryFire() + self:GetNextSecondaryFire()

	return math.Round(sd)
end

function SWEP:Get3DSensitivity()
	if self.Secondary.ScopeZoom then
		return math.sqrt(1 / self.Secondary.ScopeZoom)
	else
		return math.sqrt(90 / self.Secondary.IronFOV)
	end
end

SWEP.StatusLengthOverride = {}
SWEP.SequenceLengthOverride = {}

local slo, sqlo

function SWEP:GetActivityLength(tanim, status)
	if not self:VMIV() then return 0 end

	tanim = tanim or self:GetLastActivity()
	if tanim < 0 then return 0 end
	nm = self.OwnerViewModel:GetSequenceName(self.OwnerViewModel:SelectWeightedSequence(tanim))

	if tanim == self.OwnerViewModel:GetSequenceActivity(self.OwnerViewModel:GetSequence()) then
		sqlen = self.OwnerViewModel:SequenceDuration(self.OwnerViewModel:GetSequence())
	else
		sqlen = self.OwnerViewModel:SequenceDuration(self.OwnerViewModel:SelectWeightedSequenceSeeded(math.max(tanim or 1, 1), self:GetSeed()))
	end

	slo = self.StatusLengthOverride[nm] or self.StatusLengthOverride[tanim]
	sqlo = self.SequenceLengthOverride[nm] or self.SequenceLengthOverride[tanim]

	if status and slo then
		sqlen = slo
	elseif sqlo then
		sqlen = sqlo
	end
	return sqlen
end

function SWEP:ClearStatCache()
end

function SWEP:GetStat(stat)
	local statTbl = string.Explode(".",stat,false)
	local t = self
	for _, st in ipairs(statTbl) do
		if t[st] then
			t = t[st]
		else
			return
		end
	end
	return t
end

function SWEP:ClearMaterialCache()
	self.MaterialCached = nil
end

function SWEP:Unload()
	local amm = self:Clip1()
	self:SetClip1(0)

	if self.OwnerIsValid and self:OwnerIsValid() and self.Owner.GiveAmmo then
		self.Owner:GiveAmmo(amm, self:GetPrimaryAmmoType(), true)
	end
end

local bgt
SWEP.Bodygroups_V = {}
SWEP.Bodygroups_W = {}

function SWEP:ProcessBodygroups()
	if not self.HasFilledBodygroupTables then
		if self:VMIV() then
			for i = 0, #(self.OwnerViewModel:GetBodyGroups() or self.Bodygroups_V) do
				self.Bodygroups_V[i] = self.Bodygroups_V[i] or 0
			end
		end

		for i = 0, #(self:GetBodyGroups() or self.Bodygroups_W) do
			self.Bodygroups_W[i] = self.Bodygroups_W[i] or 0
		end

		self.HasFilledBodygroupTables = true
	end

	if self:VMIV() then
		bgt = self:GetStat("Bodygroups_V", self.Bodygroups_V)

		for k, v in pairs(bgt) do
			if type(k) == "string" then
				k = tonumber(k)
			end

			if k and self.OwnerViewModel:GetBodygroup(k) ~= v then
				self.OwnerViewModel:SetBodygroup(k, v)
			end
		end
	end

	bgt = self:GetStat("Bodygroups_W", self.Bodygroups_W)

	for k, v in pairs(bgt) do
		if type(k) == "string" then
			k = tonumber(k)
		end

		if k and self:GetBodygroup(k) ~= v then
			self:SetBodygroup(k, v)
		end
	end
end

local rlcv = GetConVar("sv_tfa_reloads_enabled")

function SWEP:ReloadCV()
	if rlcv then
		if ( not rlcv:GetBool() ) and (not self.Primary.ClipSize_PreEdit) then
			self.Primary.ClipSize_PreEdit = self.Primary.ClipSize
			self.Primary.ClipSize = -1
		elseif rlcv:GetBool() and self.Primary.ClipSize_PreEdit then
			self.Primary.ClipSize = self.Primary.ClipSize_PreEdit
			self.Primary.ClipSize_PreEdit = nil
		end
	end
end

function SWEP:OwnerIsValid()
	if oiv == nil then oiv = IsValid(self.Owner) end
	return oiv
end

function SWEP:NullifyOIV()
	oiv = nil
	return self:VMIV()
end

function SWEP:VMIV()
	if not IsValid(self.OwnerViewModel) then
		if IsValid(self.Owner) and self.Owner.GetViewModel then
			self.OwnerViewModel = self.Owner:GetViewModel()
		end
		return false
	else
		return self.OwnerViewModel
	end
end

function SWEP:CanChamber()
	if self.C_CanChamber ~= nil then
		return self.C_CanChamber
	else
		self.C_CanChamber = not self.BoltAction and not self.Shotgun and not self.Revolver and not self.DisableChambering

		return self.C_CanChamber
	end
end

function SWEP:GetPrimaryClipSize( calc )
	targetclip = self.Primary.ClipSize

	if self:CanChamber() and not ( calc and self:Clip1() <= 0 ) then
		targetclip = targetclip + ( self.Akimbo and 2 or 1)
	end

	return math.max(targetclip,-1)
end

function SWEP:TakePrimaryAmmo( num, pool )

	-- Doesn't use clips
	if self.Primary.ClipSize < 0 or pool then

		if ( self:Ammo1() <= 0 ) then return end

		self.Owner:RemoveAmmo( math.min( self:Ammo1(), num), self:GetPrimaryAmmoType() )

		return
	end

	self:SetClip1( math.max(self:Clip1() - num,0) )

end

function SWEP:GetFireDelay()
	if self:GetMaxBurst() > 1 and self.Primary.RPM_Burst and self.Primary.RPM_Burst > 0 then
		return 60 / self.Primary.RPM_Burst
	elseif self.Primary.RPM_Semi and not self.Primary.Automatic and self.Primary.RPM_Semi and self.Primary.RPM_Semi > 0 then
		return 60 / self.Primary.RPM_Semi
	elseif self.Primary.RPM and self.Primary.RPM > 0 then
		return 60 / self.Primary.RPM
	else
		return self.Primary.Delay or 0.1
	end
end

function SWEP:GetBurstDelay(bur)
	if not bur then
		bur = self:GetMaxBurst()
	end

	if bur <= 1 then return 0 end
	if self.Primary.BurstDelay then return self.Primary.BurstDelay end

	return self:GetFireDelay() * 3
end

--[[
Function Name:  IsSafety
Syntax: self:IsSafety( ).
Returns:   Are we in safety firemode.
Notes:    Non.
Purpose:  Utility
]]--
function SWEP:IsSafety()
	if not self.FireModes then return false end
	local fm = self.FireModes[self:GetFireMode()]
	local fmn = string.lower(fm and fm or self.FireModes[1])

	if fmn == "safe" or fmn == "holster" then
		return true
	else
		return false
	end
end

function SWEP:UpdateMuzzleAttachment()
	if not self:VMIV() then return end
	vm = self.OwnerViewModel
	if not IsValid(vm) then return end
	self.MuzzleAttachmentRaw = nil

	if not self.MuzzleAttachmentSilenced then
		self.MuzzleAttachmentSilenced = (vm:LookupAttachment("muzzle_silenced") <= 0) and self.MuzzleAttachment or "muzzle_silenced"
	end

	if self:GetSilenced() and self.MuzzleAttachmentSilenced then
		self.MuzzleAttachmentRaw = vm:LookupAttachment(self.MuzzleAttachmentSilenced)

		if not self.MuzzleAttachmentRaw or self.MuzzleAttachmentRaw <= 0 then
			self.MuzzleAttachmentRaw = nil
		end
	end

	if not self.MuzzleAttachmentRaw and self.MuzzleAttachment then
		self.MuzzleAttachmentRaw = vm:LookupAttachment(self.MuzzleAttachment)

		if not self.MuzzleAttachmentRaw or self.MuzzleAttachmentRaw <= 0 then
			self.MuzzleAttachmentRaw = 1
		end
	end
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

--[[
Function Name:  IsCurrentlyScoped
Syntax: self:IsCurrentlyScoped( ).
Returns:   Is the player scoped in enough to display the overlay?  true/false, returns a boolean.
Notes:    Change SWEP.ScopeOverlayThreshold to change when the overlay is displayed.
Purpose:  Utility
]]--
function SWEP:IsCurrentlyScoped()
	return (self.IronSightsProgress > self.ScopeOverlayThreshold) and self.Scoped
end

--[[
Function Name:  IsHidden
Syntax: self:IsHidden( ).
Returns:   Should we hide self?.
Notes:
Purpose:  Utility
]]--
function SWEP:GetHidden()
	if not self:VMIV() then return true end
	if self.DrawViewModel ~= nil and not self.DrawViewModel then return true end
	if self.ShowViewModel ~= nil and not self.ShowViewModel then return true end
	return self:IsCurrentlyScoped()
end

--[[
Function Name:  IsFirstPerson
Syntax: self:IsFirstPerson( ).
Returns:   Is the owner in first person.
Notes:    Broken in singplayer because gary.
Purpose:  Utility
]]--
function SWEP:IsFirstPerson()
	if not IsValid(self) or not self:OwnerIsValid() then return false end
	if self.Owner.ShouldDrawLocalPlayer and self.Owner:ShouldDrawLocalPlayer() then return false end
	local gmsdlp

	if LocalPlayer then
		gmsldp = hook.Call("ShouldDrawLocalPlayer", GAMEMODE, self.Owner)
	else
		gmsldp = false
	end

	if gmsdlp then return false end
	return true
end

--[[
Function Name:  GetMuzzlePos
Syntax: self:GetMuzzlePos( hacky workaround that doesn't work anyways ).
Returns:   The AngPos for the muzzle attachment.
Notes:    Defaults to the first attachment, and uses GetFPMuzzleAttachment
Purpose:  Utility
]]--
local fp
function SWEP:GetMuzzlePos(ignorepos)
	fp = self:IsFirstPerson()
	if not IsValid(vm) then
		vm = self.OwnerViewModel
	end
	if not IsValid(vm) then
		vm = self
	end

	obj = self.MuzzleAttachmentRaw or vm:LookupAttachment(self.MuzzleAttachment)
	obj = math.Clamp(obj or 1, 1, 128)

	if fp then
		muzzlepos = vm:GetAttachment(obj)
	else
		muzzlepos = self:GetAttachment(obj)
	end

	return muzzlepos
end

function SWEP:FindEvenBurstNumber()
	if (self.Primary.ClipSize % 3 == 0) then
		return 3
	elseif (self.Primary.ClipSize % 2 == 0) then
		return 2
	else
		local i = 4

		while i <= 7 do
			if self.Primary.ClipSize % i == 0 then return i end
			i = i + 1
		end
	end

	return nil
end


function SWEP:GetFireModeName()
	local fm = self:GetFireMode()
	local fmn = string.lower( self.FireModes[fm] )
	if fmn == "safe" or fmn == "holster" then return "Safety" end
	if self.FireModeName then return self.FireModeName end
	if fmn == "auto" or fmn == "automatic" then return "Full-Auto" end

	if fmn == "semi" or fmn == "single" then
		if self.Revolver then
			if (self.BoltAction) then
				return "Single-Action"
			else
				return "Double-Action"
			end
		else
			if (self.BoltAction) then
				return "Bolt-Action"
			else
				if (self.Shotgun and self.Primary.RPM < 250) then
					return "Pump-Action"
				else
					return "Semi-Auto"
				end
			end
		end
	end

	local bpos = string.find(fmn, "burst")
	if bpos then return string.sub(fmn, 1, bpos - 1) .. " Round Burst" end
	return ""
end

SWEP.BurstCountCache = {}

function SWEP:GetMaxBurst()
	local fm = self:GetFireMode()
	if not self.BurstCountCache[ fm ] then
		local fmn = string.lower( self.FireModes[fm] )
		local bpos = string.find(fmn, "burst")
		if bpos then
			self.BurstCountCache[ fm ] = tonumber( string.sub(fmn, 1, bpos - 1) )
		else
			self.BurstCountCache[ fm ] = 1
		end
	end
	return self.BurstCountCache[ fm ]
end

--[[
Function Name:  CycleFireMode
Syntax: self:CycleFireMode()
Returns:  Nothing.
Notes: Cycles to next firemode.
Purpose:  Feature
]]--
local l_CT = CurTime
function SWEP:CycleFireMode()
	local fm = self:GetFireMode()
	fm = fm + 1

	if fm >= #self.FireModes then
		fm = 1
	end

	self:SetFireMode(fm)
	self:EmitSound("Weapon_AR2.Empty")
	self:SetNextPrimaryFire(l_CT() + math.max( self:GetFireDelay(), 0.25))
	self.BurstCount = 0
	--self:SetStatus(TFA.Enum.STATUS_FIREMODE)
	--self:SetStatusEnd( self:GetNextPrimaryFire() )
end

--[[
Function Name:  CycleSafety
Syntax: self:CycleSafety()
Returns:  Nothing.
Notes: Toggles safety
Purpose:  Feature
]]--
function SWEP:CycleSafety()
	ct = l_CT()
	local fm = self:GetFireMode()

	if fm ~= #self.FireModes then
		self.LastFireMode = fm
		self:SetFireMode(#self.FireModes)
	else
		self:SetFireMode(self.LastFireMode or 1)
	end

	self:EmitSound("Weapon_AR2.Empty")
	self:SetNextPrimaryFire(ct + math.max( self:GetFireDelay(), 0.25))
	self.BurstCount = 0
	--self:SetStatus(TFA.Enum.STATUS_FIREMODE)
	--self:SetStatusEnd( self:GetNextPrimaryFire() )
end

--[[
Function Name:  ProcessFireMode
Syntax: self:ProcessFireMode()
Returns:  Nothing.
Notes: Processes fire mode changing and whether the swep is auto or not.
Purpose:  Feature
]]--
local fm
local sp = game.SinglePlayer()

function SWEP:ProcessFireMode()
	if self.Owner:KeyPressed(IN_RELOAD) and self.Owner:KeyDown(IN_USE) and self:GetStatus() == TFA.Enum.STATUS_IDLE and ( SERVER or not sp ) then
		if self.SelectiveFire and not self.Owner:KeyDown(IN_SPEED) then
			self:CycleFireMode()
		elseif self.Owner:KeyDown(IN_SPEED) then
			self:CycleSafety()
		end
	end

	fm = self.FireModes[self:GetFireMode()]

	if fm == "Automatic" or fm == "Auto" then
		self.Primary.Automatic = true
	else
		self.Primary.Automatic = false
	end
end