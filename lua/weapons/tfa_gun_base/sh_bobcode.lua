local stepinterval = 4
local stepintervaloffset = 0
SWEP.customboboffset = Vector(0, 0, 0)


--Bob code
local ftv, ws, rs
local owvel, meetswalkgate, meetssprintgate, walkfactorv, runfactorv, sprintfactorv
local customboboffsetx, customboboffsety, customboboffsetz, mypi, curtimecompensated, runspeed, timehasbeensprinting, tironsightscale
local cl_tfa_viewmodel_centered
if CLIENT then
	cl_tfa_viewmodel_centered = GetConVar("cl_tfa_viewmodel_centered")
end

walkfactorv = 10.25
runfactorv = 18
sprintfactorv = 24

local VecOr = Vector()

function SWEP:DoBobFrame()
	VecOr:Zero()
	ftv = FrameTime()
	ws = self.Owner:GetWalkSpeed()
	rs = self.Owner:GetRunSpeed()
	ftv = ftv * 200 / ws

	if not self.bobtimevar then
		self.bobtimevar = 0
	end

	owvel = self.Owner:GetVelocity():Length()
	meetssprintgate = false
	meetswalkgate = false

	if owvel <= ws * 0.55 then
		meetswalkgate = true
	end

	if owvel > rs * 0.8 then
		meetssprintgate = true
	end
	if self.Sprint_Mode == TFA.Enum.LOCOMOTION_ANI and meetssprintgate then
		meetssprintgate = false
		owvel = math.min(owvel,100)
	end

	if not self.bobtimehasbeensprinting then
		self.bobtimehasbeensprinting = 0
	end

	if not self.tprevvel then
		self.tprevvel = owvel
	end

	if not meetssprintgate then
		self.bobtimehasbeensprinting = math.Approach(self.bobtimehasbeensprinting, 0, ftv / (self.IronSightTime / 2))
	else
		self.bobtimehasbeensprinting = math.Approach(self.bobtimehasbeensprinting, 3, ftv)
	end

	if not self.Owner:IsOnGround() then
		self.bobtimehasbeensprinting = math.Approach(self.bobtimehasbeensprinting, 0, ftv / (5 / 60))
	end

	if cl_tfa_viewmodel_centered:GetBool() then ftv = ftv * 0.5 end

	if owvel > 1 and owvel <= ws * 0.1 and owvel > self.tprevvel then
		if self.Owner:IsOnGround() then
			local val1 = math.Round(self.bobtimevar / stepinterval) * stepinterval + stepintervaloffset
			local val2 = math.Round(self.bobtimevar / stepinterval) * stepinterval - stepintervaloffset

			if math.abs(self.bobtimevar - val1) < math.abs(self.bobtimevar - val2) then
				self.bobtimevar = math.Approach(self.bobtimevar, val1, ftv / (5 / 60))
			else
				self.bobtimevar = math.Approach(self.bobtimevar, val2, ftv / (5 / 60))
			end
		end
	else
		if self.Owner:IsOnGround() then
			self.bobtimevar = self.bobtimevar + ftv * math.max(1, owvel / (runfactorv + (sprintfactorv - runfactorv) * (meetssprintgate and 1 or 0) - (runfactorv - walkfactorv) * (meetswalkgate and 1 or 0)))
		else
			self.bobtimevar = self.bobtimevar + ftv
		end
	end

	self.tprevvel = owvel
end

--[[
Function Name:  CalculateBob
Syntax: self:CalculateBob(position, angle, scale).
Returns:  Position and Angle, corrected for viewbob.  Scale controls how much they're affected.
Notes:  This is really important and slightly messy.
Purpose:  Feature
]]--

