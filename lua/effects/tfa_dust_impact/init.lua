local ParticleEmitter = ParticleEmitter
local IsValid = IsValid
local CurTime = CurTime
local math_sqrt = math.sqrt
local math_Rand = math.Rand
local math_Round = math.Round
local math_Clamp = math.Clamp

function EFFECT:Init(data)
	local ply = data:GetEntity()
	local wep

	if IsValid(ply) and ply:IsPlayer() then
		wep = ply:GetActiveWeapon()
	end

	local dmg = (IsValid(wep) and wep.Primary and wep.Primary.Damage) or 30
	local sfac = math_sqrt(dmg / 30)
	if sfac <= 0 then sfac = 1 end
	local sfac_sqrt = math_sqrt(sfac)

	local pos = data:GetOrigin()
	local forward = data:GetNormal()
	local emitter = ParticleEmitter(pos)
	if not emitter then return end

	local count = math_Round(8 * sfac)
	for i = 0, count do
		local p = emitter:Add("particle/particle_smokegrenade", pos)
		if p then
			local si = math_sqrt(i)
			p:SetVelocity(90 * si * forward)
			p:SetAirResistance(400)
			p:SetStartAlpha(255)
			p:SetEndAlpha(0)
			p:SetDieTime(math_Rand(0.75, 1) * (1 + si / 3))

			local ic = math_Clamp(i, 1, 8)
			local ic_s = math_sqrt(ic / 8) * 8

			p:SetStartSize(sfac_sqrt * ic_s)
			p:SetEndSize(math_Rand(1.5, 1.75) * sfac_sqrt * ic)
			p:SetRoll(math_Rand(-25, 25))
			p:SetRollDelta(math_Rand(-0.05, 0.05))
			p:SetColor(255, 255, 255)
			p:SetLighting(true)
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
