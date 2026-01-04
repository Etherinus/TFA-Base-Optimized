ACT_VM_FIDGET_EMPTY = ACT_VM_FIDGET_EMPTY or ACT_CROSSBOW_FIDGET_UNLOADED
ACT_VM_BLOWBACK = ACT_VM_BLOWBACK or -2
ACT_VM_HOLSTER_SILENCED = ACT_VM_HOLSTER_SILENCED or ACT_CROSSBOW_HOLSTER_UNLOADED

local ServersideLooped = {
	[ACT_VM_FIDGET] = true,
	[ACT_VM_FIDGET_EMPTY] = true
}

local d, pbr
local tval

local function clamp_rate(rate)
	if rate == nil then return 1 end
	rate = tonumber(rate) or 1
	if rate <= 0 then return 0.0001 end
	return rate
end

local function get_vm(self)
	if self.OwnerViewModel and IsValid(self.OwnerViewModel) then
		return self.OwnerViewModel
	end

	local owner = self:GetOwner()
	if IsValid(owner) then
		local vm = owner:GetViewModel()
		if IsValid(vm) then
			self.OwnerViewModel = vm
			return vm
		end
	end

	return nil
end

local function set_next_idle(self, dur, rate, blend)
	if not self.SetNextIdleAnim then return end
	blend = tonumber(blend) or 0
	dur = tonumber(dur) or 0
	rate = tonumber(rate) or 1
	if rate <= 0 then rate = 0.0001 end
	local dt = dur / rate - blend
	if dt < 0 then dt = 0 end
	self:SetNextIdleAnim(CurTime() + dt)
end

function SWEP:SendViewModelAnim(act, rate, targ, blend)
	if act == nil then return end
	act = tonumber(act) or -1
	if act < 0 then return end
	if not self:VMIV() then return end

	local vm = get_vm(self)
	if not IsValid(vm) then return end

	local last = self.GetLastActivity and self:GetLastActivity() or nil
	if self.SetLastActivity then
		self:SetLastActivity(act)
	end

	if targ then
		rate = clamp_rate(rate)
	else
		rate = clamp_rate(rate)
	end

	local seq = vm:SelectWeightedSequenceSeeded(act, CurTime())
	if not seq or seq < 0 then
		return
	end

	if self.ResetEvents then
		self:ResetEvents()
	end

	local looped_same = (last == act) and ServersideLooped[act] and true or false

	if looped_same then
		if self.ChooseIdleAnim then
			self:ChooseIdleAnim()
		end

		vm:SetPlaybackRate(0)
		vm:SetCycle(0)

		if self.SetNextIdleAnim then
			self:SetNextIdleAnim(CurTime() + 0.03)
		end

		if IsFirstTimePredicted() then
			local wep = self
			local vmref = vm

			timer.Simple(0, function()
				if not IsValid(wep) then return end
				local vm2 = get_vm(wep)
				if not IsValid(vm2) then return end
				if vm2 ~= vmref then return end

				vm2:SendViewModelMatchingSequence(seq)
				d = vm2:SequenceDuration()
				pbr = targ and (d / rate) or rate
				if pbr <= 0 then pbr = 0.0001 end
				vm2:SetPlaybackRate(pbr)

				if blend == nil then
					blend = wep.Idle_Smooth
				end

				set_next_idle(wep, d, pbr, blend)
			end)
		end
	else
		vm:SendViewModelMatchingSequence(seq)
		d = vm:SequenceDuration()
		pbr = targ and (d / rate) or rate
		if pbr <= 0 then pbr = 0.0001 end
		vm:SetPlaybackRate(pbr)

		if blend == nil then
			blend = self.Idle_Smooth
		end

		set_next_idle(self, d, pbr, blend)
	end

	return true, act
end

