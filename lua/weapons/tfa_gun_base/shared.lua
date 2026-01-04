SWEP.SV_MODULES = SWEP.SV_MODULES or {}
SWEP.SH_MODULES = SWEP.SH_MODULES or { "sh_anims.lua", "sh_autodetection.lua", "sh_utils.lua", "sh_bullet.lua", "sh_effects.lua", "sh_bobcode.lua", "sh_calc.lua", "sh_akimbo.lua", "sh_events.lua", "sh_nzombies.lua" }
SWEP.ClSIDE_MODULES = SWEP.ClSIDE_MODULES or { "cl_effects.lua", "cl_viewbob.lua", "cl_hud.lua", "cl_mods.lua" }

SWEP.Category = SWEP.Category or ""
SWEP.Author = SWEP.Author or "TheForgottenArchitect"
SWEP.Contact = SWEP.Contact or "theforgottenarchitect"
SWEP.Purpose = SWEP.Purpose or ""
SWEP.Instructions = SWEP.Instructions or ""

SWEP.DrawCrosshair = (SWEP.DrawCrosshair ~= nil) and SWEP.DrawCrosshair or true
SWEP.ViewModelFOV = SWEP.ViewModelFOV or 65
SWEP.ViewModelFlip = (SWEP.ViewModelFlip ~= nil) and SWEP.ViewModelFlip or false
SWEP.Skin = SWEP.Skin or 0
SWEP.Spawnable = (SWEP.Spawnable ~= nil) and SWEP.Spawnable or false

SWEP.IsTFAWeapon = true

SWEP.Primary = SWEP.Primary or {}
SWEP.Secondary = SWEP.Secondary or {}

SWEP.StatCache_Blacklist = SWEP.StatCache_Blacklist or {}
SWEP.SightsPos = SWEP.SightsPos or Vector(0, 0, 0)
SWEP.SightsAng = SWEP.SightsAng or Angle(0, 0, 0)
SWEP.DTapActivities = SWEP.DTapActivities or {}
SWEP.Animations = SWEP.Animations or {}

local function tfaEnsureNW2(self)
	self.SetNW2Bool = self.SetNW2Bool or self.SetNWBool
	self.GetNW2Bool = self.GetNW2Bool or self.GetNWBool
	self.SetNW2Int = self.SetNW2Int or self.SetNWInt
	self.GetNW2Int = self.GetNW2Int or self.GetNWInt
	self.SetNW2Float = self.SetNW2Float or self.SetNWFloat
	self.GetNW2Float = self.GetNW2Float or self.GetNWFloat
	self.SetNW2Entity = self.SetNW2Entity or self.SetNWEntity
	self.GetNW2Entity = self.GetNW2Entity or self.GetNWEntity
end

local function tfaAddBaseFallbacks(swep)
	if swep._TFA_BaseNWInitialized then return end
	swep._TFA_BaseNWInitialized = true

	local function ensure(self)
		tfaEnsureNW2(self)
	end

	if not swep.SetIronSightsRaw then
		swep.SetIronSightsRaw = function(self, val)
			ensure(self)
			self:SetNW2Bool("IronSightsRaw", val and true or false)
		end
	end

	if not swep.GetIronSightsRaw then
		swep.GetIronSightsRaw = function(self)
			ensure(self)
			return self:GetNW2Bool("IronSightsRaw", false)
		end
	end

	if not swep.SetSprinting then
		swep.SetSprinting = function(self, val)
			ensure(self)
			self:SetNW2Bool("Sprinting", val and true or false)
		end
	end

	if not swep.GetSprinting then
		swep.GetSprinting = function(self)
			ensure(self)
			return self:GetNW2Bool("Sprinting", false)
		end
	end

	if not swep.SetSilenced then
		swep.SetSilenced = function(self, val)
			ensure(self)
			self:SetNW2Bool("Silenced", val and true or false)
		end
	end

	if not swep.GetSilenced then
		swep.GetSilenced = function(self)
			ensure(self)
			return self:GetNW2Bool("Silenced", false)
		end
	end

	if not swep.SetShotgunCancel then
		swep.SetShotgunCancel = function(self, val)
			ensure(self)
			self:SetNW2Bool("ShotgunCancel", val and true or false)
		end
	end

	if not swep.GetShotgunCancel then
		swep.GetShotgunCancel = function(self)
			ensure(self)
			return self:GetNW2Bool("ShotgunCancel", false)
		end
	end

	if not swep.SetStatus then
		swep.SetStatus = function(self, val)
			ensure(self)
			self:SetNW2Int("Status", val or 0)
		end
	end

	if not swep.GetStatus then
		swep.GetStatus = function(self)
			ensure(self)
			return self:GetNW2Int("Status", (TFA and TFA.Enum and TFA.Enum.STATUS_IDLE) or 0)
		end
	end

	if not swep.SetStatusEnd then
		swep.SetStatusEnd = function(self, val)
			ensure(self)
			self:SetNW2Float("StatusEnd", val or 0)
		end
	end

	if not swep.GetStatusEnd then
		swep.GetStatusEnd = function(self)
			ensure(self)
			return self:GetNW2Float("StatusEnd", 0)
		end
	end

	if not swep.SetNextIdleAnim then
		swep.SetNextIdleAnim = function(self, val)
			ensure(self)
			self:SetNW2Float("NextIdleAnim", val or 0)
		end
	end

	if not swep.GetNextIdleAnim then
		swep.GetNextIdleAnim = function(self)
			ensure(self)
			return self:GetNW2Float("NextIdleAnim", 0)
		end
	end

	if not swep.SetFireMode then
		swep.SetFireMode = function(self, val)
			ensure(self)
			self:SetNW2Int("FireMode", val or 0)
		end
	end

	if not swep.GetFireMode then
		swep.GetFireMode = function(self)
			ensure(self)
			return self:GetNW2Int("FireMode", 0)
		end
	end

	if not swep.SetLastActivity then
		swep.SetLastActivity = function(self, val)
			ensure(self)
			self:SetNW2Int("LastActivity", val or 0)
		end
	end

	if not swep.GetLastActivity then
		swep.GetLastActivity = function(self)
			ensure(self)
			return self:GetNW2Int("LastActivity", 0)
		end
	end

	if not swep.SetBurstCount then
		swep.SetBurstCount = function(self, val)
			ensure(self)
			self:SetNW2Int("BurstCount", val or 0)
		end
	end

	if not swep.GetBurstCount then
		swep.GetBurstCount = function(self)
			ensure(self)
			return self:GetNW2Int("BurstCount", 0)
		end
	end

	if not swep.SetSwapTarget then
		swep.SetSwapTarget = function(self, val)
			ensure(self)
			self:SetNW2Entity("SwapTarget", val)
		end
	end

	if not swep.GetSwapTarget then
		swep.GetSwapTarget = function(self)
			ensure(self)
			return self:GetNW2Entity("SwapTarget")
		end
	end
end

tfaAddBaseFallbacks(SWEP)

function SWEP:GetAnimationRate()
	return self.AnimationRate or 1
end

function SWEP:ScheduleStatus(status, len)
	if not self.SetStatus or not self.SetStatusEnd then return end
	self:SetStatus(status or 0)
	self:SetStatusEnd(CurTime() + (len or 0))
end

SWEP.data = SWEP.data or {}
SWEP.data.ironsights = SWEP.data.ironsights or 1

SWEP.MoveSpeed = SWEP.MoveSpeed or 1
SWEP.IronSightsMoveSpeed = SWEP.IronSightsMoveSpeed

SWEP.Primary.Damage = SWEP.Primary.Damage or -1
SWEP.Primary.NumShots = SWEP.Primary.NumShots or 1
SWEP.Primary.Force = SWEP.Primary.Force or -1
SWEP.Primary.KnockBack = SWEP.Primary.KnockBack or -1
SWEP.Primary.Recoil = SWEP.Primary.Recoil or 1
SWEP.Primary.RPM = SWEP.Primary.RPM or 600
SWEP.Primary.RPM_Semi = SWEP.Primary.RPM_Semi or -1
SWEP.Primary.RPM_Burst = SWEP.Primary.RPM_Burst or -1
SWEP.Primary.StaticRecoilFactor = SWEP.Primary.StaticRecoilFactor or 0.5
SWEP.Primary.KickUp = SWEP.Primary.KickUp or 0.5
SWEP.Primary.KickDown = SWEP.Primary.KickDown or 0.5
SWEP.Primary.KickRight = SWEP.Primary.KickRight or 0.5
SWEP.Primary.KickHorizontal = SWEP.Primary.KickHorizontal or 0.5
SWEP.Primary.DamageType = SWEP.Primary.DamageType
SWEP.Primary.Ammo = SWEP.Primary.Ammo or "smg1"
SWEP.Primary.AmmoConsumption = SWEP.Primary.AmmoConsumption or 1
SWEP.Primary.Spread = SWEP.Primary.Spread or 0
SWEP.Primary.SpreadMultiplierMax = SWEP.Primary.SpreadMultiplierMax or -1
SWEP.Primary.SpreadIncrement = SWEP.Primary.SpreadIncrement or -1
SWEP.Primary.SpreadRecovery = SWEP.Primary.SpreadRecovery or -1
SWEP.Primary.IronAccuracy = SWEP.Primary.IronAccuracy or 0
SWEP.Primary.MaxPenetration = SWEP.Primary.MaxPenetration or 2
SWEP.Primary.Range = SWEP.Primary.Range or 1200
SWEP.Primary.RangeFalloff = SWEP.Primary.RangeFalloff or 0.5

