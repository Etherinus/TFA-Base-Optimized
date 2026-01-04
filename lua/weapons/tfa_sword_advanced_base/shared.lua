DEFINE_BASECLASS("tfa_gun_base")

SWEP.Primary.Ammo = ""
SWEP.data = {}

SWEP.Gun = ""
SWEP.Category = ""
SWEP.Base = "tfa_gun_base"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Left click to slash" .. "\n" .. "Hold right mouse to put up guard."
SWEP.PrintName = "Snowflake Katana"
SWEP.Slot = 0
SWEP.SlotPos = 21
SWEP.DrawAmmo = false
SWEP.DrawWeaponInfoBox = true
SWEP.BounceWeaponIcon = false
SWEP.DrawCrosshair = false
SWEP.Weight = 50
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true
SWEP.Secondary.IronFOV = 90
SWEP.WeaponLength = 8
SWEP.MoveSpeed = 0.9
SWEP.IronSightsMoveSpeed = 0.8

SWEP.Kind = WEAPON_EQUIP
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.CanBuy = {ROLE_TRAITOR, ROLE_DETECTIVE, ROLE_INNOCENT}
SWEP.LimitedStock = true
SWEP.WeaponID = AMMO_SWORD
SWEP.NoSights = false
SWEP.IsSilent = true

SWEP.HoldType = "melee2"
SWEP.BlockHoldType = "slam"

SWEP.WorldModel = ""
SWEP.ShowWorldModel = true
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.UseHands = true
SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = false
SWEP.ViewModel = ""

SWEP.Primary.Damage = 200
SWEP.DamageType = DMG_SLASH
SWEP.Primary.RPM = 180
SWEP.Primary.KickUp = 0.4
SWEP.Primary.KickDown = 0.3
SWEP.Primary.KickHorizontal = 0.3
SWEP.Primary.Automatic = false
SWEP.FiresUnderwater = true

SWEP.BlockPos = Vector(-18, -10, 3)
SWEP.BlockAng = Vector(10, -25, -15)

SWEP.Slash = 1
SWEP.Sequences = {}

SWEP.SlashRandom = Angle(5, 0, 10)
SWEP.SlashJitter = Angle(1, 1, 1)
SWEP.randfac = 0
SWEP.HitRange = 86
SWEP.AmmoType = "TFMSwordHitGenericSlash"
SWEP.SlashPrecision = 15
SWEP.SlashDecals = 8
SWEP.SlashSounds = 6
SWEP.LastTraceTime = 0
SWEP.NextPrimaryFire = 0

SWEP.BlockSequences = {}

SWEP.DisableIdleAnimations = false
SWEP.IronBobMult = 1
SWEP.NinjaMode = false
SWEP.DrawTime = 0.2
SWEP.BlockAngle = 135
SWEP.BlockMaximum = 0.1
SWEP.BlockMinimum = 0.7
SWEP.BlockWindow = 0.5
SWEP.BlockFadeTime = 1
SWEP.PrevBlocking = false
SWEP.BlockProceduralAnimTime = 0.15

SWEP.SlashSound = Sound("weapons/blades/woosh.mp3")
SWEP.KnifeShink = Sound("weapons/blades/hitwall.mp3")
SWEP.KnifeSlash = Sound("weapons/blades/slash.mp3")
SWEP.KnifeStab = Sound("weapons/blades/nastystab.mp3")
SWEP.SwordChop = Sound("weapons/blades/swordchop.mp3")
SWEP.SwordClash = Sound("weapons/blades/clash.mp3")

SWEP.Primary.Sound = SWEP.SlashSound
SWEP.Primary.Sound_Impact_Flesh = SWEP.SwordChop
SWEP.Primary.Sound_Impact_Generic = SWEP.KnifeShink
SWEP.Primary.Sound_Impact_Metal = SWEP.SwordClash
SWEP.Primary.Sound_Pitch_Low = 97
SWEP.Primary.Sound_Pitch_High = 100
SWEP.Primary.Sound_World_Glass_Enabled = true
SWEP.Primary.Sound_Glass_Enabled = true
SWEP.Primary.Sound_Glass = Sound("impacts/glass_impact.wav")
SWEP.GlassSoundPlayed = false

SWEP.VElements = {}
SWEP.WElements = {}
SWEP.sounds = 0
SWEP.Action = true

