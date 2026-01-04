local l_mathClamp = math.Clamp

local cv_dmg_mult = GetConVar("sv_tfa_damage_multiplier")
local cv_dmg_mult_min = GetConVar("sv_tfa_damage_mult_min")
local cv_dmg_mult_max = GetConVar("sv_tfa_damage_mult_max")
local cv_forcemult = GetConVar("sv_tfa_force_multiplier")

local penetration_max_cvar = GetConVar("sv_tfa_penetration_limit")
local penetration_cvar = GetConVar("sv_tfa_bullet_penetration")
local cv_rangemod = GetConVar("sv_tfa_range_modifier")
local cv_decalbul = GetConVar("sv_tfa_fx_penetration_decal")

local TracerName
local sp = game.SinglePlayer()

local function DisableOwnerDamage(attacker, tr, dmginfo)
	if tr and tr.Entity == attacker and dmginfo then
		dmginfo:ScaleDamage(0)
	end
end

local matnamec = {
	[MAT_GLASS] = "glass",
	[MAT_GRATE] = "metal",
	[MAT_METAL] = "metal",
	[MAT_VENT] = "metal",
	[MAT_COMPUTER] = "metal",
	[MAT_CLIP] = "metal",
	[MAT_FLESH] = "flesh",
	[MAT_ALIENFLESH] = "flesh",
	[MAT_ANTLION] = "flesh",
	[MAT_FOLIAGE] = "foliage",
	[MAT_DIRT] = "dirt",
	[MAT_GRASS] = "dirt",
	[MAT_EGGSHELL] = "plastic",
	[MAT_PLASTIC] = "plastic",
	[MAT_TILE] = "ceramic",
	[MAT_CONCRETE] = "ceramic",
	[MAT_WOOD] = "wood",
	[MAT_SAND] = "sand",
	[MAT_SNOW] = "snow",
	[MAT_SLOSH] = "slime",
	[MAT_WARPSHIELD] = "energy",
	[89] = "glass",
	[-1] = "default"
}

local matfacs = {
	metal = 2.5,
	wood = 8,
	plastic = 5,
	flesh = 8,
	ceramic = 1.0,
	glass = 10,
	energy = 0.05,
	sand = 0.7,
	slime = 0.7,
	dirt = 2.0,
	foliage = 6.5,
	default = 4
}

local BulletProto = {}
BulletProto.__index = BulletProto

