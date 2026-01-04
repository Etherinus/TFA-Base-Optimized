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

local function rvec(vec)
	vec.x = math.Round(vec.x)
	vec.y = math.Round(vec.y)
	vec.z = math.Round(vec.z)
	return vec
end

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
	if dlight then
		dlight.pos = self.vOffset - ownerent:EyeAngles():Right() * 5 + 1.05 * ownerent:GetVelocity() * FrameTime()
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.brightness = 5
		dlight.Decay = 1750
		dlight.Size = 96
		dlight.DieTime = CurTime() + 0.3
	end

	local emitter = ParticleEmitter(self.vOffset)
	if not emitter then return end

	for i = 1, 2 do
		local particle = emitter:Add("effects/splash" .. tostring(math_random(1, 2)), self.vOffset)
		if particle then
			particle:SetVelocity(dir * 4 + 1.05 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(0.15)
			particle:SetStartAlpha(math_Rand(32, 64))
			particle:SetEndAlpha(0)
			particle:SetStartSize(3 * (halofac * 0.8 + 0.2), 0, 1)
			particle:SetEndSize(8 * (halofac * 0.8 + 0.2))
			particle:SetRoll(math_rad(math_Rand(0, 360)))
			particle:SetRollDelta(math_rad(math_Rand(-40, 40)))
			particle:SetColor(255, 255, 255)
			particle:SetLighting(false)
			particle.FollowEnt = self.WeaponEnt
			particle.Att = self.Attachment
			if TFARegPartThink and TFAMuzzlePartFunc then
				TFARegPartThink(particle, TFAMuzzlePartFunc)
			end
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