local function tfaEnsureNW2(ent)
	if not ent then return end
	ent.SetNW2Bool = ent.SetNW2Bool or ent.SetNWBool
	ent.GetNW2Bool = ent.GetNW2Bool or ent.GetNWBool
	ent.SetNW2Int = ent.SetNW2Int or ent.SetNWInt
	ent.GetNW2Int = ent.GetNW2Int or ent.GetNWInt
	ent.SetNW2Float = ent.SetNW2Float or ent.SetNWFloat
	ent.GetNW2Float = ent.GetNW2Float or ent.GetNWFloat
	ent.SetNW2String = ent.SetNW2String or ent.SetNWString
	ent.GetNW2String = ent.GetNW2String or ent.GetNWString
end

function SWEP:Deploy()
	tfaEnsureNW2(self)
	self:SetNW2Float("SharedRandomVal", CurTime())
	self:SetBlockStart(-1)
	self.PrevBlockRat = 0
	return BaseClass.Deploy(self)
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 20, "BlockStart")
	BaseClass.SetupDataTables(self)
end

function SWEP:DoImpactEffect(tr, dmg)
	local seq = self.Sequences[self:GetNW2Int("Slash", 1)]
	local impactpos = tr.HitPos
	local impactnormal = tr.HitNormal

	self.sounds = self.sounds or 0

	if tr.HitSky == false then
		if util.SharedRandom(CurTime(), 1, self.SlashPrecision, "TFMSwordDecal") < self.SlashDecals then
			util.Decal("ManhackCut", impactpos + impactnormal, impactpos - impactnormal)
		end

		if tr.MatType == MAT_GLASS and self.Primary.Sound_Glass and self.Primary.Sound_Glass_Enabled == true and self.GlassSoundPlayed == false then
			self:EmitSound(self.Primary.Sound_Glass, 100, math.random(self.Primary.Sound_Pitch_Low, self.Primary.Sound_Pitch_High), 0.75, CHAN_WEAPON)
			self.GlassSoundPlayed = true
		end
	end

	return true
end

function SWEP:HitThing(ply, posv, normalv, damage, tr)
	if not IsValid(ply) then return end

	local bullet = {}
	bullet.Num = 1
	bullet.Src = posv
	bullet.Dir = normalv
	bullet.Spread = vector_origin
	bullet.Tracer = 0
	bullet.Force = damage / 16
	bullet.Damage = damage
	bullet.Distance = self.HitRange
	bullet.HullSize = self.WeaponLength / self.SlashPrecision
	bullet.AmmoType = self.AmmoType

	bullet.Callback = function(_, b, c)
		if not IsValid(self) then return end
		if not self.sounds then return end

		c:SetDamageType(self.DamageType)

		if self.sounds < self.SlashSounds then
			local hitmat = b.MatType

			if hitmat == MAT_METAL or hitmat == MAT_GRATE or hitmat == MAT_VENT or hitmat == MAT_COMPUTER then
				self:EmitSound(self.Primary.Sound_Impact_Metal, 100, math.random(self.Primary.Sound_Pitch_Low, self.Primary.Sound_Pitch_High), 0.75, CHAN_AUTO)
				self.sounds = self.sounds + 1
			elseif hitmat == MAT_FLESH or hitmat == MAT_BLOODYFLESH or hitmat == MAT_ALIENFLESH then
				self:EmitSound(self.Primary.Sound_Impact_Flesh, 100, math.random(self.Primary.Sound_Pitch_Low, self.Primary.Sound_Pitch_High), 0.75, CHAN_AUTO)
				self.sounds = self.sounds + 1
			else
				self:EmitSound(self.Primary.Sound_Impact_Generic, 100, math.random(self.Primary.Sound_Pitch_Low, self.Primary.Sound_Pitch_High), 0.75, CHAN_AUTO)
				self.sounds = self.sounds + 1
			end
		end
	end

	ply:FireBullets(bullet)
end