function BulletProto:Penetrate(attacker, traceres, dmginfo, weapon)
	if not IsValid(weapon) then return end
	if not traceres or not dmginfo then return end

	local hitent = traceres.Entity

	if IsValid(hitent) and (hitent == attacker or hitent == weapon:GetOwner()) then
		dmginfo:ScaleDamage(0)
	end

	if not self.HasAppliedRange then
		local range = (weapon.Primary and weapon.Primary.Range) or 8192
		local falloff = (weapon.Primary and weapon.Primary.RangeFalloff) or 0
		if range <= 0 then range = 8192 end

		local bulletdistance = (traceres.HitPos - traceres.StartPos):Length()
		local damagescale = bulletdistance / range
		damagescale = math.Clamp(damagescale - falloff, 0, 1)

		local denom = math.max(1 - falloff, 0.01)
		damagescale = math.Clamp(damagescale / denom, 0, 1)

		local rm = cv_rangemod and cv_rangemod:GetFloat() or 1
		damagescale = (1 - rm) + (math.Clamp(1 - damagescale, 0, 1) * rm)

		dmginfo:ScaleDamage(damagescale)
		self.HasAppliedRange = true
	end

	if weapon.Primary and weapon.Primary.DamageType then
		dmginfo:SetDamageType(weapon.Primary.DamageType)
	end

	if SERVER and IsValid(attacker) and attacker:IsPlayer() and IsValid(hitent) and (hitent:IsPlayer() or hitent:IsNPC()) then
		net.Start("tfaHitmarker")
		net.Send(attacker)
	end

	if weapon.Primary and weapon.Primary.DamageType and weapon.Primary.DamageType ~= DMG_BULLET then
		if (dmginfo:IsDamageType(DMG_SHOCK) or dmginfo:IsDamageType(DMG_BLAST)) and traceres.Hit and IsValid(hitent) and hitent:GetClass() == "npc_strider" then
			hitent:SetHealth(math.max(hitent:Health() - dmginfo:GetDamage(), 2))

			if hitent:Health() <= 3 then
				hitent:Extinguish()
				hitent:Fire("sethealth", "-1", 0.01)
				dmginfo:ScaleDamage(0)
			end
		end

		if dmginfo:IsDamageType(DMG_BURN) and traceres.Hit and IsValid(hitent) and not traceres.HitWorld and not traceres.HitSky and dmginfo:GetDamage() > 1 and hitent.Ignite then
			hitent:Ignite(dmginfo:GetDamage() / 2, 1)
		end

		if dmginfo:IsDamageType(DMG_BLAST) and traceres.Hit and not traceres.HitSky then
			local tmpdmg = dmginfo:GetDamage()
			local wepOwner = weapon:GetOwner()
			util.BlastDamage(weapon, IsValid(wepOwner) and wepOwner or weapon, traceres.HitPos, tmpdmg / 2, tmpdmg)

			local fx = EffectData()
			fx:SetOrigin(traceres.HitPos)
			fx:SetNormal(traceres.HitNormal or traceres.Normal or vector_origin)

			if tmpdmg > 90 then
				util.Effect("Explosion", fx)
			elseif tmpdmg > 45 then
				util.Effect("cball_explode", fx)
			else
				util.Effect("ManhackSparks", fx)
			end

			dmginfo:ScaleDamage(0.15)
		end
	end

	if penetration_cvar and not penetration_cvar:GetBool() then return end

	local maxCfg = weapon.Primary and weapon.Primary.MaxPenetration or 0
	local lim = penetration_max_cvar and penetration_max_cvar:GetInt() or 1
	if lim < 0 then
		lim = maxCfg
	else
		lim = math.max(lim - 1, 0)
		lim = (maxCfg > 0) and math.min(lim, maxCfg) or lim
	end

	if lim <= 0 then return end
	if (self.PenetrationCount or 0) >= lim then return end

	local mult = weapon:GetPenetrationMultiplier(traceres.MatType or -1)
	local force = tonumber(self.Force) or 0
	local offLen = math.Clamp(force * mult, 0, 32)
	if offLen <= 0 then return end

	local nrm = traceres.HitNormal or traceres.Normal or vector_origin
	local penetrationoffset = nrm * offLen

	local pentrace = {}
	pentrace.endpos = traceres.HitPos
	pentrace.start = traceres.HitPos + penetrationoffset
	pentrace.mask = MASK_SHOT
	pentrace.filter = {attacker, weapon}

	local pentraceres = util.TraceLine(pentrace)
	if pentraceres.StartSolid or pentraceres.Fraction >= 1.0 or pentraceres.Fraction <= 0.0 then return end

	local bull = table.Copy(self)
	setmetatable(bull, BulletProto)

	local spreadv = self.Spread
	if spreadv then
		bull.Spread = Vector(spreadv.x, spreadv.y, spreadv.z)
	else
		bull.Spread = Vector(0, 0, 0)
	end

	bull.Src = pentraceres.HitPos
	bull.PenetrationCount = (self.PenetrationCount or 0) + 1
	bull.HullSize = 0

	if (bull.Num or 0) <= 1 then
		bull.Spread = Vector(0, 0, 0)
	end

	local dist = pentraceres.HitPos:Distance(traceres.HitPos)
	local denom = math.max(penetrationoffset:Length(), 0.001)

	local rngfac = math.pow(dist / denom, 2)
	local mfac = math.pow(mult / 10, 0.35)

	bull.Force = Lerp(rngfac, self.Force, (self.Force or 0) * mfac)
	bull.Damage = Lerp(rngfac, self.Damage, (self.Damage or 0) * mfac)

	if bull.Spread then
		bull.Spread = bull.Spread / math.sqrt(math.max(mfac, 0.001))
	end

	local decal = {
		Num = 1,
		Spread = vector_origin,
		Tracer = 0,
		Force = 0.1,
		Damage = 0.1
	}

	decal.Dir = -nrm * 64

	if IsValid(attacker) and attacker:IsPlayer() then
		local eye = attacker:EyeAngles()
		decal.Dir = eye:Forward() * (-64)
		bull.Dir = eye:Forward()
	end

	decal.Src = pentraceres.HitPos - decal.Dir * 4
	decal.TracerName = ""
	decal.Callback = DisableOwnerDamage

	if bull.TracerName ~= "Ar2Tracer" then
		local fx = EffectData()
		fx:SetOrigin(bull.Src)

		local rv = VectorRand()
		local spv = bull.Spread or vector_origin
		fx:SetNormal((bull.Dir or nrm) + rv * spv)

		fx:SetMagnitude(1)
		fx:SetEntity(weapon)
		util.Effect("tfa_penetrate", fx)

		bull.Tracer = 0
		bull.TracerName = ""
	end

	bull.Callback = function(a, b, c)
		if not IsValid(weapon) then return end
		if bull.Callback2 then
			bull.Callback2(a, b, c)
		end
		BulletProto.Penetrate(bull, a, b, c, weapon)
	end

	local doDecal = cv_decalbul and cv_decalbul:GetBool() or false
	timer.Simple(0, function()
		if not IsValid(attacker) then return end
		if doDecal then
			attacker:FireBullets(decal)
		end
		attacker:FireBullets(bull)
	end)
