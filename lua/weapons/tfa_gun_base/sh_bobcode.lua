local stepinterval = 4
local stepintervaloffset = 0

SWEP.customboboffset = SWEP.customboboffset or Vector(0, 0, 0)

local ftv, ws, rs
local owvel, meetswalkgate, meetssprintgate
local customboboffsetx, customboboffsety, customboboffsetz
local mypi, curtimecompensated, runspeed, timehasbeensprinting, tironsightscale

local cl_tfa_viewmodel_centered
if CLIENT then
	cl_tfa_viewmodel_centered = GetConVar("cl_tfa_viewmodel_centered")
end

local walkfactorv = 10.25
local runfactorv = 18
local sprintfactorv = 24

local VecOr = Vector(0, 0, 0)

local m_Abs = math.abs
local m_Max = math.max
local m_Min = math.min
local m_Sqrt = math.sqrt
local m_Sin = math.sin
local m_Cos = math.cos
local m_Pow = math.pow
local m_Approach = math.Approach
local m_Clamp = math.Clamp
local m_Round = math.Round

local l_FrameTime = FrameTime
local l_WorldToLocal = WorldToLocal

function SWEP:DoBobFrame()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	VecOr:Zero()

	ftv = l_FrameTime()

	ws = owner:GetWalkSpeed() or 200
	rs = owner:GetRunSpeed() or 400
	ws = m_Max(ws, 1)

	ftv = ftv * 200 / ws

	if self.bobtimevar == nil then
		self.bobtimevar = 0
	end

	owvel = owner:GetVelocity():Length()
	meetswalkgate = owvel <= ws * 0.55
	meetssprintgate = owvel > rs * 0.8

	if self.Sprint_Mode == TFA.Enum.LOCOMOTION_ANI and meetssprintgate then
		meetssprintgate = false
		owvel = m_Min(owvel, 100)
	end

	if self.bobtimehasbeensprinting == nil then
		self.bobtimehasbeensprinting = 0
	end

	if self.tprevvel == nil then
		self.tprevvel = owvel
	end

	if not meetssprintgate then
		local ist = tonumber(self.IronSightTime) or 0.3
		local denom = ist * 0.5
		if denom <= 0 then denom = 0.15 end
		self.bobtimehasbeensprinting = m_Approach(self.bobtimehasbeensprinting, 0, ftv / denom)
	else
		self.bobtimehasbeensprinting = m_Approach(self.bobtimehasbeensprinting, 3, ftv)
	end

	if not owner:IsOnGround() then
		self.bobtimehasbeensprinting = m_Approach(self.bobtimehasbeensprinting, 0, ftv / (5 / 60))
	end

	if CLIENT and cl_tfa_viewmodel_centered and cl_tfa_viewmodel_centered:GetBool() then
		ftv = ftv * 0.5
	end

	if owvel > 1 and owvel <= ws * 0.1 and owvel > self.tprevvel then
		if owner:IsOnGround() then
			local base = m_Round(self.bobtimevar / stepinterval) * stepinterval
			local v1 = base + stepintervaloffset
			local v2 = base - stepintervaloffset

			if m_Abs(self.bobtimevar - v1) < m_Abs(self.bobtimevar - v2) then
				self.bobtimevar = m_Approach(self.bobtimevar, v1, ftv / (5 / 60))
			else
				self.bobtimevar = m_Approach(self.bobtimevar, v2, ftv / (5 / 60))
			end
		end
	else
		if owner:IsOnGround() then
			local sprintmul = meetssprintgate and 1 or 0
			local walkmul = meetswalkgate and 1 or 0
			local denom = runfactorv + (sprintfactorv - runfactorv) * sprintmul - (runfactorv - walkfactorv) * walkmul
			if denom <= 0 then denom = 1 end
			self.bobtimevar = self.bobtimevar + ftv * m_Max(1, owvel / denom)
		else
			self.bobtimevar = self.bobtimevar + ftv
		end
	end

	self.tprevvel = owvel
end