function SWEP:PrimaryAttack()
	local sharedrandomval = self:GetNW2Float("SharedRandomVal", 0)
	math.randomseed(sharedrandomval)

	if CLIENT and not IsFirstTimePredicted() then return end
	if not self:OwnerIsValid() then return end
	if CurTime() < self:GetNextPrimaryFire() then return end
	if not TFA.Enum.ReadyStatus[self:GetStatus()] then return end
	if self:IsSafety() then return end

	self:SetStatus(TFA.Enum.STATUS_SHOOTING)
	self.sounds = 0
	self:ChooseShootAnim()

	if SERVER then
		timer.Simple(0, function()
			if IsValid(self) then
				self:SetNW2Float("SharedRandomVal", math.Rand(-1024, 1024))
			end
		end)
	end

	local vm = self.Owner:GetViewModel()
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	tfaEnsureNW2(self.Owner)
	self.Owner:SetNW2Float("TFM_SwingStart", CurTime())

	local seq = self.Sequences[self:GetNW2Int("Slash", 1)]
	local seqid = vm:LookupSequence(seq.name)
	self:SetStatusEnd(CurTime() + vm:SequenceDuration(seqid))

	self.LastTraceTime = CurTime() + seq.startt
	self:SetNextPrimaryFire(CurTime() + 1 / (self.Primary.RPM / 60))

	if SERVER then
		timer.Simple(seq.startt, function()
			if IsValid(self) and self.Primary.Sound then
				self:EmitSound(self.Primary.Sound)
			end
		end)
	end
end

local cv_ts = GetConVar("host_timescale")
local blockseqn, ply, vm
local seq, swe
local ft, len, strikepercent, swingprogress, sws
local aimoff, jitfac
local cutangle

function SWEP:IronSights()
	BaseClass.IronSights(self)
	ply = self.Owner
	seq = self.Sequences[self:GetNW2Int("Slash", 1)]

	tfaEnsureNW2(ply)
	swe = ply:GetNW2Float("TFM_SwingStart", CurTime()) + seq.endt

	if CurTime() < swe then
		self:SetIronSightsRaw(false)
	end
end

function SWEP:Think2()
	BaseClass.Think2(self)

	local isr = self.IronSightsProgress
	ply = self.Owner

	if self.PrevBlockRat and isr and self.PrevBlockRat <= 0.3 and isr > 0.3 then
		self:SetBlockStart(CurTime())
	end

	if isr and self.PrevBlockRat and isr < 0.1 and self.PrevBlockRat > 0.1 then
		self:SetBlockStart(-1)
	end

	self.PrevBlockRat = isr

	local stat = self:GetStatus()
	if stat == TFA.Enum.STATUS_SHOOTING then
		seq = self.Sequences[self:GetNW2Int("Slash", 1)]

		local ct = CurTime()
		ft = ct - self.LastTraceTime
		len = seq.endt - seq.startt
		if len <= 0 then return end

		strikepercent = ft / len

		tfaEnsureNW2(ply)
		sws = ply:GetNW2Float("TFM_SwingStart", ct) + seq.startt
		swe = ply:GetNW2Float("TFM_SwingStart", ct) + seq.endt

		swingprogress = (ct - sws) / len

		if ct < swe then
			self:SetIronSightsRaw(false)
		end

		if ct > sws and ct < swe and ft > len / self.SlashPrecision and strikepercent > 0 then
			aimoff = ply:EyeAngles()

			cutangle = Angle(seq.pitch * (swingprogress - 0.5) * seq.dir, seq.yaw * (swingprogress - 0.5) * seq.dir, seq.roll)
			jitfac = 0.5 - util.SharedRandom("TFMSwordJitter", 0, 1, ct)

			aimoff:RotateAroundAxis(aimoff:Forward(), cutangle.r + self.SlashRandom.r * self.randfac + self.SlashJitter.r * jitfac)
			aimoff:RotateAroundAxis(aimoff:Up(), cutangle.y + self.SlashRandom.y * self.randfac + self.SlashJitter.y * jitfac)
			aimoff:RotateAroundAxis(aimoff:Right(), cutangle.p + self.SlashRandom.p * self.randfac + self.SlashJitter.p * jitfac)

			self:HitThing(ply, ply:GetShootPos(), aimoff:Forward(), self.Primary.Damage * strikepercent)
			self.LastTraceTime = ct
		end
	end
end

