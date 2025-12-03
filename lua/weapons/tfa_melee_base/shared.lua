DEFINE_BASECLASS("tfa_bash_base")
SWEP.DrawCrosshair = false
SWEP.SlotPos = 72
SWEP.Slot = 0
SWEP.WeaponLength = 8
SWEP.data = {}
SWEP.data.ironsights = 0
SWEP.Primary.Directional = false
SWEP.Primary.Attacks = {}
SWEP.DTapActivities = SWEP.DTapActivities or {}

local l_CT = CurTime

--[[{
{
['act'] = ACT_VM_HITLEFT, -- Animation; ACT_VM_THINGY, ideally something unique per-sequence
['src'] = Vector(20,10,0), -- Trace source; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
['dir'] = Vector(-40,30,0), -- Trace direction/length; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
['dmg'] = 60, --Damage
['dmgtype'] = DMG_SLASH, --DMG_SLASH,DMG_CRUSH, etc.
['delay'] = 0.2, --Delay
['spr'] = true, --Allow attack while sprinting?
['snd'] = "Swing.Sound", -- Sound ID
["viewpunch"] = Angle(1,-10,0), --viewpunch angle
['end'] = 1, --time before next attack
['hull'] = 10, --Hullsize
['direction'] = "L" --Swing direction
},
{
['act'] = ACT_VM_HITRIGHT, -- Animation; ACT_VM_THINGY, ideally something unique per-sequence
['src'] = Vector(-10,10,0), -- Trace source; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
['dir'] = Vector(40,30,0), -- Trace direction/length; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
['dmg'] = 60, --Damage
['dmgtype'] = DMG_SLASH, --DMG_SLASH,DMG_CRUSH, etc.
['delay'] = 0.2, --Delay
['spr'] = true, --Allow attack while sprinting?
['snd'] = "Swing.Sound", -- Sound ID
["viewpunch"] = Angle(1,10,0), --viewpunch angle
['end'] = 1, --time before next attack
['hull'] = 10, --Hullsize
['direction'] = "R" --Swing direction
}
}

SWEP.Secondary.Attacks = {
{
['act'] = ACT_VM_MISSCENTER, -- Animation; ACT_VM_THINGY, ideally something unique per-sequence
['src'] = Vector(0,5,0), -- Trace source; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
['dir'] = Vector(0,50,0), -- Trace direction/length; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
['dmg'] = 60, --Damage
['dmgtype'] = DMG_SLASH, --DMG_SLASH,DMG_CRUSH, etc.
['delay'] = 0.2, --Delay
['spr'] = true, --Allow attack while sprinting?
['snd'] = "Swing.Sound", -- Sound ID
["viewpunch"] = Angle(5,0,0), --viewpunch angle
['end'] = 1, --time before next attack
['combotime'] = 0.2
}
}
]]--
SWEP.Secondary.Directional = true
SWEP.Primary.Automatic = true
SWEP.Secondary.Automatic = true
SWEP.ImpactDecal = "ManhackCut"
SWEP.Secondary.CanBash = false
SWEP.DefaultComboTime = 0.2
--[[ START OF BASE CODE ]]--
SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo = ""
SWEP.Seed = 0

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 30, "VP")
	self:NetworkVar("Float", 27, "VPTime")
	self:NetworkVar("Float", 28, "VPPitch")
	self:NetworkVar("Float", 29, "VPYaw")
	self:NetworkVar("Float", 30, "VPRoll")
	self:NetworkVar("Int", 30, "Seed")
	self:NetworkVar("Int", 31, "MelAttackID")
	self:SetMelAttackID(1)
	self:SetVP(false)
	self:SetVPPitch(0)
	self:SetVPYaw(0)
	self:SetVPRoll(0)
	self:SetVPTime(-1)

	if SERVER then
		self:SetSeed(self.Seed)
	end

	return BaseClass.SetupDataTables(self)
end

function SWEP:Deploy()
	self:SetMelAttackID(1)
	self:SetVP(false)
	self:SetVPPitch(0)
	self:SetVPYaw(0)
	self:SetVPRoll(0)
	self:SetVPTime(-1)
	self.up_hat = false

	if SERVER then
		self:SetSeed(self.Seed)
	end

	return BaseClass.Deploy(self)
end

local att = {}
local attack
local vm
local ind
local tr, traceres
local pos, ang, mdl, ski, prop
local succ

tr = {}
local bul = {}
local srctbl
SWEP.hpf = false
SWEP.hpw = false

