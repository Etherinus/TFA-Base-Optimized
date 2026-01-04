local l_Lerp = function(t, a, b) return a + (b - a) * t end
local l_mathMin = function(a, b) return (a < b) and a or b end
local l_mathMax = function(a, b) return (a > b) and a or b end
local l_ABS = function(a) return (a < 0) and -a or a end
local l_mathClamp = function(t, a, b) return l_mathMax(l_mathMin(t, b), a) end

local l_FT = FrameTime

local is, spr, ist, sprt, ft, hlst, stat, jr_targ
ft = 0.01

SWEP.LastRatio = nil

local mult_cvar = GetConVar("sv_tfa_spread_multiplier")
local dynacc_cvar = GetConVar("sv_tfa_dynamicaccuracy")

SWEP.JumpRatio = 0

function SWEP:CalculateRatios()
	ft = l_FT()
	stat = self:GetStatus()

	is = self:GetIronSights()
	spr = self:GetSprinting()

	ist = is and 1 or 0
	sprt = spr and 1 or 0

	local adstransitionspeed
	if is then
		adstransitionspeed = 15
	elseif spr then
		adstransitionspeed = 7.5
	else
		adstransitionspeed = 12.5
	end

	local ow = self:GetOwner()
	if not IsValid(ow) then return end

	local cr = ow:Crouching() and 1 or 0
	self.CrouchingRatio = self.CrouchingRatio or 0
	if self.CrouchingRatio ~= cr then
		self.CrouchingRatio = l_Lerp(ft * 15, self.CrouchingRatio, cr)
	end

	self.SpreadRatio = self.SpreadRatio or 1
	local sr = (self.Primary and self.Primary.SpreadRecovery) or 0
	local smax = (self.Primary and self.Primary.SpreadMultiplierMax) or 1
	self.SpreadRatio = l_mathClamp(self.SpreadRatio - sr * ft, 1, smax)

	self.IronSightsProgress = self.IronSightsProgress or 0
	if ist ~= self.IronSightsProgress then
		self.IronSightsProgress = l_Lerp(ft * adstransitionspeed, self.IronSightsProgress, ist)
	end

	self.SprintProgress = self.SprintProgress or 0
	if sprt ~= self.SprintProgress then
		self.SprintProgress = l_Lerp(ft * adstransitionspeed, self.SprintProgress, sprt)
	end

	if self.ProceduralHolsterEnabled or self.ProceduralReloadEnabled then
		hlst = ((TFA.Enum.HolsterStatus[stat] and self.ProceduralHolsterEnabled) or (TFA.Enum.ReloadStatus[stat] and self.ProceduralReloadEnabled)) and 1 or 0
		self.ProceduralHolsterProgress = self.ProceduralHolsterProgress or 0
		local pht = tonumber(self.ProceduralHolsterTime) or 0.3
		if pht <= 0 then pht = 0.3 end
		self.ProceduralHolsterProgress = l_Lerp(ft * 10 / pht, self.ProceduralHolsterProgress, hlst)
	end

	self.InspectingProgress = self.InspectingProgress or 0
	self.InspectingProgress = l_Lerp(ft * 10, self.InspectingProgress, self.Inspecting and 1 or 0)

	self.CLIronSightsProgress = self.IronSightsProgress

	jr_targ = l_ABS(ow:GetVelocity().z) * 0.002
	self.JumpRatio = self.JumpRatio or 0
	self.JumpRatio = l_Lerp(ft * 20, self.JumpRatio, jr_targ)
end

SWEP.IronRecoilMultiplier = 0.5
SWEP.CrouchRecoilMultiplier = 0.65
SWEP.JumpRecoilMultiplier = 1.3
SWEP.WallRecoilMultiplier = 1.1
SWEP.ChangeStateRecoilMultiplier = 1.3
SWEP.CrouchAccuracyMultiplier = 0.5
SWEP.ChangeStateAccuracyMultiplier = 1.5
SWEP.JumpAccuracyMultiplier = 2
SWEP.WalkAccuracyMultiplier = 1.35
SWEP.ToCrouchTime = 0.2