function SWEP:SendViewModelSeq(seq, rate, targ, blend)
	if not self:VMIV() then return end

	local vm = get_vm(self)
	if not IsValid(vm) then return end

	if type(seq) == "string" then
		seq = vm:LookupSequence(seq) or -1
	end

	seq = tonumber(seq) or -1
	if seq < 0 then return end

	local act = vm:GetSequenceActivity(seq)

	local last = self.GetLastActivity and self:GetLastActivity() or nil
	if self.SetLastActivity then
		self:SetLastActivity(act)
	end

	rate = clamp_rate(rate)

	if self.ResetEvents then
		self:ResetEvents()
	end

	local looped_same = (last == act) and ServersideLooped[act] and true or false

	if looped_same then
		vm:SendViewModelMatchingSequence(act == 0 and 1 or 0)
		vm:SetPlaybackRate(0)
		vm:SetCycle(0)

		if self.SetNextIdleAnim then
			self:SetNextIdleAnim(CurTime() + 0.03)
		end

		if IsFirstTimePredicted() then
			local wep = self
			local vmref = vm

			timer.Simple(0, function()
				if not IsValid(wep) then return end
				local vm2 = get_vm(wep)
				if not IsValid(vm2) then return end
				if vm2 ~= vmref then return end

				vm2:SendViewModelMatchingSequence(seq)
				d = vm2:SequenceDuration()
				pbr = targ and (d / rate) or rate
				if pbr <= 0 then pbr = 0.0001 end
				vm2:SetPlaybackRate(pbr)

				if blend == nil then
					blend = wep.Idle_Smooth
				end

				set_next_idle(wep, d, pbr, blend)
			end)
		end
	else
		vm:SendViewModelMatchingSequence(seq)
		d = vm:SequenceDuration()
		pbr = targ and (d / rate) or rate
		if pbr <= 0 then pbr = 0.0001 end
		vm:SetPlaybackRate(pbr)

		if blend == nil then
			blend = self.Idle_Smooth
		end

		set_next_idle(self, d, pbr, blend)
	end

	return true, act
end

function SWEP:PlayAnimation(data)
	if not self:VMIV() then return end
	if not data then return false, -1 end

	local vm = get_vm(self)
	if not IsValid(vm) then return false, -1 end

	if data.type == TFA.Enum.ANIMATION_ACT then
		tval = data.value

		if self:Clip1() <= 0 and self.Primary.ClipSize >= 0 then
			tval = data.value_empty or tval
		end

		if self:Clip1() == 1 and self.Primary.ClipSize >= 0 then
			tval = data.value_last or tval
		end

		if self:GetSilenced() then
			tval = data.value_sil or tval
		end

		if self:GetIronSights() then
			tval = data.value_is or tval

			if self:Clip1() <= 0 and self.Primary.ClipSize >= 0 then
				tval = data.value_is_empty or tval
			end

			if self:Clip1() == 1 and self.Primary.ClipSize >= 0 then
				tval = data.value_is_last or tval
			end

			if self:GetSilenced() then
				tval = data.value_is_sil or tval
			end
		end

		if type(tval) == "string" then
			tval = tonumber(tval) or -1
		end

		if tval and tval > 0 then
			return self:SendViewModelAnim(tval, 1, false, data.transition and self.Idle_Blend or self.Idle_Smooth)
		end
	elseif data.type == TFA.Enum.ANIMATION_SEQ then
		tval = data.value

		if self:Clip1() <= 0 and self.Primary.ClipSize >= 0 then
			tval = data.value_empty or tval
		end

		if self:Clip1() == 1 and self.Primary.ClipSize >= 0 then
			tval = data.value_last or tval
		end

		if type(tval) == "string" then
			tval = vm:LookupSequence(tval)
		end

		if tval and tval > 0 then
			return self:SendViewModelSeq(tval, 1, false, data.transition and self.Idle_Blend or self.Idle_Smooth)
		end
	end

	return false, -1
end

function SWEP:Locomote(flipis, is, flipsp, spr)
	if not (flipis or flipsp) then return end
	local stat = self:GetStatus()
	if not (stat == TFA.Enum.STATUS_IDLE or (stat == TFA.Enum.STATUS_SHOOTING and not self.BoltAction)) then return end

	local tldata = nil

	if flipis then
		if is and self.IronAnimation and self.IronAnimation["in"] then
			tldata = self.IronAnimation["in"]
		elseif self.IronAnimation and self.IronAnimation.out and not flipsp then
			tldata = self.IronAnimation.out
		end
	end

	if flipsp then
		if spr and self.SprintAnimation and self.SprintAnimation["in"] then
			tldata = self.SprintAnimation["in"]
		elseif self.SprintAnimation and self.SprintAnimation.out and not flipis and not spr then
			tldata = self.SprintAnimation.out
		end
	end

	if tldata then
		return self:PlayAnimation(tldata)
	end

	return false, -1
