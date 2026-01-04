local DynamicLight = DynamicLight
local IsValid = IsValid
local LocalPlayer = LocalPlayer
local CurTime = CurTime
local math_Round = math.Round

function EFFECT:Init(data)
	local wepEnt = data:GetEntity()
	if not IsValid(wepEnt) then return end

	self.WeaponEnt = wepEnt
	self.Attachment = data:GetAttachment()
	self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)

	local ownerent = wepEnt.Owner
	if not IsValid(ownerent) then
		ownerent = LocalPlayer()
	end

	if IsValid(wepEnt.Owner) then
		if wepEnt.Owner == LocalPlayer() then
			if wepEnt.Owner:ShouldDrawLocalPlayer() then
				local ang = wepEnt.Owner:EyeAngles()
				ang:Normalize()
				self.Forward = ang:Forward()
			else
				self.WeaponEnt = wepEnt.Owner:GetViewModel()
			end
		else
			local ang = wepEnt.Owner:EyeAngles()
			ang:Normalize()
			self.Forward = ang:Forward()
		end
	end

	self.Forward = self.Forward or data:GetNormal()
	local dir = self.Forward

	local dlight = DynamicLight(self.WeaponEnt:EntIndex())
	if dlight then
		dlight.Pos = self.Position + dir - dir:Angle():Right() * 5
		dlight.r = 25
		dlight.g = 200
		dlight.b = 255
		dlight.Brightness = 4.0
		dlight.size = 110
		dlight.DieTime = CurTime() + 0.03
	end

	ParticleEffectAttach("tfa_muzzle_energy", PATTACH_POINT_FOLLOW, self.WeaponEnt, self.Attachment)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