SWEP.Shotgun = (SWEP.Shotgun ~= nil) and SWEP.Shotgun or false
SWEP.ShotgunEmptyAnim = (SWEP.ShotgunEmptyAnim ~= nil) and SWEP.ShotgunEmptyAnim or true
SWEP.ShotgunEmptyAnim_Shell = (SWEP.ShotgunEmptyAnim_Shell ~= nil) and SWEP.ShotgunEmptyAnim_Shell or true

SWEP.BoltAction = (SWEP.BoltAction ~= nil) and SWEP.BoltAction or false
SWEP.BoltAction_Forced = (SWEP.BoltAction_Forced ~= nil) and SWEP.BoltAction_Forced or false
SWEP.Scoped = (SWEP.Scoped ~= nil) and SWEP.Scoped or false
SWEP.ScopeOverlayThreshold = SWEP.ScopeOverlayThreshold or 0.875
SWEP.BoltTimerOffset = SWEP.BoltTimerOffset or 0.25
SWEP.ScopeScale = SWEP.ScopeScale or 0.5
SWEP.ReticleScale = SWEP.ReticleScale or 0.7

SWEP.MuzzleAttachment = SWEP.MuzzleAttachment or "1"
SWEP.ShellAttachment = SWEP.ShellAttachment or "2"

SWEP.MuzzleFlashEnabled = (SWEP.MuzzleFlashEnabled ~= nil) and SWEP.MuzzleFlashEnabled or true
SWEP.MuzzleFlashEffect = SWEP.MuzzleFlashEffect
SWEP.CustomMuzzleFlash = (SWEP.CustomMuzzleFlash ~= nil) and SWEP.CustomMuzzleFlash or true

SWEP.LuaShellEject = (SWEP.LuaShellEject ~= nil) and SWEP.LuaShellEject or false
SWEP.LuaShellEjectDelay = SWEP.LuaShellEjectDelay or 0
SWEP.LuaShellEffect = SWEP.LuaShellEffect

SWEP.SequenceLengthOverride = SWEP.SequenceLengthOverride or {}

SWEP.BlowbackEnabled = (SWEP.BlowbackEnabled ~= nil) and SWEP.BlowbackEnabled or false
SWEP.BlowbackVector = SWEP.BlowbackVector or Vector(0, -1, 0)
SWEP.BlowbackCurrentRoot = SWEP.BlowbackCurrentRoot or 0
SWEP.BlowbackCurrent = SWEP.BlowbackCurrent or 0
SWEP.BlowbackBoneMods = SWEP.BlowbackBoneMods
SWEP.Blowback_Only_Iron = (SWEP.Blowback_Only_Iron ~= nil) and SWEP.Blowback_Only_Iron or true
SWEP.Blowback_PistolMode = (SWEP.Blowback_PistolMode ~= nil) and SWEP.Blowback_PistolMode or false

SWEP.ProceduralHolsterEnabled = (SWEP.ProceduralHolsterEnabled ~= nil) and SWEP.ProceduralHolsterEnabled or false
SWEP.ProceduralHolsterTime = SWEP.ProceduralHolsterTime or 0.3
SWEP.ProceduralHolsterPos = SWEP.ProceduralHolsterPos or Vector(3, 0, -5)
SWEP.ProceduralHolsterAng = SWEP.ProceduralHolsterAng or Vector(-40, -30, 10)

SWEP.ProceduralReloadEnabled = (SWEP.ProceduralReloadEnabled ~= nil) and SWEP.ProceduralReloadEnabled or false
SWEP.ProceduralReloadTime = SWEP.ProceduralReloadTime or 1

ACT_VM_FIDGET_EMPTY = ACT_VM_FIDGET_EMPTY or ACT_CROSSBOW_FIDGET_UNLOADED

SWEP.Blowback_PistolMode_Disabled = SWEP.Blowback_PistolMode_Disabled or {
	[ACT_VM_RELOAD] = true,
	[ACT_VM_RELOAD_EMPTY] = true,
	[ACT_VM_DRAW_EMPTY] = true,
	[ACT_VM_IDLE_EMPTY] = true,
	[ACT_VM_HOLSTER_EMPTY] = true,
	[ACT_VM_DRYFIRE] = true,
	[ACT_VM_FIDGET] = true,
	[ACT_VM_FIDGET_EMPTY] = true
}

SWEP.Blowback_Shell_Enabled = (SWEP.Blowback_Shell_Enabled ~= nil) and SWEP.Blowback_Shell_Enabled or true
SWEP.Blowback_Shell_Effect = SWEP.Blowback_Shell_Effect or "ShellEject"

SWEP.Secondary.Ammo = SWEP.Secondary.Ammo or ""
SWEP.Secondary.ClipSize = (SWEP.Secondary.ClipSize ~= nil) and SWEP.Secondary.ClipSize or -1
SWEP.Secondary.DefaultClip = SWEP.Secondary.DefaultClip or 0

SWEP.Sights_Mode = SWEP.Sights_Mode or TFA.Enum.LOCOMOTION_LUA
SWEP.Sprint_Mode = SWEP.Sprint_Mode or TFA.Enum.LOCOMOTION_LUA
SWEP.SprintFOVOffset = SWEP.SprintFOVOffset or 5
SWEP.Idle_Mode = SWEP.Idle_Mode or TFA.Enum.IDLE_LUA
SWEP.Idle_Blend = SWEP.Idle_Blend or 0.25
SWEP.Idle_Smooth = SWEP.Idle_Smooth or 0.05

SWEP.IronSightTime = SWEP.IronSightTime or 0.3
SWEP.IronSightsSensitivity = SWEP.IronSightsSensitivity or 1

SWEP.InspectPosDef = SWEP.InspectPosDef or Vector(9.779, -11.658, -2.241)
SWEP.InspectAngDef = SWEP.InspectAngDef or Vector(24.622, 42.915, 15.477)

SWEP.RunSightsPos = SWEP.RunSightsPos or Vector(0, 0, 0)
SWEP.RunSightsAng = SWEP.RunSightsAng or Vector(0, 0, 0)
SWEP.AllowSprintAttack = (SWEP.AllowSprintAttack ~= nil) and SWEP.AllowSprintAttack or false

SWEP.EventTable = SWEP.EventTable or {}

SWEP.RTMaterialOverride = SWEP.RTMaterialOverride
SWEP.RTOpaque = (SWEP.RTOpaque ~= nil) and SWEP.RTOpaque or false
SWEP.RTCode = SWEP.RTCode

SWEP.VMPos = SWEP.VMPos or Vector(0, 0, 0)
SWEP.VMAng = SWEP.VMAng or Vector(0, 0, 0)
SWEP.CameraOffset = SWEP.CameraOffset or Angle(0, 0, 0)
SWEP.VMPos_Additive = (SWEP.VMPos_Additive ~= nil) and SWEP.VMPos_Additive or true

local vm_offset_pos = Vector()
local vm_offset_ang = Angle()

SWEP.IronAnimation = SWEP.IronAnimation or {}
SWEP.SprintAnimation = SWEP.SprintAnimation or {}

SWEP.IronSightsProgress = SWEP.IronSightsProgress or 0
SWEP.SprintProgress = SWEP.SprintProgress or 0
SWEP.SpreadRatio = SWEP.SpreadRatio or 0
SWEP.CrouchingRatio = SWEP.CrouchingRatio or 0
SWEP.SmokeParticles = SWEP.SmokeParticles or {}

SWEP.Inspecting = (SWEP.Inspecting ~= nil) and SWEP.Inspecting or false
SWEP.InspectingProgress = SWEP.InspectingProgress or 0
SWEP.LuaShellRequestTime = SWEP.LuaShellRequestTime or -1
SWEP.BobScale = SWEP.BobScale or 0
SWEP.SwayScale = SWEP.SwayScale or 0
SWEP.BoltDelay = SWEP.BoltDelay or 1
SWEP.ProceduralHolsterProgress = SWEP.ProceduralHolsterProgress or 0
SWEP.BurstCount = SWEP.BurstCount or 0
SWEP.DefaultFOV = SWEP.DefaultFOV or 90

local function l_Lerp(v, f, t)
	return f + (t - f) * v
end