function SWEP:ChooseShootAnim(mynewvar)
	local sharedrandomval = self:GetNW2Float("SharedRandomVal", 0)
	if not self:OwnerIsValid() then return end

	ply = self.Owner
	vm = ply:GetViewModel()

	local selection = {}
	local relativedir = WorldToLocal(ply:GetVelocity(), Angle(0, 0, 0), vector_origin, ply:EyeAngles())
	local fwd = relativedir.x
	local hor = relativedir.y

	if hor < -ply:GetWalkSpeed() / 2 then
		for k, v in pairs(self.Sequences) do
			if v.right then
				table.insert(selection, #selection + 1, k)
			end
		end
	elseif hor > ply:GetWalkSpeed() / 2 then
		for k, v in pairs(self.Sequences) do
			if v.left then
				table.insert(selection, #selection + 1, k)
			end
		end
	elseif fwd > ply:GetWalkSpeed() / 2 then
		for k, v in pairs(self.Sequences) do
			if v.up then
				table.insert(selection, #selection + 1, k)
			end
		end
	elseif fwd < ply:GetWalkSpeed() / 2 then
		for k, v in pairs(self.Sequences) do
			if v.down then
				table.insert(selection, #selection + 1, k)
			end
		end
	end

	if #selection <= 0 and math.abs(fwd) < ply:GetWalkSpeed() / 2 and math.abs(hor) < ply:GetWalkSpeed() / 2 then
		for k, v in pairs(self.Sequences) do
			if v.up or v.down then
				table.insert(selection, #selection + 1, k)
			end
		end
	end

	if #selection <= 0 and math.abs(hor) < ply:GetWalkSpeed() / 2 and math.abs(fwd) < ply:GetWalkSpeed() / 2 then
		for k, v in pairs(self.Sequences) do
			if v.standing then
				table.insert(selection, #selection + 1, k)
			end
		end
	end

	if #selection <= 0 then
		math.randomseed(sharedrandomval)

		if math.random(0, 1) == 0 then
			math.randomseed(sharedrandomval)
			self:SetNW2Int("Slash", math.random(1, #self.Sequences))
		else
			self:SetNW2Int("Slash", self:GetNW2Int("Slash", 1) + 1)
			if self:GetNW2Int("Slash", 1) > #self.Sequences then
				self:SetNW2Int("Slash", 1)
			end
		end
	else
		math.randomseed(sharedrandomval)
		self:SetNW2Int("Slash", selection[math.random(1, #selection)])
	end

	local n = tonumber(mynewvar and mynewvar or "")
	local seqn = n and n or self:GetNW2Int("Slash", 1)

	seq = self.Sequences[seqn]

	local seqid = vm:LookupSequence(seq.name)
	seqid = seqid and seqid or 0

	local actid = vm:GetSequenceActivity(seqid)

	if actid and actid >= 0 and self.Action then
		self:SendViewModelAnim(actid)
	else
		self:SendViewModelSeq(seqid)
	end

	if SERVER and game.SinglePlayer() then
		self:CallOnClient("ChooseShootAnim", tostring(seqn))
	end

	return true, ACT_VM_PRIMARYATTACK
end

function SWEP:BlockAnim()
	local sharedrandomval = self:GetNW2Float("SharedRandomVal", 0)

	if self.BlockSequences and #self.BlockSequences > 0 then
		math.randomseed(sharedrandomval)
		blockseqn = math.random(1, #self.BlockSequences)
		seq = self.BlockSequences[blockseqn]
		ply = self.Owner

		if IsValid(ply) then
			vm = ply:GetViewModel()

			if IsValid(vm) then
				self:SetNextIdleAnim(-1)
				self:SendWeaponAnim(ACT_VM_IDLE)
				vm:SendViewModelMatchingSequence(vm:LookupSequence(seq.name))

				if seq.recoverysequence and seq.recoverysequence == true then
					if seq.recoverytime then
						self.NextPrimaryFire = CurTime() + vm:SequenceDuration() + seq.recoverytime
						self:SetNextPrimaryFire(CurTime() + vm:SequenceDuration() + seq.recoverytime)
						self:SetStatus(TFA.Enum.STATUS_FIDGET)
						self:SetStatusEnd(self.NextPrimaryFire)
					else
						self.NextPrimaryFire = CurTime() + vm:SequenceDuration()
						self:SetNextPrimaryFire(CurTime() + vm:SequenceDuration())
						self:SetStatus(TFA.Enum.STATUS_FIDGET)
						self:SetStatusEnd(self.NextPrimaryFire)
					end
				else
					self.NextPrimaryFire = CurTime() + (seq.recoverytime or 0)

					if seq.recoverytime then
						self:SetNextPrimaryFire(CurTime() + seq.recoverytime)
					else
						self:SetNextPrimaryFire(CurTime())
					end
				end
			end
		end
	end
end
