local fx, sp

sp = game.SinglePlayer()

local shellNetCV

function SWEP:EventShell()
	--[[if SERVER and not game.SinglePlayer() then
		net.Start("tfaBaseShellSV")
		net.WriteEntity(self)
		net.SendOmit(self:GetOwner())
	else]]--
	self:MakeShellBridge(IsFirstTimePredicted())
	--end
end

function SWEP:PCFTracer(bul, hitpos, ovrride)
	if bul.PCFTracer then
		self:UpdateMuzzleAttachment()
		local mzp = self:GetMuzzlePos()
		if bul.PenetrationCount > 0 and not ovrride then return end --Taken care of with the pen effect

		if (CLIENT or game.SinglePlayer()) and self.Scoped and self:IsCurrentlyScoped() and self:IsFirstPerson() then
			TFA.ParticleTracer(bul.PCFTracer, self:GetOwner():GetShootPos() - self:GetOwner():EyeAngles():Up() * 5, hitpos, false, 0, -1)
		else
			local vent = self

			if (CLIENT or game.SinglePlayer()) and self:IsFirstPerson() then
				vent = self.OwnerViewModel
			end

			if game.SinglePlayer() and not self:IsFirstPerson() then
				TFA.ParticleTracer(bul.PCFTracer, self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 32, hitpos, false)
			else
				TFA.ParticleTracer(bul.PCFTracer, mzp.Pos, hitpos, false, vent, self.MuzzleAttachmentRaw or 1)
			end
		end
	end
end

function SWEP:MakeShellBridge(ifp)
	if game.SinglePlayer() and CLIENT then return end
	shellNetCV = shellNetCV or GetConVar("sv_tfa_net_shells")
	if SERVER and ( not game.SinglePlayer() ) and not shellNetCV:GetBool() then return end

	if ifp then
		if self.LuaShellEjectDelay > 0 then
			self.LuaShellRequestTime = CurTime() + self.LuaShellEjectDelay / self:NZAnimationSpeed(ACT_VM_PRIMARYATTACK)
		else
			self:MakeShell()
		end
	end
end

SWEP.ShellEffectOverride = nil

function SWEP:MakeShell()
	local shelltype = "tfa_shell"
	if IsValid(self) then
		self:EjectionSmoke(true)
		local vm = (self:IsFirstPerson()) and self.OwnerViewModel or self
		if type(shelltype) ~= "string" or shelltype == "" then return end -- allows to disable shells by setting override to ""

		if IsValid(vm) then
			fx = EffectData()
			local attid = vm:LookupAttachment(self:GetStat("ShellAttachment"))

			if self.Akimbo then
				attid = 3 + self.AnimCycle
			end

			attid = math.Clamp(attid and attid or 2, 1, 127)
			local angpos = vm:GetAttachment(attid)

			if angpos then
				fx:SetEntity(self)
				fx:SetAttachment(attid)
				fx:SetMagnitude(1)
				fx:SetScale(1)
				fx:SetOrigin(angpos.Pos)
				fx:SetNormal(angpos.Ang:Forward())
				if SERVER then
					local crep = RecipientFilter()
					crep:AddPVS(self:GetPos())
					util.Effect(shelltype, fx)
				else
					util.Effect(shelltype, fx)
				end
			end
		end
	end
end

--[[
Function Name:  CleanParticles
Syntax: self:CleanParticles().
Returns:  Nothing.
Notes:    Cleans up particles.
Purpose:  FX
]]--
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

--[[
Function Name:  EjectionSmoke
Syntax: self:EjectionSmoke().
Returns:  Nothing.
Notes:    Puff of smoke on shell attachment.
Purpose:  FX
]]--
function SWEP:EjectionSmoke()
	if TFA.GetEJSmokeEnabled() then
		local vm = self.OwnerViewModel

		if IsValid(vm) then
			local att = vm:LookupAttachment(self.ShellAttachment)

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

			if angpos and angpos.Pos then
				fx = EffectData()
				fx:SetEntity(vm)
				fx:SetOrigin(angpos.Pos)
				fx:SetAttachment(att)
				fx:SetNormal(angpos.Ang:Forward())
				if SERVER then
					local crep = RecipientFilter()
					crep:AddPVS(self:GetPos())
					util.Effect("tfa_shelleject_smoke", fx)
				else
					util.Effect("tfa_shelleject_smoke", fx)
				end
			end
		end
	end
end

--[[
Function Name:  ShootEffectsCustom
Syntax: self:ShootEffectsCustom().
Returns:  Nothing.
Notes:    Calls the proper muzzleflash, muzzle smoke, muzzle light code.
Purpose:  FX
]]--
local culldistancecvar = GetConVar("sv_tfa_worldmodel_culldistance")
local muzzleCV = GetConVar("sv_tfa_net_muzzles")
function SWEP:ShootEffectsCustom( ifp )
	if CLIENT and self:OwnerIsValid() and culldistancecvar and self:GetOwner():GetPos():Distance(LocalPlayer():EyePos()) > culldistancecvar:GetFloat() and culldistancecvar:GetInt() ~= -1 then return end
	if SERVER and ( not sp ) and not muzzleCV:GetBool() then return end
	if self.DoMuzzleFlash ~= nil then
		self.MuzzleFlashEnabled = self.DoMuzzleFlash
		self.DoMuzzleFlash = nil
	end
	if not self.MuzzleFlashEnabled then return end
	ifp = ifp or IsFirstTimePredicted()

	if sp == nil then
		sp = game.SinglePlayer()
	end

	if (SERVER and sp and self.ParticleMuzzleFlash) or (SERVER and not sp) then
		net.Start("tfa_base_muzzle_mp")
		net.WriteEntity(self)

		if (sp) then
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
		local vm = self.Owner:GetViewModel()
		self:UpdateMuzzleAttachment()
		local att = math.max(1, self.MuzzleAttachmentRaw or (sp and vm or self):LookupAttachment(self.MuzzleAttachment))
		if self.Akimbo then
			att = 1 + self.AnimCycle
		end
		self:CleanParticles()
		fx = EffectData()
		fx:SetOrigin(self.Owner:GetShootPos())
		fx:SetNormal(self.Owner:EyeAngles():Forward())
		fx:SetEntity(self)
		fx:SetAttachment(att)
		util.Effect("tfa_muzzlesmoke", fx)

		local fxn = self:GetSilenced() and "tfa_muzzleflash_silenced" or self.MuzzleFlashEffect
		if SERVER then
			local crep = RecipientFilter()
			crep:AddPVS(self:GetOwner():GetShootPos())
			util.Effect(fxn, fx)
		else
			util.Effect(fxn, fx)
		end
	end
end

--[[
Function Name:  CanDustEffect
Syntax: self:CanDustEffect( concise material name ).
Returns:  True/False
Notes:    Used for the impact effect.  Should be used with GetMaterialConcise.
Purpose:  Utility
]]--

function SWEP:CanDustEffect( matv )
	local n = self:GetMaterialConcise(matv )
	if n == "energy" or n == "dirt" or n == "ceramic" or n == "plastic" or n == "wood" then return true end

	return false
end

--[[
Function Name:  CanSparkEffect
Syntax: self:CanSparkEffect( concise material name ).
Returns:  True/False
Notes:    Used for the impact effect.  Should be used with GetMaterialConcise.
Purpose:  Utility
]]--

function SWEP:CanSparkEffect(matv)
	local n = self:GetMaterialConcise(matv)
	if n == "default" or n == "metal" then return true end

	return false
end