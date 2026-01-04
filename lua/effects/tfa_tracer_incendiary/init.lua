local FrameTime = FrameTime
local Lerp = Lerp

local render_SetMaterial = render.SetMaterial
local render_DrawBeam = render.DrawBeam

local math_max = math.max
local math_min = math.min

EFFECT.Mat = Material("effects/laser_tracer")
EFFECT.Col1 = Color(255, 90, 25, 200)
EFFECT.Col2 = Color(225, 25, 25, 200)
EFFECT.Speed = 8192
EFFECT.TracerLength = 128

local lerpedcol = Color(225, 225, 225, 225)

function EFFECT:Init(data)
	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()

	local startPos = self:GetTracerShootPos(self.Position, self.WeaponEnt, self.Attachment)
	local endPos = data:GetOrigin()

	self.StartPos = startPos
	self.EndPos = endPos

	local delta = endPos - startPos
	local len = delta:Length()

	self.Normal = (len > 0) and (delta / len) or vector_origin
	self.Length = len

	self.Life = 0
	self.MaxLife = math_max(len / self.Speed, 0.0001)

	if self.SetRenderBoundsWS then
		self:SetRenderBoundsWS(startPos, endPos)
	elseif self.Entity and self.Entity.SetRenderBoundsWS then
		self.Entity:SetRenderBoundsWS(startPos, endPos)
	end

	self.CurPos = startPos
end

function EFFECT:Think()
	self.Life = self.Life + (FrameTime() / self.MaxLife)
	return self.Life < 1
end

function EFFECT:Render()
	render_SetMaterial(self.Mat)

	lerpedcol.r = Lerp(self.Life, self.Col1.r, self.Col2.r)
	lerpedcol.g = Lerp(self.Life, self.Col1.g, self.Col2.g)
	lerpedcol.b = Lerp(self.Life, self.Col1.b, self.Col2.b)
	lerpedcol.a = Lerp(self.Life, self.Col1.a, self.Col2.a)

	local startbeampos = Lerp(self.Life, self.StartPos, self.EndPos)

	local len = math_max(self.Length, 0.0001)
	local endFrac = math_min(self.Life + (self.TracerLength / len), 1)
	local endbeampos = Lerp(endFrac, self.StartPos, self.EndPos)

	render_DrawBeam(startbeampos, endbeampos, 8, 0, 1, lerpedcol)
end