end

function SWEP:ShootBulletInformation()
	local ifp = IsFirstTimePredicted()

	self:UpdateConDamage()
	self.lastbul = nil
	self.lastbulnoric = false

	self.ConDamageMultiplier = cv_dmg_mult and cv_dmg_mult:GetFloat() or 1
	if not ifp then return end

	local con, rec = self:CalculateConeRecoil()

	local mn = cv_dmg_mult_min and cv_dmg_mult_min:GetFloat() or 1
	local mx = cv_dmg_mult_max and cv_dmg_mult_max:GetFloat() or 1
	local tmpranddamage = math.Rand(mn, mx)

	local basedamage = (self.ConDamageMultiplier or 1) * ((self.Primary and self.Primary.Damage) or 0)
	local dmg = basedamage * tmpranddamage

	local ns = tonumber(self.Primary and self.Primary.NumShots) or 1
	if ns <= 0 then ns = 1 end

	local clip = (self.Primary and self.Primary.ClipSize == -1) and self:Ammo1() or self:Clip1()
	if clip == nil then clip = ns end

	local frac = 1
	if ns > 0 then
		frac = math.min((clip or ns) / ns, 1)
	end
	ns = math.max(1, math.floor(ns * frac + 0.5))

	self:ShootBullet(dmg, rec, ns, con)
end

function SWEP:ShootBullet(damage, recoil, num_bullets, aimcone, disablericochet, bulletoverride)
	if not IsFirstTimePredicted() and not sp then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	num_bullets = tonumber(num_bullets) or 1
	if num_bullets <= 0 then num_bullets = 1 end

	aimcone = tonumber(aimcone) or 0
	if aimcone < 0 then aimcone = 0 end

	if self.ProjectileEntity then
		if SERVER then
			for i = 1, num_bullets do
				local ent = ents.Create(self.ProjectileEntity)
				if not IsValid(ent) then continue end

				local ang = owner:EyeAngles()
				ang:RotateAroundAxis(ang:Right(), -aimcone / 2 + math.Rand(0, aimcone))
				ang:RotateAroundAxis(ang:Up(), -aimcone / 2 + math.Rand(0, aimcone))

				local dir = ang:Forward()

				ent:SetPos(owner:GetShootPos())
				ent:SetAngles(owner:EyeAngles())

				ent.damage = (self.Primary and self.Primary.Damage) or 0
				ent.mydamage = ent.damage

				if self.ProjectileModel then
					ent:SetModel(self.ProjectileModel)
				end

				ent:SetOwner(owner)
				ent.Owner = owner

				ent:Spawn()
				ent:SetVelocity(dir * (self.ProjectileVelocity or 0))

				local phys = ent:GetPhysicsObject()
				if IsValid(phys) then
					phys:SetVelocity(dir * (self.ProjectileVelocity or 0))
				end

				if self.ProjectileModel then
					ent:SetModel(self.ProjectileModel)
				end
			end
		end

		return
	end

	if self.Tracer == 1 then
		TracerName = "Ar2Tracer"
	elseif self.Tracer == 2 then
		TracerName = "AirboatGunHeavyTracer"
	else
		TracerName = "Tracer"
	end

	if self.TracerName and self.TracerName ~= "" then
		TracerName = self.TracerName
	end

	local bt = bulletoverride or setmetatable({}, BulletProto)

	bt.Attacker = owner
	bt.Inflictor = self
	bt.Num = num_bullets
	bt.Src = owner:GetShootPos()

	local srcAng = owner:GetAimVector():Angle()
	srcAng = srcAng + owner:GetViewPunchAngles()
	bt.Dir = srcAng:Forward()

	bt.HullSize = (self.Primary and self.Primary.HullSize) or 0
	bt.Spread = Vector(aimcone, aimcone, 0)

	bt.Tracer = self.TracerCount or 3
	bt.TracerName = TracerName

	bt.PenetrationCount = 0
	bt.AmmoType = self:GetPrimaryAmmoType()

	local ku = (self.Primary and self.Primary.KickUp) or 1
	local kd = (self.Primary and self.Primary.KickDown) or 1
	local kh = (self.Primary and self.Primary.KickHorizontal) or 1
	local fm = cv_forcemult and cv_forcemult:GetFloat() or 1

	bt.Force = (damage or 0) / 6 * math.sqrt(ku + kd + kh) * fm * (self:GetAmmoForceMultiplier() or 1)
	bt.Damage = damage or 0
	bt.HasAppliedRange = false

	if self.CustomBulletCallback then
		bt.Callback2 = self.CustomBulletCallback
	else
		bt.Callback2 = nil
	end

	bt.Callback = function(a, b, c)
		if not IsValid(self) then return end
		if bt.Callback2 then
			bt.Callback2(a, b, c)
		end
		BulletProto.Penetrate(bt, a, b, c, self)
	end

	owner:FireBullets(bt)
