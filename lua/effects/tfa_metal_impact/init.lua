local gravity_cv = GetConVar("sv_gravity")

local ParticleEmitter = ParticleEmitter
local VectorRand = VectorRand
local CurTime = CurTime
local math_random = math.random
local math_Rand = math.Rand
local Lerp = Lerp

EFFECT.VelocityRandom = 0.25
EFFECT.VelocityMin = 95
EFFECT.VelocityMax = 125
EFFECT.ParticleCountMin = 4
EFFECT.ParticleCountMax = 7
EFFECT.ParticleLife = 1.3

function EFFECT:Init(data)
	self.StartPos = data:GetOrigin()
	self.Dir = data:GetNormal()
	self.LifeTime = 0.1
	self.DieTime = CurTime() + self.LifeTime
	self.PartMult = 0.2
	local grav = gravity_cv and gravity_cv:GetFloat() or 600
	self.Grav = Vector(0, 0, -grav)
	self.SparkLife = 1

	local emitter = ParticleEmitter(self.StartPos)
	if not emitter then return end

	local partcount = math_random(self.ParticleCountMin, self.ParticleCountMax)

	for i = 1, partcount do
		local part = emitter:Add("effects/yellowflare", self.StartPos)
		if part then
			part:SetVelocity(Lerp(self.VelocityRandom, self.Dir, VectorRand()) * math_Rand(self.VelocityMin, self.VelocityMax))
			part:SetDieTime(math_Rand(0.25, 1) * self.SparkLife)
			part:SetStartAlpha(255)
			part:SetStartSize(math_Rand(2, 4))
			part:SetEndSize(0)
			part:SetRoll(0)
			part:SetGravity(self.Grav)
			part:SetCollide(true)
			part:SetBounce(0.55)
			part:SetAirResistance(0.5)
			part:SetStartLength(0.2)
			part:SetEndLength(0)
			part:SetVelocityScale(true)
		end
	end

	local impact = emitter:Add("effects/yellowflare", self.StartPos)
	if impact then
		impact:SetStartAlpha(255)
		impact:SetStartSize(15 * self.PartMult)
		impact:SetDieTime(self.LifeTime)
		impact:SetEndSize(0)
		impact:SetEndAlpha(0)
		impact:SetRoll(math_Rand(0, 360))
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	return false
end
