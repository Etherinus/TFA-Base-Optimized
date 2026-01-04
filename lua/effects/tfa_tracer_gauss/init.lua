local FrameTime = FrameTime
local CurTime = CurTime
local Lerp = Lerp
local LocalPlayer = LocalPlayer
local IsValid = IsValid

local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local render_DrawQuadEasy = render.DrawQuadEasy
local render_DrawBeam = render.DrawBeam

local ColorAlpha = ColorAlpha
local table_Copy = table.Copy

local math_Clamp = math.Clamp

local bvec = Vector(0, 0, 0)
local uAng = Angle(90, 0, 0)

local TRACER_FLAG_USEATTACHMENT = 0x0002
local SOUND_FROM_WORLD = 0
local CHAN_STATIC = 6

EFFECT.Thickness = 16
EFFECT.Life = 0.25
EFFECT.RotVelocity = 30
EFFECT.InValid = false

local Mat_Impact = Material("effects/combinemuzzle2")
local Mat_Beam = Material("effects/tool_tracer")
local Mat_TracePart = Material("effects/select_ring")

local beamcol = table_Copy(color_white)
local beamcol2 = Color(0, 225, 255, 255)

function EFFECT:Init(data)
	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.WeaponEntOG = self.WeaponEnt
	self.Attachment = data:GetAttachment()
	self.Dir = data:GetNormal()

	local owent

	if IsValid(self.WeaponEnt) then
		owent = self.WeaponEnt.Owner or self.WeaponEnt:GetOwner()
		if not IsValid(owent) then
			owent = self.WeaponEnt:GetParent()
		end
	end

	if IsValid(owent) and owent:IsPlayer() then
		if owent ~= LocalPlayer() or owent:ShouldDrawLocalPlayer() then
			self.WeaponEnt = owent:GetActiveWeapon()
			if not IsValid(self.WeaponEnt) then
				self.InValid = true
				return
			end
		else
			self.WeaponEnt = owent:GetViewModel()
			local theirweapon = owent:GetActiveWeapon()
			if IsValid(theirweapon) and (theirweapon.ViewModelFlip or theirweapon.ViewModelFlipped) then
				self.Flipped = true
			end
			if not IsValid(self.WeaponEnt) then
				self.InValid = true
				return
			end
		end
	end

	if IsValid(self.WeaponEntOG) and self.WeaponEntOG.MuzzleAttachment then
		self.Attachment = self.WeaponEnt:LookupAttachment(self.WeaponEntOG.MuzzleAttachment)
		if not self.Attachment or self.Attachment <= 0 then
			self.Attachment = 1
		end
		if self.WeaponEntOG.Akimbo then
			self.Attachment = 2 - (self.WeaponEntOG.AnimCycle or 0)
		end
	end

	local angpos
	if IsValid(self.WeaponEnt) then
		angpos = self.WeaponEnt:GetAttachment(self.Attachment)
	end

	if not angpos or not angpos.Pos then
		angpos = { Pos = bvec, Ang = uAng }
	end

	if self.Flipped then
		local tmpang = (self.Dir or angpos.Ang:Forward()):Angle()
		local localang = self.WeaponEnt:WorldToLocalAngles(tmpang)
		localang.y = localang.y + 180
		localang = self.WeaponEnt:LocalToWorldAngles(localang)
		self.Dir = localang:Forward()
	end

	if IsValid(owent) and self.Position:Distance(owent:GetShootPos()) > 72 then
		self.WeaponEnt = nil
	end

	self.StartPos = self:GetTracerShootPos(self.WeaponEnt and angpos.Pos or self.Position, self.WeaponEnt, self.Attachment)
	self.EndPos = data:GetOrigin()

	if self.SetRenderBoundsWS then
		self:SetRenderBoundsWS(self.StartPos, self.EndPos)
	elseif self.Entity and self.Entity.SetRenderBoundsWS then
		self.Entity:SetRenderBoundsWS(self.StartPos, self.EndPos)
	end

	local delta = self.EndPos - self.StartPos
	self.Normal = delta:GetNormalized()

	self.StartTime = 0
	self.LifeTime = self.Life
	self.data = data
	self.rot = 0
end

function EFFECT:Think()
	if self.InValid then return false end
	local ft = FrameTime()
	self.LifeTime = self.LifeTime - ft
	self.StartTime = self.StartTime + ft
	return self.LifeTime > 0
end

function EFFECT:Render()
	if self.InValid then return end

	self.StartPos = self:GetTracerShootPos(self.StartPos, self.WeaponEnt, self.Attachment)

	local startPos = self.StartPos
	local endPos = self.EndPos

	beamcol.a = (self.LifeTime / self.Life) * 255
	self.rot = self.rot + FrameTime() * self.RotVelocity

	render_SetMaterial(Mat_Impact)
	render_DrawSprite(endPos, 12, 12, ColorAlpha(color_white, beamcol.a))

	render_SetMaterial(Mat_TracePart)

	local f = self.LifeTime / self.Life
	local tracerpos

	tracerpos = Lerp(math_Clamp(f - 0.1, 0, 1), endPos, startPos)
	render_DrawQuadEasy(tracerpos, self.Normal, 12, 12, beamcol2, self.rot - 60)

	tracerpos = Lerp(math_Clamp(f - 0.05, 0, 1), endPos, startPos)
	render_DrawQuadEasy(tracerpos, self.Normal, 12, 12, beamcol2, self.rot - 30)

	tracerpos = Lerp(math_Clamp(f, 0, 1), endPos, startPos)
	render_DrawQuadEasy(tracerpos, self.Normal, 12, 12, beamcol2, self.rot)

	tracerpos = Lerp(math_Clamp(f + 0.05, 0, 1), endPos, startPos)
	render_DrawQuadEasy(tracerpos, self.Normal, 12, 12, beamcol2, self.rot + 30)

	tracerpos = Lerp(math_Clamp(f + 0.1, 0, 1), endPos, startPos)
	render_DrawQuadEasy(tracerpos, self.Normal, 12, 12, beamcol2, self.rot + 60)

	tracerpos = Lerp(math_Clamp(f + 0.15, 0, 1), endPos, startPos)
	render_DrawQuadEasy(tracerpos, self.Normal, 12, 12, beamcol2, self.rot + 30)

	tracerpos = Lerp(math_Clamp(f + 0.2, 0, 1), endPos, startPos)
	render_DrawQuadEasy(tracerpos, self.Normal, 12, 12, beamcol2, self.rot + 60)

	render_SetMaterial(Mat_Beam)
	render_DrawBeam(startPos, endPos, self.Thickness, beamcol.a / 128, (endPos:Distance(startPos) / 64) + (beamcol.a / 128), beamcol)
end
