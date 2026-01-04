SWEP.Base = "tfa_gun_base"
DEFINE_BASECLASS(SWEP.Base)

SWEP.Primary.Automatic = true
SWEP.Secondary.Automatic = true

SWEP.Primary.RPM = 120
SWEP.Secondary.RPM = 60

SWEP.SlashDelay = 0.15
SWEP.StabDelay = 0.33

SWEP.SlashLength = 32
SWEP.StabLength = 24

SWEP.Primary.Sound = Sound("Weapon_Knife.hull")
SWEP.KnifeShink = "Weapon_Knife.HitWall"
SWEP.KnifeSlash = "Weapon_Knife.Hit"
SWEP.KnifeStab = "Weapon_Knife.hull"

SWEP.SlashTable = {"midslash1", "midslash2"}
SWEP.StabTable = {"stab"}
SWEP.StabMissTable = {"stab_miss"}

SWEP.DisableIdleAnimations = false

SWEP.DamageType = DMG_SLASH
SWEP.MuzzleFlashEffect = ""
SWEP.DoMuzzleFlash = false
SWEP.WeaponLength = 1

SWEP.Primary.Ammo = ""
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1

SWEP.data = {}
SWEP.data.ironsights = 0

SWEP.Callback = {}

local l_CT = CurTime
local l_IsFirstTimePredicted = IsFirstTimePredicted
local l_mathRand = math.Rand
local l_mathRandom = math.random
local l_utilTraceHull = util.TraceHull
local l_IsValid = IsValid

local hull = {
	start = nil,
	endpos = nil,
	filter = nil,
	mins = Vector(-10, -5, 0),
	maxs = Vector(10, 5, 5)
}

