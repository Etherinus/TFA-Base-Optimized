function EFFECT:Init(data)
	local posoffset = data:GetOrigin()
	local emitter = ParticleEmitter(posoffset)

	if TFA.GetGasEnabled() then
		local p = emitter:Add("sprites/heatwave", posoffset)
		p:SetVelocity(50 * data:GetNormal() + 0.5 * VectorRand())
		p:SetAirResistance(200)
		p:SetStartSize(math.random(12.5, 17.5))
		p:SetEndSize(2)
		p:SetDieTime(math.Rand(0.15, 0.225))
		p:SetRoll(math.Rand(-180, 180))
		p:SetRollDelta(math.Rand(-0.75, 0.75))
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
return false
end