function SWEP:ApplyForce(ent, force, posv, now)
	if not IsValid(ent) or not ent.GetPhysicsObjectNum then return end

	if now then
		if ent.GetRagdollEntity then
			ent = ent:GetRagdollEntity() or ent
		end

		if not IsValid(ent) then return end
		local phys = ent:GetPhysicsObjectNum(0)

		if IsValid(phys) then
			if ent:IsPlayer() or ent:IsNPC() then
				ent:SetVelocity( force * 0.1 )
				phys:SetVelocity(phys:GetVelocity() + force * 0.1)
			else
				phys:ApplyForceOffset(force, posv)
			end
		end
	else
		timer.Simple(0, function()
			if IsValid(self) and self:OwnerIsValid() and IsValid(ent) then
				self:ApplyForce(ent, force, posv, true)
			end
		end)
	end
end

function SWEP:MakeDoor(ent, dmginfo)
	pos = ent:GetPos()
	ang = ent:GetAngles()
	mdl = ent:GetModel()
	ski = ent:GetSkin()
	ent:SetNotSolid(true)
	ent:SetNoDraw(true)
	prop = ents.Create("prop_physics")
	prop:SetPos(pos)
	prop:SetAngles(ang)
	prop:SetModel(mdl)
	prop:SetSkin(ski or 0)
	prop:Spawn()
	prop:SetVelocity(dmginfo:GetDamageForce() * 48)
	prop:GetPhysicsObject():ApplyForceOffset(dmginfo:GetDamageForce() * 48, dmginfo:GetDamagePosition())
	prop:SetPhysicsAttacker(dmginfo:GetAttacker())
	prop:EmitSound("physics/wood/wood_furniture_break" .. tostring(math.random(1, 2)) .. ".wav", 110, math.random(90, 110))
end

function SWEP:BurstDoor(ent, dmginfo)
	if not ents.Create then return end
	if dmginfo:GetDamage() > 60 and ( dmginfo:IsDamageType(DMG_CRUSH) or dmginfo:IsDamageType(DMG_CLUB) ) and ( ent:GetClass() == "func_door_rotating" or ent:GetClass() == "prop_door_rotating" ) then
		if dmginfo:GetDamage() > 150 then
			local ply = self.Owner
			self:MakeDoor(ent, dmginfo)
			ply:EmitSound("ambient/materials/door_hit1.wav", 100, math.random(90, 110))
		else
			local ply = self.Owner
			ply:EmitSound("ambient/materials/door_hit1.wav", 100, math.random(90, 110))
			ply.oldname = ply:GetName()
			ply:SetName("bashingpl" .. ply:EntIndex())
			ent:SetKeyValue("Speed", "500")
			ent:SetKeyValue("Open Direction", "Both directions")
			ent:SetKeyValue("opendir", "0")
			ent:Fire("unlock", "", .01)
			ent:Fire("openawayfrom", "bashingpl" .. ply:EntIndex(), .01)

			timer.Simple(0.02, function()
				if IsValid(ply) then
					ply:SetName(ply.oldname)
				end
			end)

			timer.Simple(0.3, function()
				if IsValid(ent) then
					ent:SetKeyValue("Speed", "100")
				end
			end)
		end
	end
end

function SWEP:Think2()
	if not self:VMIV() then return end
	if self:GetVP() and CurTime() > self:GetVPTime() then
		self:SetVP(false)
		self:SetVPTime(-1)
		self.Owner:ViewPunch(Angle(self:GetVPPitch(), self:GetVPYaw(), self:GetVPRoll()))
	end
	self:StrikeThink()
	BaseClass.Think2(self)
end