function SWEP:Deploy()
	self.StabIndex = l_mathRandom(1, #self.StabTable)
	self.StabMiss = l_mathRandom(1, #self.StabMissTable)
	self.SlashCounter = 1
	self.hull = 1
	return BaseClass.Deploy(self)
end

function SWEP:PrimaryAttack()
	if not self:OwnerIsValid() then return end
	if not TFA.Enum.ReadyStatus[self:GetStatus()] then return end

	local ct = l_CT()
	if self:GetNextPrimaryFire() < ct and self.Owner:IsPlayer() and not self.Owner:KeyDown(IN_RELOAD) then
		self.hull = (self.hull or 0) + 1
		if self.hull > #self.SlashTable then
			self.hull = 1
		end

		self:SendViewModelSeq(self.SlashTable[self.hull])

		if l_IsFirstTimePredicted() then
			self:EmitSound(self.Primary.Sound)
		end

		self.Owner:SetAnimation(PLAYER_ATTACK1)

		local delay = 1 / (self.Primary.RPM / 60)
		self:SetNextPrimaryFire(ct + delay)
		self:SetNextSecondaryFire(ct + delay)

		self:SetStatus(TFA.Enum.STATUS_RELOADING)
		self:SetStatusEnd(ct + self.SlashDelay)
	end
end

function SWEP:SecondaryAttack()
	if not self:OwnerIsValid() then return end
	if not TFA.Enum.ReadyStatus[self:GetStatus()] then return end

	local ct = l_CT()
	if self:GetNextSecondaryFire() < ct and self.Owner:IsPlayer() and not self.Owner:KeyDown(IN_RELOAD) then
		if l_IsFirstTimePredicted() then
			self:EmitSound(self.Primary.Sound)
		end

		local pos = self.Owner:GetShootPos()
		local dir = self.Owner:GetAimVector()

		hull.start = pos
		hull.endpos = pos + (dir * self.StabLength)
		hull.filter = self.Owner

		local stabtrace = l_utilTraceHull(hull)

		if stabtrace.Hit then
			self.StabIndex = (self.StabIndex or 0) + 1
			if self.StabIndex > #self.StabTable then
				self.StabIndex = 1
			end
			self:SendViewModelSeq(self.StabTable[self.StabIndex])
		else
			self.StabMiss = (self.StabMiss or 0) + 1
			if self.StabMiss > #self.StabMissTable then
				self.StabMiss = 1
			end
			self:SendViewModelSeq(self.StabMissTable[self.StabMiss])
		end

		self.Owner:SetAnimation(PLAYER_ATTACK1)

		local delay = 1 / (self.Secondary.RPM / 60)
		self:SetNextPrimaryFire(ct + delay)
		self:SetNextSecondaryFire(ct + delay)

		self:SetStatus(TFA.Enum.STATUS_SILENCER_TOGGLE)
		self:SetStatusEnd(ct + self.StabDelay)
	end
end

function SWEP:PrimarySlash()
	if not self:OwnerIsValid() then return end

	local owner = self.Owner
	local pos = owner:GetShootPos()
	local dir = owner:GetAimVector()

	local damagedice = l_mathRand(0.85, 1.25)
	local dmgval = (self.Primary.Damage or 0) * damagedice
	if not dmgval or dmgval <= 1 then
		dmgval = 40 * damagedice
	end

	owner:LagCompensation(true)

	hull.start = pos
	hull.endpos = pos + (dir * self.SlashLength)
	hull.filter = owner

	local slashtrace = l_utilTraceHull(hull)

	if slashtrace.Hit then
		local ent = slashtrace.Entity
		if l_IsValid(ent) then
			if game.GetTimeScale() > 0.99 then
				owner:FireBullets({
					Attacker = owner,
					Inflictor = self,
					Damage = dmgval,
					Force = dmgval * 0.15,
					Distance = self.SlashLength + 10,
					HullSize = 12.5,
					Tracer = 0,
					Src = pos,
					Dir = dir,
					Callback = function(_, _, c)
						if c then
							c:SetDamageType(DMG_SLASH)
						end
					end
				})
			else
				local dmg = DamageInfo()
				dmg:SetAttacker(owner)
				dmg:SetInflictor(self)
				dmg:SetDamagePosition(pos)
				dmg:SetDamageForce(dir * (dmgval * 0.25))
				dmg:SetDamage(dmgval)
				dmg:SetDamageType(DMG_SLASH)
				ent:TakeDamageInfo(dmg)
			end

			if slashtrace.MatType == MAT_FLESH or slashtrace.MatType == MAT_ALIENFLESH then
				self:EmitSound(self.KnifeSlash)
			else
				self:EmitSound(self.KnifeShink)
			end
		end
	end

	owner:LagCompensation(false)
end

function SWEP:Stab()
	if not self:OwnerIsValid() then return end

	local owner = self.Owner
	local pos = owner:GetShootPos()
	local dir = owner:GetAimVector()

	local damagedice = l_mathRand(0.85, 1.25)
	local dmgval = (self.Secondary.Damage or 0) * damagedice
	if not dmgval or dmgval <= 1 then
		dmgval = 100 * damagedice
	end

	owner:LagCompensation(true)

	hull.start = pos
	hull.endpos = pos + (dir * self.StabLength)
	hull.filter = owner

	local stabtrace = l_utilTraceHull(hull)

	if stabtrace.Hit then
		local ent = stabtrace.Entity
		if l_IsValid(ent) then
			if game.GetTimeScale() > 0.99 then
				owner:FireBullets({
					Attacker = owner,
					Inflictor = self,
					Damage = dmgval,
					Force = dmgval * 0.15,
					Distance = self.StabLength + 10,
					HullSize = 12.5,
					Tracer = 0,
					Src = pos,
					Dir = dir,
					Callback = function(_, _, c)
						if c then
							c:SetDamageType(DMG_SLASH)
						end
					end
				})
			else
				local dmg = DamageInfo()
				dmg:SetAttacker(owner)
				dmg:SetInflictor(self)
				dmg:SetDamagePosition(pos)
				dmg:SetDamageForce(dir * (dmgval * 0.25))
				dmg:SetDamage(dmgval)
				dmg:SetDamageType(DMG_SLASH)
				ent:TakeDamageInfo(dmg)
			end

			if stabtrace.MatType == MAT_FLESH or stabtrace.MatType == MAT_ALIENFLESH then
				self:EmitSound(self.KnifeSlash)
			else
				self:EmitSound(self.KnifeShink)
			end
		end
	end

	owner:LagCompensation(false)
end

function SWEP:ThrowKnife()
	if not l_IsFirstTimePredicted() then return end
	if not self:OwnerIsValid() then return end

	self:EmitSound(self.Primary.Sound)

	if SERVER then
		local owner = self.Owner
		local knife = ents.Create("tfa_thrown_blade")
		if l_IsValid(knife) then
			knife.SetNW2String = knife.SetNW2String or knife.SetNWString
			knife.GetNW2String = knife.GetNW2String or knife.GetNWString

			knife:SetAngles(owner:EyeAngles())
			knife:SetPos(owner:GetShootPos())
			knife:SetOwner(owner)
			knife:SetModel(self.WorldModel)
			knife:SetPhysicsAttacker(owner)
			knife:Spawn()
			knife:Activate()

			knife:SetNW2String("ClassName", self.ClassName or self:GetClass())

			owner:SetAnimation(PLAYER_ATTACK1)

			local phys = knife:GetPhysicsObject()
			if l_IsValid(phys) then
				phys:SetVelocity(owner:GetAimVector() * 1500)
				phys:AddAngleVelocity(Vector(0, 500, 0))
			end

			owner:StripWeapon(self:GetClass())
		end
	end
end

function SWEP:Reload()
	if not self:OwnerIsValid() then return end
	self:ThrowKnife()
end

function SWEP:Think2()
	local ct = l_CT()
	if self:GetStatus() == TFA.Enum.STATUS_RELOADING and ct > self:GetStatusEnd() then
		self:PrimarySlash()
	elseif self:GetStatus() == TFA.Enum.STATUS_SILENCER_TOGGLE and ct > self:GetStatusEnd() then
		self:Stab()
	end
	BaseClass.Think2(self)
end

SWEP.IsKnife = true
SWEP.WeaponLength = 8

function SWEP:CanAttack()
	if self:GetNextPrimaryFire() > l_CT() then return false end
	if self:GetStatus() == TFA.Enum.STATUS_RELOADING then return false end
	return true
end

function SWEP:GetSlashTrace(tracedata, _)
	tracedata.mins = Vector(-10, -5, 0)
	tracedata.maxs = Vector(10, 5, 5)
	return util.TraceHull(tracedata)
end
