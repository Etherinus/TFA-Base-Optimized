local PenetColor = Color(255, 255, 255, 255)
local PenetMat = Material("trails/smoke")
local PenetMat2 = Material("effects/yellowflare")

local cv_gv = GetConVar("sv_gravity")

local CurTime = CurTime
local IsValid = IsValid
local EffectData = EffectData
local ColorAlpha = ColorAlpha

local util_QuickTrace = util.QuickTrace
local util_Effect = util.Effect

local render_SetMaterial = render.SetMaterial
local render_DrawBeam = render.DrawBeam

local math_Clamp = math.Clamp
local math_Rand = math.Rand

function EFFECT:Init(data)
	self.StartPos = data:GetOrigin()
	self.Dir = data:GetNormal()
	self.Dir:Normalize()

	self.Len = 32
	self.EndPos = self.StartPos + self.Dir * self.Len

	self.LifeTime = 0.75
	self.DieTime = CurTime() + self.LifeTime
	self.Thickness = 1

	self.Grav = Vector(0, 0, -cv_gv:GetFloat())
	self.PartMult = data:GetMagnitude()
	self.SparkLife = 0.3

	self.WeaponEnt = data:GetEntity()
	if not IsValid(self.WeaponEnt) then return end

	if self.WeaponEnt.TracerName then
		local fx = EffectData()
		fx:SetStart(self.StartPos)
		local traceres = util_QuickTrace(self.StartPos, self.Dir * 9999999, nil)
		fx:SetOrigin((traceres and traceres.HitPos) or self.StartPos)
		util_Effect(self.WeaponEnt.TracerName, fx)
		self:Remove()
		return
	end

	local emitter = ParticleEmitter(self.StartPos)
	if not emitter then return end

	local p1 = emitter:Add("effects/select_ring", self.StartPos)
	if p1 then
		p1:SetStartAlpha(225)
		p1:SetStartSize(1)
		p1:SetDieTime(self.LifeTime / 5)
		p1:SetEndSize(0)
		p1:SetEndAlpha(0)
		p1:SetRoll(math_Rand(0, 360))
		p1:SetColor(200, 200, 200)
	end

	local p2 = emitter:Add("effects/select_ring", self.StartPos)
	if p2 then
		p2:SetStartAlpha(255)
		p2:SetStartSize(1.5 * self.PartMult)
		p2:SetDieTime(self.LifeTime / 6)
		p2:SetEndSize(0)
		p2:SetEndAlpha(0)
		p2:SetRoll(math_Rand(0, 360))
		p2:SetColor(200, 200, 200)
	end

	emitter:Finish()
end

function EFFECT:Think()
	if self.DieTime and (CurTime() > self.DieTime) then
		return false
	end
	return true
end

function EFFECT:Render()
	if not self.DieTime then return end

	local fDelta = (self.DieTime - CurTime()) / self.LifeTime
	fDelta = math_Clamp(fDelta, 0, 1)

	render_SetMaterial(PenetMat)
	local color = ColorAlpha(PenetColor, 32 * fDelta)

	local precision = 16
	local i = 1
	while i <= precision do
		local a = self.StartPos + self.Dir * self.Len * ((i - 1) / precision)
		local b = self.StartPos + self.Dir * self.Len * (i / precision)
		render_DrawBeam(a, b, self.Thickness * fDelta * (1 - i / precision), 0.5, 0.5, color)
		i = i + 1
	end

	render_SetMaterial(PenetMat2)
	i = 1
	while i <= precision do
		local a = self.StartPos + self.Dir * self.Len * ((i - 1) / precision)
		local b = self.StartPos + self.Dir * self.Len * (i / precision)
		render_DrawBeam(a, b, (self.Thickness / 3) * 2 * fDelta * (1 - i / precision), 0.5, 0.5, color)
		i = i + 1
	end
end
