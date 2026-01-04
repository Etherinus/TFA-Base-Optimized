local VectorRand = VectorRand
local ParticleEmitter = ParticleEmitter
local DynamicLight = DynamicLight
local CurTime = CurTime
local IsValid = IsValid
local LocalPlayer = LocalPlayer
local Entity = Entity

local math_Round = math.Round
local math_max = math.max

local function rvec(vec)
	vec.x = math_Round(vec.x)
	vec.y = math_Round(vec.y)
	vec.z = math_Round(vec.z)
	return vec
end

local blankvec = Vector(0, 0, 0)

function EFFECT:Init(data)
	self.StartPacket = data:GetStart()
	self.Attachment = data:GetAttachment()

	local addVel = vector_origin
	local lp = LocalPlayer()
	if lp and IsValid(lp) then
		addVel = lp:GetVelocity()
	end
	if addVel == vector_origin and game.SinglePlayer() then
		local p1 = Entity(1)
		if IsValid(p1) then
			addVel = p1:GetVelocity()
		end
	end

	self.Position = data:GetOrigin()
	self.Forward = data:GetNormal()

	local wepent = Entity(math_Round(self.StartPacket.z))
	if IsValid(wepent) and wepent.IsFirstPerson and not wepent:IsFirstPerson() then
		data:SetEntity(wepent)
		self.Position = blankvec
	end

	local ownerent = player.GetByID(math_Round(self.StartPacket.x))
	local serverside = (math_Round(self.StartPacket.y) == 1)

	local ent = data:GetEntity()
	if serverside and IsValid(ownerent) then
		if lp == ownerent then return end
		ent = ownerent:GetActiveWeapon()
		addVel = ownerent:GetVelocity()
	end

	if (not self.Position) or (rvec(self.Position) == blankvec) then
		self.WeaponEnt = data:GetEntity()
		self.Attachment = data:GetAttachment()

		if IsValid(self.WeaponEnt) then
			local rpos = self.WeaponEnt:GetAttachment(self.Attachment)
			if rpos and rpos.Pos then
				self.Position = rpos.Pos
				if data:GetNormal() == vector_origin then
					self.Forward = rpos.Ang:Up()
				end
			end
		end
	end

	local dir = self.Forward
	addVel = addVel * 0.05

	local dlight = IsValid(ent) and DynamicLight(ent:EntIndex()) or DynamicLight(0)
	if dlight then
		dlight.Pos = self.Position + dir - dir:Angle():Right() * 5
		dlight.r = 180
		dlight.g = 120
		dlight.b = 40
		dlight.Brightness = 4.0
		dlight.size = 110
		dlight.DieTime = CurTime() + 0.1
		dlight.Fade = 1000
	end

	local att = math_max(1, data:GetAttachment())
	ParticleEffectAttach("tfa_muzzle_m82", PATTACH_POINT_FOLLOW, ent, att)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
