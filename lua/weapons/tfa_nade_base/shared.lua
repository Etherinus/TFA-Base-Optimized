SWEP.Base = "tfa_gun_base"
DEFINE_BASECLASS(SWEP.Base)

SWEP.Type = "Grenade"
SWEP.MuzzleFlashEffect = ""

SWEP.data = {}
SWEP.data.ironsights = 0

SWEP.Delay = 0.3
SWEP.Delay_Underhand = 0.3

SWEP.Primary.Round = ""
SWEP.Velocity = 550

SWEP.Underhanded = false
SWEP.DisableIdleAnimations = true

SWEP.IronSightsPos = Vector(5, 0, 0)
SWEP.IronSightsAng = Vector(0, 0, 0)

SWEP.Callback = {}

local nzombies = nil

local function tfaEnsureNW2(ent)
	if not ent then return end
	ent.SetNW2Bool = ent.SetNW2Bool or ent.SetNWBool
	ent.GetNW2Bool = ent.GetNW2Bool or ent.GetNWBool
	ent.SetNW2Int = ent.SetNW2Int or ent.SetNWInt
	ent.GetNW2Int = ent.GetNW2Int or ent.GetNWInt
	ent.SetNW2Float = ent.SetNW2Float or ent.SetNWFloat
	ent.GetNW2Float = ent.GetNW2Float or ent.GetNWFloat
	ent.SetNW2Entity = ent.SetNW2Entity or ent.SetNWEntity
	ent.GetNW2Entity = ent.GetNW2Entity or ent.GetNWEntity
	ent.SetNW2String = ent.SetNW2String or ent.SetNWString
	ent.GetNW2String = ent.GetNW2String or ent.GetNWString
end

function SWEP:Initialize()
	tfaEnsureNW2(self)

	if nzombies == nil then
		nzombies = engine.ActiveGamemode() == "nzombies"
	end

	self.ProjectileEntity = self.Primary.Round
	self.ProjectileVelocity = self.Velocity and self.Velocity or 550
	self.ProjectileModel = nil

	self:SetNW2Bool("Ready", false)
	self:SetNW2Bool("Underhanded", false)

	self.VElements = {}
	BaseClass.Initialize(self)
end

function SWEP:Deploy()
	tfaEnsureNW2(self)

	if self:Clip1() <= 0 then
		if self:Ammo1() <= 0 then
			timer.Simple(0, function()
				if IsValid(self) and self:OwnerIsValid() and SERVER and not nzombies then
					self.Owner:StripWeapon(self:GetClass())
				end
			end)
		else
			self:TakePrimaryAmmo(1, true)
			self:SetClip1(1)
		end
	end

	self:SetNW2Bool("Ready", false)
	self:SetNW2Bool("Underhanded", false)

	self.oldang = self.Owner:EyeAngles()
	self.anga = Angle()
	self.angb = Angle()
	self.angc = Angle()

	self:CleanParticles()
	return BaseClass.Deploy(self)
end

function SWEP:ChoosePullAnim()
	if not self:OwnerIsValid() then return end

	if self.Callback.ChoosePullAnim then
		self.Callback.ChoosePullAnim(self)
	end

	self.Owner:SetAnimation(PLAYER_RELOAD)

	local tanim = ACT_VM_PULLPIN
	local success = true
	self:SendViewModelAnim(ACT_VM_PULLPIN)

	if game.SinglePlayer() then
		self:CallOnClient("AnimForce", tanim)
	end

	self.lastact = tanim
	return success, tanim
end

function SWEP:ChooseShootAnim()
	if not self:OwnerIsValid() then return end

	if self.Callback.ChooseShootAnim then
		self.Callback.ChooseShootAnim(self)
	end

	self.Owner:SetAnimation(PLAYER_ATTACK1)

	local mybool = self:GetNW2Bool("Underhanded", false)
	local tanim = mybool and ACT_VM_RELEASE or ACT_VM_THROW
	if not self.SequenceEnabled[ACT_VM_RELEASE] then
		tanim = ACT_VM_THROW
	end

	local success = true
	self:SendViewModelAnim(tanim)

	if game.SinglePlayer() then
		self:CallOnClient("AnimForce", tanim)
	end

	self.lastact = tanim
	return success, tanim
