local IsValid = IsValid
local LocalPlayer = LocalPlayer

function EFFECT:Init(data)
	local wep = data:GetEntity()
	if not IsValid(wep) then return end

	local att = data:GetAttachment()

	local smokepart = "smoke_trail"
	if wep.SmokeParticles then
		local key = wep.DefaultHoldType or wep.HoldType
		smokepart = wep.SmokeParticles[key] or smokepart
	end

	if not smokepart or smokepart == "" then return end
	if TFA.HasParticleSystem and not TFA.HasParticleSystem(smokepart) then return end

	local pos = self:GetTracerShootPos(data:GetOrigin(), wep, att)

	local owner = wep.Owner
	local forward

	if IsValid(owner) then
		if owner == LocalPlayer() then
			if owner:ShouldDrawLocalPlayer() then
				local ang = owner:EyeAngles()
				ang:Normalize()
				forward = ang:Forward()
			else
				local vm = owner:GetViewModel()
				if IsValid(vm) then
					wep = vm
				end
			end
		else
			local ang = owner:EyeAngles()
			ang:Normalize()
			forward = ang:Forward()
		end
	end

	forward = forward or data:GetNormal()

	if (not TFA.GetMZSmokeEnabled) or TFA.GetMZSmokeEnabled() then
		ParticleEffectAttach(smokepart, PATTACH_POINT_FOLLOW, wep, att)
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
