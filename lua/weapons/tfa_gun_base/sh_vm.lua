local l_Lerp = function(t, a, b) return a + (b - a) * t end
local l_mathMin = function(a, b) return (a < b) and a or b end
local l_mathMax = function(a, b) return (a > b) and a or b end
local l_ABS = function(a) return (a < 0) and -a or a end
local l_mathClamp = function(t, a, b) return l_mathMax(l_mathMin(t, b), a) end

local l_mathApproach = function(a, b, delta)
	if a < b then
		return l_mathMin(a + l_ABS(delta), b)
	end
	return l_mathMax(a - l_ABS(delta), b)
end

local l_NormalizeAngle = math.NormalizeAngle

local function util_NormalizeAngles(a)
	a.p = l_NormalizeAngle(a.p)
	a.y = l_NormalizeAngle(a.y)
	a.r = l_NormalizeAngle(a.r)
	return a
end

local vm_offset_pos = Vector()
local vm_offset_ang = Angle()

local l_FT = FrameTime
local host_timescale_cv = GetConVar("host_timescale")
local sv_cheats_cv = GetConVar("sv_cheats")

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

local target_pos = Vector()
local target_ang = Vector()
local adstransitionspeed, hls

local flip_vec = Vector(-1, 1, 1)
local flip_ang = Vector(1, -1, -1)

local cl_tfa_viewmodel_offset_x
local cl_tfa_viewmodel_offset_y
local cl_tfa_viewmodel_offset_z
local cl_tfa_viewmodel_centered
local fovmod_add
local fovmod_mult

if CLIENT then
	cl_tfa_viewmodel_offset_x = GetConVar("cl_tfa_viewmodel_offset_x")
	cl_tfa_viewmodel_offset_y = GetConVar("cl_tfa_viewmodel_offset_y")
	cl_tfa_viewmodel_offset_z = GetConVar("cl_tfa_viewmodel_offset_z")
	cl_tfa_viewmodel_centered = GetConVar("cl_tfa_viewmodel_centered")
	fovmod_add = GetConVar("cl_tfa_viewmodel_offset_fov")
	fovmod_mult = GetConVar("cl_tfa_viewmodel_multiplier_fov")
end

local centered_sprintpos = Vector(0, -1, 1)
local centered_sprintang = Vector(-15, 0, 0)

