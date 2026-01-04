local ParticleEmitter = ParticleEmitter
local VectorRand = VectorRand
local CurTime = CurTime
local math_random = math.random
local math_Rand = math.Rand

function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local emitter = ParticleEmitter(pos)
	if not emitter then return end

	if TFA.GetGasEnabled and TFA.GetGasEnabled() then
		local p = emitter:Add("sprites/heatwave", pos)
		if p then
			p:SetVelocity(50 * data:GetNormal() + 0.5 * VectorRand())
			p:SetAirResistance(200)
			p:SetStartSize(math_random(12, 18))
			p:SetEndSize(2)
			p:SetDieTime(math_Rand(0.15, 0.225))
			p:SetRoll(math_Rand(-180, 180))
			p:SetRollDelta(math_Rand(-0.75, 0.75))
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	return false
end
