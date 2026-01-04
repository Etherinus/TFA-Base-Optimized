local VectorRand = VectorRand
local ParticleEmitter = ParticleEmitter
local DynamicLight = DynamicLight
local EyeAngles = EyeAngles
local FrameTime = FrameTime
local CurTime = CurTime
local IsValid = IsValid
local LocalPlayer = LocalPlayer

local math_random = math.random
local math_Rand = math.Rand
local math_rad = math.rad
local math_abs = math.abs
local math_acos = math.acos
local math_deg = math.deg
local math_Clamp = math.Clamp
local math_max = math.max

function EFFECT:Init(data)
	local wep = data:GetEntity()
	if not IsValid(wep) then return end

	local att = data:GetAttachment()
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
	local dir = forward

	local addVel = vector_origin
	local lp = LocalPlayer()
	if IsValid(lp) then
		addVel = lp:GetVelocity()
	end
	addVel = addVel * 0.05

	local dot = dir:GetNormalized():Dot(EyeAngles():Forward())
	local dotang = math_deg(math_acos(math_abs(dot)))
	local halofac = math_Clamp(1 - (dotang / 90), 0, 1)

	local ownerent = owner
	if CLIENT and not IsValid(ownerent) then
		ownerent = lp
	end

	local dlight = IsValid(ownerent) and DynamicLight(ownerent:EntIndex()) or DynamicLight(0)
	if dlight and IsValid(ownerent) then
		dlight.pos = pos - ownerent:EyeAngles():Right() * 5 + 1.05 * ownerent:GetVelocity() * FrameTime()
		dlight.r = 255
		dlight.g = 140
		dlight.b = 32
		dlight.brightness = 5
		dlight.Decay = 1750
		dlight.Size = 128
		dlight.DieTime = CurTime() + 0.3
	end

	local emitter = ParticleEmitter(pos)
	if not emitter then return end

	do
		local p = emitter:Add("effects/scotchmuzzleflash" .. math_random(1, 4), pos)
		if p then
			p:SetVelocity(dir * 4 + 1.05 * addVel)
			p:SetLifeTime(0)
			p:SetDieTime(0.10)
			p:SetStartAlpha(math_Rand(225, 255))
			p:SetEndAlpha(0)
			p:SetStartSize(6 * (halofac * 0.8 + 0.2), 0, 1)
			p:SetEndSize(10 * (halofac * 0.8 + 0.2))
			p:SetRoll(math_rad(math_Rand(0, 360)))
			p:SetRollDelta(math_rad(math_Rand(-40, 40)))
			p:SetColor(255, 218, 97)
			p:SetLighting(false)
			p.FollowEnt = wep
			p.Att = att
			if TFARegPartThink and TFAMuzzlePartFunc then
				TFARegPartThink(p, TFAMuzzlePartFunc)
			end
		end
	end

	for i = 0, 5 do
		local p = emitter:Add("particles/flamelet" .. math_random(1, 5), pos + (dir * 0.6 * i))
		if p then
			p:SetVelocity((dir * 19 * i) + 1.05 * addVel)
			p:SetLifeTime(0)
			p:SetDieTime(0.075)
			p:SetStartAlpha(math_Rand(200, 255))
			p:SetEndAlpha(0)
			p:SetStartSize(math_max(5.4 - 0.55 * i, 1) * 0.55)
			p:SetEndSize(math_max(5.4 - 0.55 * i, 1) * 0.95)
			p:SetRoll(math_rad(math_Rand(0, 360)))
			p:SetRollDelta(math_rad(math_Rand(-40, 40)))
			p:SetColor(255, 218, 97)
			p:SetLighting(false)
			p.FollowEnt = wep
			p.Att = att
			if TFARegPartThink and TFAMuzzlePartFunc then
				TFARegPartThink(p, TFAMuzzlePartFunc)
			end
			p:SetPos(vector_origin)
		end
	end

	for i = 0, 7 do
		local p = emitter:Add("particles/smokey", pos + dir * math_Rand(6, 10))
		if p then
			p:SetVelocity(VectorRand() * 10 + dir * math_Rand(15, 20) + 1.05 * addVel)
			p:SetLifeTime(0)
			p:SetDieTime(math_Rand(0.6, 0.7))
			p:SetStartAlpha(math_Rand(8, 12))
			p:SetEndAlpha(0)
			p:SetStartSize(math_Rand(5, 7))
			p:SetEndSize(math_Rand(12, 14))
			p:SetRoll(math_rad(math_Rand(0, 360)))
			p:SetRollDelta(math_Rand(-0.8, 0.8))
			p:SetLighting(true)
			p:SetAirResistance(10)
			p:SetGravity(Vector(0, 0, 60))
			p:SetColor(255, 255, 255)
		end
	end

	local sparkcount = math_random(4, 6)
	for i = 0, sparkcount do
		local p = emitter:Add("effects/yellowflare", pos)
		if p then
			p:SetVelocity(VectorRand() * 40 + dir * math_Rand(40, 100) + 1.05 * addVel)
			p:SetLifeTime(0)
			p:SetDieTime(math_Rand(0.4, 0.7))
			p:SetStartAlpha(255)
			p:SetEndAlpha(0)
			p:SetStartSize(0.3)
			p:SetEndSize(2)
			p:SetRoll(math_rad(math_Rand(0, 360)))
			p:SetGravity(Vector(0, 0, -50))
			p:SetAirResistance(50)
			p:SetStartLength(0.1)
			p:SetEndLength(0)
			p:SetColor(255, 215, 192)
			p:SetVelocityScale(true)

			p:SetThinkFunction(function(pa)
				pa:SetVelocity(pa:GetVelocity() + VectorRand() * 5)
				pa:SetNextThink(CurTime() + 0.01)
			end)
			p:SetNextThink(CurTime() + 0.01)
		end
	end

	if TFA.GetGasEnabled and TFA.GetGasEnabled() then
		for i = 0, 3 do
			local p = emitter:Add("sprites/heatwave", pos + (dir * i))
			if p then
				p:SetVelocity((dir * 25 * i) + 1.05 * addVel + VectorRand() * 5)
				p:SetLifeTime(0)
				p:SetDieTime(math_Rand(0.05, 0.15))
				p:SetStartAlpha(math_Rand(200, 225))
				p:SetEndAlpha(0)
				p:SetStartSize(math_Rand(3, 5))
				p:SetEndSize(math_Rand(8, 10))
				p:SetRoll(math_Rand(0, 360))
				p:SetRollDelta(math_Rand(-2, 2))
				p:SetAirResistance(5)
				p:SetGravity(Vector(0, 0, 40))
				p:SetColor(255, 255, 255)
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