function SWEP:CalculateViewModelOffset()
	local ft = (TFA and TFA.FrameTime and TFA.FrameTime()) or l_FT()

	if self.VMPos_Additive then
		target_pos:Zero()
		target_ang:Zero()
	else
		local vmp = self.VMPos or vector_origin
		local vma = self.VMAng or vector_origin
		target_pos:Set(vmp)
		target_ang:Set(vma)
	end

	adstransitionspeed = 10

	local is = self:GetIronSights()
	local spr = self:GetSprinting()
	local stat = self:GetStatus()

	hls = TFA.Enum.HolsterStatus[stat] and self.ProceduralHolsterEnabled

	if hls then
		target_pos:Set(self.ProceduralHolsterPos or vector_origin)
		target_ang:Set(self.ProceduralHolsterAng or vector_origin)

		if self.ViewModelFlip then
			target_pos:Mul(flip_vec)
			target_ang:Mul(flip_ang)
		end

		local pht = tonumber(self.ProceduralHolsterTime) or 0.3
		adstransitionspeed = pht * 15
	elseif is and (self.Sights_Mode == TFA.Enum.LOCOMOTION_LUA or self.Sights_Mode == TFA.Enum.LOCOMOTION_HYBRID) then
		target_pos:Set(self.IronSightsPos or self.SightsPos or vector_origin)
		target_ang:Set(self.IronSightsAng or self.SightsAng or vector_origin)
		adstransitionspeed = 15
	elseif (spr or self:IsSafety()) and (self.Sprint_Mode == TFA.Enum.LOCOMOTION_LUA or self.Sprint_Mode == TFA.Enum.LOCOMOTION_HYBRID) and stat ~= TFA.Enum.STATUS_FIDGET and stat ~= TFA.Enum.STATUS_BASHING then
		if CLIENT and cl_tfa_viewmodel_centered and cl_tfa_viewmodel_centered:GetBool() then
			self.RunSightsPos = centered_sprintpos
			self.RunSightsAng = centered_sprintang
		end
		target_pos:Set(self.RunSightsPos or vector_origin)
		target_ang:Set(self.RunSightsAng or vector_origin)
		adstransitionspeed = 7.5
	end

	if CLIENT and cl_tfa_viewmodel_offset_x and not is then
		if cl_tfa_viewmodel_centered and cl_tfa_viewmodel_centered:GetBool() and self.IronSightsPos then
			target_pos.x = target_pos.x + (self.IronSightsPos.x or 0)
			if self.IronSightsAng then
				target_ang.y = target_ang.y + (self.IronSightsAng.y or 0)
			end
			target_pos.z = target_pos.z - 3
		end

		target_pos.x = target_pos.x + (cl_tfa_viewmodel_offset_x:GetFloat() or 0)
		target_pos.y = target_pos.y + ((cl_tfa_viewmodel_offset_y and cl_tfa_viewmodel_offset_y:GetFloat()) or 0)
		target_pos.z = target_pos.z + ((cl_tfa_viewmodel_offset_z and cl_tfa_viewmodel_offset_z:GetFloat()) or 0)
	end

	if self.Inspecting then
		if not self.InspectPos then
			self.InspectPos = (self.InspectPosDef or vector_origin) * 1
			if self.ViewModelFlip then
				self.InspectPos.x = self.InspectPos.x * -1
			end
		end

		if not self.InspectAng then
			self.InspectAng = (self.InspectAngDef or vector_origin) * 1
			if self.ViewModelFlip then
				self.InspectAng.x = (self.InspectAngDef and self.InspectAngDef.x) or self.InspectAng.x
				self.InspectAng.y = ((self.InspectAngDef and self.InspectAngDef.y) or self.InspectAng.y) * -1
				self.InspectAng.z = ((self.InspectAngDef and self.InspectAngDef.z) or self.InspectAng.z) * -1
			end
		end

		target_pos:Set(self.InspectPos)
		target_ang:Set(self.InspectAng)
		adstransitionspeed = 10
	end

	vm_offset_pos.x = math.Approach(vm_offset_pos.x, target_pos.x, (target_pos.x - vm_offset_pos.x) * ft * adstransitionspeed)
	vm_offset_pos.y = math.Approach(vm_offset_pos.y, target_pos.y, (target_pos.y - vm_offset_pos.y) * ft * adstransitionspeed)
	vm_offset_pos.z = math.Approach(vm_offset_pos.z, target_pos.z, (target_pos.z - vm_offset_pos.z) * ft * adstransitionspeed)

	vm_offset_ang.p = math.ApproachAngle(vm_offset_ang.p, target_ang.x, math.AngleDifference(target_ang.x, vm_offset_ang.p) * ft * adstransitionspeed)
	vm_offset_ang.y = math.ApproachAngle(vm_offset_ang.y, target_ang.y, math.AngleDifference(target_ang.y, vm_offset_ang.y) * ft * adstransitionspeed)
	vm_offset_ang.r = math.ApproachAngle(vm_offset_ang.r, target_ang.z, math.AngleDifference(target_ang.z, vm_offset_ang.r) * ft * adstransitionspeed)

	self:DoBobFrame()
end

local oldang = Angle()
local anga = Angle()
local angb = Angle()
local angc = Angle()

local posfac = 0.75
local gunswaycvar = GetConVar("cl_tfa_gunbob_intensity")

function SWEP:Sway(pos, ang)
	if not self:OwnerIsValid() then return pos, ang end

	local owner = self:GetOwner()
	if not IsValid(owner) then return pos, ang end

	local nowSys = SysTime()
	local lastSys = self.LastSysT or nowSys
	local rft = (nowSys - lastSys) * game.GetTimeScale()

	local ft = l_FT()
	if rft > ft then
		rft = ft
	end

	rft = l_mathClamp(rft, 0, 1 / 30)

	if sv_cheats_cv and sv_cheats_cv:GetBool() and host_timescale_cv and host_timescale_cv:GetFloat() < 1 then
		rft = rft * host_timescale_cv:GetFloat()
	end

	self.LastSysT = nowSys

	ang:Normalize()

	local bobint = (gunswaycvar and gunswaycvar:GetFloat()) or 1
	local isr = tonumber(self.IronSightsProgress) or 0

	local angrange = l_Lerp(isr, 7.5, 2.5) * bobint
	local rate = l_Lerp(isr, 15, 30)
	local fac = l_Lerp(isr, 0.6, 0.15)

	local eye = owner:EyeAngles()
	anga = eye - oldang
	oldang = eye

	angb.y = angb.y + (0 - angb.y) * rft * 5
	angb.p = angb.p + (0 - angb.p) * rft * 5

	if angb.y < 50 and anga.y > 0 and anga.y < 25 then
		angb.y = angb.y + anga.y / 5
	end
	if angb.y > -50 and anga.y < 0 and anga.y > -25 then
		angb.y = angb.y + anga.y / 5
	end

	if angb.p < 50 and anga.p < 0 and anga.p > -25 then
		angb.p = angb.p - anga.p / 5
	end
	if angb.p > -50 and anga.p > 0 and anga.p < 25 then
		angb.p = angb.p - anga.p / 5
	end

	angb.p = l_mathClamp(angb.p, -angrange, angrange)
	angb.y = l_mathClamp(angb.y, -angrange, angrange)

	angc.y = angc.y + (angb.y / 15 - angc.y) * rft * rate
	angc.p = angc.p + (angb.p / 15 - angc.p) * rft * rate

	local flipMul = self.ViewModelFlip and -1 or 1

	ang:RotateAroundAxis(oldang:Up(), angc.y * 15 * flipMul * fac)
	ang:RotateAroundAxis(oldang:Right(), angc.p * 15 * fac)
	ang:RotateAroundAxis(oldang:Forward(), angc.y * 10 * fac)

	pos:Add(oldang:Right() * angc.y * posfac)
	pos:Add(oldang:Up() * -angc.p * posfac)

	return pos, util_NormalizeAngles(ang)