function SWEP:StrikeThink()
	if self:IsSafety() then return end

	if not IsFirstTimePredicted() then return end
	if self:GetStatus() ~= TFA.Enum.STATUS_SHOOTING then return end
	if self.up_hat then return end

	if CurTime() > self:GetStatusEnd() then
		ind = self:GetMelAttackID() or 1
		srctbl = (ind < 0) and self.Secondary.Attacks or self.Primary.Attacks
		attack = srctbl[math.abs(ind)]
		self.DamageType = attack.dmgtype
		--Just attacked, so don't do it again
		self.up_hat = true
		self:SetStatus(TFA.Enum.STATUS_IDLE)
		--Prepare Data
		local eang = self.Owner:EyeAngles()
		tr.start = self.Owner:GetShootPos()
		tr.endpos = tr.start + eang:Forward() * attack.len
		tr.mask = MASK_SHOT

		tr.filter = function(ent)
			if ent == self.Owner or ent == self then return false end

			return true
		end

		self.Owner:LagCompensation(true)

		if attack.hull and attack.hull > 0 then
			tr.mask = MASK_SHOT_HULL
			tr.mins = Vector(-attack.hull, -attack.hull, -attack.hull) / 2
			tr.maxs = Vector(attack.hull, attack.hull, attack.hull) / 2
			traceres = util.TraceHull(tr)
		else
			traceres = util.TraceLine(tr)
		end

		self.Owner:LagCompensation(false)
		local dirvec = Vector(0, 0, 0)
		dirvec:Add(attack.dir.x * eang:Right())
		dirvec:Add(attack.dir.y * eang:Forward())
		dirvec:Add(attack.dir.z * eang:Up())
		bul.Attacker = self.Owner or self
		bul.Inflictor = self
		bul.Damage = attack.dmg
		bul.Force = 1 --attack.force or attack.dmg/4
		bul.Dir = dirvec
		bul.Src = traceres.HitPos + eang:Forward() * 16 - dirvec / 2
		bul.Distance = dirvec:Length() + attack.len / 4
		bul.Range = bul.Distance
		bul.Tracer = 0
		bul.Num = 1
		bul.Spread = vector_origin
		bul.HullSize = 16 --attack.hull
		local hpw, hpf, hitent = nil, nil, nil
		local forcevec = dirvec:GetNormalized() * (attack.force or attack.dmg / 4) * 128

		bul.Callback = function(a, b, c)
			if b.Fraction >= 1 then
				c:ScaleDamage(0)

				return
			end

			if b.HitPos:Distance(b.StartPos) >= bul.Distance then
				c:ScaleDamage(0)

				return
			end

			c:SetDamageType(attack.dmgtype or DMG_SLASH)
			hitent = b.Entity

			if c:IsDamageType(DMG_BURN) and hitent.Ignite then
				hitent:Ignite(bul.Damage / 10, 1)
			end

			if IsValid(self) then
				if IsValid(hitent) and (b.MatType == MAT_FLESH or hitent:IsPlayer() or hitent:IsRagdoll() or hitent:IsNPC()) and attack.hitflesh then
					if not hpf then
						self:EmitSound(attack.hitflesh)
						hpf = true
					end
				elseif attack.hitworld then
					if not hpw then
						self:EmitSound(attack.hitworld)
						hpw = true
					end

					hpw = true
				end

				self:DoImpactEffect(b, attack.dmgtype)
				self:ApplyForce(hitent, forcevec, traceres.HitPos)
				self:BurstDoor(hitent, c)
			end
		end

		local tr2 = {}
		tr2.start = bul.Src
		tr2.endpos = bul.Src + bul.Dir
		tr2.mask = MASK_SHOT
		tr2.filter = tr.filter
		local traceres2 = util.TraceLine(tr2)

		if IsValid(traceres.Entity) then
			local ent = traceres.Entity
			local phys = traceres.Entity.GetPhysicsObjectNum and ent:GetPhysicsObjectNum(0)

			if ((IsValid(phys) and phys:GetMaterial() == "flesh") or ent:IsNPC() or ent:IsPlayer() or ent:IsRagdoll()) then
				if not hpf then
					self:EmitSound(attack.hitflesh)
					hpf = true
				end
			elseif attack.hitworld then
				if not hpw then
					self:EmitSound(attack.hitworld)
					hpw = true
				end
			end
		end

		if traceres2.Hit and traceres2.Fraction < 1 then
			self.Owner:FireBullets(bul)
		end

		if IsValid(traceres.Entity) and traceres.Entity ~= hitent and not traceres.HitWorld then
			local dmginfo = DamageInfo()
			dmginfo:SetAttacker(bul.Attacker)
			dmginfo:SetInflictor(bul.Inflictor)
			dmginfo:SetDamage(bul.Damage)
			dmginfo:SetDamageType(attack.dmgtype or DMG_SLASH)
			dmginfo:SetDamagePosition(traceres.HitPos)
			dmginfo:SetDamageForce(bul.Dir:GetNormalized() * bul.Force)
			local ent = traceres.Entity

			if IsValid(ent) and ent.TakeDamageInfo then
				ent:TakeDamageInfo(dmginfo)
			end

			if traceres.MatType == MAT_FLESH or traceres.MatType == MAT_ALIENFLESH then
				local fx = EffectData()
				fx:SetOrigin(traceres.HitPos)
				fx:SetNormal(traceres.HitNormal)
				fx:SetEntity(traceres.Entity)
				fx:SetColor(BLOOD_COLOR_RED or 0)
				util.Effect("BloodImpact", fx)
			end

			self:DoImpactEffect(traceres, attack.dmgtype)
			self:ApplyForce(traceres.Entity, forcevec, traceres.HitPos)
			self:BurstDoor(traceres.Entity, dmginfo)

			if dmginfo:IsDamageType(DMG_BURN) and traceres.Entity.Ignite then
				traceres.Entity:Ignite(bul.Damage / 10, 1)
			end
		end

		if traceres.HitWorld then
			bul.Src = self.Owner:GetShootPos()
			bul.Dir = self.Owner:GetAimVector()
			bul.Distance = attack.len
			bul.Range = bul.Distance
			bul.Force = 1
			bul.Damage = 1
			self.Owner:FireBullets(bul)
		end
	end
