local bvec = Vector(0, 0, 0)
local uAng = Angle(90, 0, 0)

local IsValid = IsValid
local LocalPlayer = LocalPlayer
local VectorRand = VectorRand
local ParticleEmitter = ParticleEmitter

local game_SinglePlayer = game.SinglePlayer

local math_Rand = math.Rand
local math_rad = math.rad

function EFFECT:Init(data)
	if TFA.GetEJSmokeEnabled and not TFA.GetEJSmokeEnabled() then return end

	self.Position = bvec

	local wep = data:GetEntity()
	if not IsValid(wep) then return end

	self.WeaponEntOG = wep
	self.WeaponEnt = wep
	self.Attachment = data:GetAttachment()

	local dir = data:GetNormal()

	local owent = wep.Owner or wep:GetOwner()
	if not IsValid(owent) then
		owent = wep:GetParent()
	end

	if IsValid(owent) and owent:IsPlayer() then
		if owent ~= LocalPlayer() or owent:ShouldDrawLocalPlayer() then
			self.WeaponEnt = owent:GetActiveWeapon()
			if not IsValid(self.WeaponEnt) then return end
		else
			self.WeaponEnt = owent:GetViewModel()
			local theirweapon = owent:GetActiveWeapon()
			if IsValid(theirweapon) and (theirweapon.ViewModelFlip or theirweapon.ViewModelFlipped) then
				self.Flipped = true
			end
			if not IsValid(self.WeaponEnt) then return end
		end
	end

	if IsValid(self.WeaponEntOG) and self.WeaponEntOG.ShellAttachment then
		self.Attachment = self.WeaponEnt:LookupAttachment(self.WeaponEntOG.ShellAttachment)
		if not self.Attachment or self.Attachment <= 0 then
			self.Attachment = 2
		end
		if self.WeaponEntOG.ShellAttachmentRaw then
			self.Attachment = self.WeaponEntOG.ShellAttachmentRaw
		end
	end

	local angpos = self.WeaponEnt:GetAttachment(self.Attachment)
	if not angpos or not angpos.Pos then
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

	local emitter = ParticleEmitter(self.vOffset)
	if not emitter then return end

	dir = data:GetNormal()

	for i = 0, 6 do
		local p = emitter:Add("particles/smokey", self.vOffset + dir * math_Rand(2, 4))
		if p then
			p:SetVelocity(VectorRand() * 5 + dir * math_Rand(7, 10))
			p:SetLifeTime(0)
			p:SetDieTime(math_Rand(0.6, 0.7))
			p:SetStartAlpha(math_Rand(6, 10))
			p:SetEndAlpha(0)
			p:SetStartSize(math_Rand(2, 3))
			p:SetEndSize(math_Rand(6, 8))
			p:SetRoll(math_rad(math_Rand(0, 360)))
			p:SetRollDelta(math_Rand(-0.8, 0.8))
			p:SetLighting(true)
			p:SetAirResistance(20)
			p:SetGravity(Vector(0, 0, 30))
			p:SetColor(255, 255, 255)
		end
	end

	if TFA.GetGasEnabled and TFA.GetGasEnabled() then
		for i = 0, 1 do
			local p = emitter:Add("sprites/heatwave", self.vOffset + (dir * i))
			if p then
				p:SetVelocity((dir * 25 * i) + VectorRand() * 5)
				p:SetLifeTime(0)
				p:SetDieTime(math_Rand(0.05, 0.15))
				p:SetStartAlpha(math_Rand(200, 225))
				p:SetEndAlpha(0)
				p:SetStartSize(math_Rand(1, 3))
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