end

function SWEP:ChooseDrawAnim()
	if not self:VMIV() then return end
	self.SequenceEnabled = self.SequenceEnabled or {}

	local tanim

	if self.SequenceEnabled[ACT_VM_DRAW_DEPLOYED] and not self:GetNW2Bool("Drawn") then
		tanim = ACT_VM_DRAW_DEPLOYED
	elseif self.SequenceEnabled[ACT_VM_DRAW_SILENCED] and self:GetSilenced() then
		tanim = ACT_VM_DRAW_SILENCED
	elseif self.SequenceEnabled[ACT_VM_DRAW_EMPTY] and (self:Clip1() == 0) then
		tanim = ACT_VM_DRAW_EMPTY
	else
		tanim = ACT_VM_DRAW
	end

	self:SendViewModelAnim(tanim)

	return true, tanim
end

function SWEP:ChooseInspectAnim()
	if not self:VMIV() then return end
	self.SequenceEnabled = self.SequenceEnabled or {}

	local tanim = ACT_VM_FIDGET
	local success = true

	if self.SequenceEnabled[ACT_VM_FIDGET_EMPTY] and self.Primary.ClipSize > 0 and math.Round(self:Clip1()) == 0 then
		tanim = ACT_VM_FIDGET_EMPTY
	elseif self.InspectionActions and #self.InspectionActions > 0 then
		local idx = self:EntIndex()
		local r = util.SharedRandom("tfa_inspect_" .. idx, 1, #self.InspectionActions + 0.999, CurTime())
		local pick = math.Clamp(math.floor(r), 1, #self.InspectionActions)
		tanim = self.InspectionActions[pick]
	elseif self.SequenceEnabled[ACT_VM_FIDGET] then
		tanim = ACT_VM_FIDGET
	else
		tanim = ACT_VM_IDLE
		success = false
	end

	return self:SendViewModelAnim(tanim), success and tanim or tanim
end

function SWEP:ChooseHolsterAnim()
	if not self:VMIV() then return end
	self.SequenceEnabled = self.SequenceEnabled or {}

	local tanim
	local success = true

	if self:GetSilenced() and self.SequenceEnabled[ACT_VM_HOLSTER_SILENCED] then
		tanim = ACT_VM_HOLSTER_SILENCED
	elseif self.SequenceEnabled[ACT_VM_HOLSTER_EMPTY] and self:Clip1() == 0 then
		tanim = ACT_VM_HOLSTER_EMPTY
	elseif self.SequenceEnabled[ACT_VM_HOLSTER] then
		tanim = ACT_VM_HOLSTER
	else
		tanim = ACT_VM_IDLE
		success = false
	end

	self:SendViewModelAnim(tanim)

	return success, tanim
end

function SWEP:ChooseProceduralReloadAnim()
	if not self:VMIV() then return end

	if not self.DisableIdleAnimations then
		self:SendViewModelAnim(ACT_VM_IDLE)
	end

	return true, ACT_VM_IDLE
end

function SWEP:ChooseReloadAnim()
	if not self:VMIV() then return false, 0 end
	if self.ProceduralReloadEnabled then return false, 0 end

	self.SequenceEnabled = self.SequenceEnabled or {}

	local tanim

	if self.SequenceEnabled[ACT_VM_RELOAD_SILENCED] and self:GetSilenced() then
		tanim = ACT_VM_RELOAD_SILENCED
	elseif self.SequenceEnabled[ACT_VM_RELOAD_EMPTY] and self:Clip1() == 0 and not self.Shotgun then
		tanim = ACT_VM_RELOAD_EMPTY
	else
		tanim = ACT_VM_RELOAD
	end

	local fac = 1
	if self.Shotgun and self.ShellTime then
		fac = clamp_rate(self.ShellTime)
	end

	self.AnimCycle = 0

	if SERVER and game.SinglePlayer() then
		self.SetNW2Int = self.SetNW2Int or self.SetNWInt
		self:SetNW2Int("AnimCycle", self.AnimCycle)
	end

	return self:SendViewModelAnim(tanim, fac, fac ~= 1)
end

function SWEP:ChooseShotgunReloadAnim()
	if not self:VMIV() then return end
	self.SequenceEnabled = self.SequenceEnabled or {}

	local tanim

	if self.SequenceEnabled[ACT_VM_RELOAD_SILENCED] and self:GetSilenced() then
		tanim = ACT_VM_RELOAD_SILENCED
	elseif self.SequenceEnabled[ACT_VM_RELOAD_EMPTY] and self.ShotgunEmptyAnim and self:Clip1() == 0 then
		tanim = ACT_VM_RELOAD_EMPTY
	elseif self.SequenceEnabled[ACT_SHOTGUN_RELOAD_START] then
		tanim = ACT_SHOTGUN_RELOAD_START
	else
		local _, idleact = self:ChooseIdleAnim()
		return false, idleact
	end

	return self:SendViewModelAnim(tanim)
end

function SWEP:ChooseShotgunPumpAnim()
	if not self:VMIV() then return end
	return self:SendViewModelAnim(ACT_SHOTGUN_RELOAD_FINISH)
end

local idleCV

function SWEP:ChooseIdleAnim()
	if not self:VMIV() then return end

	if not idleCV then
		idleCV = GetConVar("sv_tfa_net_idles")
	end

	if self.Idle_Mode ~= TFA.Enum.IDLE_BOTH and self.Idle_Mode ~= TFA.Enum.IDLE_ANI then
		return
	end

	if self:GetIronSights() then
		if self.Sights_Mode == TFA.Enum.LOCOMOTION_LUA then
			return self:ChooseFlatAnim()
		end
		return self:ChooseADSAnim()
	elseif self:GetSprinting() and self.Sprint_Mode ~= TFA.Enum.LOCOMOTION_LUA then
		return self:ChooseSprintAnim()
	end

	if self:GetNextIdleAnim() ~= -1 and idleCV and not idleCV:GetBool() then
		return
	end

	self.SequenceEnabled = self.SequenceEnabled or {}

	local tanim

	if self.SequenceEnabled[ACT_VM_IDLE_SILENCED] and self:GetSilenced() then
		tanim = ACT_VM_IDLE_SILENCED
	elseif (self.Primary.ClipSize > 0 and self:Clip1() == 0) or (self.Primary.ClipSize <= 0 and self:Ammo1() == 0) then
		if self.SequenceEnabled[ACT_VM_IDLE_EMPTY] then
			tanim = ACT_VM_IDLE_EMPTY
		else
			tanim = ACT_VM_IDLE
		end
	else
		tanim = ACT_VM_IDLE
	end

	return self:SendViewModelAnim(tanim)
end

function SWEP:ChooseFlatAnim()
	if not self:VMIV() then return end
	self.SequenceEnabled = self.SequenceEnabled or {}

	local tanim = ACT_VM_IDLE

	if self.SequenceEnabled[ACT_VM_IDLE_SILENCED] and self:GetSilenced() then
		tanim = ACT_VM_IDLE_SILENCED
	elseif self.SequenceEnabled[ACT_VM_IDLE_EMPTY] and self:Clip1() == 0 then
		tanim = ACT_VM_IDLE_EMPTY
	end

	self:SendViewModelAnim(tanim, 0.00001)
	return true, tanim
end

function SWEP:ChooseADSAnim()
	local succ, tan = self:PlayAnimation(self.IronAnimation and self.IronAnimation.loop)
	if succ then
		return succ, tan
	end
	return self:ChooseFlatAnim()
end

function SWEP:ChooseSprintAnim()
	self:PlayAnimation(self.SprintAnimation and self.SprintAnimation.loop)
	return true, -1
end

function SWEP:ChooseWalkAnim()
	if self.WalkAnimation and self.WalkAnimation.loop then
		self:PlayAnimation(self.WalkAnimation.loop)
		return true, -1
	end

	return self:ChooseFlatAnim()
end

function SWEP:ChooseShootAnim(ifp)
	ifp = ifp or IsFirstTimePredicted()
	if not self:VMIV() then return end

	self.SequenceEnabled = self.SequenceEnabled or {}

	if self:GetIronSights() and (self.Sights_Mode == TFA.Enum.LOCOMOTION_ANI or self.Sights_Mode == TFA.Enum.LOCOMOTION_HYBRID) and self.IronAnimation and self.IronAnimation.shoot then
		if self.LuaShellEject and ifp then
			self:EventShell()
		end

		return self:PlayAnimation(self.IronAnimation.shoot)
	end

	if not self.BlowbackEnabled or (not self:GetIronSights() and self.Blowback_Only_Iron) then
		if self.LuaShellEject then
			self:MakeShellBridge(ifp)
		end

		local tanim

		if self.SequenceEnabled[ACT_VM_PRIMARYATTACK_SILENCED] and self:GetSilenced() then
			tanim = ACT_VM_PRIMARYATTACK_SILENCED
		elseif self:Clip1() <= self.Primary.AmmoConsumption and self.SequenceEnabled[ACT_VM_PRIMARYATTACK_EMPTY] and not self.ForceEmptyFireOff then
			tanim = ACT_VM_PRIMARYATTACK_EMPTY
		elseif self:Clip1() == 0 and self.SequenceEnabled[ACT_VM_DRYFIRE] and not self.ForceDryFireOff then
			tanim = ACT_VM_DRYFIRE
		elseif self.Akimbo and self.SequenceEnabled[ACT_VM_SECONDARYATTACK] and ((self.AnimCycle == 0 and not self.Akimbo_Inverted) or (self.AnimCycle == 1 and self.Akimbo_Inverted)) then
			tanim = ACT_VM_SECONDARYATTACK
		elseif self:GetIronSights() and self.SequenceEnabled[ACT_VM_PRIMARYATTACK_1] then
			tanim = ACT_VM_PRIMARYATTACK_1
		else
			tanim = ACT_VM_PRIMARYATTACK
		end

		self:SendViewModelAnim(tanim)
		return true, tanim
	end

	if game.SinglePlayer() and SERVER then
		self:CallOnClient("BlowbackFull", "")
	end

	if ifp then
		self:BlowbackFull(ifp)
	end

	self:MakeShellBridge(ifp)
	self:SendViewModelAnim(ACT_VM_BLOWBACK)

	return true, ACT_VM_IDLE
end

function SWEP:BlowbackFull()
	if IsValid(self) then
		self.BlowbackCurrent = 1
		self.BlowbackCurrentRoot = 1
	end
end

function SWEP:ChooseSilenceAnim(val)
	if not self:VMIV() then return end
	self.SequenceEnabled = self.SequenceEnabled or {}

	local tanim = ACT_VM_PRIMARYATTACK
	local success = false

	if val then
		if self.SequenceEnabled[ACT_VM_ATTACH_SILENCER] then
			self:SendViewModelAnim(ACT_VM_ATTACH_SILENCER)
			tanim = ACT_VM_ATTACH_SILENCER
			success = true
		end
	else
		if self.SequenceEnabled[ACT_VM_DETACH_SILENCER] then
			self:SendViewModelAnim(ACT_VM_DETACH_SILENCER)
			tanim = ACT_VM_DETACH_SILENCER
			success = true
		end
	end

	if not success then
		local _, idleact = self:ChooseIdleAnim()
		tanim = idleact or tanim
	end

	return success, tanim
end

function SWEP:ChooseDryFireAnim()
	if not self:VMIV() then return end
	self.SequenceEnabled = self.SequenceEnabled or {}

	local tanim = ACT_VM_DRYFIRE
	local success = true

	if self.SequenceEnabled[ACT_VM_DRYFIRE_SILENCED] and self:GetSilenced() and not self.ForceDryFireOff then
		self:SendViewModelAnim(ACT_VM_DRYFIRE_SILENCED)
		tanim = ACT_VM_DRYFIRE_SILENCED
	else
		if self.SequenceEnabled[ACT_VM_DRYFIRE] and not self.ForceDryFireOff then
			self:SendViewModelAnim(ACT_VM_DRYFIRE)
			tanim = ACT_VM_DRYFIRE
		else
			success = false
			tanim = -1
		end
	end

	return success, tanim
end

SWEP.IronSightHoldTypes = {
	pistol = "revolver",
	smg = "rpg",
	grenade = "melee",
	ar2 = "rpg",
	shotgun = "ar2",
	rpg = "rpg",
	physgun = "physgun",
	crossbow = "ar2",
	melee = "melee2",
	slam = "camera",
	normal = "fist",
	melee2 = "magic",
	knife = "fist",
	duel = "duel",
	camera = "camera",
	magic = "magic",
	revolver = "revolver"
}

SWEP.SprintHoldTypes = {
	pistol = "normal",
	smg = "passive",
	grenade = "normal",
	ar2 = "passive",
	shotgun = "passive",
	rpg = "passive",
	physgun = "normal",
	crossbow = "passive",
	melee = "normal",
	slam = "normal",
	normal = "normal",
	melee2 = "melee",
	knife = "fist",
	duel = "normal",
	camera = "slam",
	magic = "normal",
	revolver = "normal"
}

SWEP.ReloadHoldTypes = {
	pistol = "pistol",
	smg = "smg",
	grenade = "melee",
	ar2 = "ar2",
	shotgun = "shotgun",
	rpg = "ar2",
	physgun = "physgun",
	crossbow = "crossbow",
	melee = "pistol",
	slam = "smg",
	normal = "pistol",
	melee2 = "pistol",
	knife = "pistol",
	duel = "duel",
	camera = "pistol",
	magic = "pistol",
	revolver = "revolver"
}

SWEP.CrouchHoldTypes = {
	ar2 = "ar2",
	smg = "smg",
	rpg = "ar2"
}

SWEP.IronSightHoldTypeOverride = ""
SWEP.SprintHoldTypeOverride = ""
SWEP.ReloadHoldTypeOverride = ""

local dynholdtypecvar = GetConVar("sv_tfa_holdtype_dynamic")

function SWEP:InitHoldType()
	if not self.DefaultHoldType then
		self.DefaultHoldType = self.HoldType or "ar2"
	end

	if not self.SprintHoldType then
		self.SprintHoldType = self.SprintHoldTypes[self.DefaultHoldType] or "passive"
		if self.SprintHoldTypeOverride and self.SprintHoldTypeOverride ~= "" then
			self.SprintHoldType = self.SprintHoldTypeOverride
		end
	end

	if not self.IronHoldType then
		self.IronHoldType = self.IronSightHoldTypes[self.DefaultHoldType] or "rpg"
		if self.IronSightHoldTypeOverride and self.IronSightHoldTypeOverride ~= "" then
			self.IronHoldType = self.IronSightHoldTypeOverride
		end
	end

	if not self.ReloadHoldType then
		self.ReloadHoldType = self.ReloadHoldTypes[self.DefaultHoldType] or "ar2"
		if self.ReloadHoldTypeOverride and self.ReloadHoldTypeOverride ~= "" then
			self.ReloadHoldType = self.ReloadHoldTypeOverride
		end
	end

	if not self.SetCrouchHoldType then
		self.SetCrouchHoldType = true
		self.CrouchHoldType = self.CrouchHoldTypes[self.DefaultHoldType]
		if self.CrouchHoldTypeOverride and self.CrouchHoldTypeOverride ~= "" then
			self.CrouchHoldType = self.CrouchHoldTypeOverride
		end
	end
end

function SWEP:ProcessHoldType()
	local curhold = self:GetHoldType()
	local targhold = self.DefaultHoldType
	local stat = self:GetStatus()

	if dynholdtypecvar and dynholdtypecvar:GetBool() then
		if self:OwnerIsValid() and self:GetOwner():Crouching() and self.CrouchHoldType then
			targhold = self.CrouchHoldType
		else
			if self:GetIronSights() then
				targhold = self.IronHoldType
			elseif self:GetSprinting() or TFA.Enum.HolsterStatus[stat] or self:IsSafety() then
				targhold = self.SprintHoldType
			end

			if TFA.Enum.ReloadStatus[stat] then
				targhold = self.ReloadHoldType
			end
		end
	end

	if targhold and targhold ~= curhold then
		self:SetHoldType(targhold)
	end
end
