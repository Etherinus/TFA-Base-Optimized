local bvec = Vector(0, 0, 0)
local uAng = Angle(90, 0, 0)
local blankvec = Vector(0, 0, 0)

local DynamicLight = DynamicLight
local IsValid = IsValid
local LocalPlayer = LocalPlayer
local CurTime = CurTime

function EFFECT:Init(data)
	self.Position = blankvec
	local wepEnt = data:GetEntity()
	if not IsValid(wepEnt) then return end

	self.WeaponEnt = wepEnt
	self.WeaponEntOG = wepEnt
	self.Attachment = data:GetAttachment()
	self.Dir = data:GetNormal()

	local owent = wepEnt.Owner or wepEnt:GetOwner()
	if not IsValid(owent) then
		owent = wepEnt:GetParent()
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

	if IsValid(self.WeaponEntOG) and self.WeaponEntOG.MuzzleAttachment then
		local att = self.WeaponEnt:LookupAttachment(self.WeaponEntOG.MuzzleAttachment)
		if not att or att <= 0 then att = 1 end

		if self.WeaponEntOG.Akimbo then
			att = 2 - (self.WeaponEntOG.AnimCycle or 1)
		end

		self.Attachment = att
	end

	local angpos = self.WeaponEnt:GetAttachment(self.Attachment)
	if not (angpos and angpos.Pos) then
		angpos = { Pos = bvec, Ang = uAng }
	end

	if self.Flipped then
		local tmpang = (self.Dir or angpos.Ang:Forward()):Angle()
		local localang = self.WeaponEnt:WorldToLocalAngles(tmpang)
		localang.y = localang.y + 180
		localang = self.WeaponEnt:LocalToWorldAngles(localang)
		self.Dir = localang:Forward()
	end

	self.Position = self:GetTracerShootPos(angpos.Pos, self.WeaponEnt, self.Attachment)
	local dir = self.Dir or angpos.Ang:Forward()
	self.vOffset = self.Position

	local dlight = DynamicLight(self.WeaponEnt:EntIndex())
	local fadeouttime = 0.2
	if dlight then
		dlight.Pos = self.Position + dir - dir:Angle():Right() * 5
		dlight.r = 25
		dlight.g = 200
		dlight.b = 255
		dlight.Brightness = 4.0
		dlight.size = 110
		dlight.decay = 1000
		dlight.DieTime = CurTime() + fadeouttime
	end

	ParticleEffectAttach("tfa_muzzle_gauss", PATTACH_POINT_FOLLOW, self.WeaponEnt, self.Attachment)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