local l_mathApproach = math.Approach
local l_mathClamp = math.Clamp
local l_CT = CurTime
local l_FT = FrameTime
local l_RT = RealTime

local qerppower = 2

local function pow(num, power)
	return math.pow(num, power)
end

local function QerpIn(progress, startval, change, totaltime)
	totaltime = totaltime or 1
	return startval + change * pow(progress / totaltime, qerppower)
end

local function QerpOut(progress, startval, change, totaltime)
	totaltime = totaltime or 1
	return startval - change * pow(progress / totaltime, qerppower)
end

local function Qerp(progress, startval, endval, totaltime)
	local change = endval - startval
	totaltime = totaltime or 1
	if progress < totaltime / 2 then
		return QerpIn(progress, startval, change / 2, totaltime / 2)
	end
	return QerpOut(totaltime - progress, endval, change / 2, totaltime / 2)
end

local l_NormalizeAngle = math.NormalizeAngle

local function util_NormalizeAngles(a)
	a.p = l_NormalizeAngle(a.p)
	a.y = l_NormalizeAngle(a.y)
	a.r = l_NormalizeAngle(a.r)
	return a
end

local function QerpAngle(progress, startang, endang, totaltime)
	return util_NormalizeAngles(LerpAngle(Qerp(progress, 0, 1, totaltime), startang, endang))
end

local myqerpvec = Vector()

local function QerpVector(progress, startang, endang, totaltime)
	totaltime = totaltime or 1
	myqerpvec.x = Qerp(progress, startang.x, endang.x, totaltime)
	myqerpvec.y = Qerp(progress, startang.y, endang.y, totaltime)
	myqerpvec.z = Qerp(progress, startang.z, endang.z, totaltime)
	return myqerpvec
end

local l_ct = CurTime
local l_ft = FrameTime

local success, tanim
local stat, statend
local ct, ft
ft = 0.01
local sp = game.SinglePlayer()

local host_timescale_cv = GetConVar("host_timescale")
local sv_cheats_cv = GetConVar("sv_cheats")

function SWEP:ResetEvents()
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "IronSightsRaw")
	self:NetworkVar("Bool", 1, "Sprinting")
	self:NetworkVar("Bool", 2, "Silenced")
	self:NetworkVar("Bool", 3, "ShotgunCancel")
	self:NetworkVar("Float", 0, "StatusEnd")
	self:NetworkVar("Float", 1, "NextIdleAnim")
	self:NetworkVar("Int", 0, "Status")
	self:NetworkVar("Int", 1, "FireMode")
	self:NetworkVar("Int", 2, "LastActivity")
	self:NetworkVar("Int", 3, "BurstCount")
	self:NetworkVar("Entity", 0, "SwapTarget")
end

function SWEP:Initialize()
	self.DrawCrosshairDefault = self.DrawCrosshair
	self.HasInitialized = true

	self.DTapActivities = self.DTapActivities or {}
	self.Animations = self.Animations or {}

	self.Primary_TFA = self.Primary_TFA or table.Copy(self.Primary or {})
	if self.Primary and self.Primary.Projectile then
		self.ProjectileEntity = self.Primary.Projectile
		self.ProjectileVelocity = self.Primary.ProjectileVelocity or 0
		self.ProjectileModel = self.Primary.ProjectileModel
	end

	self.Secondary_TFA = self.Secondary_TFA or table.Copy(self.Secondary or {})

	self.GetIronSightsProgress = self.GetIronSightsProgress or self.GetIronSights

	self.BobScaleCustom = 1
	self.BobScale = 0
	self.SwayScaleCustom = 1
	self.SwayScale = 0

	self:SetSilenced(self.Silenced or self.DefaultSilenced)
	self.Silenced = self.Silenced or self.DefaultSilenced

	self:FixRPM()
	self:FixIdles()
	self:FixIS()
	self:FixProceduralReload()
	self:FixCone()

	self:AutoDetectMuzzle()
	self:AutoDetectDamage()
	self:AutoDetectDamageType()
	self:AutoDetectForce()
	self:AutoDetectKnockback()
	self:AutoDetectSpread()

	self:IconFix()
	self:CreateFireModes()
	self:FixAkimbo()
	self:InitHoldType()
	self:Precache()

	if not self.IronSightsMoveSpeed then
		self.IronSightsMoveSpeed = (self.MoveSpeed or 1) * 0.8
	end

	tfaEnsureNW2(self)
	self:SetNW2Bool("Drawn", false)
end

local function GetDir(snd)
	if not snd or snd == "" then return "" end
	snd = tostring(snd)
	snd = string.Replace(snd, "^", "")
	snd = string.Replace(snd, ")", "")
	snd = string.Replace(snd, "\\", "/")
	local dir = snd:match("^(.*)/[^/]*$")
	if dir and #dir > 0 then
		return dir .. "/"
	end
	return ""
end

function SWEP:Precache()
	local smk = self.SmokeParticles
	if istable(smk) then
		for _, v in pairs(smk) do
			if isstring(v) and v ~= "" and TFA and TFA.HasParticleSystem and TFA.HasParticleSystem(v) then
				PrecacheParticleSystem(v)
			end
		end
	end

	local snd = self.Primary and self.Primary.Sound
	if not snd or not isstring(snd) then
		util.PrecacheModel(self.ViewModel or "")
		util.PrecacheModel(self.WorldModel or "")
		if self.Primary and self.Primary.ProjectileModel then
			util.PrecacheModel(self.Primary.ProjectileModel)
		end
		return
	end

	local sndTbl = sound.GetProperties(snd)
	if sndTbl and sndTbl.sound then
		local wav = sndTbl.sound
		if istable(wav) then
			for _, s in pairs(wav) do
				wav = s
				break
			end
		end

		local dir = isstring(wav) and GetDir(wav) or ""
		if dir ~= "" and TFA and TFA.PrecacheDirectory then
			TFA.PrecacheDirectory("sound/" .. dir)
		end
	end

	util.PrecacheModel(self.ViewModel or "")
	util.PrecacheModel(self.WorldModel or "")
	if self.Primary and self.Primary.ProjectileModel then
		util.PrecacheModel(self.Primary.ProjectileModel)
	end
end

function SWEP:Deploy()
	ct = l_CT()

	self:VMIV()
	if not self:VMIV() then
		self:SetStatus((TFA and TFA.Enum and TFA.Enum.STATUS_IDLE) or 0)
		self:SetStatusEnd(ct)
		self:SetNextPrimaryFire(ct)
		self:SetIronSightsRaw(false)
		self:SetShotgunCancel(false)
		self:SetBurstCount(0)
		self.IronSightsProgress = 0
		self.SprintProgress = 0
		self.Inspecting = false
		local owner = self:GetOwner()
		self.DefaultFOV = TFADUSKFOV or (IsValid(owner) and owner:GetFOV() or 90)
		return true
	end

	if not self.HasDetectedValidAnimations then
		self:CacheAnimations()
	end

	success, tanim = self:ChooseDrawAnim()

	if sp then
		self:CallOnClient("ChooseDrawAnim", "")
	end

	self:SetStatus(TFA.Enum.STATUS_DRAW)

	local len = self:GetActivityLength(tanim)
	self:SetStatusEnd(ct + len)
	self:SetNextPrimaryFire(ct + len)

	self:SetIronSightsRaw(false)
	if not self.PumpAction then
		self:SetShotgunCancel(false)
	end
	self:SetBurstCount(0)

	self.IronSightsProgress = 0
	self.SprintProgress = 0
	self.Inspecting = false

	local owner = self:GetOwner()
	self.DefaultFOV = TFADUSKFOV or (IsValid(owner) and owner:GetFOV() or 90)

	return true
end

function SWEP:Holster(target)
	if not IsValid(target) then return true end
	if not IsValid(self) then return true end

	ct = l_CT()
	stat = self:GetStatus()

	if not TFA.Enum.HolsterStatus[stat] then
		if stat == TFA.GetStatus("reloading_wait") and self:Clip1() <= self:GetStat("Primary.ClipSize") and (not self:GetStat("DisableChambering")) and (not self:GetStat("Shotgun")) then
			tfaEnsureNW2(self)
			self:SetNW2Bool("Drawn", false)
		end

		success, tanim = self:ChooseHolsterAnim()

		if IsFirstTimePredicted() then
			self:SetSwapTarget(target)
		end

		self:SetStatus(TFA.Enum.STATUS_HOLSTER)

		if success then
			self:SetStatusEnd(ct + self:GetActivityLength(tanim))
		else
			self:SetStatusEnd(ct + self:GetStat("ProceduralHolsterTime"))
			self.ProceduralHolsterEnabled = true
			if sp then
				self:CallOnClient("EnableProceduralHolster")
			end
		end

		return false
	elseif stat == TFA.Enum.STATUS_HOLSTER_READY or stat == TFA.Enum.STATUS_HOLSTER_FINAL then
		return true
	end

	return true
end