function SWEP:CalculateBob(pos, ang, ci, igvmf)
	if not self:OwnerIsValid() then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	if not pos or not ang then return end

	ci = tonumber(ci) or 1
	ci = ci * 0.66

	local isp = tonumber(self.IronSightsProgress) or 0
	tironsightscale = 1 - 0.6 * isp

	owvel = owner:GetVelocity():Length()
	runspeed = owner:GetWalkSpeed() or 200
	runspeed = m_Max(runspeed, 1)

	curtimecompensated = self.bobtimevar or 0
	timehasbeensprinting = self.bobtimehasbeensprinting or 0

	if self.BobScaleCustom == nil then
		self.BobScaleCustom = 1
	end

	mypi = 0.5 * 3.14159
	customboboffsetx = m_Cos(mypi * (curtimecompensated - 0.5) * 0.5)
	customboboffsetz = m_Sin(mypi * (curtimecompensated - 0.5))
	customboboffsety = m_Sin(mypi * (curtimecompensated - 0.5) * 3 / 8) * 0.5

	customboboffsetx = customboboffsetx - (m_Sin(mypi * (timehasbeensprinting / 2)) * 0.5 + m_Sin(mypi * (timehasbeensprinting / 6)) * 2) * m_Max(0, (owvel - runspeed * 0.8) / runspeed)

	local cb = self.customboboffset
	if not cb then
		cb = Vector(0, 0, 0)
		self.customboboffset = cb
	end

	cb.x = customboboffsetx * 1.3
	cb.y = customboboffsety
	cb.z = customboboffsetz

	local bobScale = (tonumber(self.BobScaleCustom) or 1) * 0.45
	cb:Mul(bobScale)

	local sprintbobfac = m_Sqrt(m_Clamp((tonumber(self.BobScaleCustom) or 1) - 1, 0, 1))
	local cboboff2 = customboboffsetx * sprintbobfac * 1.5

	cb:Mul(1 + sprintbobfac / 3)

	local eyeang = owner:EyeAngles()
	pos:Add(eyeang:Right() * cboboff2)

	cb:Mul(ci)

	if CLIENT and cl_tfa_viewmodel_centered and cl_tfa_viewmodel_centered:GetBool() then
		cb.x = 0
	end

	pos:Add(ang:Right() * cb.x * -1.33)
	pos:Add(ang:Forward() * cb.y * -1)
	pos:Add(ang:Up() * cb.z)

	ang:RotateAroundAxis(ang:Right(), cb.x)
	ang:RotateAroundAxis(ang:Up(), cb.y)
	ang:RotateAroundAxis(ang:Forward(), cb.z)

	tironsightscale = m_Pow(tironsightscale, 2)

	local vel = owner:GetVelocity()
	local localisedmove = l_WorldToLocal(vel, vel:Angle(), VecOr, eyeang)

	local yv = (math.Approach(localisedmove.y, 0, 1) / (runspeed / 8)) * tironsightscale * ci
	local xv = (math.Approach(localisedmove.x, 0, 1) / runspeed) * tironsightscale * ci

	if not igvmf then
		local sign = self.ViewModelFlip and 1 or -1
		yv = yv * sign
		xv = xv * sign
	end

	ang:RotateAroundAxis(ang:Forward(), yv)
	ang:RotateAroundAxis(ang:Right(), xv)

	ang:Normalize()
	return pos, ang
end

function SWEP:Footstep()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if self.bobtimevar == nil then
		self.bobtimevar = 0
	end

	local base = m_Round(self.bobtimevar / stepinterval) * stepinterval
	local v1 = base + stepintervaloffset
	local v2 = base - stepintervaloffset

	owvel = owner:GetVelocity():Length()

	if owvel > (owner:GetWalkSpeed() or 200) * 0.2 then
		if m_Abs(self.bobtimevar - v1) < m_Abs(self.bobtimevar - v2) then
			self.bobtimevar = m_Approach(self.bobtimevar, v1, 0.15)
		else
			self.bobtimevar = m_Approach(self.bobtimevar, v2, 0.15)
		end
	end
end
