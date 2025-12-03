AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Damage = 100
ENT.Delay = 3

function ENT:Initialize()
	local mdl = self:GetModel()

	if not mdl or mdl == "" or mdl == "models/error.mdl" then
		self:SetModel("models/weapons/w_eq_fraggrenade.mdl")
	end

	self:PhysicsInit(SOLID_VPHYSICS)
	--self:PhysicsInitSphere((self:OBBMaxs() - self:OBBMins()):Length() / 4, "metal")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end

	self:SetFriction(self.Delay)
	self.killtime = CurTime() + self.Delay
	self:DrawShadow(true)
end

function ENT:Think()
	if self.killtime < CurTime() then
		self:Explode()

		return false
	end

	self:NextThink(CurTime())

	return true
end

local effectdata, shake

function ENT:Explode()
	if not IsValid(self.Owner) then
		self:Remove()

		return
	end

	effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	util.Effect("HelicopterMegaBomb", effectdata)
	util.Effect("Explode", effectdata)
	self.Damage = self.mydamage or self.Damage
	util.BlastDamage(self, self.Owner, self:GetPos(), math.pow( self.Damage / 100,0.75) * 200, self.Damage )
	shake = ents.Create("env_shake")
	shake:SetOwner(self.Owner)
	shake:SetPos(self:GetPos())
	shake:SetKeyValue("amplitude", tostring(self.Damage * 20)) -- Power of the shake
	shake:SetKeyValue("radius", tostring( math.pow( self.Damage / 100,0.75) * 400) ) -- Radius of the shake
	shake:SetKeyValue("duration", tostring( self.Damage / 200 )) -- Time of shake
	shake:SetKeyValue("frequency", "255") -- How har should the screenshake be
	shake:SetKeyValue("spawnflags", "4") -- Spawnflags(In Air)
	shake:Spawn()
	shake:Activate()
	shake:Fire("StartShake", "", 0)
	self:EmitSound("weapons/explode" .. math.random(3, 5) .. ".wav", self.Pos, 100, 100)
	self:Remove()
end

function ENT:PhysicsCollide(data, phys)
	if data.Speed > 60 then
		self:EmitSound(Sound("HEGrenade.Bounce"))
		local impulse = (data.OurOldVelocity - 2 * data.OurOldVelocity:Dot(data.HitNormal) * data.HitNormal) * 0.25
		phys:ApplyForceCenter(impulse)
	end
end