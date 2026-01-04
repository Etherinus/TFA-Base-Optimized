local fx
local sp = game.SinglePlayer()

local shellNetCV
local culldistancecvar = GetConVar("sv_tfa_worldmodel_culldistance")
local muzzleCV = GetConVar("sv_tfa_net_muzzles")

function SWEP:EventShell()
	self:MakeShellBridge(IsFirstTimePredicted())
end

function SWEP:PCFTracer(bul, hitpos, ovrride)
	if not bul or not bul.PCFTracer then return end

	self:UpdateMuzzleAttachment()
	local mzp = self:GetMuzzlePos()
	if bul.PenetrationCount and bul.PenetrationCount > 0 and not ovrride then return end

	if (CLIENT or sp) and self.Scoped and self.IsCurrentlyScoped and self:IsCurrentlyScoped() and self.IsFirstPerson and self:IsFirstPerson() then
		TFA.ParticleTracer(bul.PCFTracer, self:GetOwner():GetShootPos() - self:GetOwner():EyeAngles():Up() * 5, hitpos, false, 0, -1)
		return
	end

	local vent = self
	if (CLIENT or sp) and self.IsFirstPerson and self:IsFirstPerson() then
		vent = self.OwnerViewModel
	end

	if sp and self.IsFirstPerson and not self:IsFirstPerson() then
		TFA.ParticleTracer(bul.PCFTracer, self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 32, hitpos, false)
	else
		if not mzp or not mzp.Pos then return end
		TFA.ParticleTracer(bul.PCFTracer, mzp.Pos, hitpos, false, vent, self.MuzzleAttachmentRaw or 1)
	end
end

function SWEP:MakeShellBridge(ifp)
	if sp and CLIENT then return end

	shellNetCV = shellNetCV or GetConVar("sv_tfa_net_shells")
	if SERVER and (not sp) and shellNetCV and not shellNetCV:GetBool() then return end

	if ifp then
		if (self.LuaShellEjectDelay or 0) > 0 then
			local spd = self.NZAnimationSpeed and self:NZAnimationSpeed(ACT_VM_PRIMARYATTACK) or 1
			if spd <= 0 then spd = 1 end
			self.LuaShellRequestTime = CurTime() + self.LuaShellEjectDelay / spd
		else
			self:MakeShell()
		end
	end
end

SWEP.ShellEffectOverride = nil

function SWEP:MakeShell()
	if not IsValid(self) then return end

	self:EjectionSmoke(true)

	local shelltype = self.ShellEffectOverride or "tfa_shell"
	if type(shelltype) ~= "string" then return end
	if shelltype == "" then return end

	local vm = (self.IsFirstPerson and self:IsFirstPerson()) and self.OwnerViewModel or self
	if not IsValid(vm) then return end

	local attName = self.GetStat and self:GetStat("ShellAttachment") or self.ShellAttachment
	local attid

	if isnumber(attName) then
		attid = attName
	else
		attid = vm:LookupAttachment(attName or "")
	end

	if self.Akimbo then
		attid = 3 + (self.AnimCycle or 0)
	end

	attid = math.Clamp(attid or 2, 1, 127)

	local angpos = vm:GetAttachment(attid)
	if not angpos then return end

	fx = EffectData()
	fx:SetEntity(self)
	fx:SetAttachment(attid)
	fx:SetMagnitude(1)
	fx:SetScale(1)
	fx:SetOrigin(angpos.Pos)
	fx:SetNormal(angpos.Ang:Forward())

	util.Effect(shelltype, fx)
end

function SWEP:CleanParticles()
	if not IsValid(self) then return end

	if self.StopParticles then
		self:StopParticles()
	end

	if self.StopParticleEmission then
		self:StopParticleEmission()
	end

	if not self:OwnerIsValid() then return end

	local vm = self.OwnerViewModel
	if IsValid(vm) then
		if vm.StopParticles then
			vm:StopParticles()
		end
		if vm.StopParticleEmission then
			vm:StopParticleEmission()
		end
	end
end

function SWEP:EjectionSmoke()
	if not TFA.GetEJSmokeEnabled() then return end

	local vm = self.OwnerViewModel
	if not IsValid(vm) then return end

	local attName = self.ShellAttachment
	local att

	if isnumber(attName) then
		att = attName
	else
		att = vm:LookupAttachment(attName or "")
	end

	if not att or att <= 0 then
		att = 2
	end

	local oldatt = att

	if self.ShellAttachmentRaw then
		att = self.ShellAttachmentRaw
	end

	local angpos = vm:GetAttachment(att)
	if not angpos then
		att = oldatt
		angpos = vm:GetAttachment(att)
	end
	if not angpos or not angpos.Pos then return end

	fx = EffectData()
	fx:SetEntity(vm)
	fx:SetOrigin(angpos.Pos)
	fx:SetAttachment(att)
	fx:SetNormal(angpos.Ang:Forward())

	util.Effect("tfa_shelleject_smoke", fx)
end

function SWEP:ShootEffectsCustom(ifp)
	if CLIENT and self:OwnerIsValid() and culldistancecvar and culldistancecvar:GetInt() ~= -1 then
		if self:GetOwner():GetPos():Distance(LocalPlayer():EyePos()) > culldistancecvar:GetFloat() then
			return
		end
	end

	if SERVER and (not sp) and muzzleCV and not muzzleCV:GetBool() then return end

	if self.DoMuzzleFlash ~= nil then
		self.MuzzleFlashEnabled = self.DoMuzzleFlash
		self.DoMuzzleFlash = nil
	end

	if not self.MuzzleFlashEnabled then return end

	ifp = ifp or IsFirstTimePredicted()

	if (SERVER and sp and self.ParticleMuzzleFlash) or (SERVER and not sp) then
		net.Start("tfa_base_muzzle_mp")
		net.WriteEntity(self)

		if sp then
			net.Broadcast()
		else
			local crep = RecipientFilter()
			crep:AddPVS(self:GetOwner():GetShootPos())
			crep:RemovePlayer(self:GetOwner())
			net.Send(crep)
		end

		return
	end

	if (CLIENT and ifp and not sp) or (sp and SERVER) then
		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		local vm = owner:GetViewModel()
		self:UpdateMuzzleAttachment()

		local entForLookup = (sp and vm) or self
		local att = math.max(1, self.MuzzleAttachmentRaw or (IsValid(entForLookup) and entForLookup:LookupAttachment(self.MuzzleAttachment) or 1))

		if self.Akimbo then
			att = 1 + (self.AnimCycle or 0)
		end

		self:CleanParticles()

		fx = EffectData()
		fx:SetOrigin(owner:GetShootPos())
		fx:SetNormal(owner:EyeAngles():Forward())
		fx:SetEntity(self)
		fx:SetAttachment(att)

		util.Effect("tfa_muzzlesmoke", fx)

		local fxn = self:GetSilenced() and "tfa_muzzleflash_silenced" or self.MuzzleFlashEffect
		util.Effect(fxn, fx)
	end
end

function SWEP:CanDustEffect(matv)
	local n = self:GetMaterialConcise(matv)
	return n == "energy" or n == "dirt" or n == "ceramic" or n == "plastic" or n == "wood"
end

function SWEP:CanSparkEffect(matv)
	local n = self:GetMaterialConcise(matv)
	return n == "default" or n == "metal"
end