end

function SWEP:Recoil(recoil, ifp)
	if sp and type(recoil) == "string" then
		local _, CurrentRecoil = self:CalculateConeRecoil()
		self:Recoil(CurrentRecoil, true)
		return
	end

	recoil = tonumber(recoil) or 1

	if ifp then
		local inc = (self.Primary and self.Primary.SpreadIncrement) or 0
		local mx = (self.Primary and self.Primary.SpreadMultiplierMax) or 1
		self.SpreadRatio = l_mathClamp((self.SpreadRatio or 1) + inc, 1, mx)
	end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	local seed = tonumber(self:GetSeed()) or math.floor(CurTime() * 1000)
	local id = tostring(self:EntIndex())

	local kd = (self.Primary and self.Primary.KickDown) or 1
	local ku = (self.Primary and self.Primary.KickUp) or 1
	local kh = (self.Primary and self.Primary.KickHorizontal) or 1
	local srf = (self.Primary and self.Primary.StaticRecoilFactor) or 0

	local pitch = util.SharedRandom("tfa_recoil_p_" .. id, kd, ku, seed) * recoil * -1
	local yaw = util.SharedRandom("tfa_recoil_y_" .. id, -kh, kh, seed + 1337) * recoil

	local ea = owner:EyeAngles()
	local tmprecoilang = Angle(pitch, yaw, 0)

	local vp = owner:GetViewPunchAngles()
	local maxdist = math.min(math.max(0, 89 + ea.p - math.abs((vp and vp.p or 0) * 2)), 88.5)
	local tmprecoilangclamped = Angle(math.Clamp(tmprecoilang.p, -maxdist, maxdist), tmprecoilang.y, 0)

	owner:ViewPunch(tmprecoilangclamped * (1 - srf))

	if (sp and SERVER) or (CLIENT and ifp) then
		local neweyeang = ea + tmprecoilang * srf
		owner:SetEyeAngles(neweyeang)
	end
end

function SWEP:GetAmmoForceMultiplier()
	local am = string.lower((self.Primary and self.Primary.Ammo) or "")

	if am == "pistol" then
		return 0.4
	elseif am == "357" then
		return 0.6
	elseif am == "smg1" then
		return 0.475
	elseif am == "ar2" then
		return 0.6
	elseif am == "buckshot" then
		return 0.5
	elseif am == "slam" then
		return 0.5
	elseif am == "airboatgun" then
		return 0.7
	elseif am == "sniperpenetratedround" then
		return 1
	end

	return 1
end

function SWEP:GetMaterialConcise(mat)
	return matnamec[mat] or matnamec[-1]
end

function SWEP:GetPenetrationMultiplier(matt)
	local mat = isstring(matt) and matt or self:GetMaterialConcise(matt)
	local fac = matfacs[mat or "default"] or matfacs.default
	local pm = (self.Primary and self.Primary.PenetrationMultiplier) or 1
	return fac * pm
end
