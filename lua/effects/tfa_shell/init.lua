local bvec = Vector(0, 0, 0)
local uAng = Angle(90, 0, 0)

function EFFECT:Init(data)
	self.Position = bvec
	self.WeaponEnt = data:GetEntity()
	if not IsValid(self.WeaponEnt) then return end
	self.WeaponEntOG = self.WeaponEnt
	self.Attachment = data:GetAttachment()
	self.Dir = data:GetNormal()
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
			self.Attachment = 4 - ( game.SinglePlayer() and self.WeaponEntOG:GetNW2Int("AnimCycle",1) or self.WeaponEntOG.AnimCycle )
		end

		if self.WeaponEntOG.ShellAttachmentRaw then
			self.Attachment = self.WeaponEntOG.ShellAttachmentRaw
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
		local tmpang = (self.Dir or angpos.Ang:Forward()):Angle()
		local localang = self.WeaponEnt:WorldToLocalAngles(tmpang)
		localang.y = localang.y + 180
		localang = self.WeaponEnt:LocalToWorldAngles(localang)
		--localang:RotateAroundAxis(localang:Up(),180)
		--tmpang:RotateAroundAxis(tmpang:Up(),180)
		self.Dir = localang:Forward()
	end

	-- Keep the start and end Pos - we're going to interpolate between them
	self.Pos = self:GetTracerShootPos(angpos.Pos, self.WeaponEnt, self.Attachment)
	self.Norm =  angpos.Ang:Forward() --angpos.Ang:Forward()
	--print(self.Norm)
	self.Magnitude = data:GetMagnitude()
	self.Scale = data:GetScale()
	local fx = EffectData()
	fx:SetOrigin(self.Pos)
	fx:SetStart(self.Pos)
	fx:SetEntity(self.WeaponEnt)
	fx:SetAttachment(self.Attachment)
	fx:SetNormal(self.Norm)
	fx:SetAngles(self.Norm:Angle())
	fx:SetScale(self.Scale)
	fx:SetMagnitude(self.Magnitude)
	local se = (self.WeaponEntOG.LuaShellEffect or self.WeaponEntOG.Blowback_Shell_Effect) or "ShellEject"
	util.Effect(se, fx)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