end

local gunbob_intensity_cvar = GetConVar("cl_tfa_gunbob_intensity")
local vmfov

function SWEP:GetViewModelPosition(pos, ang)
	local owner = self:GetOwner()
	if not IsValid(owner) then return pos, ang end

	local ws = owner:GetWalkSpeed()
	if ws <= 0 then ws = 1 end

	local vel = owner:GetVelocity():Length()
	local walkFrac = math.min(vel / ws, 1)

	local isr = tonumber(self.IronSightsProgress) or 0
	local spr = tonumber(self.SprintProgress) or 0

	local ironBobMult = tonumber(self.IronBobMult) or 1
	local ironBobMultWalk = tonumber(self.IronBobMultWalk) or ironBobMult
	local sprintBobMult = tonumber(self.SprintBobMult) or 1

	self.BobScaleCustom = l_Lerp(isr, 1, l_Lerp(walkFrac, ironBobMult, ironBobMultWalk))
	self.BobScaleCustom = l_Lerp(spr, self.BobScaleCustom, sprintBobMult)

	local gunbobintensity = ((gunbob_intensity_cvar and gunbob_intensity_cvar:GetFloat()) or 1) * 0.65 * 0.66
	if self.Idle_Mode == TFA.Enum.IDLE_LUA or self.Idle_Mode == TFA.Enum.IDLE_BOTH then
		pos, ang = self:CalculateBob(pos, ang, gunbobintensity)
	end

	if not ang then return end

	if not self.ogviewmodelfov then
		self.ogviewmodelfov = self.ViewModelFOV
	end

	if CLIENT and fovmod_mult and fovmod_add then
		vmfov = self.ogviewmodelfov * fovmod_mult:GetFloat()
		vmfov = vmfov + fovmod_add:GetFloat()
		self.ViewModelFOV = vmfov
	end

	local vmp = self.VMPos or vector_origin
	local vma = self.VMAng or vector_origin

	pos:Add(ang:Right() * vmp.x)
	pos:Add(ang:Forward() * vmp.y)
	pos:Add(ang:Up() * vmp.z)

	ang:RotateAroundAxis(ang:Right(), vma.x)
	ang:RotateAroundAxis(ang:Up(), vma.y)
	ang:RotateAroundAxis(ang:Forward(), vma.z)

	pos, ang = self:Sway(pos, ang)

	ang:RotateAroundAxis(ang:Right(), vm_offset_ang.p)
	ang:RotateAroundAxis(ang:Up(), vm_offset_ang.y)
	ang:RotateAroundAxis(ang:Forward(), vm_offset_ang.r)

	local isIron = self:GetIronSights() and 1 or 0
	local flipMul = self.ViewModelFlip and 1 or -1
	local curve = 1 - math.abs(0.5 - isr) * 2
	ang:RotateAroundAxis(ang:Forward(), -7.5 * curve * (isIron == 1 and 1 or 0.5) * flipMul)

	pos:Add(ang:Right() * vm_offset_pos.x)
	pos:Add(ang:Forward() * vm_offset_pos.y)
	pos:Add(ang:Up() * vm_offset_pos.z)

	if self.BlowbackEnabled and (tonumber(self.BlowbackCurrentRoot) or 0) > 0.01 then
		local bbv = self.BlowbackVector or vector_origin
		local bbr = tonumber(self.BlowbackCurrentRoot) or 0
		pos:Add(ang:Right() * bbv.x * bbr)
		pos:Add(ang:Forward() * bbv.y * bbr)
		pos:Add(ang:Up() * bbv.z * bbr)
	end

	if self:GetHidden() then
		pos.z = -10000
	end

	return pos, ang
end