end

function SWEP:PlaySwing(act)
	self:SendViewModelAnim(act)
	return true, act
end

local lvec, ply, targ

lvec = Vector()

function SWEP:PrimaryAttack()
	if self:IsSafety() then return end
	if not self:VMIV() then return end
	if CurTime() <= self:GetNextPrimaryFire() then return end
	if not TFA.Enum.ReadyStatus[self:GetStatus()] then return end
	table.Empty(att)
	local founddir = false

	if self.Primary.Directional then
		ply = self.Owner
		--lvec = WorldToLocal(ply:GetVelocity(), Angle(0, 0, 0), vector_origin, ply:EyeAngles()):GetNormalized()
		lvec.x = 0
		lvec.y = 0
		if ply:KeyDown(IN_MOVERIGHT) then lvec.y = lvec.y - 1 end
		if ply:KeyDown(IN_MOVELEFT) then lvec.y = lvec.y + 1 end
		if ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_JUMP) then lvec.x = lvec.x + 1 end
		if ply:KeyDown(IN_BACK) or ply:KeyDown(IN_DUCK) then lvec.x = lvec.x - 1 end
		lvec.z = 0
		--lvec:Normalize()

		if lvec.y > 0.3 then
			targ = "L"
		elseif lvec.y < -0.3 then
			targ = "R"
		elseif lvec.x > 0.5 then
			targ = "F"
		elseif lvec.x < -0.1 then
			targ = "B"
		else
			targ = ""
		end

		for k, v in pairs(self.Primary.Attacks) do
			if (not self:GetSprinting() or v.spr) and v.direction and string.find(v.direction, targ) then
				if string.find(v.direction, targ) then
					founddir = true
				end

				table.insert(att, #att + 1, k)
			end
		end
	end

	if not self.Primary.Directional or #att <= 0 or not founddir then
		for k, v in pairs(self.Primary.Attacks) do
			if (not self:GetSprinting() or v.spr) and v.dmg then
				table.insert(att, #att + 1, k)
			end
		end
	end

	if #att <= 0 then return end

	if SERVER then
		timer.Simple(0, function()
			if IsValid(self) then
				self.Seed = math.random(-99999, 99999)
				self:SetSeed(self.Seed)
			end
		end)
	elseif IsFirstTimePredicted() then
		self.Seed = self:GetSeed()
	end

	math.randomseed(CurTime() + self.Seed)
	ind = att[math.random(1, #att)]
	attack = self.Primary.Attacks[ind]
	vm = self.Owner:GetViewModel()
	--We have attack isolated, begin attack logic
	self:PlaySwing(attack.act)

	if not attack.snd_delay or attack.snd_delay <= 0 then
		if IsFirstTimePredicted() then
			self:EmitSound(attack.snd)

			if self.Owner.Vox then
				self.Owner:Vox("bash", 4)
			end
		end

		self.Owner:ViewPunch(attack.viewpunch)
	elseif attack.snd_delay then
		timer.Simple(attack.snd_delay, function()
			if IsValid(self) and self:IsValid() and SERVER then
				self:EmitSound(attack.snd)

				if self:OwnerIsValid() and self.Owner.Vox then
					self.Owner:Vox("bash", 4)
				end
			end
		end)

		self:SetVP(true)
		self:SetVPPitch(attack.viewpunch.p)
		self:SetVPYaw(attack.viewpunch.y)
		self:SetVPRoll(attack.viewpunch.r)
		self:SetVPTime(CurTime() + attack.snd_delay)
		self.Owner:ViewPunch(-Angle(attack.viewpunch.p / 2, attack.viewpunch.y / 2, attack.viewpunch.r / 2))
	end

	self.up_hat = false
	self:SetStatus(TFA.Enum.STATUS_SHOOTING)
	self:SetMelAttackID(ind)
	self:SetStatusEnd(CurTime() + attack.delay)
	self:SetNextPrimaryFire(CurTime() + attack["end"])
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:SecondaryAttack()
	if self:IsSafety() then return end
	if not self:VMIV() then return end
	if CurTime() <= self:GetNextPrimaryFire() then return end
	if not TFA.Enum.ReadyStatus[self:GetStatus()] then return end
	table.Empty(att)
	local founddir = false

	if not self.Secondary.Attacks or #self.Secondary.Attacks == 0 then
		self.Secondary.Attacks = self.Primary.Attacks
	end

	if self.Secondary.Directional then
		ply = self.Owner
		--lvec = WorldToLocal(ply:GetVelocity(), Angle(0, 0, 0), vector_origin, ply:EyeAngles()):GetNormalized()
		lvec.x = 0
		lvec.y = 0
		if ply:KeyDown(IN_MOVERIGHT) then lvec.y = lvec.y - 1 end
		if ply:KeyDown(IN_MOVELEFT) then lvec.y = lvec.y + 1 end
		if ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_JUMP) then lvec.x = lvec.x + 1 end
		if ply:KeyDown(IN_BACK) or ply:KeyDown(IN_DUCK) then lvec.x = lvec.x - 1 end
		lvec.z = 0
		--lvec:Normalize()

		if lvec.y > 0.3 then
			targ = "L"
		elseif lvec.y < -0.3 then
			targ = "R"
		elseif lvec.x > 0.5 then
			targ = "F"
		elseif lvec.x < -0.1 then
			targ = "B"
		else
			targ = ""
		end

		for k, v in pairs(self.Secondary.Attacks) do
			if (not self:GetSprinting() or v.spr) and v.direction and string.find(v.direction, targ) then
				if string.find(v.direction, targ) then
					founddir = true
				end

				table.insert(att, #att + 1, k)
			end
		end
	end

	if not self.Secondary.Directional or #att <= 0 or not founddir then
		for k, v in pairs(self.Secondary.Attacks) do
			if (not self:GetSprinting() or v.spr) and v.dmg then
				table.insert(att, #att + 1, k)
			end
		end
	end

	if #att <= 0 then return end

	if SERVER then
		self.Seed = math.random(-99999, 99999)
		self:SetSeed(self.Seed)
	elseif IsFirstTimePredicted() then
		self.Seed = self:GetSeed()
	end

	math.randomseed(CurTime() + self.Seed)
	ind = att[math.random(1, #att)]
	attack = self.Secondary.Attacks[ind]
	vm = self.Owner:GetViewModel()
	--We have attack isolated, begin attack logic
	self:PlaySwing(attack.act)

	if not attack.snd_delay or attack.snd_delay <= 0 then
		if IsFirstTimePredicted() then
			self:EmitSound(attack.snd)

			if self.Owner.Vox then
				self.Owner:Vox("bash", 4)
			end
		end

		self.Owner:ViewPunch(attack.viewpunch)
	elseif attack.snd_delay then
		timer.Simple(attack.snd_delay, function()
			if IsValid(self) and self:IsValid() and SERVER then
				self:EmitSound(attack.snd)

				if self:OwnerIsValid() and self.Owner.Vox then
					self.Owner:Vox("bash", 4)
				end
			end
		end)

		self:SetVP(true)
		self:SetVPPitch(attack.viewpunch.p)
		self:SetVPYaw(attack.viewpunch.y)
		self:SetVPRoll(attack.viewpunch.r)
		self:SetVPTime(CurTime() + attack.snd_delay)
		self.Owner:ViewPunch(-Angle(attack.viewpunch.p / 2, attack.viewpunch.y / 2, attack.viewpunch.r / 2))
	end

	self.up_hat = false
	self:SetStatus(TFA.Enum.STATUS_SHOOTING)
	self:SetMelAttackID(-ind)
	self:SetStatusEnd(CurTime() + attack.delay)
	self:SetNextPrimaryFire(CurTime() + attack["end"])
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:AltAttack()
	if not self:VMIV() then return end
	if not TFA.Enum.ReadyStatus[self:GetStatus()] then return end
	if not self.Secondary.CanBash then return end
	if self:IsSafety() then return end

	return BaseClass.AltAttack(self)
end

function SWEP:Reload()
	if not self:VMIV() then return end
	if (self.SequenceEnabled[ACT_VM_FIDGET] or self.InspectionActions) and self:GetStatus() == TFA.Enum.STATUS_IDLE then
		self:SetStatus(TFA.Enum.STATUS_FIDGET)
		succ,tanim = self:ChooseInspectAnim()
		self:SetStatusEnd( l_CT() + (self.SequenceLengthOverride[tanim] or self:GetActivityLength()) )
	end
end