function SWEP:EnableProceduralHolster()
	self.ProceduralHolsterEnabled = true
end

function SWEP:FinishHolster()
	if SERVER then
		local ent = self:GetSwapTarget()
		self:CleanParticles()
		self:Holster(ent)

		if IsValid(ent) and ent:IsWeapon() then
			local owner = self:GetOwner()
			if IsValid(owner) then
				owner:SelectWeapon(ent:GetClass())
			end
			self.OwnerViewModel = nil
		end
	end
end

function SWEP:OnRemove()
end

function SWEP:OnDrop()
end

function SWEP:Think()
end

local finalstat

function SWEP:PlayerThink()
	ft = (TFA and TFA.FrameTime and TFA.FrameTime()) or l_FT()
	if not self:NullifyOIV() then return end
	self:Think2()
	if SERVER then
		self:CalculateRatios()
	end
end

function SWEP:PlayerThinkCL()
	ft = (TFA and TFA.FrameTime and TFA.FrameTime()) or l_FT()
	if not self:NullifyOIV() then return end

	self:CalculateRatios()
	self:Think2()
	self:CalculateViewModelOffset()
	self:CalculateViewModelFlip()

	if (not self.Blowback_PistolMode) or self:Clip1() == -1 or self:Clip1() > 0.1 or (self.Blowback_PistolMode_Disabled and self.Blowback_PistolMode_Disabled[self:GetLastActivity()]) then
		self.BlowbackCurrent = l_mathApproach(self.BlowbackCurrent or 0, 0, (self.BlowbackCurrent or 0) * ft * 15)
	end

	self.BlowbackCurrentRoot = l_mathApproach(self.BlowbackCurrentRoot or 0, 0, (self.BlowbackCurrentRoot or 0) * ft * 15)
end

local waittime, is, spr

function SWEP:Think2()
	if not self.hasAtt then
		self.hasAtt = true
		if TFAApplyAttachmentOuter then
			TFAApplyAttachmentOuter(self)
		end
	end

	if self.LuaShellRequestTime and self.LuaShellRequestTime > 0 and CurTime() > self.LuaShellRequestTime then
		self.LuaShellRequestTime = -1
		self:MakeShell()
	end

	if not self.HasInitialized then
		self:Initialize()
	end

	if not self.HasDetectedValidAnimations then
		self:CacheAnimations()
		self:ChooseDrawAnim()
	end

	self:ProcessEvents()
	self:ProcessFireMode()
	self:ProcessHoldType()
	self:ReloadCV()

	is, spr = self:IronSights()
	is = self:GetIronSights()

	ct = l_ct()
	stat = self:GetStatus()
	statend = self:GetStatusEnd()

	if stat ~= TFA.Enum.STATUS_IDLE and ct > statend then
		finalstat = TFA.Enum.STATUS_IDLE

		if stat == TFA.Enum.STATUS_DRAW then
			tfaEnsureNW2(self)
			self:SetNW2Bool("Drawn", true)
		elseif stat == TFA.Enum.STATUS_HOLSTER then
			finalstat = TFA.Enum.STATUS_HOLSTER_READY
			self:SetStatusEnd(ct)
		elseif stat == TFA.Enum.STATUS_HOLSTER_READY then
			self:FinishHolster()
			finalstat = TFA.Enum.STATUS_HOLSTER_FINAL
			self:SetStatusEnd(ct + 0.6)
		elseif stat == TFA.Enum.STATUS_RELOADING_SHOTGUN_START_SHELL then
			self:TakePrimaryAmmo(1, true)
			self:TakePrimaryAmmo(-1)

			if self:Ammo1() <= 0 or self:Clip1() >= self:GetPrimaryClipSize() or self:GetShotgunCancel() then
				finalstat = TFA.Enum.STATUS_RELOADING_SHOTGUN_END
				local _
				_, tanim = self:ChooseShotgunPumpAnim()
				self:SetStatusEnd(ct + self:GetActivityLength(tanim))
				self:SetShotgunCancel(false)
			else
				waittime = self:GetActivityLength(self:GetLastActivity(), false) - self:GetActivityLength(self:GetLastActivity(), true)
				if waittime > 0.01 then
					finalstat = TFA.GetStatus("reloading_wait")
					self:SetStatusEnd(ct + waittime)
				else
					finalstat = self:LoadShell()
				end
			end
		elseif stat == TFA.Enum.STATUS_RELOADING_SHOTGUN_START then
			finalstat = self:LoadShell()
		elseif stat == TFA.Enum.STATUS_RELOADING_SHOTGUN_LOOP then
			self:TakePrimaryAmmo(1, true)
			self:TakePrimaryAmmo(-1)

			local lact = self:GetLastActivity()
			if self:GetActivityLength(lact, true) < self:GetActivityLength(lact, false) - 0.01 then
				local sht = self.ShellTime
				waittime = (sht or self:GetActivityLength(lact, false)) - self:GetActivityLength(lact, true)
			else
				waittime = 0
			end

			if waittime > 0.01 then
				finalstat = TFA.GetStatus("reloading_wait")
				self:SetStatusEnd(ct + waittime)
			else
				if self:Ammo1() <= 0 or self:Clip1() >= self:GetPrimaryClipSize() or self:GetShotgunCancel() then
					finalstat = TFA.Enum.STATUS_RELOADING_SHOTGUN_END
					local _
					_, tanim = self:ChooseShotgunPumpAnim()
					self:SetStatusEnd(ct + self:GetActivityLength(tanim))
					self:SetShotgunCancel(false)
				else
					finalstat = self:LoadShell()
				end
			end
		elseif stat == TFA.Enum.STATUS_RELOADING then
			self:CompleteReload()
			waittime = self:GetActivityLength(self:GetLastActivity(), false) - self:GetActivityLength(self:GetLastActivity(), true)
			if waittime > 0.01 then
				finalstat = TFA.GetStatus("reloading_wait")
				self:SetStatusEnd(ct + waittime)
			end
		elseif stat == TFA.GetStatus("reloading_wait") and self.Shotgun then
			if self:Ammo1() <= 0 or self:Clip1() >= self:GetPrimaryClipSize() or self:GetShotgunCancel() then
				finalstat = TFA.Enum.STATUS_RELOADING_SHOTGUN_END
				local _
				_, tanim = self:ChooseShotgunPumpAnim()
				self:SetStatusEnd(ct + self:GetActivityLength(tanim))
			else
				finalstat = self:LoadShell()
			end
		elseif stat == TFA.Enum.STATUS_SILENCER_TOGGLE then
			self:SetSilenced(not self:GetSilenced())
			self.Silenced = self:GetSilenced()
		elseif stat == TFA.GetStatus("reloading_shotgun_end") and self.Shotgun then
			self:SetShotgunCancel(false)
		elseif self.PumpAction and stat == TFA.GetStatus("pump") then
			self:SetShotgunCancel(false)
		elseif stat == TFA.GetStatus("shooting") and self.PumpAction then
			if self:Clip1() == 0 and self.PumpAction.value_empty then
				self:SetShotgunCancel(true)
			elseif (self.Primary.ClipSize < 0 or self:Clip1() > 0) and self.PumpAction.value then
				self:SetShotgunCancel(true)
			end
		end

		if finalstat == TFA.Enum.STATUS_IDLE then
			if stat ~= TFA.Enum.STATUS_SHOOTING then
				self:SetNextIdleAnim(-1)
			end
		end

		self:SetStatus(finalstat)
		self.LastBoltShoot = nil

		if self:GetBurstCount() > 0 then
			if finalstat ~= TFA.Enum.STATUS_SHOOTING and finalstat ~= TFA.Enum.STATUS_IDLE then
				self:SetBurstCount(0)
			elseif self:GetBurstCount() < self:GetMaxBurst() and self:Clip1() > 0 then
				self:PrimaryAttack()
			else
				self:SetBurstCount(0)
				self:SetNextPrimaryFire(CurTime() + self:GetBurstDelay())
			end
		end
	end

	stat = self:GetStatus()

	if self:GetShotgunCancel() and stat == TFA.Enum.STATUS_IDLE then
		if self.PumpAction then
			local owner = self:GetOwner()
			if CurTime() > self:GetNextPrimaryFire() and IsValid(owner) and not owner:KeyDown(IN_ATTACK) then
				self:DoPump()
			end
		else
			self:SetShotgunCancel(false)
		end
	end

	if TFA.Enum.ReadyStatus[stat] and ct > self:GetNextIdleAnim() then
		self:ChooseIdleAnim()
	end
end

local issighting, issprinting = false, false
local issighting_tmp
local ironsights_toggle_cvar, ironsights_resight_cvar
local ironsights_cv = GetConVar("sv_tfa_ironsights_enabled")
local sprint_cv = GetConVar("sv_tfa_sprint_enabled")