local ccon, crec

function SWEP:CalculateConeRecoil()
	local owner = self:GetOwner()
	if not IsValid(owner) then
		return 0, 0
	end

	local dynacc = false
	local isr = self.IronSightsProgress or 0

	if dynacc_cvar and dynacc_cvar:GetBool() and ((self.Primary and self.Primary.NumShots) or 1) <= 1 then
		dynacc = true
	end

	local isr_1 = l_mathClamp(isr * 2, 0, 1)
	local isr_2 = l_mathClamp((isr - 0.5) * 2, 0, 1)

	local acv = (self.Primary and (self.Primary.Spread or self.Primary.Accuracy)) or 0.01
	local recv = ((self.Primary and self.Primary.Recoil) or 0) * 5

	local ironAcc = (self.Primary and self.Primary.IronAccuracy) or acv

	if dynacc then
		ccon = l_Lerp(isr_2, l_Lerp(isr_1, acv, acv * self.ChangeStateAccuracyMultiplier), ironAcc)
		crec = l_Lerp(isr_2, l_Lerp(isr_1, recv, recv * self.ChangeStateRecoilMultiplier), recv * self.IronRecoilMultiplier)
	else
		ccon = l_Lerp(isr, acv, ironAcc)
		crec = l_Lerp(isr, recv, recv * self.IronRecoilMultiplier)
	end

	local cr = self.CrouchingRatio or 0
	local crc_1 = l_mathClamp(cr * 2, 0, 1)
	local crc_2 = l_mathClamp((cr - 0.5) * 2, 0, 1)

	if dynacc then
		ccon = l_Lerp(crc_2, l_Lerp(crc_1, ccon, ccon * self.ChangeStateAccuracyMultiplier), ccon * self.CrouchAccuracyMultiplier)
		crec = l_Lerp(crc_2, l_Lerp(crc_1, crec, ((self.Primary and self.Primary.Recoil) or 0) * self.ChangeStateRecoilMultiplier), crec * self.CrouchRecoilMultiplier)
	end

	local ovel = owner:GetVelocity():Length2D()
	local ws = owner:GetWalkSpeed()
	if ws <= 0 then ws = 1 end

	local vfc_1 = l_mathClamp(ovel / ws, 0, 2)

	if dynacc then
		ccon = l_Lerp(vfc_1, ccon, ccon * self.WalkAccuracyMultiplier)
		crec = l_Lerp(vfc_1, crec, crec * self.WallRecoilMultiplier)
	end

	local jr = self.JumpRatio or 0
	if dynacc then
		ccon = l_Lerp(jr, ccon, ccon * self.JumpAccuracyMultiplier)
		crec = l_Lerp(jr, crec, crec * self.JumpRecoilMultiplier)
	end

	ccon = ccon * (self.SpreadRatio or 1)

	if mult_cvar then
		ccon = ccon * mult_cvar:GetFloat()
	end

	return ccon, crec
end

local righthanded, shouldflip, cl_vm_flip_cv

function SWEP:CalculateViewModelFlip()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if CLIENT and not cl_vm_flip_cv then
		cl_vm_flip_cv = GetConVar("cl_tfa_viewmodel_flip")
	end

	if self.ViewModelFlipDefault == nil then
		self.ViewModelFlipDefault = self.ViewModelFlip
	end

	righthanded = true

	if SERVER and owner:GetInfoNum("cl_tfa_viewmodel_flip", 0) == 1 then
		righthanded = false
	end

	if CLIENT and cl_vm_flip_cv and cl_vm_flip_cv:GetBool() then
		righthanded = false
	end

	shouldflip = self.ViewModelFlipDefault

	if not righthanded then
		shouldflip = not self.ViewModelFlipDefault
	end

	if self.ViewModelFlip ~= shouldflip then
		self.ViewModelFlip = shouldflip
	end
end
