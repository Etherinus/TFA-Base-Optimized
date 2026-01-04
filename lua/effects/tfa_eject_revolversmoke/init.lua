local bvec = Vector(0, 0, 0)
local uAng = Angle(90, 0, 0)

local ParticleEmitter = ParticleEmitter
local IsValid = IsValid
local LocalPlayer = LocalPlayer
local EyeAngles = EyeAngles
local VectorRand = VectorRand
local CurTime = CurTime
local math_random = math.random
local math_Rand = math.Rand
local math_rad = math.rad
local math_abs = math.abs
local math_acos = math.acos
local math_deg = math.deg
local math_sqrt = math.sqrt
local math_Clamp = math.Clamp
local math_max = math.max
local math_Approach = math.Approach

function EFFECT:Init(data)
	if not (TFA.GetEJSmokeEnabled and TFA.GetEJSmokeEnabled()) then return end

	local wepEnt = data:GetEntity()
	if not IsValid(wepEnt) then return end

	self.WeaponEntOG = wepEnt
	self.Attachment = data:GetAttachment()
	local dir = data:GetNormal()

	local ownerent = wepEnt.Owner or wepEnt:GetOwner()
	if not IsValid(ownerent) then
		ownerent = wepEnt:GetParent()
	end
	if CLIENT and not IsValid(ownerent) then
		ownerent = LocalPlayer()
	end

	if IsValid(ownerent) and ownerent:IsPlayer() then
		if ownerent ~= LocalPlayer() or ownerent:ShouldDrawLocalPlayer() then
			wepEnt = ownerent:GetActiveWeapon()
			if not IsValid(wepEnt) then return end
		else
			wepEnt = ownerent:GetViewModel()
			local theirweapon = ownerent:GetActiveWeapon()
			if IsValid(theirweapon) and (theirweapon.ViewModelFlip or theirweapon.ViewModelFlipped) then
				self.Flipped = true
			end
			if not IsValid(wepEnt) then return end
		end
	end

	self.WeaponEnt = wepEnt

	if IsValid(self.WeaponEntOG) and self.WeaponEntOG.ShellAttachment then
		local att = self.WeaponEnt:LookupAttachment(self.WeaponEntOG.ShellAttachment)
		if not att or att <= 0 then att = 2 end

		if self.WeaponEntOG.Akimbo then
			att = 4 - (self.WeaponEntOG.AnimCycle or 1)
		end

		self.Attachment = att
	end

	local angpos = self.WeaponEnt:GetAttachment(self.Attachment)
	if not (angpos and angpos.Pos) then
		angpos = { Pos = bvec, Ang = uAng }
	end

	if self.Flipped then
		local tmpang = (dir or angpos.Ang:Forward()):Angle()
		local localang = self.WeaponEnt:WorldToLocalAngles(tmpang)
		localang.y = localang.y + 180
		localang = self.WeaponEnt:LocalToWorldAngles(localang)
		dir = localang:Forward()
	end

	self.vOffset = self:GetTracerShootPos(angpos.Pos, self.WeaponEnt, self.Attachment)
	dir = dir or angpos.Ang:Forward()

	local AddVel = (IsValid(ownerent) and ownerent:GetVelocity()) or bvec
	local dot = dir:GetNormalized():Dot(EyeAngles():Forward())
	local dotang = math_deg(math_acos(math_abs(dot)))
	local halofac = math_sqrt(math_Clamp(1 - (dotang / 90), 0, 1))

	local emitter = ParticleEmitter(self.vOffset)
	if not emitter then return end

	for i = 1, 2 do
		local particle = emitter:Add("effects/scotchmuzzleflash" .. math_random(1, 4), self.vOffset)
		if particle then
			particle:SetVelocity(dir * 4 + 1.05 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(0.125)
			particle:SetStartAlpha(math_Rand(225, 255))
			particle:SetEndAlpha(0)
			particle:SetStartSize(3 * (halofac * 0.8 + 0.2), 0, 1)
			particle:SetEndSize(6 * (halofac * 0.8 + 0.2))
			particle:SetRoll(math_rad(math_Rand(0, 360)))
			particle:SetRollDelta(math_rad(math_Rand(-40, 40)))
			particle:SetColor(255, 218, 97)
			particle:SetLighting(false)
			particle.FollowEnt = self.WeaponEnt
			particle.Att = self.Attachment
			if TFARegPartThink and TFAMuzzlePartFunc then
				TFARegPartThink(particle, TFAMuzzlePartFunc)
			end
		end
	end

	for i = 0, 3 do
		local angoff = dir:Angle()
		angoff:RotateAroundAxis(angoff:Up(), 120)
		local dir2 = angoff:Forward()

		local particle = emitter:Add("effects/scotchmuzzleflash" .. math_random(1, 4), self.vOffset + (dir2 * 0.6 * i))
		if particle then
			particle:SetVelocity((dir2 * 20 * i) + 1.05 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(0.125)
			particle:SetStartAlpha(math_Rand(225, 255))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math_max(5.4 - 0.9 * i, 1) * 0.6)
			particle:SetEndSize(math_max(5.4 - 0.9 * i, 1) * 1.3)
			particle:SetRoll(math_rad(math_Rand(0, 360)))
			particle:SetRollDelta(math_rad(math_Rand(-40, 40)))
			particle:SetColor(255, 218, 97)
			particle:SetLighting(false)
			particle.FollowEnt = self.WeaponEnt
			particle.Att = self.Attachment
			if TFARegPartThink and TFAMuzzlePartFunc then
				TFARegPartThink(particle, TFAMuzzlePartFunc)
			end
			particle:SetPos(vector_origin)
		end
	end

	for i = 0, 3 do
		local angoff = dir:Angle()
		angoff:RotateAroundAxis(angoff:Up(), -120)
		local dir2 = angoff:Forward()

		local particle = emitter:Add("effects/scotchmuzzleflash" .. math_random(1, 4), self.vOffset + (dir2 * 0.6 * i))
		if particle then
			particle:SetVelocity((dir2 * 20 * i) + 1.05 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(0.125)
			particle:SetStartAlpha(math_Rand(225, 255))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math_max(5.4 - 0.9 * i, 1) * 0.6)
			particle:SetEndSize(math_max(5.4 - 0.9 * i, 1) * 1.3)
			particle:SetRoll(math_rad(math_Rand(0, 360)))
			particle:SetRollDelta(math_rad(math_Rand(-40, 40)))
			particle:SetColor(255, 218, 97)
			particle:SetLighting(false)
			particle.FollowEnt = self.WeaponEnt
			particle.Att = self.Attachment
			if TFARegPartThink and TFAMuzzlePartFunc then
				TFARegPartThink(particle, TFAMuzzlePartFunc)
			end
			particle:SetPos(vector_origin)
		end
	end

	for i = 0, 6 do
		local particle = emitter:Add("particles/smokey", self.vOffset + dir * math_Rand(6, 10))
		if particle then
			particle:SetVelocity(VectorRand() * 10 + dir * math_Rand(15, 20) + 1.05 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(math_Rand(0.6, 0.7))
			particle:SetStartAlpha(math_Rand(6, 10))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math_Rand(5, 7))
			particle:SetEndSize(math_Rand(12, 14))
			particle:SetRoll(math_rad(math_Rand(0, 360)))
			particle:SetRollDelta(math_Rand(-0.8, 0.8))
			particle:SetLighting(true)
			particle:SetAirResistance(10)
			particle:SetGravity(Vector(0, 0, 60))
			particle:SetColor(255, 255, 255)
		end
	end

	local sparkcount = math_random(3, 4)

	local function makeSpark(sign)
		for i = 0, sparkcount do
			local side = dir:Angle():Right() * sign
			local particle = emitter:Add("effects/yellowflare", self.vOffset)
			if particle then
				particle:SetVelocity((VectorRand() + Vector(0, 0, 0.3)) * 25 * Vector(0.8, 0.8, 0.6) + side * math_Rand(45, 60) + 1.15 * AddVel)
				particle:SetLifeTime(0)
				particle:SetDieTime(math_Rand(0.25, 0.4))
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(0)
				particle:SetStartSize(0.25)
				particle:SetEndSize(1.0)
				particle:SetRoll(math_rad(math_Rand(0, 360)))
				particle:SetGravity(Vector(0, 0, -50))
				particle:SetAirResistance(40)
				particle:SetStartLength(0.2)
				particle:SetEndLength(0.05)
				particle:SetColor(255, 200, 140)
				particle:SetVelocityScale(true)

				particle:SetThinkFunction(function(pa)
					pa.ranvel = pa.ranvel or (VectorRand() * 4)
					pa.ranvel.x = math_Approach(pa.ranvel.x, math_Rand(-4, 4), 0.5)
					pa.ranvel.y = math_Approach(pa.ranvel.y, math_Rand(-4, 4), 0.5)
					pa.ranvel.z = math_Approach(pa.ranvel.z, math_Rand(-4, 4), 0.5)
					pa:SetVelocity(pa:GetVelocity() + pa.ranvel * 0.6)
					pa:SetNextThink(CurTime() + 0.01)
				end)

				particle:SetNextThink(CurTime() + 0.01)
			end
		end
	end

	makeSpark(1)
	makeSpark(-1)

	if TFA.GetGasEnabled and TFA.GetGasEnabled() then
		for i = 0, 1 do
			local particle = emitter:Add("sprites/heatwave", self.vOffset + (dir * i))
			if particle then
				particle:SetVelocity((dir * 25 * i) + 1.05 * AddVel)
				particle:SetLifeTime(0)
				particle:SetDieTime(math_Rand(0.05, 0.15))
				particle:SetStartAlpha(math_Rand(200, 225))
				particle:SetEndAlpha(0)
				particle:SetStartSize(math_Rand(3, 5))
				particle:SetEndSize(math_Rand(8, 10))
				particle:SetRoll(math_Rand(0, 360))
				particle:SetRollDelta(math_Rand(-2, 2))
				particle:SetAirResistance(5)
				particle:SetGravity(Vector(0, 0, 40))
				particle:SetColor(255, 255, 255)
			end
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