if CLIENT then
	ironsights_resight_cvar = GetConVar("cl_tfa_ironsights_resight")
	ironsights_toggle_cvar = GetConVar("cl_tfa_ironsights_toggle")
end

function SWEP:IronSights()
	if not self.Scoped and not self.Scoped_3D then
		if ironsights_cv and not ironsights_cv:GetBool() then
			self.data.ironsights_default = self.data.ironsights_default or self.data.ironsights
			self.data.ironsights = 0
		elseif self.data.ironsights_default == 1 and self.data.ironsights == 0 then
			self.data.ironsights = 1
			self.data.ironsights_default = 0
		end
	end

	ct = l_CT()
	stat = self:GetStatus()

	local owner = self:GetOwner()
	if not IsValid(owner) then
		self:SetIronSightsRaw(false)
		self:SetSprinting(false)
		return false, false
	end

	issighting = false
	issprinting = false

	self.is_old = self:GetIronSightsRaw()
	self.spr_old = self:GetSprinting()

	if sprint_cv and sprint_cv:GetBool() and not self.IsKnife and not self.IsMelee then
		issprinting = owner:GetVelocity():Length2D() > owner:GetRunSpeed() * 0.6 and owner:KeyDown(IN_SPEED)
	end

	if not (self.data and self.data.ironsights == 0) then
		if CLIENT then
			if ironsights_toggle_cvar and not ironsights_toggle_cvar:GetBool() then
				if owner:KeyDown(IN_ATTACK2) then
					issighting = true
				end
			else
				issighting = self:GetIronSightsRaw()
				if owner:KeyPressed(IN_ATTACK2) then
					issighting = not issighting
					self:SetIronSightsRaw(issighting)
				end
			end
		else
			if owner:GetInfoNum("cl_tfa_ironsights_toggle", 0) == 0 then
				if owner:KeyDown(IN_ATTACK2) then
					issighting = true
				end
			else
				issighting = self:GetIronSightsRaw()
				if owner:KeyPressed(IN_ATTACK2) then
					issighting = not issighting
					self:SetIronSightsRaw(issighting)
				end
			end
		end
	end

	local toggleMode = (CLIENT and ironsights_toggle_cvar and ironsights_toggle_cvar:GetBool()) or (SERVER and owner:GetInfoNum("cl_tfa_ironsights_toggle", 0) == 1)
	local resightMode = (CLIENT and ironsights_resight_cvar and ironsights_resight_cvar:GetBool()) or (SERVER and owner:GetInfoNum("cl_tfa_ironsights_resight", 0) == 1)

	if toggleMode and not resightMode then
		if issprinting then
			issighting = false
		end

		if not TFA.Enum.IronStatus[stat] then
			issighting = false
		end

		if self.BoltAction or self.BoltAction_Forced then
			if stat == TFA.Enum.STATUS_SHOOTING then
				if not self.LastBoltShoot then
					self.LastBoltShoot = CurTime()
				end
				if CurTime() > self.LastBoltShoot + self.BoltTimerOffset then
					issighting = false
				end
			else
				self.LastBoltShoot = nil
			end
		end
	end

	if TFA.Enum.ReloadStatus[stat] then
		issprinting = false
	end

	self.is_cached = nil

	if issighting or issprinting or stat ~= TFA.Enum.STATUS_IDLE then
		self.Inspecting = false
	end

	if self.is_old ~= issighting then
		self:SetIronSightsRaw(issighting)
	end

	issighting_tmp = issighting

	if issprinting then
		issighting = false
	end

	if stat ~= TFA.Enum.STATUS_IDLE and stat ~= TFA.Enum.STATUS_SHOOTING then
		issighting = false
	end

	if self:IsSafety() then
		issighting = false
	end

	if self.BoltAction or self.BoltAction_Forced then
		if stat == TFA.Enum.STATUS_SHOOTING then
			if not self.LastBoltShoot then
				self.LastBoltShoot = CurTime()
			end
			if CurTime() > self.LastBoltShoot + self.BoltTimerOffset then
				issighting = false
			end
		else
			self.LastBoltShoot = nil
		end
	end

	if self.is_old_final ~= issighting then
		if (not issighting) and ((CLIENT and IsFirstTimePredicted()) or (SERVER and sp)) then
			self:EmitSound(self.IronOutSound or "TFA.IronOut")
		elseif issighting and ((CLIENT and IsFirstTimePredicted()) or (SERVER and sp)) then
			self:EmitSound(self.IronInSound or "TFA.IronIn")
		end

		if self.Sights_Mode == TFA.Enum.LOCOMOTION_LUA then
			self:SetNextIdleAnim(-1)
		end
	end

	local smi = (self.Sights_Mode == TFA.Enum.LOCOMOTION_ANI) and (self.is_old_final ~= issighting)
	local spi = (self.Sprint_Mode == TFA.Enum.LOCOMOTION_HYBRID or self.Sprint_Mode == TFA.Enum.LOCOMOTION_ANI) and (self.spr_old ~= issprinting)

	if (smi or spi) and (self:GetStatus() == TFA.Enum.STATUS_IDLE or (self:GetStatus() == TFA.Enum.STATUS_SHOOTING and not self.BoltAction)) and not self:GetShotgunCancel() then
		local toggle_is = self.is_old ~= issighting
		if issighting and self.spr_old ~= issprinting then
			toggle_is = true
		end

		success = self:Locomote(
			toggle_is and (self.Sights_Mode == TFA.Enum.LOCOMOTION_ANI or self.Sights_Mode == TFA.Enum.LOCOMOTION_HYBRID),
			issighting,
			(self.spr_old ~= issprinting) and (self.Sprint_Mode == TFA.Enum.LOCOMOTION_ANI or self.Sprint_Mode == TFA.Enum.LOCOMOTION_HYBRID),
			issprinting
		)

		if (not success) and ((toggle_is and smi) or ((self.spr_old ~= issprinting) and spi)) then
			self:SetNextIdleAnim(-1)
		end
	end

	if self.spr_old ~= issprinting then
		self:SetSprinting(issprinting)
	end

	self.is_old_final = issighting

	return issighting_tmp, issprinting
end

SWEP.is_cached = nil
SWEP.is_cached_old = false

function SWEP:GetIronSights()
	if self.is_cached == nil then
		issighting = self:GetIronSightsRaw()
		issprinting = self:GetSprinting()
		stat = self:GetStatus()

		if issprinting then
			issighting = false
		end

		if not TFA.Enum.IronStatus[stat] then
			issighting = false
		end

		if self.BoltAction or self.BoltAction_Forced then
			if stat == TFA.Enum.STATUS_SHOOTING then
				if not self.LastBoltShoot then
					self.LastBoltShoot = CurTime()
				end
				if CurTime() > self.LastBoltShoot + self.BoltTimerOffset then
					issighting = false
				end
			else
				self.LastBoltShoot = nil
			end
		end

		self.is_cached = issighting
		self.is_cached_old = self.is_cached
	end

	return self.is_cached
end

local legacy_reloads_cv = GetConVar("sv_tfa_reloads_legacy")
local dryfire_cvar = GetConVar("sv_tfa_allow_dryfire")

function SWEP:CanPrimaryAttack()
	stat = self:GetStatus()

	if not TFA.Enum.ReadyStatus[stat] and stat ~= TFA.Enum.STATUS_SHOOTING then
		if stat == TFA.Enum.STATUS_RELOADING_SHOTGUN_START or stat == TFA.Enum.STATUS_RELOADING_SHOTGUN_LOOP then
			self:SetShotgunCancel(true)
		end
		return false
	end

	if self:GetShotgunCancel() and TFA.Enum.ReadyStatus[stat] then
		return false
	end

	if self:IsSafety() then
		self:EmitSound("Weapon_AR2.Empty2")
		self.LastSafetyShoot = self.LastSafetyShoot or 0

		if l_CT() < self.LastSafetyShoot + 0.2 then
			self:CycleSafety()
			self:SetNextPrimaryFire(l_CT() + 0.1)
		end

		self.LastSafetyShoot = l_CT()
		return false
	end

	local owner = self:GetOwner()
	if not IsValid(owner) then return false end

	if (self.Primary.ClipSize or -1) <= 0 and self:Ammo1() < (self.Primary.AmmoConsumption or 1) then
		return false
	end

	if self:GetPrimaryClipSize(true) > 0 and self:Clip1() < (self.Primary.AmmoConsumption or 1) then
		self:ChooseDryFireAnim()
		if not self.HasPlayedEmptyClick then
			self:EmitSound("Weapon_Pistol.Empty2")
			if dryfire_cvar and not dryfire_cvar:GetBool() then
				self:Reload(true)
			end
			self.HasPlayedEmptyClick = true
		end
		return false
	end

	if self:GetSprinting() and not (self.AllowSprintAttack or self.IsKnife or self.IsMelee) then
		return false
	end

	if self.FiresUnderwater == false and owner:WaterLevel() >= 3 then
		self:SetNextPrimaryFire(l_CT() + 0.5)
		self:EmitSound("Weapon_AR2.Empty")
		return false
	end

	self.HasPlayedEmptyClick = false
	return true
