DEFINE_BASECLASS("tfa_gun_base")
SWEP.Secondary.BashDamage = 25
SWEP.Secondary.BashSound = Sound("TFA.Bash")
SWEP.Secondary.BashHitSound = Sound("TFA.BashWall")
SWEP.Secondary.BashHitSound_Flesh = Sound("TFA.BashFlesh")
SWEP.Secondary.BashLength = 54
SWEP.Secondary.BashDelay = 0.2
SWEP.Secondary.BashDamageType = DMG_SLASH
SWEP.Secondary.BashEnd = nil --Override bash sequence length easier
SWEP.BashBase = true
SWEP.DTapActivities = SWEP.DTapActivities or {}

--SWEP.tmptoggle = true
function SWEP:BashForce(ent, force, pos, now)
	if not IsValid(ent) or not ent.GetPhysicsObjectNum then return end

	if now then
		if ent.GetRagdollEntity then
			ent = ent:GetRagdollEntity() or ent
		end

		local phys = ent:GetPhysicsObjectNum(0)

		if IsValid(phys) then
			if ent:IsPlayer() or ent:IsNPC() then
				ent:SetVelocity( force * 0.1)
				phys:SetVelocity(phys:GetVelocity() + force * 0.1)
			else
				phys:ApplyForceOffset(force, pos)
			end
		end
	else
		timer.Simple(0, function()
			if IsValid(self) and self:OwnerIsValid() and IsValid(ent) then
				self:BashForce(ent, force, pos, true)
			end
		end)
	end
end

local function bashcallback(a, b, c, wep)
	if not IsValid(wep) then return end

	if c then
		c:SetDamageType(wep.Secondary.BashDamageType)
	end

	if IsValid(b.Entity) and b.Entity.TakeDamageInfo then
		local dmg = DamageInfo()
		dmg:SetAttacker(wep.Owner)
		dmg:SetInflictor(wep)
		dmg:SetDamagePosition(wep.Owner:GetShootPos())
		dmg:SetDamageForce(wep.Owner:GetAimVector() * 1) --(pain))
		dmg:SetDamage(pain)
		dmg:SetDamageType(wep.Secondary.BashDamageType)
		b.Entity:TakeDamageInfo(dmg)
		wep:BashForce(b.Entity, wep.Owner:GetAimVector() * math.sqrt(pain / 80) * 32 * 80, b.HitPos)
	end
end

function SWEP:HandleDoor(slashtrace)
	if CLIENT then return end

	if slashtrace.Entity:GetClass() == "func_door_rotating" or slashtrace.Entity:GetClass() == "prop_door_rotating" then
		local ply = self.Owner
		ply:EmitSound("ambient/materials/door_hit1.wav", 100, math.random(80, 120))
		ply.oldname = ply:GetName()
		ply:SetName("bashingpl" .. ply:EntIndex())
		slashtrace.Entity:SetKeyValue("Speed", "500")
		slashtrace.Entity:SetKeyValue("Open Direction", "Both directions")
		slashtrace.Entity:SetKeyValue("opendir", "0")
		slashtrace.Entity:Fire("unlock", "", .01)
		slashtrace.Entity:Fire("openawayfrom", "bashingpl" .. ply:EntIndex(), .01)

		timer.Simple(0.02, function()
			if IsValid(ply) then
				ply:SetName(ply.oldname)
			end
		end)

		timer.Simple(0.3, function()
			if IsValid(slashtrace.Entity) then
				slashtrace.Entity:SetKeyValue("Speed", "100")
			end
		end)
	end
end

local l_CT = CurTime

function SWEP:AltAttack()
	if self.Secondary.CanBash == false then return end
	if not self:OwnerIsValid() then return end
	local stat = self:GetStatus()
	if not TFA.Enum.ReadyStatus[stat] then return end
	if self:IsSafety() then return end

	local vm = self.Owner:GetViewModel()
	--if SERVER then
	self:SendWeaponAnim(ACT_VM_HITCENTER)

	--else
	--	self:SendWeaponAnim(ACT_VM_HITCENTER)
	--end
	if self.Owner.Vox then
		self.Owner:Vox("bash", 0)
	end

	local altanim = false
	--if IsValid(wep) and wep.GetHoldType then
	local ht = self.HoldType

	if ht == "ar2" or ht == "shotgun" or ht == "crossbow" or ht == "physgun" then
		altanim = true
	end
	self.Owner:AnimRestartGesture(0, altanim and ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND or ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2, true)

	self.unpredbash = true

	timer.Simple(0.1, function()
		if IsValid(self) then
			self.unpredbash = false
		end
	end)

	self.tmptoggle = not self.tmptoggle
	self:SetNextIdleAnim(CurTime() + vm:SequenceDuration())
	self:SetNextPrimaryFire(CurTime() + (self.Secondary.BashEnd or self.SequenceLengthOverride[ACT_VM_HITCENTER] or vm:SequenceDuration()))
	self:SetNextSecondaryFire(CurTime() + (self.Secondary.BashEnd or self.SequenceLengthOverride[ACT_VM_HITCENTER] or vm:SequenceDuration()))

	if IsFirstTimePredicted() then
		self:EmitSound(self.Secondary.BashSound)
	end
	self:SetStatus(TFA.Enum.STATUS_BASHING)
	self:SetStatusEnd(self:GetNextPrimaryFire())

	self:SetNW2Float("BashTTime", CurTime() + self.Secondary.BashDelay)