end

function SWEP:ThrowStart()
	if self:Clip1() > 0 then
		local _, tanim = self:ChooseShootAnim()
		self:SetStatus(TFA.GetStatus("grenade_throw"))
		self:SetStatusEnd(CurTime() + (self.SequenceLengthOverride[tanim] or self:GetActivityLength()))

		local under = self:GetNW2Bool("Underhanded", false)
		local delay = under and self.Delay_Underhand or self.Delay

		timer.Simple(delay, function()
			if IsValid(self) and self:OwnerIsValid() then
				self:Throw()
			end
		end)
	end
end

function SWEP:Throw()
	if self:Clip1() > 0 then
		local under = self:GetNW2Bool("Underhanded", false)

		if not under then
			self.ProjectileVelocity = self.Velocity and self.Velocity or 550
		else
			if self.Velocity_Underhand then
				self.ProjectileVelocity = self.Velocity_Underhand
			else
				self.ProjectileVelocity = (self.Velocity and self.Velocity or 550) / 1.5
			end
		end

		self:TakePrimaryAmmo(1)
		self:ShootBulletInformation()
		self:DoAmmoCheck()
	end
end

function SWEP:DoAmmoCheck()
	if IsValid(self) and SERVER then
		local vm = self.Owner:GetViewModel()
		if not IsValid(vm) then return end

		local delay = vm:SequenceDuration()
		delay = delay * 1 - math.Clamp(vm:GetCycle(), 0, 1)

		timer.Simple(delay, function()
			if IsValid(self) then
				self:Deploy()
			end
		end)
	end
end

local stat

function SWEP:Think2()
	if not self:OwnerIsValid() then return end

	stat = self:GetStatus()

	if stat == TFA.GetStatus("grenade_pull") then
		if self.Owner:KeyDown(IN_ATTACK2) then
			self:SetNW2Bool("Underhanded", true)
		end

		if CurTime() > self:GetStatusEnd() then
			stat = TFA.GetStatus("grenade_ready")
			self:SetStatus(stat)
			self:SetStatusEnd(math.huge)
		end
	end

	if stat == TFA.GetStatus("grenade_ready") then
		if self.Owner:KeyDown(IN_ATTACK2) then
			self:SetNW2Bool("Underhanded", true)
		end

		if not self.Owner:KeyDown(IN_ATTACK2) and not self.Owner:KeyDown(IN_ATTACK) then
			self:ThrowStart()
		end
	end

	BaseClass.Think2(self)
end

function SWEP:PrimaryAttack()
	if self:Clip1() > 0 and self:OwnerIsValid() and self:CanFire() then
		local _, tanim = self:ChoosePullAnim()
		self:SetStatus(TFA.GetStatus("grenade_pull"))
		self:SetStatusEnd(CurTime() + (self.SequenceLengthOverride[tanim] or self:GetActivityLength()))
		self:SetNW2Bool("Charging", true)
		self:SetNW2Bool("Underhanded", false)

		if IsFirstTimePredicted() then
			timer.Simple(self.Owner:GetViewModel():SequenceDuration(), function()
				if IsValid(self) then
					self:SetNW2Bool("Ready", true)
				end
			end)
		end
	end
end

function SWEP:SecondaryAttack()
	if self:Clip1() > 0 and self:OwnerIsValid() and self:CanFire() then
		local _, tanim = self:ChoosePullAnim()
		self:SetNW2Bool("Ready", false)
		self:SetNW2Bool("Underhanded", true)
		self:SetStatus(TFA.GetStatus("grenade_pull"))
		self:SetStatusEnd(CurTime() + (self.SequenceLengthOverride[tanim] or self:GetActivityLength()))
	end
end

function SWEP:Reload()
	if self:Clip1() <= 0 and self:OwnerIsValid() and self:CanFire() then
		self:Deploy()
	end
end

function SWEP:CanFire()
	if not self:CanPrimaryAttack() then return false end
	return true
end

function SWEP:ChooseIdleAnim(...)
	if self:GetNW2Bool("Ready") then return end
	BaseClass.ChooseIdleAnim(self, ...)
end

SWEP.AllowSprintAttack = true