end

function SWEP:PrimaryAttack()
	if not IsValid(self) then return end
	if not self:VMIV() then return end
	if not self:CanPrimaryAttack() then return end

	local owner = self:GetOwner()

	if self.CanBeSilenced and IsValid(owner) and owner:KeyDown(IN_USE) and (SERVER or not sp) then
		local _, anim = self:ChooseSilenceAnim(not self:GetSilenced())
		self:SetStatus(TFA.Enum.STATUS_SILENCER_TOGGLE)
		self:SetStatusEnd(l_CT() + (self.SequenceLengthOverride[anim] or self:GetActivityLength(anim, true)))
		return
	end

	local now = l_CT()
	self:SetNextPrimaryFire(now + self:GetFireDelay())

	if self:GetMaxBurst() > 1 then
		self:SetBurstCount(math.max(1, self:GetBurstCount() + 1))
	end

	self:SetStatus(TFA.Enum.STATUS_SHOOTING)

	self:ToggleAkimbo()

	local _, shootAnim = self:ChooseShootAnim()
	local statusEnd = self:GetNextPrimaryFire()
	local animLength = shootAnim and self:GetActivityLength(shootAnim, true) or 0

	if animLength > 0 and self:GetMaxBurst() <= 1 and not self.PumpAction then
		statusEnd = math.max(statusEnd, now + animLength)
	end

	self:SetStatusEnd(statusEnd)

	if IsValid(owner) then
		owner:SetAnimation(PLAYER_ATTACK1)
	end

	if self.Primary.Sound and IsFirstTimePredicted() and not (sp and CLIENT) then
		if self.Primary.SilencedSound and self:GetSilenced() then
			self:EmitSound(self.Primary.SilencedSound)
		else
			self:EmitSound(self.Primary.Sound)
		end
	end

	self:TakePrimaryAmmo(self.Primary.AmmoConsumption or 1)
	self:ShootBulletInformation()

	local _, currentRecoil = self:CalculateConeRecoil()
	self:Recoil(currentRecoil, IsFirstTimePredicted())

	if sp and SERVER then
		self:CallOnClient("Recoil", "")
	end

	if self.MuzzleFlashEnabled and not self.AutoDetectMuzzleAttachment then
		self:ShootEffectsCustom()
	end

	if self.EjectionSmoke and IsFirstTimePredicted() and not (self.LuaShellEject and self.LuaShellEjectDelay > 0) then
		self:EjectionSmoke()
	end

	self:DoAmmoCheck()
end

function SWEP:CanSecondaryAttack()
end

function SWEP:SecondaryAttack()
	if self.data and self.data.ironsights == 0 and self.AltAttack then
		self:AltAttack()
		return
	end
end

function SWEP:Reload(released)
	if not self:VMIV() then return end
	if self:Ammo1() <= 0 then return end
	if (self.Primary.ClipSize or -1) < 0 then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if legacy_reloads_cv and legacy_reloads_cv:GetBool() and dryfire_cvar and not dryfire_cvar:GetBool() and not owner:KeyDown(IN_RELOAD) then return end
	if owner:KeyDown(IN_USE) then return end

	ct = l_CT()

	if self:GetStatus() == TFA.Enum.STATUS_IDLE then
		if self:Clip1() < self:GetPrimaryClipSize() then
			if self.Shotgun then
				local _
				_, tanim = self:ChooseShotgunReloadAnim()

				if self.ShotgunEmptyAnim then
					if tanim == ACT_VM_RELOAD_EMPTY and self.ShotgunEmptyAnim_Shell then
						self:SetStatus(TFA.Enum.STATUS_RELOADING_SHOTGUN_START_SHELL)
					else
						self:SetStatus(TFA.Enum.STATUS_RELOADING_SHOTGUN_START)
					end
				else
					self:SetStatus(TFA.Enum.STATUS_RELOADING_SHOTGUN_START)
				end

				self:SetStatusEnd(ct + self:GetActivityLength(tanim, true))
			else
				success, tanim = self:ChooseReloadAnim()
				self:SetStatus(TFA.Enum.STATUS_RELOADING)

				if self.ProceduralReloadEnabled then
					self:SetStatusEnd(ct + (self.ProceduralReloadTime or 0))
				else
					self:SetStatusEnd(ct + self:GetActivityLength(tanim, true))
				end
			end

			owner:SetAnimation(PLAYER_RELOAD)

			if self.Primary.ReloadSound and IsFirstTimePredicted() then
				self:EmitSound(self.Primary.ReloadSound)
			end
		else
			self:CheckAmmo()
		end
	end
end

function SWEP:LoadShell()
	local _
	_, tanim = self:ChooseReloadAnim()

	if self:GetActivityLength(tanim, true) < self:GetActivityLength(tanim, false) then
		self:SetStatusEnd(ct + self:GetActivityLength(tanim, true))
	else
		local sht = self.ShellTime
		self:SetStatusEnd(ct + (sht or self:GetActivityLength(tanim, true)))
	end

	return TFA.Enum.STATUS_RELOADING_SHOTGUN_LOOP
end

function SWEP:CompleteReload()
	local maxclip = self:GetPrimaryClipSize(true)
	local curclip = self:Clip1()
	local amounttoreplace = math.min(maxclip - curclip, self:Ammo1())
	self:TakePrimaryAmmo(amounttoreplace * -1)
	self:TakePrimaryAmmo(amounttoreplace, true)
end

function SWEP:CheckAmmo()
	if self:GetIronSights() or self:GetSprinting() then return end
	if (self.SequenceEnabled and self.SequenceEnabled[ACT_VM_FIDGET] or self.InspectionActions) and self:GetStatus() == TFA.Enum.STATUS_IDLE then
		local _
		_, tanim = self:ChooseInspectAnim()
		self:SetStatus(TFA.Enum.STATUS_FIDGET)
		self:SetStatusEnd(l_CT() + self:GetActivityLength(tanim, true))
	end
end

local cv_strip = GetConVar("sv_tfa_weapon_strip")

function SWEP:DoAmmoCheck()
	if IsValid(self) and SERVER and cv_strip and cv_strip:GetBool() and self:Clip1() == 0 and self:Ammo1() == 0 then
		timer.Simple(0.1, function()
			if SERVER and IsValid(self) and self:OwnerIsValid() then
				local owner = self:GetOwner()
				if IsValid(owner) then
					owner:StripWeapon(self.ClassName)
				end
			end
		end)
	end
end

local fovv
local sensval
local sensitivity_cvar, sensitivity_fov_cvar, sensitivity_speed_cvar
local resrat

if CLIENT then
	resrat = ScrW() / ScrH()
	sensitivity_cvar = GetConVar("cl_tfa_scope_sensitivity")
	sensitivity_fov_cvar = GetConVar("cl_tfa_scope_sensitivity_autoscale")
	sensitivity_speed_cvar = GetConVar("sv_tfa_scope_gun_speed_scale")
end

function SWEP:AdjustMouseSensitivity()
	sensval = 1

	if self:GetIronSights() then
		local sens = sensitivity_cvar and sensitivity_cvar:GetFloat() or 100
		sensval = sensval * sens / 100

		local autoscale = false
		if sensitivity_fov_cvar then
			if sensitivity_fov_cvar.GetBool then
				autoscale = sensitivity_fov_cvar:GetBool()
			else
				autoscale = sensitivity_fov_cvar:GetFloat() ~= 0
			end
		end

		if autoscale then
			if self.Scoped_3D then
				fovv = (self.RTScopeFOV or 0) * 4
			else
				local owner = self:GetOwner()
				fovv = IsValid(owner) and owner:GetFOV() or 90
			end

			local zoom = (self.Scoped_3D and self.Secondary and self.Secondary.ScopeZoom) or 1
			zoom = (zoom and zoom > 0) and zoom or 1
			fovv = fovv / zoom

			local dfov = self.DefaultFOV or 90
			sensval = sensval * math.atan(resrat * math.tan(math.rad(fovv / 2))) / math.atan(resrat * math.tan(math.rad(dfov / 2)))
		end

		local speedScale = sensitivity_speed_cvar and ((sensitivity_speed_cvar.GetBool and sensitivity_speed_cvar:GetBool()) or (sensitivity_speed_cvar:GetFloat() ~= 0)) or false
		if speedScale then
			sensval = sensval * (self.IronSightsMoveSpeed or 1)
		end
	end

	sensval = sensval * l_Lerp(self.IronSightsProgress or 0, 1, self.IronSightsSensitivity or 1)
	return sensval
end

local nfov

function SWEP:TranslateFOV(fov)
	self:CorrectScopeFOV()

	local sec = self.Secondary or {}
	local ironfov = tonumber(sec.IronFOV) or 90
	nfov = l_Lerp(self.IronSightsProgress or 0, fov, fov * math.min(ironfov / 90, 1))

	return l_Lerp(self.SprintProgress or 0, nfov, nfov + (self.SprintFOVOffset or 0))
