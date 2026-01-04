local function rvec(vec)
	vec.x = math.Round(vec.x)
	vec.y = math.Round(vec.y)
	vec.z = math.Round(vec.z)
	return vec
end

local blankvec = Vector(0, 0, 0)

local ParticleEmitter = ParticleEmitter
local DynamicLight = DynamicLight
local IsValid = IsValid
local LocalPlayer = LocalPlayer
local EyeAngles = EyeAngles
local Entity = Entity
local player_GetByID = player.GetByID
local CurTime = CurTime
local FrameTime = FrameTime
local VectorRand = VectorRand
local math_random = math.random
local math_Rand = math.Rand
local math_abs = math.abs
local math_acos = math.acos
local math_deg = math.deg
local math_Clamp = math.Clamp
local math_rad = math.rad
local math_max = math.max

function EFFECT:Init(data)
	self.StartPacket = data:GetStart()
	self.Attachment = data:GetAttachment()

	local AddVel = vector_origin
	if LocalPlayer and IsValid(LocalPlayer()) then
		AddVel = LocalPlayer():GetVelocity()
	end
	if game.SinglePlayer() then
		AddVel = Entity(1):GetVelocity()
	end

	self.Position = data:GetOrigin()
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()

	local wepent = Entity(math.Round(self.StartPacket.z))
	local ownerent = player_GetByID(math.Round(self.StartPacket.x))
	local serverside = (math.Round(self.StartPacket.y) == 1)

	if IsValid(wepent) and ((wepent.IsFirstPerson and not wepent:IsFirstPerson()) or serverside) then
		data:SetEntity(wepent)
		self.Position = blankvec
	end

	if serverside and IsValid(ownerent) then
		if LocalPlayer() == ownerent then return end
		AddVel = ownerent:GetVelocity()
	end

	if (not self.Position) or (rvec(self.Position) == blankvec) then
		self.WeaponEnt = data:GetEntity()
		self.Attachment = data:GetAttachment()

		if self.WeaponEnt and IsValid(self.WeaponEnt) then
			local rpos = self.WeaponEnt:GetAttachment(self.Attachment)
			if rpos and rpos.Pos then
				self.Position = rpos.Pos
				if data:GetNormal() == vector_origin then
					self.Forward = rpos.Ang:Up()
					self.Angle = self.Forward:Angle()
					self.Right = self.Angle:Right()
				end
			end
		end
	end

	self.vOffset = self.Position
	local dir = self.Forward
	AddVel = AddVel * 0.05

	local dot = dir:GetNormalized():Dot(EyeAngles():Forward())
	local dotang = math_deg(math_acos(math_abs(dot)))
	local halofac = math_Clamp(1 - (dotang / 90), 0, 1)

	if CLIENT and not IsValid(ownerent) then
		ownerent = LocalPlayer()
	end

	local dlight = IsValid(ownerent) and DynamicLight(ownerent:EntIndex()) or DynamicLight(0)
	if dlight and IsValid(ownerent) then
		dlight.pos = self.vOffset - ownerent:EyeAngles():Right() * 5 + 1.05 * ownerent:GetVelocity() * FrameTime()
		dlight.r = 255
		dlight.g = 192
		dlight.b = 64
		dlight.brightness = 4
		dlight.Decay = 1750
		dlight.Size = 96
		dlight.DieTime = CurTime() + 0.3
	end

	local emitter = ParticleEmitter(self.vOffset)
	if not emitter then return end

	for i = 0, 4 do
		local particle = emitter:Add("effects/scotchmuzzleflash" .. math_random(1, 4), self.vOffset)
		if particle then
			particle:SetVelocity(dir * 4 + 1.05 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(0.1)
			particle:SetStartAlpha(math_Rand(225, 255))
			particle:SetEndAlpha(0)
			particle:SetStartSize(7.5 * (halofac * 0.8 + 0.2), 0, 1)
			particle:SetEndSize(0)

			local deg = math_Rand(-180, 180)
			particle:SetRoll(math_rad(deg))
			particle:SetRollDelta(math_sqrt(math_abs(math_Clamp(deg, -90, 90))) / 9)

			particle:SetColor(255, 218, 97)
			particle:SetLighting(false)
			particle.FollowEnt = self.WeaponEnt
			particle.Att = self.Attachment
			if TFARegPartThink and TFAMuzzlePartFunc then
				TFARegPartThink(particle, TFAMuzzlePartFunc)
			end
		end
	end

	for i = 0, 4 do
		local particle = emitter:Add("particles/flamelet" .. math_random(1, 5), self.vOffset + (dir * 0.8 * i))
		if particle then
			particle:SetVelocity((dir * 6 * i) + 1.05 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(0.1)
			particle:SetStartAlpha(math_Rand(200, 255))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math_max(3.8 - 0.65 * i, 1))
			particle:SetEndSize(1)
			particle:SetRoll(math_Rand(0, 360))
			particle:SetRollDelta(math_Rand(-10, 10))
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
		local particle = emitter:Add("particles/smokey", self.vOffset + dir * math_Rand(3, 6))
		if particle then
			particle:SetVelocity(VectorRand() * 5 + dir * math_Rand(13, 20) + 1.05 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(0.5)
			particle:SetStartAlpha(math_Rand(5, 15))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math_Rand(3, 5))
			particle:SetEndSize(math_Rand(2, 5))
			particle:SetRoll(math_Rand(0, 360))
			particle:SetRollDelta(math_Rand(-0.8, 0.8))
			particle:SetLighting(true)
			particle:SetAirResistance(10)
			particle:SetGravity(Vector(0, 0, 60))
			particle:SetColor(255, 255, 255)
		end
	end

	local sparkcount = math_random(2, 3)
	for i = 0, sparkcount do
		local particle = emitter:Add("effects/yellowflare", self.Position)
		if particle then
			particle:SetVelocity((VectorRand() + Vector(0, 0, 0.3)) * 15 * Vector(0.8, 0.8, 0.6) + dir * math_Rand(45, 60) + 1.15 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(math_Rand(0.25, 0.4))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(0.35)
			particle:SetEndSize(1.15)
			particle:SetRoll(math_rad(math_Rand(0, 360)))
			particle:SetGravity(Vector(0, 0, -50))
			particle:SetAirResistance(40)
			particle:SetStartLength(0.2)
			particle:SetEndLength(0.05)
			particle:SetColor(255, 200, 140)
			particle:SetVelocityScale(true)

			particle:SetThinkFunction(function(pa)
				pa.ranvel = pa.ranvel or (VectorRand() * 4)
				pa.ranvel.x = math.Approach(pa.ranvel.x, math_Rand(-4, 4), 0.5)
				pa.ranvel.y = math.Approach(pa.ranvel.y, math_Rand(-4, 4), 0.5)
				pa.ranvel.z = math.Approach(pa.ranvel.z, math_Rand(-4, 4), 0.5)
				pa:SetVelocity(pa:GetVelocity() + pa.ranvel * 0.5)
				pa:SetNextThink(CurTime() + 0.01)
			end)

			particle:SetNextThink(CurTime() + 0.01)
		end
	end

	if TFA.GetGasEnabled and TFA.GetGasEnabled() then
		for i = 0, 2 do
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
				particle.FollowEnt = self.WeaponEnt
				particle.Att = self.Attachment
				if TFARegPartThink and TFAMuzzlePartFunc then
					TFARegPartThink(particle, TFAMuzzlePartFunc)
				end
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