end

local ttime = -1

function SWEP:Think2()
	ttime = self:GetNW2Float("BashTTime", -1)

	if ttime ~= -1 and CurTime() > ttime then
		self:SetNW2Float("BashTTime", -1)
		local pos = self.Owner:GetShootPos()
		local av = self.Owner:EyeAngles():Forward()
		local slash = {}
		slash.start = pos
		slash.endpos = pos + (av * self.Secondary.BashLength)
		slash.filter = self.Owner
		slash.mins = Vector(-10, -5, 0)
		slash.maxs = Vector(10, 5, 5)
		local slashtrace = util.TraceHull(slash)
		pain = self.Secondary.BashDamage

		if slashtrace.Hit then
			self:HandleDoor(slashtrace)
			if not ( game.SinglePlayer() and CLIENT ) then
				self:EmitSound((slashtrace.MatType == MAT_FLESH or slashtrace.MatType == MAT_ALIENFLESH) and self.Secondary.BashHitSound_Flesh or self.Secondary.BashHitSound)
			end
			
			if game.GetTimeScale() > 0.99 then
				self.Owner:FireBullets({
					Attacker = self.Owner,
					Inflictor = self,
					Damage = 1,
					Force = 1, --pain,
					Distance = self.Secondary.BashLength + 10,
					HullSize = 10,
					Tracer = 0,
					Src = self.Owner:GetShootPos(),
					Dir = slashtrace.Normal,
					Callback = function(a, b, c)
						bashcallback(a, b, c, self)
					end
				})
			else
				local dmg = DamageInfo()
				dmg:SetAttacker(self.Owner)
				dmg:SetInflictor(self)
				dmg:SetDamagePosition(self.Owner:GetShootPos())
				dmg:SetDamageForce(self.Owner:GetAimVector() * pain)
				dmg:SetDamage(pain)
				dmg:SetDamageType(self.Secondary.BashDamageType)

				if IsValid(slashtrace.Entity) and slashtrace.Entity.TakeDamageInfo then
					slashtrace.Entity:TakeDamageInfo(dmg)
				end
			end

			local ent = slashtrace.Entity
			if not IsValid(ent) or not ent.GetPhysicsObject then return end
			local phys

			if ent:IsRagdoll() then
				phys = ent:GetPhysicsObjectNum(slashtrace.PhysicsBone or 0)
			else
				phys = ent:GetPhysicsObject()
			end

			if IsValid(phys) then
				if ent:IsPlayer() or ent:IsNPC() then
					ent:SetVelocity( self.Owner:GetAimVector() * self.Secondary.BashDamage * 0.5 )
					phys:SetVelocity(phys:GetVelocity() + self.Owner:GetAimVector() * self.Secondary.BashDamage * 0.5 )
				else
					phys:ApplyForceOffset(self.Owner:GetAimVector() * self.Secondary.BashDamage * 0.5, slashtrace.HitPos)
				end
			end
		end
	end

	BaseClass.Think2(self)
end

function SWEP:SecondaryAttack()
	if self.data and self.data.ironsights == 0 then
		self:AltAttack()
		return
	end

	BaseClass.SecondaryAttack(self)
end

local bash, vm, seq, actid

function SWEP:GetBashing()
	if not self:OwnerIsValid() then return false end

	if not IsValid(vm) or not vm.GetSequence then
		vm = self.OwnerViewModel

		return false
	end

	seq = vm:GetSequence()
	actid = vm:GetSequenceActivity(seq)
	bash = ((actid == ACT_VM_HITCENTER) and vm:GetCycle() > 0 and vm:GetCycle() < 0.65) or self.unpredbash

	return bash
end