end

function SWEP:GetPrimaryAmmoType()
	return (self.Primary and self.Primary.Ammo) or ""
end

local target_pos, target_ang, adstransitionspeed, hls
local flip_vec = Vector(-1, 1, 1)
local flip_ang = Vector(1, -1, -1)

local cl_tfa_viewmodel_offset_x
local cl_tfa_viewmodel_offset_y
local cl_tfa_viewmodel_offset_z
local cl_tfa_viewmodel_centered
local fovmod_add
local fovmod_mult

if CLIENT then
	cl_tfa_viewmodel_offset_x = GetConVar("cl_tfa_viewmodel_offset_x")
	cl_tfa_viewmodel_offset_y = GetConVar("cl_tfa_viewmodel_offset_y")
	cl_tfa_viewmodel_offset_z = GetConVar("cl_tfa_viewmodel_offset_z")
	cl_tfa_viewmodel_centered = GetConVar("cl_tfa_viewmodel_centered")
	fovmod_add = GetConVar("cl_tfa_viewmodel_offset_fov")
	fovmod_mult = GetConVar("cl_tfa_viewmodel_multiplier_fov")
end

target_pos = Vector()
target_ang = Vector()

local centered_sprintpos = Vector(0, -1, 1)
local centered_sprintang = Vector(-15, 0, 0)

function SWEP:CalculateViewModelOffset()
	ft = (TFA and TFA.FrameTime and TFA.FrameTime()) or l_FT()

	if self.VMPos_Additive then
		target_pos:Zero()
		target_ang:Zero()
	else
		local vmp = self.VMPos or vector_origin
		local vma = self.VMAng or vector_origin
		target_pos:Set(vmp)
		target_ang:Set(vma)
	end

	adstransitionspeed = 10

	is = self:GetIronSights()
	spr = self:GetSprinting()
	stat = self:GetStatus()

	hls = ((TFA.Enum.HolsterStatus[stat] and self.ProceduralHolsterEnabled) or (TFA.Enum.ReloadStatus[stat] and self.ProceduralReloadEnabled))

	if hls then
		local php = self.ProceduralHolsterPos or vector_origin
		local pha = self.ProceduralHolsterAng or vector_origin

		target_pos:Set(php)
		target_ang:Set(pha)

		if self.ViewModelFlip then
			target_pos:Mul(flip_vec)
			target_ang:Mul(flip_ang)
		end

		adstransitionspeed = (self.ProceduralHolsterTime or 0.3) * 15
	elseif is and (self.Sights_Mode == TFA.Enum.LOCOMOTION_LUA or self.Sights_Mode == TFA.Enum.LOCOMOTION_HYBRID) then
		target_pos:Set(self.IronSightsPos or self.SightsPos or vector_origin)
		target_ang:Set(self.IronSightsAng or self.SightsAng or vector_origin)
		adstransitionspeed = 15
	elseif (spr or self:IsSafety()) and (self.Sprint_Mode == TFA.Enum.LOCOMOTION_LUA or self.Sprint_Mode == TFA.Enum.LOCOMOTION_HYBRID or (self:IsSafety() and not spr)) and stat ~= TFA.Enum.STATUS_FIDGET and stat ~= TFA.Enum.STATUS_BASHING then
		if CLIENT and cl_tfa_viewmodel_centered and cl_tfa_viewmodel_centered:GetBool() then
			self.RunSightsPos = centered_sprintpos
			self.RunSightsAng = centered_sprintang
		end
		target_pos:Set(self.RunSightsPos or vector_origin)
		target_ang:Set(self.RunSightsAng or vector_origin)
		adstransitionspeed = 7.5
	end

	if CLIENT and cl_tfa_viewmodel_offset_x and not is then
		if cl_tfa_viewmodel_centered and cl_tfa_viewmodel_centered:GetBool() and self.IronSightsPos then
			target_pos.x = target_pos.x + (self.IronSightsPos.x or 0)
			if self.IronSightsAng then
				target_ang.y = target_ang.y + (self.IronSightsAng.y or 0)
			end
			target_pos.z = target_pos.z - 3
		end

		target_pos.x = target_pos.x + (cl_tfa_viewmodel_offset_x:GetFloat() or 0)
		target_pos.y = target_pos.y + ((cl_tfa_viewmodel_offset_y and cl_tfa_viewmodel_offset_y:GetFloat()) or 0)
		target_pos.z = target_pos.z + ((cl_tfa_viewmodel_offset_z and cl_tfa_viewmodel_offset_z:GetFloat()) or 0)
	end

	if self.Inspecting then
		if not self.InspectPos then
			self.InspectPos = (self.InspectPosDef or vector_origin) * 1
			if self.ViewModelFlip then
				self.InspectPos.x = self.InspectPos.x * -1
			end
		end

		if not self.InspectAng then
			self.InspectAng = (self.InspectAngDef or vector_origin) * 1
			if self.ViewModelFlip then
				self.InspectAng.x = (self.InspectAngDef and self.InspectAngDef.x) or self.InspectAng.x
				self.InspectAng.y = ((self.InspectAngDef and self.InspectAngDef.y) or self.InspectAng.y) * -1
				self.InspectAng.z = ((self.InspectAngDef and self.InspectAngDef.z) or self.InspectAng.z) * -1
			end
		end

		target_pos:Set(self.InspectPos)
		target_ang:Set(self.InspectAng)
		adstransitionspeed = 10
	end

	vm_offset_pos.x = math.Approach(vm_offset_pos.x, target_pos.x, (target_pos.x - vm_offset_pos.x) * ft * adstransitionspeed)
	vm_offset_pos.y = math.Approach(vm_offset_pos.y, target_pos.y, (target_pos.y - vm_offset_pos.y) * ft * adstransitionspeed)
	vm_offset_pos.z = math.Approach(vm_offset_pos.z, target_pos.z, (target_pos.z - vm_offset_pos.z) * ft * adstransitionspeed)

	vm_offset_ang.p = math.ApproachAngle(vm_offset_ang.p, target_ang.x, math.AngleDifference(target_ang.x, vm_offset_ang.p) * ft * adstransitionspeed)
	vm_offset_ang.y = math.ApproachAngle(vm_offset_ang.y, target_ang.y, math.AngleDifference(target_ang.y, vm_offset_ang.y) * ft * adstransitionspeed)
	vm_offset_ang.r = math.ApproachAngle(vm_offset_ang.r, target_ang.z, math.AngleDifference(target_ang.z, vm_offset_ang.r) * ft * adstransitionspeed)

	self:DoBobFrame()
end

local oldang = Angle()
local anga = Angle()
local angb = Angle()
local angc = Angle()
local posfac = 0.75
local gunswaycvar = GetConVar("cl_tfa_gunbob_intensity")

function SWEP:Sway(pos, ang)
	if not self:OwnerIsValid() then return pos, ang end

	local owner = self:GetOwner()
	if not IsValid(owner) then return pos, ang end

	local nowSys = SysTime()
	local lastSys = self.LastSysT or nowSys
	local rft = (nowSys - lastSys) * game.GetTimeScale()

	local ftLocal = l_FT()
	if rft > ftLocal then
		rft = ftLocal
	end

	rft = l_mathClamp(rft, 0, 1 / 30)

	if sv_cheats_cv and sv_cheats_cv:GetBool() and host_timescale_cv and host_timescale_cv:GetFloat() < 1 then
		rft = rft * host_timescale_cv:GetFloat()
	end

	self.LastSysT = nowSys

	ang:Normalize()

	local bobint = gunswaycvar and gunswaycvar:GetFloat() or 1
	local isr = self.IronSightsProgress or 0

	local angrange = l_Lerp(isr, 7.5, 2.5) * bobint
	local rate = l_Lerp(isr, 15, 30)
	local fac = l_Lerp(isr, 0.6, 0.15)

	local eye = owner:EyeAngles()
	anga = eye - oldang
	oldang = eye

	angb.y = angb.y + (0 - angb.y) * rft * 5
	angb.p = angb.p + (0 - angb.p) * rft * 5

	if angb.y < 50 and anga.y > 0 and anga.y < 25 then
		angb.y = angb.y + anga.y / 5
	end

	if angb.y > -50 and anga.y < 0 and anga.y > -25 then
		angb.y = angb.y + anga.y / 5
	end

	if angb.p < 50 and anga.p < 0 and anga.p > -25 then
		angb.p = angb.p - anga.p / 5
	end

	if angb.p > -50 and anga.p > 0 and anga.p < 25 then
		angb.p = angb.p - anga.p / 5
	end

	angb.p = l_mathClamp(angb.p, -angrange, angrange)
	angb.y = l_mathClamp(angb.y, -angrange, angrange)

	angc.y = angc.y + (angb.y / 15 - angc.y) * rft * rate
	angc.p = angc.p + (angb.p / 15 - angc.p) * rft * rate

	ang:RotateAroundAxis(oldang:Up(), angc.y * 15 * (self.ViewModelFlip and -1 or 1) * fac)
	ang:RotateAroundAxis(oldang:Right(), angc.p * 15 * fac)
	ang:RotateAroundAxis(oldang:Forward(), angc.y * 10 * fac)

	pos:Add(oldang:Right() * angc.y * posfac)
	pos:Add(oldang:Up() * -angc.p * posfac)

	return pos, util_NormalizeAngles(ang)
