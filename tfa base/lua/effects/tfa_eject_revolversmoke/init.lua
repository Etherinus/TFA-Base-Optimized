local bvec = Vector(0, 0, 0)
local uAng = Angle(90, 0, 0)
local dir

function EFFECT:Init(data)
	if not TFA.GetEJSmokeEnabled() then return end
	self.Position = bvec
	self.WeaponEnt = data:GetEntity()
	if not IsValid(self.WeaponEnt) then return end
	self.WeaponEntOG = self.WeaponEnt
	self.Attachment = data:GetAttachment()
	dir = data:GetNormal()
	local owent = self.WeaponEnt.Owner or self.WeaponEnt:GetOwner()

	if not IsValid(owent) then
		owent = self.WeaponEnt:GetParent()
	end

	if IsValid(owent) and owent:IsPlayer() then
		if owent ~= LocalPlayer() or owent:ShouldDrawLocalPlayer() then
			self.WeaponEnt = owent:GetActiveWeapon()
			if not IsValid(self.WeaponEnt) then return end
		else
			self.WeaponEnt = owent:GetViewModel()
			local theirweapon = owent:GetActiveWeapon()

			if IsValid(theirweapon) and theirweapon.ViewModelFlip or theirweapon.ViewModelFlipped then
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

		if self.WeaponEntOG.Akimbo then
			self.Attachment = 4 - self.WeaponEntOG.AnimCycle
		end
	end

	local angpos = self.WeaponEnt:GetAttachment(self.Attachment)

	if not angpos or not angpos.Pos then
		angpos = {
			Pos = bvec,
			Ang = uAng
		}
	end

	if self.Flipped then
		local tmpang = (dir or angpos.Ang:Forward()):Angle()
		local localang = self.WeaponEnt:WorldToLocalAngles(tmpang)
		localang.y = localang.y + 180
		localang = self.WeaponEnt:LocalToWorldAngles(localang)
		--localang:RotateAroundAxis(localang:Up(),180)
		--tmpang:RotateAroundAxis(tmpang:Up(),180)
		dir = localang:Forward()
	end

	-- Keep the start and end Pos - we're going to interpolate between them
	self.vOffset = self:GetTracerShootPos(angpos.Pos, self.WeaponEnt, self.Attachment)
	dir = dir or angpos.Ang:Forward() --angpos.Ang:Forward()

	if CLIENT and not IsValid(ownerent) then
		ownerent = LocalPlayer()
	end

	local AddVel = ownerent:GetVelocity()
	local dot = dir:GetNormalized():Dot(EyeAngles():Forward())
	local dotang = math.deg(math.acos(math.abs(dot)))
	local halofac = math.sqrt(math.Clamp(1 - (dotang / 90), 0, 1))
	--[[
	local dlight = DynamicLight( ownerent:EntIndex()+64 )
	if ( dlight ) then
	dlight.pos = self.vOffset - ownerent:EyeAngles():Right()*5 + 1.05 * ownerent:GetVelocity() * FrameTime()
	dlight.r = 255
	dlight.g = 192
	dlight.b = 64
	dlight.brightness = 4.5
	dlight.Decay = 1000
	dlight.Size = 96
	dlight.DieTime = CurTime() + 0.5
	end
	]]
	--
	local emitter = ParticleEmitter(self.vOffset)

	for i = 1, 2 do
		local particle = emitter:Add("effects/scotchmuzzleflash" .. math.random(1, 4), self.vOffset)

		if (particle) then
			particle:SetVelocity(dir * 4 + 1.05 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(0.125)
			particle:SetStartAlpha(math.Rand(225, 255))
			particle:SetEndAlpha(0)
			--particle:SetStartSize( 7.5 * (halofac*0.8+0.2), 0, 1)
			--particle:SetEndSize( 0 )
			particle:SetStartSize(3 * (halofac * 0.8 + 0.2), 0, 1)
			particle:SetEndSize(6 * (halofac * 0.8 + 0.2))
			particle:SetRoll(math.rad(math.Rand(0, 360)))
			particle:SetRollDelta(math.rad(math.Rand(-40, 40)))
			particle:SetColor(255, 218, 97)
			particle:SetLighting(false)
			particle.FollowEnt = self.WeaponEnt
			particle.Att = self.Attachment
			TFARegPartThink(particle, TFAMuzzlePartFunc)
		end
	end

	for i = 0, 3 do
		local angoff = dir:Angle()
		angoff:RotateAroundAxis(angoff:Up(), 120)
		local dir2 = angoff:Forward()
		local particle = emitter:Add("effects/scotchmuzzleflash" .. math.random(1, 4), self.vOffset + (dir2 * 0.6 * i))

		if (particle) then
			particle:SetVelocity((dir2 * 20 * i) + 1.05 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(0.125)
			particle:SetStartAlpha(math.Rand(255, 225))
			particle:SetEndAlpha(0)
			--particle:SetStartSize( math.max(5.4 - 0.55 * i,1) )
			--particle:SetEndSize( 0 )
			particle:SetStartSize(math.max(5.4 - 0.9 * i, 1) * 0.6)
			particle:SetEndSize(math.max(5.4 - 0.9 * i, 1) * 1.3)
			particle:SetRoll(math.rad(math.Rand(0, 360)))
			particle:SetRollDelta(math.rad(math.Rand(-40, 40)))
			particle:SetColor(255, 218, 97)
			particle:SetLighting(false)
			particle.FollowEnt = self.WeaponEnt
			particle.Att = self.Attachment
			TFARegPartThink(particle, TFAMuzzlePartFunc)
			particle:SetPos(vector_origin)
		end
	end

	for i = 0, 3 do
		local angoff = dir:Angle()
		angoff:RotateAroundAxis(angoff:Up(), -120)
		local dir2 = angoff:Forward()
		local particle = emitter:Add("effects/scotchmuzzleflash" .. math.random(1, 4), self.vOffset + (dir2 * 0.6 * i))

		if (particle) then
			particle:SetVelocity((dir2 * 20 * i) + 1.05 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(0.125)
			particle:SetStartAlpha(math.Rand(255, 225))
			particle:SetEndAlpha(0)
			--particle:SetStartSize( math.max(5.4 - 0.55 * i,1) )
			--particle:SetEndSize( 0 )
			particle:SetStartSize(math.max(5.4 - 0.9 * i, 1) * 0.6)
			particle:SetEndSize(math.max(5.4 - 0.9 * i, 1) * 1.3)
			particle:SetRoll(math.rad(math.Rand(0, 360)))
			particle:SetRollDelta(math.rad(math.Rand(-40, 40)))
			particle:SetColor(255, 218, 97)
			particle:SetLighting(false)
			particle.FollowEnt = self.WeaponEnt
			particle.Att = self.Attachment
			TFARegPartThink(particle, TFAMuzzlePartFunc)
			particle:SetPos(vector_origin)
		end
	end

	for i = 0, 6 do
		local particle = emitter:Add("particles/smokey", self.vOffset + dir * math.Rand(6, 10))

		if (particle) then
			particle:SetVelocity(VectorRand() * 10 + dir * math.Rand(15, 20) + 1.05 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(0.6, 0.7))
			particle:SetStartAlpha(math.Rand(6, 10))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(5, 7))
			particle:SetEndSize(math.Rand(12, 14))
			particle:SetRoll(math.rad(math.Rand(0, 360)))
			particle:SetRollDelta(math.Rand(-0.8, 0.8))
			particle:SetLighting(true)
			particle:SetAirResistance(10)
			particle:SetGravity(Vector(0, 0, 60))
			particle:SetColor(255, 255, 255)
		end
	end

	local sparkcount = math.random(3, 4)

	for i = 0, sparkcount do
		local olddir = dir * 1
		dir = olddir:Angle():Right()
		local particle = emitter:Add("effects/yellowflare", self.Position)

		if (particle) then
			particle:SetVelocity((VectorRand() + Vector(0, 0, 0.3)) * 25 * Vector(0.8, 0.8, 0.6) + dir * math.Rand(45, 60) + 1.15 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(0.25, 0.4))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(.25)
			particle:SetEndSize(1.0)
			particle:SetRoll(math.rad(math.Rand(0, 360)))
			particle:SetGravity(Vector(0, 0, -50))
			particle:SetAirResistance(40)
			particle:SetStartLength(0.2)
			particle:SetEndLength(0.05)
			particle:SetColor(255, 200, 140)
			particle:SetVelocityScale(true)

			particle:SetThinkFunction(function(pa)
				pa.ranvel = pa.ranvel or VectorRand() * 4
				pa.ranvel.x = math.Approach(pa.ranvel.x, math.Rand(-4, 4), 0.5)
				pa.ranvel.y = math.Approach(pa.ranvel.y, math.Rand(-4, 4), 0.5)
				pa.ranvel.z = math.Approach(pa.ranvel.z, math.Rand(-4, 4), 0.5)
				pa:SetVelocity(pa:GetVelocity() + pa.ranvel * 0.6)
				pa:SetNextThink(CurTime() + 0.01)
			end)

			particle:SetNextThink(CurTime() + 0.01)
		end
	end

	for i = 0, sparkcount do
		local olddir = dir * 1
		dir = olddir:Angle():Right() * -1
		local particle = emitter:Add("effects/yellowflare", self.Position)

		if (particle) then
			particle:SetVelocity((VectorRand() + Vector(0, 0, 0.3)) * 25 * Vector(0.8, 0.8, 0.6) + dir * math.Rand(45, 60) + 1.15 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(0.25, 0.4))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(.25)
			particle:SetEndSize(1.0)
			particle:SetRoll(math.rad(math.Rand(0, 360)))
			particle:SetGravity(Vector(0, 0, -50))
			particle:SetAirResistance(40)
			particle:SetStartLength(0.2)
			particle:SetEndLength(0.05)
			particle:SetColor(255, 200, 140)
			particle:SetVelocityScale(true)

			particle:SetThinkFunction(function(pa)
				pa.ranvel = pa.ranvel or VectorRand() * 4
				pa.ranvel.x = math.Approach(pa.ranvel.x, math.Rand(-4, 4), 0.5)
				pa.ranvel.y = math.Approach(pa.ranvel.y, math.Rand(-4, 4), 0.5)
				pa.ranvel.z = math.Approach(pa.ranvel.z, math.Rand(-4, 4), 0.5)
				pa:SetVelocity(pa:GetVelocity() + pa.ranvel * 0.6)
				pa:SetNextThink(CurTime() + 0.01)
			end)

			particle:SetNextThink(CurTime() + 0.01)
		end
	end

	if TFA.GetGasEnabled() then
		for i = 0, 1 do
			local particle = emitter:Add("sprites/heatwave", self.vOffset + (dir * i))

			if (particle) then
				particle:SetVelocity((dir * 25 * i) + 1.05 * AddVel)
				particle:SetLifeTime(0)
				particle:SetDieTime(math.Rand(0.05, 0.15))
				particle:SetStartAlpha(math.Rand(200, 225))
				particle:SetEndAlpha(0)
				particle:SetStartSize(math.Rand(3, 5))
				particle:SetEndSize(math.Rand(8, 10))
				particle:SetRoll(math.Rand(0, 360))
				particle:SetRollDelta(math.Rand(-2, 2))
				particle:SetAirResistance(5)
				particle:SetGravity(Vector(0, 0, 40))
				particle:SetColor(255, 255, 255)
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