function SWEP:CalculateBob(pos, ang, ci, igvmf)
	if not self:OwnerIsValid() then return end

	if not ci then
		ci = 1
	end

	ci = ci * 0.66
	tironsightscale = 1 - 0.6 * self.IronSightsProgress
	owvel = self.Owner:GetVelocity():Length()
	runspeed = self.Owner:GetWalkSpeed()
	curtimecompensated = self.bobtimevar or 0
	timehasbeensprinting = self.bobtimehasbeensprinting or 0

	if not self.BobScaleCustom then
		self.BobScaleCustom = 1
	end

	mypi = 0.5 * 3.14159
	customboboffsetx = math.cos(mypi * (curtimecompensated - 0.5) * 0.5)
	customboboffsetz = math.sin(mypi * (curtimecompensated - 0.5))
	customboboffsety = math.sin(mypi * (curtimecompensated - 0.5) * 3 / 8) * 0.5
	customboboffsetx = customboboffsetx - (math.sin(mypi * (timehasbeensprinting / 2)) * 0.5 + math.sin(mypi * (timehasbeensprinting / 6)) * 2) * math.max(0, (owvel - runspeed * 0.8) / runspeed)
	--[[
	if CLIENT then
		ci = customboboffsetx * (1+ci*self.CLRunSightsProgress)
	else
		ci = customboboffsetx * (1+ci*self:RunSightsRatio())
	end
	]]--
	self.customboboffset.x = customboboffsetx * 1.3
	self.customboboffset.y = customboboffsety
	self.customboboffset.z = customboboffsetz
	self.customboboffset = self.customboboffset * self.BobScaleCustom * 0.45
	local sprintbobfac = math.sqrt(math.Clamp(self.BobScaleCustom - 1, 0, 1))
	local cboboff2 = customboboffsetx * sprintbobfac * 1.5
	self.customboboffset = self.customboboffset * (1 + sprintbobfac / 3)
	pos:Add(self.Owner:EyeAngles():Right() * cboboff2)
	self.customboboffset = self.customboboffset * ci
	if cl_tfa_viewmodel_centered:GetBool() then self.customboboffset.x = 0 end
	pos:Add(ang:Right() * self.customboboffset.x * -1.33)
	pos:Add(ang:Forward() * self.customboboffset.y * -1)
	pos:Add(ang:Up() * self.customboboffset.z)
	ang:RotateAroundAxis(ang:Right(), self.customboboffset.x)
	ang:RotateAroundAxis(ang:Up(), self.customboboffset.y)
	ang:RotateAroundAxis(ang:Forward(), self.customboboffset.z)
	tironsightscale = math.pow(tironsightscale, 2)
	local localisedmove = WorldToLocal(self.Owner:GetVelocity(), self.Owner:GetVelocity():Angle(), VecOr, self.Owner:EyeAngles())

	if igvmf then
		ang:RotateAroundAxis(ang:Forward(), (math.Approach(localisedmove.y, 0, 1) / (runspeed / 8) * tironsightscale) * (ci or 1))
		ang:RotateAroundAxis(ang:Right(), (math.Approach(localisedmove.x, 0, 1) / runspeed) * tironsightscale * (ci or 1))
	else
		ang:RotateAroundAxis(ang:Forward(), (math.Approach(localisedmove.y, 0, 1) / (runspeed / 8) * tironsightscale) * (ci or 1) * (-1 + 2 * (self.ViewModelFlip and 1 or 0)))
		ang:RotateAroundAxis(ang:Right(), (math.Approach(localisedmove.x, 0, 1) / runspeed) * tironsightscale * (ci or 1) * (-1 + 2 * (self.ViewModelFlip and 1 or 0)))
	end

	ang:Normalize()

	return pos, ang
end

--[[
Function Name:  Footstep
Syntax: self:Footstep().  Called for each footstep.
Returns:  Nothing.
Notes:  Corrects the bob time by making it move closer to the downwards position with each footstep.
Purpose:  Feature
]]--
local val1, val2
function SWEP:Footstep()

	if not self.bobtimevar then
		self.bobtimevar = 0
	end

	val1 = math.Round(self.bobtimevar / stepinterval) * stepinterval + stepintervaloffset
	val2 = math.Round(self.bobtimevar / stepinterval) * stepinterval - stepintervaloffset
	owvel = self.Owner:GetVelocity():Length()

	if owvel > self.Owner:GetWalkSpeed() * 0.2 then
		if math.abs(self.bobtimevar - val1) < math.abs(self.bobtimevar - val2) then
			self.bobtimevar = math.Approach(self.bobtimevar, val1, 0.15)
		else
			self.bobtimevar = math.Approach(self.bobtimevar, val2, 0.15)
		end
	end
end