end

local gunbob_intensity_cvar = GetConVar("cl_tfa_gunbob_intensity")
local vmfov

function SWEP:GetViewModelPosition(pos, ang)
	local owner = self:GetOwner()
	if not IsValid(owner) then return pos, ang end

	self:CalculateViewModelOffset()

	self.BobScaleCustom = l_Lerp(
		self.IronSightsProgress or 0,
		1,
		l_Lerp(math.min(owner:GetVelocity():Length() / math.max(owner:GetWalkSpeed(), 1), 1), self.IronBobMult or 1, self.IronBobMultWalk or (self.IronBobMult or 1))
	)
	self.BobScaleCustom = l_Lerp(self.SprintProgress or 0, self.BobScaleCustom, self.SprintBobMult or 1)

	local gunbobintensity = (gunbob_intensity_cvar and gunbob_intensity_cvar:GetFloat() or 1) * 0.65 * 0.66
	if self.Idle_Mode == TFA.Enum.IDLE_LUA or self.Idle_Mode == TFA.Enum.IDLE_BOTH then
		pos, ang = self:CalculateBob(pos, ang, gunbobintensity)
	end

	if not ang then return end

	if not self.ogviewmodelfov then
		self.ogviewmodelfov = self.ViewModelFOV
	end

	if CLIENT and fovmod_mult and fovmod_add then
		vmfov = self.ogviewmodelfov * fovmod_mult:GetFloat()
		vmfov = vmfov + fovmod_add:GetFloat()
		self.ViewModelFOV = vmfov
	end

	pos, ang = self:Sway(pos, ang)

	ang:RotateAroundAxis(ang:Right(), vm_offset_ang.p)
	ang:RotateAroundAxis(ang:Up(), vm_offset_ang.y)
	ang:RotateAroundAxis(ang:Forward(), vm_offset_ang.r)

	local isr = self.IronSightsProgress or 0
	local curve = 1 - math.abs(0.5 - isr) * 2
	ang:RotateAroundAxis(ang:Forward(), -7.5 * curve * (self:GetIronSights() and 1 or 0.5) * (self.ViewModelFlip and 1 or -1))

	pos:Add(ang:Right() * vm_offset_pos.x)
	pos:Add(ang:Forward() * vm_offset_pos.y)
	pos:Add(ang:Up() * vm_offset_pos.z)

	if self.BlowbackEnabled and (self.BlowbackCurrentRoot or 0) > 0.01 then
		local bbv = self.BlowbackVector or vector_origin
		local bbr = self.BlowbackCurrentRoot or 0
		pos:Add(ang:Right() * bbv.x * bbr)
		pos:Add(ang:Forward() * bbv.y * bbr)
		pos:Add(ang:Up() * bbv.z * bbr)
	end

	if self:GetHidden() then
		pos.z = -10000
	end

	if self.VMPos_Additive then
		local vmp = self.VMPos or vector_origin
		local vma = self.VMAng or vector_origin

		pos:Add(ang:Right() * vmp.x)
		pos:Add(ang:Forward() * vmp.y)
		pos:Add(ang:Up() * vmp.z)

		ang:RotateAroundAxis(ang:Right(), vma.x)
		ang:RotateAroundAxis(ang:Up(), vma.y)
		ang:RotateAroundAxis(ang:Forward(), vma.z)
	end

	return pos, ang
end

function SWEP:DoPump()
	local owner = self:GetOwner()
	if IsValid(owner) and owner:IsNPC() then return end
	local _, anim = self:PlayAnimation(self.PumpAction)
	self:SetStatus(TFA.GetStatus("pump"))
	self:SetStatusEnd(CurTime() + self:GetActivityLength(anim, true))
	self:SetNextPrimaryFire(CurTime() + self:GetActivityLength(anim, false))
	self:SetNextIdleAnim(math.max(self:GetNextIdleAnim(), CurTime() + self:GetActivityLength(anim, false)))
end

function SWEP:ToggleInspect()
	if self:GetSprinting() or self:GetIronSights() or self:GetStatus() ~= TFA.Enum.STATUS_IDLE then return end
	self.Inspecting = not self.Inspecting
end

function SWEP:GetWalking()
	if not self:OwnerIsValid() then return false end
	local ply = self:GetOwner()
	if not IsValid(ply) or not ply:IsPlayer() then return false end
	local v = ply:GetVelocity():Length2D()
	return ply:KeyDown(IN_WALK) or (v <= ply:GetWalkSpeed() and v > 1)
end

function SWEP:IsJammed()
	return false
end

function SWEP:UpdateJamFactor()
end

function SWEP:RollJamChance()
end

local tfa_default_animations = {
	draw = { type = TFA.Enum.ANIMATION_ACT, value = ACT_VM_DRAW },
	draw_empty = { type = TFA.Enum.ANIMATION_ACT, value = ACT_VM_DRAW_EMPTY or ACT_VM_DRAW },
	draw_silenced = { type = TFA.Enum.ANIMATION_ACT, value = ACT_VM_DRAW_SILENCED or ACT_VM_DRAW },
	draw_first = { type = TFA.Enum.ANIMATION_ACT, value = ACT_VM_DRAW_DEPLOYED or ACT_VM_DRAW },
	idle = { type = TFA.Enum.ANIMATION_ACT, value = ACT_VM_IDLE },
	idle_empty = { type = TFA.Enum.ANIMATION_ACT, value = ACT_VM_IDLE_EMPTY or ACT_VM_IDLE },
	idle_silenced = { type = TFA.Enum.ANIMATION_ACT, value = ACT_VM_IDLE_SILENCED or ACT_VM_IDLE },
	holster = { type = TFA.Enum.ANIMATION_ACT, value = ACT_VM_HOLSTER },
	holster_empty = { type = TFA.Enum.ANIMATION_ACT, value = ACT_VM_HOLSTER_EMPTY or ACT_VM_HOLSTER },
	holster_silenced = { type = TFA.Enum.ANIMATION_ACT, value = ACT_VM_HOLSTER_SILENCED or ACT_VM_HOLSTER },
	reload = { type = TFA.Enum.ANIMATION_ACT, value = ACT_VM_RELOAD },
	reload_empty = { type = TFA.Enum.ANIMATION_ACT, value = ACT_VM_RELOAD_EMPTY or ACT_VM_RELOAD },
	reload_silenced = { type = TFA.Enum.ANIMATION_ACT, value = ACT_VM_RELOAD_SILENCED or ACT_VM_RELOAD },
	shoot1 = { type = TFA.Enum.ANIMATION_ACT, value = ACT_VM_PRIMARYATTACK },
	shoot1_is = { type = TFA.Enum.ANIMATION_ACT, value = ACT_VM_PRIMARYATTACK_1 or ACT_VM_PRIMARYATTACK },
	shoot1_empty = { type = TFA.Enum.ANIMATION_ACT, value = ACT_VM_PRIMARYATTACK_EMPTY or ACT_VM_PRIMARYATTACK },
	shoot1_last = { type = TFA.Enum.ANIMATION_ACT, value = ACT_VM_PRIMARYATTACK_EMPTY or ACT_VM_PRIMARYATTACK },
	shoot1_silenced = { type = TFA.Enum.ANIMATION_ACT, value = ACT_VM_PRIMARYATTACK_SILENCED or ACT_VM_PRIMARYATTACK },
	shoot2 = { type = TFA.Enum.ANIMATION_ACT, value = ACT_VM_SECONDARYATTACK or ACT_VM_PRIMARYATTACK },
	inspect = { type = TFA.Enum.ANIMATION_ACT, value = ACT_VM_FIDGET },
	inspect_empty = { type = TFA.Enum.ANIMATION_ACT, value = ACT_VM_FIDGET_EMPTY or ACT_VM_FIDGET },
	inspect_silenced = { type = TFA.Enum.ANIMATION_ACT, value = ACT_VM_FIDGET }
}

function SWEP:ChooseAnimation(anim)
	local data

	local baseAnims = self.BaseAnimations
	if baseAnims then
		data = baseAnims[anim]
	end

	if not data then
		local anims = self.Animations
		if anims then
			data = anims[anim]
		end
	end

	if not data then
		data = tfa_default_animations[anim]
	end

	if not data then return end
	return data.type, data.value
end
