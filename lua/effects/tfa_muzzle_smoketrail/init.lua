local smokecol = Color(225, 225, 225, 200)
local smokemat = Material("trails/smoke")
smokemat:SetInt("$nocull", 1)

local CurTime = CurTime
local FrameTime = FrameTime
local IsValid = IsValid
local table_insert = table.insert
local table_remove = table.remove

function EFFECT:AddPart()
	local pos = self.startpos
	local norm = self.startnormal

	if self.targent and self.targatt then
		local raw = self.targent:GetAttachment(self.targatt)
		if raw then
			pos = raw.Pos
			norm = raw.Ang:Forward()
		end
	end

	local p = {
		position = pos,
		normal = norm,
		velocity = norm * 5,
		startlife = CurTime(),
		lifetime = self.lifetime,
		radius = self.radius
	}

	table_insert(self.vparticles, p)
end

function EFFECT:ProcessFakeParticles()
	self.stepcount = self.stepcount + 1

	local ct = CurTime()
	if ct < self.emittime and (self.stepcount % self.partinterval == 0) then
		self:AddPart()
	end

	local ft = FrameTime()
	for i = #self.vparticles, 1, -1 do
		local v = self.vparticles[i]
		v.position = v.position + v.velocity * ft
		v.velocity = v.velocity + self.grav * ft

		if ct > (v.startlife + v.lifetime) then
			table_remove(self.vparticles, i)
		end
	end

	return (#self.vparticles > 0)
end

local cv_gr = GetConVar("sv_gravity")

function EFFECT:Init(ef)
	self.lifetime = 1
	self.stepcount = 0
	self.partinterval = 3
	self.emittime = CurTime() + 3
	self.targent = ef:GetEntity()
	self.targatt = ef:GetAttachment()
	self.startpos = ef:GetOrigin() or vector_origin
	self.startnormal = ef:GetNormal() or vector_origin
	self.radius = ef:GetRadius()
	if not self.radius or self.radius == 0 then self.radius = 1 end

	local grav = cv_gr and cv_gr:GetFloat() or 600
	self.grav = Vector(0, 0, grav * 0.2)

	self.vparticles = {}
	self:AddPart()
end

function EFFECT:Think()
	return self.vparticles and (#self.vparticles > 0)
end

function EFFECT:DrawBeam()
	local n = #self.vparticles
	render.StartBeam(n)
	local ct = CurTime()

	for k = 1, n do
		local v = self.vparticles[k]
		local life = (1 - (ct - v.startlife) / v.lifetime)
		if life < 0 then life = 0 end
		local alphac = ColorAlpha(smokecol, life * 64)
		render.AddBeam(v.position, v.radius * (1 - k / n), k / n, alphac)
	end

	render.EndBeam()
end

function EFFECT:Render()
	if not self.vparticles then return end
	if not self:ProcessFakeParticles() then return end
	if #self.vparticles < 2 then return end

	render.SetMaterial(smokemat)
	self:DrawBeam()
end
