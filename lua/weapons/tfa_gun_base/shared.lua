--[[Define Modules]]
SWEP.SV_MODULES = {}
SWEP.SH_MODULES = {"sh_anims.lua", "sh_autodetection.lua", "sh_utils.lua", "sh_bullet.lua", "sh_effects.lua", "sh_bobcode.lua", "sh_calc.lua", "sh_akimbo.lua", "sh_events.lua", "sh_nzombies.lua" }
SWEP.ClSIDE_MODULES = { "cl_effects.lua", "cl_viewbob.lua", "cl_hud.lua", "cl_mods.lua" }
SWEP.Category = "" --The category.  Please, just choose something generic or something I've already done if you plan on only doing like one swep.
SWEP.Author = "TheForgottenArchitect"
SWEP.Contact = "theforgottenarchitect"
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 65
SWEP.ViewModelFlip = false
SWEP.Skin = 0 --Viewmodel skin
SWEP.Spawnable = false
SWEP.IsTFAWeapon = true
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

	swep.SetIronSightsRaw = swep.SetIronSightsRaw or function(self, val)
		tfaEnsureNW2(self)
		self:SetNW2Bool("IronSightsRaw", val and true or false)
	end

	swep.GetIronSightsRaw = swep.GetIronSightsRaw or function(self)
		tfaEnsureNW2(self)
		return self:GetNW2Bool("IronSightsRaw", false)
	end

	swep.SetSprinting = swep.SetSprinting or function(self, val)
		tfaEnsureNW2(self)
		self:SetNW2Bool("Sprinting", val and true or false)
	end

	swep.GetSprinting = swep.GetSprinting or function(self)
		tfaEnsureNW2(self)
		return self:GetNW2Bool("Sprinting", false)
	end

	swep.SetSilenced = swep.SetSilenced or function(self, val)
		tfaEnsureNW2(self)
		self:SetNW2Bool("Silenced", val and true or false)
	end

	swep.GetSilenced = swep.GetSilenced or function(self)
		tfaEnsureNW2(self)
		return self:GetNW2Bool("Silenced", false)
	end

	swep.SetShotgunCancel = swep.SetShotgunCancel or function(self, val)
		tfaEnsureNW2(self)
		self:SetNW2Bool("ShotgunCancel", val and true or false)
	end

	swep.GetShotgunCancel = swep.GetShotgunCancel or function(self)
		tfaEnsureNW2(self)
		return self:GetNW2Bool("ShotgunCancel", false)
	end

	swep.SetStatus = swep.SetStatus or function(self, val)
		tfaEnsureNW2(self)
		self:SetNW2Int("Status", val or 0)
	end

	swep.GetStatus = swep.GetStatus or function(self)
		tfaEnsureNW2(self)
		return self:GetNW2Int("Status", (TFA and TFA.Enum and TFA.Enum.STATUS_IDLE) or 0)
	end

	swep.SetStatusEnd = swep.SetStatusEnd or function(self, val)
		tfaEnsureNW2(self)
		self:SetNW2Float("StatusEnd", val or 0)
	end

	swep.GetStatusEnd = swep.GetStatusEnd or function(self)
		tfaEnsureNW2(self)
		return self:GetNW2Float("StatusEnd", 0)
	end

	swep.SetNextIdleAnim = swep.SetNextIdleAnim or function(self, val)
		tfaEnsureNW2(self)
		self:SetNW2Float("NextIdleAnim", val or 0)
	end

	swep.GetNextIdleAnim = swep.GetNextIdleAnim or function(self)
		tfaEnsureNW2(self)
		return self:GetNW2Float("NextIdleAnim", 0)
	end

	swep.SetFireMode = swep.SetFireMode or function(self, val)
		tfaEnsureNW2(self)
		self:SetNW2Int("FireMode", val or 0)
	end

	swep.GetFireMode = swep.GetFireMode or function(self)
		tfaEnsureNW2(self)
		return self:GetNW2Int("FireMode", 0)
	end

	swep.SetLastActivity = swep.SetLastActivity or function(self, val)
		tfaEnsureNW2(self)
		self:SetNW2Int("LastActivity", val or 0)
	end

	swep.GetLastActivity = swep.GetLastActivity or function(self)
		tfaEnsureNW2(self)
		return self:GetNW2Int("LastActivity", 0)
	end

	swep.SetBurstCount = swep.SetBurstCount or function(self, val)
		tfaEnsureNW2(self)
		self:SetNW2Int("BurstCount", val or 0)
	end

	swep.GetBurstCount = swep.GetBurstCount or function(self)
		tfaEnsureNW2(self)
		return self:GetNW2Int("BurstCount", 0)
	end

	swep.SetSwapTarget = swep.SetSwapTarget or function(self, val)
		tfaEnsureNW2(self)
		self:SetNW2Entity("SwapTarget", val)
	end

	swep.GetSwapTarget = swep.GetSwapTarget or function(self)
		tfaEnsureNW2(self)
		return self:GetNW2Entity("SwapTarget")
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

SWEP.data = {}
SWEP.data.ironsights = 1

SWEP.MoveSpeed = 1
SWEP.IronSightsMoveSpeed = nil

SWEP.Primary.Damage = -1
SWEP.Primary.NumShots = 1
SWEP.Primary.Force = -1
SWEP.Primary.KnockBack = -1
SWEP.Primary.Recoil = 1
SWEP.Primary.RPM = 600
SWEP.Primary.RPM_Semi = -1
SWEP.Primary.RPM_Burst = -1
SWEP.Primary.StaticRecoilFactor = 0.5
SWEP.Primary.KickUp = 0.5
SWEP.Primary.KickDown = 0.5
SWEP.Primary.KickRight = 0.5
SWEP.Primary.KickHorizontal = 0.5
SWEP.Primary.DamageType = nil
SWEP.Primary.Ammo = "smg1"
SWEP.Primary.AmmoConsumption = 1
SWEP.Primary.Spread = 0
SWEP.Primary.SpreadMultiplierMax = -1 --How far the spread can expand when you shoot.
SWEP.Primary.SpreadIncrement = -1 --What percentage of the modifier is added on, per shot.
SWEP.Primary.SpreadRecovery = -1 --How much the spread recovers, per second.
SWEP.Primary.IronAccuracy = 0
SWEP.Primary.MaxPenetration = 2
SWEP.Primary.Range = 1200
SWEP.Primary.RangeFalloff = 0.5

SWEP.Shotgun = false
SWEP.ShotgunEmptyAnim = true
SWEP.ShotgunEmptyAnim_Shell = true

SWEP.BoltAction = false --Unscope/sight after you shoot?
SWEP.BoltAction_Forced = false
SWEP.Scoped = false --Draw a scope overlay?
SWEP.ScopeOverlayThreshold = 0.875 --Percentage you have to be sighted in to see the scope.
SWEP.BoltTimerOffset = 0.25 --How long you stay sighted in after shooting, with a bolt action.
SWEP.ScopeScale = 0.5
SWEP.ReticleScale = 0.7

SWEP.MuzzleAttachment = "1"
SWEP.ShellAttachment = "2"

SWEP.MuzzleFlashEnabled = true
SWEP.MuzzleFlashEffect = nil
SWEP.CustomMuzzleFlash = true

SWEP.LuaShellEject = false
SWEP.LuaShellEjectDelay = 0
SWEP.LuaShellEffect = nil --Defaults to blowback

SWEP.SequenceLengthOverride = {}

SWEP.BlowbackEnabled = false --Enable Blowback?
SWEP.BlowbackVector = Vector(0, -1, 0) --Vector to move bone <or root> relative to bone <or view> orientation.
SWEP.BlowbackCurrentRoot = 0 --Amount of blowback currently, for root
SWEP.BlowbackCurrent = 0 --Amount of blowback currently, for bones
SWEP.BlowbackBoneMods = nil --Viewmodel bone mods via SWEP Creation Kit
SWEP.Blowback_Only_Iron = true --Only do blowback on ironsights
SWEP.Blowback_PistolMode = false --Do we recover from blowback when empty?

SWEP.ProceduralHolsterEnabled = false
SWEP.ProceduralHolsterTime = 0.3
SWEP.ProceduralHolsterPos = Vector(3, 0, -5)
SWEP.ProceduralHolsterAng = Vector(-40, -30, 10)

SWEP.ProceduralReloadEnabled = false --Do we reload using lua instead of a .mdl animation
SWEP.ProceduralReloadTime = 1 --Time to take when procedurally reloading, including transition in (but not out)

ACT_VM_FIDGET_EMPTY = ACT_VM_FIDGET_EMPTY or ACT_CROSSBOW_FIDGET_UNLOADED

SWEP.Blowback_PistolMode_Disabled = {
	[ACT_VM_RELOAD] = true,
	[ACT_VM_RELOAD_EMPTY] = true,
	[ACT_VM_DRAW_EMPTY] = true,
	[ACT_VM_IDLE_EMPTY] = true,
	[ACT_VM_HOLSTER_EMPTY] = true,
	[ACT_VM_DRYFIRE] = true,
	[ACT_VM_FIDGET] = true,
	[ACT_VM_FIDGET_EMPTY] = true
}

SWEP.Blowback_Shell_Enabled = true
SWEP.Blowback_Shell_Effect = "ShellEject"

SWEP.Secondary.Ammo = ""
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0

SWEP.Sights_Mode = TFA.Enum.LOCOMOTION_LUA -- ANI = mdl, Hybrid = stop mdl animation, Lua = hybrid but continue idle
SWEP.Sprint_Mode = TFA.Enum.LOCOMOTION_LUA -- ANI = mdl, Hybrid = ani + lua, Lua = lua only
SWEP.SprintFOVOffset = 5
SWEP.Idle_Mode = TFA.Enum.IDLE_LUA --TFA.Enum.IDLE_DISABLED = no idle, TFA.Enum.IDLE_LUA = lua idle, TFA.Enum.IDLE_ANI = mdl idle, TFA.Enum.IDLE_BOTH = TFA.Enum.IDLE_ANI + TFA.Enum.IDLE_LUA
SWEP.Idle_Blend = 0.25 --Start an idle this far early into the end of a transition
SWEP.Idle_Smooth = 0.05 --Start an idle this far early into the end of another animation

SWEP.IronSightTime = 0.3
SWEP.IronSightsSensitivity = 1

SWEP.InspectPosDef = Vector(9.779, -11.658, -2.241)
SWEP.InspectAngDef = Vector(24.622, 42.915, 15.477)

SWEP.RunSightsPos = Vector(0,0,0)
SWEP.RunSightsAng = Vector(0,0,0)
SWEP.AllowSprintAttack = false --Shoot while sprinting?

SWEP.EventTable = {}

SWEP.RTMaterialOverride = nil
SWEP.RTOpaque = false
SWEP.RTCode = nil--function(self) return end

SWEP.VMPos = Vector(0,0,0)
SWEP.VMAng = Vector(0,0,0)
SWEP.CameraOffset = Angle(0, 0, 0)
SWEP.VMPos_Additive = true

local vm_offset_pos = Vector()
local vm_offset_ang = Angle()

SWEP.IronAnimation = {
	--[[
	["in"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Idle_To_Iron", --Number for act, String/Number for sequence
		["value_empty"] = "Idle_To_Iron_Dry",
		["transition"] = true
	}, --Inward transition
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Idle_Iron", --Number for act, String/Number for sequence
		["value_empty"] = "Idle_Iron_Dry"
	}, --Looping Animation
	["out"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Iron_To_Idle", --Number for act, String/Number for sequence
		["value_empty"] = "Iron_To_Idle_Dry",
		["transition"] = true
	}, --Outward transition
	["shoot"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Fire_Iron", --Number for act, String/Number for sequence
		["value_last"] = "Fire_Iron_Last",
		["value_empty"] = "Fire_Iron_Dry"
	} --What do you think
	]]--
}

SWEP.SprintAnimation = {
	--[[
	["in"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Idle_to_Sprint", --Number for act, String/Number for sequence
		["value_empty"] = "Idle_to_Sprint_Empty",
		["transition"] = true
	}, --Inward transition
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Sprint_", --Number for act, String/Number for sequence
		["value_empty"] = "Sprint_Empty_",
		["is_idle"] = true
	},--looping animation
	["out"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Sprint_to_Idle", --Number for act, String/Number for sequence
		["value_empty"] = "Sprint_to_Idle_Empty",
		["transition"] = true
	} --Outward transition
	]]--
}

SWEP.IronSightsProgress = 0
SWEP.SprintProgress = 0
SWEP.SpreadRatio = 0
SWEP.CrouchingRatio = 0
SWEP.SmokeParticles = {
	pistol = "smoke_trail_controlled",
	smg = "smoke_trail_tfa",
	grenade = "smoke_trail_tfa",
	ar2 = "smoke_trail_tfa",
	shotgun = "smoke_trail_wild",
	rpg = "smoke_trail_tfa",
	physgun = "smoke_trail_tfa",
	crossbow = "smoke_trail_tfa",
	melee = "smoke_trail_tfa",
	slam = "smoke_trail_tfa",
	normal = "smoke_trail_tfa",
	melee2 = "smoke_trail_tfa",
	knife = "smoke_trail_tfa",
	duel = "smoke_trail_tfa",
	camera = "smoke_trail_tfa",
	magic = "smoke_trail_tfa",
	revolver = "smoke_trail_tfa",
	silenced = "smoke_trail_controlled"
}

SWEP.Inspecting = false
SWEP.InspectingProgress = 0
SWEP.LuaShellRequestTime = -1
SWEP.BobScale = 0
SWEP.SwayScale = 0
SWEP.BoltDelay = 1
SWEP.ProceduralHolsterProgress = 0
SWEP.BurstCount = 0
SWEP.DefaultFOV = 90

--[[ Localize Functions  ]]
local function l_Lerp(v, f, t)
	return f + (t - f) * v
end

local l_mathApproach = math.Approach
local l_mathClamp = math.Clamp
local l_CT = CurTime
local l_FT = FrameTime
local l_RT = RealTime
--[[  Quadratic Interpolation Functions  ]]
local qerppower = 2

--[[
Function Name:  Power
Syntax: pow(number you want to take the power of, it's power)
Returns:  The number to the power you specify
Purpose:  Utility function
]]
local function pow(num, power)
	return math.pow(num, power)
end

--[[
Function Name:  Qerp Inwards
Syntax: QerpIn(progress, your starting value, how much it should change, across what period)
Returns:  A number that you get when you quadratically fade into a value.  Kind of like a more advanced LERP.
Purpose:  Utility function / Animation
]]
local function QerpIn(progress, startval, change, totaltime)
	if not totaltime then
		totaltime = 1
	end

	return startval + change * pow(progress / totaltime, qerppower)
end

--[[
Function Name:  Qerp Outwards
Syntax: QerpOut(progress, your starting value, how much it should change, across what period)
Returns:  A number that you get when you quadratically fade out of a value.  Kind of like a more advanced LERP.
Purpose:  Utility function / Animation
]]
local function QerpOut(progress, startval, change, totaltime)
	if not totaltime then
		totaltime = 1
	end

	return startval - change * pow(progress / totaltime, qerppower)
end

--[[
Function Name:  Qerp
Syntax: Qerp(progress, starting value, ending value, period)
Note:  This is different syntax from QerpIn and QerpOut.  This uses a start and end value instead of a start value and change amount.
Returns:  A number that you get when you quadratically fade out of and into a value.  Kind of like a more advanced LERP.
Purpose:  Utility function / Animation
]]
local function Qerp(progress, startval, endval, totaltime)
	change = endval - startval

	if not totaltime then
		totaltime = 1
	end

	if progress < totaltime / 2 then return QerpIn(progress, startval, change / 2, totaltime / 2) end

	return QerpOut(totaltime - progress, endval, change / 2, totaltime / 2)
end

--[[
Function Name:  QerpAngle
Syntax: QerpAngle(progress, starting value, ending value, period)
Returns:  The quadratically interpolated angle.
Purpose:  Utility function / Animation
]]
local l_NormalizeAngle = math.NormalizeAngle
local LerpAngle = LerpAngle

local function util_NormalizeAngles(a)
	a.p = l_NormalizeAngle(a.p)
	a.y = l_NormalizeAngle(a.y)
	a.r = l_NormalizeAngle(a.r)

	return a
end

local function QerpAngle(progress, startang, endang, totaltime)
	return util_NormalizeAngles(LerpAngle(Qerp(progress, 0, 1, totaltime), startang, endang))
end

--[[
Function Name:  QerpVector
Syntax: QerpVector(progress, starting value, ending value, period)
Returns:  The quadratically interpolated vector.
Purpose:  Utility function / Animation
]]
local myqerpvec = Vector()

local function QerpVector(progress, startang, endang, totaltime)
	if not totaltime then
		totaltime = 1
	end

	local startx, starty, startz, endx, endy, endz
	startx = startang.x
	starty = startang.y
	startz = startang.z
	endx = endang.x
	endy = endang.y
	endz = endang.z
	myqerpvec.x = Qerp(progress, startx, endx, totaltime)
	myqerpvec.y = Qerp(progress, starty, endy, totaltime)
	myqerpvec.z = Qerp(progress, startz, endz, totaltime)

	return myqerpvec
end

--[[Localize Functions]]
local l_ct = CurTime
local l_ft = FrameTime
--[[Frequently Reused Local Vars]]
local success, animation --Used for animations
local stat, statend --Weapon status
local ct, ft, rft --Curtime, frametime, real frametime
ft = 0.01
local sp --Singleplayer

local host_timescale_cv = GetConVar("host_timescale")
local sv_cheats_cv = GetConVar("sv_cheats")

--[[
Function Name:  ResetEvents
Syntax: self:ResetEvents()
Returns:  Nothing.
Purpose:  Cleans up events table.
]]
function SWEP:ResetEvents()
end

--[[
Function Name:  SetupDataTables
Syntax: Should not be manually called.
Returns:  Nothing.  Simple sets up DTVars to be networked.
Purpose:  Networking.
]]
function SWEP:SetupDataTables()
	--self:NetworkVar("Bool", 0, "IronSights")
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

--[[
Function Name:  Initialize
Syntax: Should not be normally called.
Notes:   Called after actual SWEP code, but before deploy, and only once.
Returns:  Nothing.  Sets the intial values for the SWEP when it's created.
Purpose:  Standard SWEP Function
]]
sp = game.SinglePlayer()

function SWEP:Initialize()
	self.DrawCrosshairDefault = self.DrawCrosshair
	self.HasInitialized = true
	self.DTapActivities = self.DTapActivities or {}
	self.Animations = self.Animations or {}
	self.Primary_TFA = self.Primary_TFA or table.Copy(self.Primary or {})
	self.Secondary_TFA = self.Secondary_TFA or table.Copy(self.Secondary or {})
	self.GetIronSightsProgress = self.GetIronSightsProgress or self.GetIronSights
	self.BobScaleCustom = 1
	self.BobScale = 0
	self.SwayScaleCustom = 1
	self.SwayScale = 0
	self:SetSilenced( self.Silenced or self.DefaultSilenced )
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
		self.IronSightsMoveSpeed = self.MoveSpeed * 0.8
	end
	self.SetNW2Bool = self.SetNW2Bool or self.SetNWBool
	self.GetNW2Bool = self.GetNW2Bool or self.GetNWBool
	self:SetNW2Bool("Drawn",false)
end

local function GetDir(snd)
	snd = string.Replace(snd,"^","")
	snd = string.Replace(snd,")","")
	snd = string.Replace(snd,"\\","/")
	local foundPos = 1
	while (foundPos ~= 0) do
		local oldFoundPos = foundPos
		foundPos = string.find(snd,"/",foundPos + 1)
		if not foundPos then
			foundPos = oldFoundPos
			break
		end
	end
	return string.sub(snd,1,foundPos)
end

function SWEP:Precache()
	for k, v in pairs(self.SmokeParticles) do
		if isstring(v) then
			PrecacheParticleSystem(v)
		end
	end
	local snd = self.Primary.Sound
	if not snd then return end
	if not isstring(snd) then return end
	local sndTbl = sound.GetProperties( snd )
	if sndTbl and sndTbl.sound then
		local wav = sndTbl.sound
		if istable(wav) then
			wav = wav[table.GetKeys(wav)[1]]
		end
		local dir = GetDir(wav)
		if dir and string.len(dir) > 1 then
			TFA.PrecacheDirectory("sound/" .. GetDir(wav))
		end
	end
	util.PrecacheModel(self.ViewModel or "")
	util.PrecacheModel(self.WorldModel or "")
	if self.Primary.ProjectileModel then
		util.PrecacheModel(self.Primary.ProjectileModel)
	end
end

--[[
Function Name:  Deploy
Syntax: self:Deploy()
Notes:  Called after self:Initialize().  Called each time you draw the gun.  This is also essential to clearing out old networked vars and resetting them.
Returns:  True/False to allow quickswitch.  Why not?  You should really return true.
Purpose:  Standard SWEP Function
]]
function SWEP:Deploy()
	ct = l_CT()
	self:VMIV()
	if not self:VMIV() then
		print("Invalid VM on owner: ")
		print(self.Owner)

		return
	end
	if not self.HasDetectedValidAnimations then
		self:CacheAnimations()
	end

	success,tanim = self:ChooseDrawAnim()

	if sp then
		self:CallOnClient("ChooseDrawAnim", "")
	end

	self:SetStatus(TFA.Enum.STATUS_DRAW)
	local len = self:GetActivityLength(tanim)
	self:SetStatusEnd(ct + len )
	self:SetNextPrimaryFire( ct + len )
	self:SetIronSightsRaw(false)
	if not self.PumpAction then
		self:SetShotgunCancel( false )
	end
	self:SetBurstCount(0)
	self.IronSightsProgress = 0
	self.SprintProgress = 0
	self.Inspecting = false
	self.DefaultFOV = TFADUSKFOV or ( IsValid(self.Owner) and self.Owner:GetFOV() or 90 )
	return true
end

--[[
Function Name:  Holster
Syntax: self:Holster( weapon entity to switch to )
Notes:  This is kind of broken.  I had to manually select the new weapon using ply:ConCommand.  Returning true is simply not enough.  This is also essential to clearing out old networked vars and resetting them.
Returns:  True/False to allow holster.  Useful for animations.
Purpose:  Standard SWEP Function
]]
function SWEP:Holster(target)
	if not IsValid(target) then return true end
	if not IsValid(self) then return end
	ct = l_CT()
	stat = self:GetStatus()

	if not TFA.Enum.HolsterStatus[stat] then
		if stat == TFA.GetStatus("reloading_wait") and self:Clip1() <= self:GetStat("Primary.ClipSize") and ( not self:GetStat("DisableChambering") ) and ( not self:GetStat("Shotgun") ) then
			self:SetNW2Bool("Drawn",false)
		end

		success, tanim = self:ChooseHolsterAnim()

		if IsFirstTimePredicted() then
			self:SetSwapTarget(target)
		end

		self:SetStatus(TFA.Enum.STATUS_HOLSTER)
		if success then
			self:SetStatusEnd( ct + self:GetActivityLength( tanim ) )
		else
			self:SetStatusEnd( ct + self:GetStat("ProceduralHolsterTime") )
			self.ProceduralHolsterEnabled = true
			if sp then
				self:CallOnClient("EnableProceduralHolster")
			end
		end
		return false
	elseif stat == TFA.Enum.STATUS_HOLSTER_READY or stat == TFA.Enum.STATUS_HOLSTER_FINAL then
		return true
	end
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
			self:GetOwner():SelectWeapon(ent:GetClass())
			self.OwnerViewModel = nil
		end
	end
end

--[[
Function Name:  OnRemove
Syntax: self:OnRemove()
Notes:  Resets bone mods and cleans up.
Returns:  Nil.
Purpose:  Standard SWEP Function
]]
function SWEP:OnRemove()
end

--[[
Function Name:  OnDrop
Syntax: self:OnDrop()
Notes:  Resets bone mods and cleans up.
Returns:  Nil.
Purpose:  Standard SWEP Function
]]
function SWEP:OnDrop()
end

--[[
Function Name:  Think
Syntax: self:Think()
Returns:  Nothing.
Notes:  This is blank.
Purpose:  Standard SWEP Function
]]
function SWEP:Think()
end

--[[
Function Name:  Think2
Syntax: self:Think2().  Called from PlayerThink.
Returns:  Nothing.
Notes:  Essential for calling other important functions.  This is called from PlayerThink.  It's used because SWEP:Think() isn't always called.
Purpose:  Standard SWEP Function
]]
local finalstat

function SWEP:PlayerThink()
	ft = TFA.FrameTime()
	if not self:NullifyOIV() then return end
	self:Think2()
	if SERVER then
		self:CalculateRatios()
	end
end

function SWEP:PlayerThinkCL()
	ft = TFA.FrameTime()
	if not self:NullifyOIV() then return end
	self:CalculateRatios()
	self:Think2()
	self:CalculateViewModelOffset()
	self:CalculateViewModelFlip()

	if not self.Blowback_PistolMode or self:Clip1() == -1 or self:Clip1() > 0.1 or self.Blowback_PistolMode_Disabled[ self:GetLastActivity() ] then
		self.BlowbackCurrent = l_mathApproach(self.BlowbackCurrent, 0, self.BlowbackCurrent * ft * 15)
	end

	self.BlowbackCurrentRoot = l_mathApproach(self.BlowbackCurrentRoot, 0, self.BlowbackCurrentRoot * ft * 15)
end

local waittime, is, spr

function SWEP:Think2()
	if not self.hasAtt then self.hasAtt = true TFAApplyAttachmentOuter(self) end
	if self.LuaShellRequestTime > 0 and CurTime() > self.LuaShellRequestTime then
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

	if stat == TFA.Enum.STATUS_SHOOTING and (not self.Owner or not self.Owner:KeyDown(IN_ATTACK)) and ct > self:GetNextPrimaryFire() then
		stat = TFA.Enum.STATUS_IDLE
		self:SetStatus(stat)
		self:SetStatusEnd(ct)
		self:SetNextIdleAnim(-1)
		if self.ChooseIdleAnim then
			self:ChooseIdleAnim()
		end
	end

	if stat ~= TFA.Enum.STATUS_IDLE and ct > statend then
		finalstat = TFA.Enum.STATUS_IDLE

		if stat == TFA.Enum.STATUS_DRAW then
			self:SetNW2Bool("Drawn",true)
		elseif stat == TFA.Enum.STATUS_HOLSTER then--Holstering
			finalstat = TFA.Enum.STATUS_HOLSTER_READY
			self:SetStatusEnd(ct + 0.0)
		elseif stat == TFA.Enum.STATUS_HOLSTER_READY then
			self:FinishHolster()
			finalstat = TFA.Enum.STATUS_HOLSTER_FINAL
			self:SetStatusEnd(ct + 0.6)
		elseif stat == TFA.Enum.STATUS_RELOADING_SHOTGUN_START_SHELL then--Shotgun Reloading
			self:TakePrimaryAmmo(1,true)
			self:TakePrimaryAmmo(-1)
			if self:Ammo1() <= 0 or self:Clip1() >= self:GetPrimaryClipSize() or self:GetShotgunCancel() then
				finalstat = TFA.Enum.STATUS_RELOADING_SHOTGUN_END
				_,tanim = self:ChooseShotgunPumpAnim()
				self:SetStatusEnd(ct + self:GetActivityLength( tanim ))
				self:SetShotgunCancel( false )
			else
				waittime = self:GetActivityLength( self:GetLastActivity(), false ) - self:GetActivityLength( self:GetLastActivity(), true )
				if waittime > 0.01 then
					finalstat = TFA.GetStatus("reloading_wait")
					self:SetStatusEnd( ct + waittime )
				else
					finalstat = self:LoadShell()
				end
				--finalstat = self:LoadShell()
				--self:SetStatusEnd( self:GetNextPrimaryFire() )
			end
		elseif stat == TFA.Enum.STATUS_RELOADING_SHOTGUN_START then--Shotgun Reloading
			finalstat = self:LoadShell()
		elseif stat == TFA.Enum.STATUS_RELOADING_SHOTGUN_LOOP then
			self:TakePrimaryAmmo(1,true)
			self:TakePrimaryAmmo(-1)
			lact = self:GetLastActivity()
			if self:GetActivityLength(lact,true) < self:GetActivityLength(lact,false) - 0.01 then
				sht = self.ShellTime
				waittime = ( sht or self:GetActivityLength( lact , false ) ) -  self:GetActivityLength( lact , true )
			else
				waittime = 0
			end
			if waittime > 0.01 then
				finalstat = TFA.GetStatus("reloading_wait")
				self:SetStatusEnd( ct + waittime )
			else
				if self:Ammo1() <= 0 or self:Clip1() >= self:GetPrimaryClipSize() or self:GetShotgunCancel() then
					finalstat = TFA.Enum.STATUS_RELOADING_SHOTGUN_END
					_,tanim = self:ChooseShotgunPumpAnim()
					self:SetStatusEnd(ct + self:GetActivityLength( tanim ))
					self:SetShotgunCancel( false )
				else
					finalstat = self:LoadShell()
				end
			end
		elseif stat == TFA.Enum.STATUS_RELOADING then
			self:CompleteReload()
			waittime = self:GetActivityLength( self:GetLastActivity(), false ) - self:GetActivityLength( self:GetLastActivity(), true )
			if waittime > 0.01 then
				finalstat = TFA.GetStatus("reloading_wait")
				self:SetStatusEnd( ct + waittime )
			end
			--self:SetStatusEnd( self:GetNextPrimaryFire() )
		elseif stat == TFA.GetStatus("reloading_wait") and self.Shotgun then
			if self:Ammo1() <= 0 or self:Clip1() >= self:GetPrimaryClipSize() or self:GetShotgunCancel() then
				finalstat = TFA.Enum.STATUS_RELOADING_SHOTGUN_END
				_,tanim = self:ChooseShotgunPumpAnim()
				self:SetStatusEnd(ct + self:GetActivityLength( tanim ))
				--self:SetShotgunCancel( false )
			else
				finalstat = self:LoadShell()
			end
		elseif stat == TFA.Enum.STATUS_SILENCER_TOGGLE then
			self:SetSilenced( not self:GetSilenced() )
			self.Silenced = self:GetSilenced()
		elseif stat == TFA.GetStatus("reloading_shotgun_end") and self.Shotgun then
			self:SetShotgunCancel( false )
		elseif self.PumpAction and stat == TFA.GetStatus("pump") then
			self:SetShotgunCancel( false )
		elseif stat == TFA.GetStatus("shooting") and self.PumpAction then
			if self:Clip1() == 0 and self.PumpAction.value_empty then
				self:SetShotgunCancel( true )
			elseif ( self.Primary.ClipSize < 0 or self:Clip1() > 0 ) and self.PumpAction.value then
				self:SetShotgunCancel( true )
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
				self:SetNextPrimaryFire( CurTime() + self:GetBurstDelay() )
			end
		end
	end

	if self:GetShotgunCancel() and stat == TFA.Enum.STATUS_IDLE then
		if self.PumpAction then
			if CurTime() > self:GetNextPrimaryFire() and not self:GetOwner():KeyDown(IN_ATTACK) then
				self:DoPump()
			end
		else
			self:SetShotgunCancel( false )
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
		if not ironsights_cv:GetBool() then
			self.data.ironsights_default = self.data.ironsights_default or self.data.ironsights
			self.data.ironsights = 0
		elseif self.data.ironsights_default == 1 and self.data.ironsights == 0 then
			self.data.ironsights = 1
			self.data.ironsights_default = 0
		end
	end
	ct = l_CT()
	stat = self:GetStatus()
	local owent = self.Owner
	issighting = false
	issprinting = false
	self.is_old = self:GetIronSightsRaw()
	self.spr_old = self:GetSprinting()
	if sprint_cv:GetBool() and not self.IsKnife and not self.IsMelee then
		issprinting = self.Owner:GetVelocity():Length2D() > self.Owner:GetRunSpeed() * 0.6 and self.Owner:KeyDown(IN_SPEED)
	end
	vm = self.OwnerViewModel

	if not (self.data and self.data.ironsights == 0) then
		if CLIENT then
			if not ironsights_toggle_cvar:GetBool() then
				if owent:KeyDown(IN_ATTACK2) then
					issighting = true
				end
			else
				issighting = self:GetIronSightsRaw()

				if owent:KeyPressed(IN_ATTACK2) then
					issighting = not issighting
					self:SetIronSightsRaw(issighting)
				end
			end
		else
			if owent:GetInfoNum("cl_tfa_ironsights_toggle", 0) == 0 then
				if owent:KeyDown(IN_ATTACK2) then
					issighting = true
				end
			else
				issighting = self:GetIronSightsRaw()

				if owent:KeyPressed(IN_ATTACK2) then
					issighting = not issighting
					self:SetIronSightsRaw(issighting)
				end
			end
		end
	end

	if ( ( CLIENT and ironsights_toggle_cvar:GetBool() ) or ( SERVER and owent:GetInfoNum("cl_tfa_ironsights_toggle", 0) == 1 ) ) and not ( ( CLIENT and ironsights_resight_cvar:GetBool() ) or ( SERVER and owent:GetInfoNum("cl_tfa_ironsights_resight", 0) == 1 ) ) then
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

	if issighting or issprinting or stat ~= TFA.Enum.STATUS_IDLE then self.Inspecting = false end

	if (self.is_old ~= issighting) then
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
		--issprinting = true
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

	if (self.is_old_final ~= issighting) then

		if (issighting == false) and ((CLIENT and IsFirstTimePredicted()) or (SERVER and sp)) then
			self:EmitSound(self.IronOutSound or "TFA.IronOut")
		elseif issighting == true and ((CLIENT and IsFirstTimePredicted()) or (SERVER and sp)) then
			self:EmitSound(self.IronInSound or "TFA.IronIn")
		end

		if self.Sights_Mode == TFA.Enum.LOCOMOTION_LUA then--and stat == TFA.Enum.STATUS_IDLE then
			self:SetNextIdleAnim(-1)
		end
	end

	local smi = ( self.Sights_Mode == TFA.Enum.LOCOMOTION_ANI ) and self.is_old_final ~= issighting
	local spi = ( self.Sprint_Mode == TFA.Enum.LOCOMOTION_HYBRID or self.Sprint_Mode == TFA.Enum.LOCOMOTION_ANI ) and self.spr_old ~= issprinting

	if ( smi or spi ) and ( self:GetStatus() == TFA.Enum.STATUS_IDLE or ( self:GetStatus() == TFA.Enum.STATUS_SHOOTING and not self.BoltAction ) ) and not self:GetShotgunCancel() then
		--self:SetNextIdleAnim(-1)
		local toggle_is = self.is_old ~= issighting
		if issighting and self.spr_old ~= issprinting then
			toggle_is = true
		end
		success = self:Locomote(toggle_is and (self.Sights_Mode == TFA.Enum.LOCOMOTION_ANI or self.Sights_Mode == TFA.Enum.LOCOMOTION_HYBRID ), issighting, (self.spr_old ~= issprinting) and (self.Sprint_Mode == TFA.Enum.LOCOMOTION_ANI or self.Sprint_Mode == TFA.Enum.LOCOMOTION_HYBRID ), issprinting)
		if ( not success ) and ( ( toggle_is and smi ) or ( (self.spr_old ~= issprinting) and spi ) ) then
			self:SetNextIdleAnim(-1)
		end
	end

	if (self.spr_old ~= issprinting) then
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
			self:SetShotgunCancel( true )
		end
		return false
	end

	if self:GetShotgunCancel() and TFA.Enum.ReadyStatus[stat] then return end

	if self:IsSafety() then
		self:EmitSound("Weapon_AR2.Empty2")
		self.LastSafetyShoot = self.LastSafetyShoot or 0

		if l_CT() < self.LastSafetyShoot + 0.2 then
			self:CycleSafety()
			self:SetNextPrimaryFire(l_CT() + 0.1)
		end

		self.LastSafetyShoot = l_CT()

		return
	end

	if self.Primary.ClipSize <= 0 and self:Ammo1() < self.Primary.AmmoConsumption then
		return false
	end
	if self:GetPrimaryClipSize(true) > 0 and self:Clip1() < self.Primary.AmmoConsumption then
		self:ChooseDryFireAnim()
		if not self.HasPlayedEmptyClick then
			self:EmitSound("Weapon_Pistol.Empty2")

			if not dryfire_cvar:GetBool() then
				self:Reload( true )
			end

			self.HasPlayedEmptyClick = true
		end
		return false
	end
	if self:GetSprinting() and not ( self.AllowSprintAttack or self.IsKnife or self.IsMelee ) then
		return false
	end
	if self.FiresUnderwater == false and self.Owner:WaterLevel() >= 3 then
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
	if self.CanBeSilenced and self.Owner:KeyDown(IN_USE) and ( SERVER or not sp ) then
		self:ChooseSilenceAnim( not self:GetSilenced() )
		success, tanim = self:SetStatus(TFA.Enum.STATUS_SILENCER_TOGGLE)
		self:SetStatusEnd( l_CT() + (self.SequenceLengthOverride[ tanim ] or self:GetActivityLength(tanim,true)) )
		return
	end
	self:SetNextPrimaryFire( CurTime() + self:GetFireDelay() )
	if self:GetMaxBurst() > 1 then
		self:SetBurstCount( math.max(1,self:GetBurstCount() + 1) )
	end
	self:SetStatus(TFA.Enum.STATUS_SHOOTING)
	self:SetStatusEnd(self:GetNextPrimaryFire())
	self:ToggleAkimbo()
	self:ChooseShootAnim()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	if self.Primary.Sound and IsFirstTimePredicted()  and not ( sp and CLIENT ) then
		if self.Primary.SilencedSound and self:GetSilenced() then
			self:EmitSound(self.Primary.SilencedSound)
		else
			self:EmitSound(self.Primary.Sound)
		end
	end
	self:TakePrimaryAmmo( self.Primary.AmmoConsumption )
	self:ShootBulletInformation()
	local _, CurrentRecoil = self:CalculateConeRecoil()
	self:Recoil(CurrentRecoil,IsFirstTimePredicted())
	if sp and SERVER then
		self:CallOnClient("Recoil","")
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
	if self.Primary.ClipSize < 0 then return end
	if ( not released ) and ( not legacy_reloads_cv:GetBool() ) then return end
	if legacy_reloads_cv:GetBool() and not  dryfire_cvar:GetBool() and not self.Owner:KeyDown(IN_RELOAD) then return end
	if self.Owner:KeyDown(IN_USE) then return end

	ct = l_CT()

	if self:GetStatus() == TFA.Enum.STATUS_IDLE then
		if self:Clip1() < self:GetPrimaryClipSize() then
			if self.Shotgun then
				_, tanim = self:ChooseShotgunReloadAnim()
				if self.ShotgunEmptyAnim  then
					if tanim == ACT_VM_RELOAD_EMPTY and self.ShotgunEmptyAnim_Shell then
						self:SetStatus(TFA.Enum.STATUS_RELOADING_SHOTGUN_START_SHELL)
					else
						self:SetStatus(TFA.Enum.STATUS_RELOADING_SHOTGUN_START)
					end
				else
					self:SetStatus(TFA.Enum.STATUS_RELOADING_SHOTGUN_START)
				end
				self:SetStatusEnd(ct + self:GetActivityLength( tanim, true ))
			else
				success, tanim = self:ChooseReloadAnim()
				self:SetStatus(TFA.Enum.STATUS_RELOADING)
				if self.ProceduralReloadEnabled then
					self:SetStatusEnd(ct + self.ProceduralReloadTime)
				else
					self:SetStatusEnd(ct + self:GetActivityLength(tanim,true))
				end
			end
			self.Owner:SetAnimation(PLAYER_RELOAD)
			if self.Primary.ReloadSound and IsFirstTimePredicted() then
				self:EmitSound(self.Primary.ReloadSound)
			end
		else
			self:CheckAmmo()
		end
	end
end

function SWEP:LoadShell()
	_, tanim = self:ChooseReloadAnim()
	if self:GetActivityLength(tanim,true) < self:GetActivityLength(tanim,false) then
		self:SetStatusEnd(ct + self:GetActivityLength( tanim, true ) )
	else
		sht = self.ShellTime
		self:SetStatusEnd(ct + ( sht or self:GetActivityLength( tanim, true ) ) )
	end
	return TFA.Enum.STATUS_RELOADING_SHOTGUN_LOOP
end

function SWEP:CompleteReload()
	local maxclip = self:GetPrimaryClipSize( true )
	local curclip = self:Clip1()
	local amounttoreplace = math.min(maxclip - curclip, self:Ammo1())
	self:TakePrimaryAmmo(amounttoreplace * -1)
	self:TakePrimaryAmmo(amounttoreplace, true)
end

function SWEP:CheckAmmo()
	if self:GetIronSights() or self:GetSprinting() then return end
	if (self.SequenceEnabled[ACT_VM_FIDGET] or self.InspectionActions) and self:GetStatus() == TFA.Enum.STATUS_IDLE then--and CurTime() > self.NextInspectAnim thenE then
		_,tanim = self:ChooseInspectAnim()
		self:SetStatus(TFA.Enum.STATUS_FIDGET)
		self:SetStatusEnd( l_CT() + self:GetActivityLength(tanim,true) )
	end
end

local cv_strip = GetConVar("sv_tfa_weapon_strip")
function SWEP:DoAmmoCheck()
	if IsValid(self) and SERVER and cv_strip:GetBool() and self:Clip1() == 0 and self:Ammo1() == 0 then
		timer.Simple(.1, function()
			if SERVER and IsValid(self) and self:OwnerIsValid() then
				self.Owner:StripWeapon(self.ClassName)
			end
		end)
	end
end

--[[
Function Name:  AdjustMouseSensitivity
Syntax: Should not normally be called.
Returns:  SWEP sensitivity multiplier.
Purpose:  Standard SWEP Function
]]

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
		sensval = sensval * sensitivity_cvar:GetFloat() / 100

		if sensitivity_fov_cvar:GetFloat() then
			if self.Scoped_3D then
				fovv = self.RTScopeFOV * 4
			else
				fovv = self.Owner:GetFOV()
			end
			fovv = fovv / ( self.Scoped_3D and self.Secondary.ScopeZoom or 1 )
			sensval = sensval * math.atan(resrat * math.tan(math.rad(fovv / 2))) / math.atan(resrat * math.tan(math.rad(self.DefaultFOV / 2)))
		else
			sensval = sensval
		end

		if sensitivity_speed_cvar:GetFloat() then
			sensval = sensval * self.IronSightsMoveSpeed
		end
	end

	sensval = sensval * l_Lerp(self.IronSightsProgress, 1, self.IronSightsSensitivity)

	return sensval
end

--[[
Function Name:  TranslateFOV
Syntax: Should not normally be called.  Takes default FOV as parameter.
Returns:  New FOV.
Purpose:  Standard SWEP Function
]]

local nfov
function SWEP:TranslateFOV(fov)
	self:CorrectScopeFOV()
	nfov = l_Lerp(self.IronSightsProgress, fov, fov * math.min(self.Secondary.IronFOV / 90,1))

	return l_Lerp(self.SprintProgress, nfov, nfov + self.SprintFOVOffset)
end

function SWEP:GetPrimaryAmmoType()
	return self.Primary.Ammo or ""
end

local target_pos,target_ang,adstransitionspeed, hls
local flip_vec = Vector(-1,1,1)
local flip_ang = Vector(1,-1,-1)
local cl_tfa_viewmodel_offset_x
local cl_tfa_viewmodel_offset_y,cl_tfa_viewmodel_offset_z, cl_tfa_viewmodel_centered, fovmod_add, fovmod_mult
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

local centered_sprintpos = Vector(0,-1,1)
local centered_sprintang = Vector(-15,0,0)

function SWEP:CalculateViewModelOffset( )

	if self.VMPos_Additive then
		target_pos:Zero()
		target_ang:Zero()
	else
		target_pos = self.VMPos * 1
		target_ang = self.VMAng * 1
	end

	adstransitionspeed = 10

	is = self:GetIronSights()
	spr = self:GetSprinting()
	stat = self:GetStatus()
	hls = ( ( TFA.Enum.HolsterStatus[ stat ] and self.ProceduralHolsterEnabled ) or ( TFA.Enum.ReloadStatus[ stat ] and self.ProceduralReloadEnabled ) )
	if hls then
		target_pos = self.ProceduralHolsterPos * 1
		target_ang = self.ProceduralHolsterAng * 1
		if self.ViewModelFlip then
			target_pos = target_pos * flip_vec
			target_ang = target_ang * flip_ang
		end
		adstransitionspeed = self.ProceduralHolsterTime * 15
	elseif is and ( self.Sights_Mode == TFA.Enum.LOCOMOTION_LUA or self.Sights_Mode == TFA.Enum.LOCOMOTION_HYBRID ) then
		target_pos = ( self.IronSightsPos or self.SightsPos ) * 1
		target_ang = ( self.IronSightsAng or self.SightsAng ) * 1
		adstransitionspeed = 15
	elseif ( spr or self:IsSafety() ) and ( self.Sprint_Mode == TFA.Enum.LOCOMOTION_LUA or self.Sprint_Mode == TFA.Enum.LOCOMOTION_HYBRID or ( self:IsSafety() and not spr ) ) and stat ~= TFA.Enum.STATUS_FIDGET and stat ~= TFA.Enum.STATUS_BASHING then
		if cl_tfa_viewmodel_centered and cl_tfa_viewmodel_centered:GetBool() then
			self.RunSightsPos = centered_sprintpos
			self.RunSightsAng = centered_sprintang
		end
		target_pos = self.RunSightsPos * 1
		target_ang = self.RunSightsAng * 1
		adstransitionspeed = 7.5
	end
	if cl_tfa_viewmodel_offset_x and not is then
		if cl_tfa_viewmodel_centered:GetBool() and self.IronSightsPos then
			target_pos.x = target_pos.x + self.IronSightsPos.x
			target_ang.y = target_ang.y + self.IronSightsAng.y
			target_pos.z = target_pos.z - 3
		end
		target_pos.x = target_pos.x + cl_tfa_viewmodel_offset_x:GetFloat()
		target_pos.y = target_pos.y + cl_tfa_viewmodel_offset_y:GetFloat()
		target_pos.z = target_pos.z + cl_tfa_viewmodel_offset_z:GetFloat()
	end

	if self.Inspecting then
		if not self.InspectPos then
			self.InspectPos = self.InspectPosDef * 1

			if self.ViewModelFlip then
				self.InspectPos.x = self.InspectPos.x * -1
			end
		end

		if not self.InspectAng then
			self.InspectAng = self.InspectAngDef * 1

			if self.ViewModelFlip then
				self.InspectAng.x = self.InspectAngDef.x * 1
				self.InspectAng.y = self.InspectAngDef.y * -1
				self.InspectAng.z = self.InspectAngDef.z * -1
			end
		end

		target_pos = self.InspectPos * 1
		target_ang = self.InspectAng * 1
		adstransitionspeed = 10
	end

	vm_offset_pos.x = math.Approach(vm_offset_pos.x,target_pos.x, (target_pos.x - vm_offset_pos.x) * ft * adstransitionspeed )
	vm_offset_pos.y = math.Approach(vm_offset_pos.y,target_pos.y, (target_pos.y - vm_offset_pos.y) * ft * adstransitionspeed )
	vm_offset_pos.z = math.Approach(vm_offset_pos.z,target_pos.z, (target_pos.z- vm_offset_pos.z) * ft * adstransitionspeed )

	vm_offset_ang.p = math.ApproachAngle(vm_offset_ang.p,target_ang.x, math.AngleDifference( target_ang.x, vm_offset_ang.p ) * ft * adstransitionspeed )
	vm_offset_ang.y = math.ApproachAngle(vm_offset_ang.y,target_ang.y, math.AngleDifference( target_ang.y, vm_offset_ang.y ) * ft * adstransitionspeed )
	vm_offset_ang.r = math.ApproachAngle(vm_offset_ang.r,target_ang.z, math.AngleDifference( target_ang.z, vm_offset_ang.r ) * ft * adstransitionspeed )

	self:DoBobFrame()

end


--[[
Function Name:  Sway
Syntax: self:Sway( ang ).
Returns:  New angle.
Notes:  This is used for calculating the swep viewmodel sway.
Purpose:  Main SWEP function
]]--

local oldang = Angle()
local anga = Angle()
local angb = Angle()
local angc = Angle()
local posfac = 0.75
local gunswaycvar = GetConVar("cl_tfa_gunbob_intensity")

function SWEP:Sway(pos, ang)
	if not self:OwnerIsValid() then return pos, ang end
	rft = (SysTime() - (self.LastSysT or SysTime())) * game.GetTimeScale()

	if rft > l_FT() then
		rft = l_FT()
	end

	rft = l_mathClamp(rft, 0, 1 / 30)

	if sv_cheats_cv:GetBool() and host_timescale_cv:GetFloat() < 1 then
		rft = rft * host_timescale_cv:GetFloat()
	end

	self.LastSysT = SysTime()
	ang:Normalize()
	--angrange = our availalbe ranges
	--rate = rate to restore our angle to the proper one
	--fac = factor to multiply by
	--each is interpolated from normal value to the ironsights value using iron sights ratio
	local angrange = l_Lerp(self.IronSightsProgress, 7.5, 2.5) * gunswaycvar:GetFloat()
	local rate = l_Lerp(self.IronSightsProgress, 15, 30)
	local fac = l_Lerp(self.IronSightsProgress, 0.6, 0.15)
	--calculate angle differences
	anga = self.Owner:EyeAngles() - oldang
	oldang = self.Owner:EyeAngles()
	angb.y = angb.y + (0 - angb.y) * rft * 5
	angb.p = angb.p + (0 - angb.p) * rft * 5

	--fix jitter
	if angb.y < 50 and anga.y > 0 and anga.y < 25 then
		angb.y = angb.y + anga.y / 5
	end

	if angb.y > -50 and anga.y < 0 and anga.y > -25 then
		angb.y = angb.y + anga.y / 5
	end

	if angb.p < 50 and anga.p < 0 and anga.p < 25 then
		angb.p = angb.p - anga.p / 5
	end

	if angb.p > -50 and anga.p > 0 and anga.p > -25 then
		angb.p = angb.p - anga.p / 5
	end

	--limit range
	angb.p = l_mathClamp(angb.p, -angrange, angrange)
	angb.y = l_mathClamp(angb.y, -angrange, angrange)
	--recover
	angc.y = angc.y + (angb.y / 15 - angc.y) * rft * rate
	angc.p = angc.p + (angb.p / 15 - angc.p) * rft * rate
	--finally, blend it into the angle
	ang:RotateAroundAxis(oldang:Up(), angc.y * 15 * (self.ViewModelFlip and -1 or 1) * fac)
	ang:RotateAroundAxis(oldang:Right(), angc.p * 15 * fac)
	ang:RotateAroundAxis(oldang:Forward(), angc.y * 10 * fac)
	pos:Add(oldang:Right() * angc.y * posfac)
	pos:Add(oldang:Up() * -angc.p * posfac)

	return pos, util_NormalizeAngles(ang)
end

local gunbob_intensity_cvar = GetConVar("cl_tfa_gunbob_intensity")
local vmfov

function SWEP:GetViewModelPosition( pos, ang )
	if not IsValid(self.Owner) then return end
	--Bobscale
	self.BobScaleCustom = l_Lerp(self.IronSightsProgress, 1, l_Lerp( math.min( self.Owner:GetVelocity():Length() / self.Owner:GetWalkSpeed(), 1 ), self.IronBobMult, self.IronBobMultWalk))
	self.BobScaleCustom = l_Lerp(self.SprintProgress, self.BobScaleCustom, self.SprintBobMult)
	--Start viewbob code
	local gunbobintensity = gunbob_intensity_cvar:GetFloat() * 0.65 * 0.66
	if self.Idle_Mode == TFA.Enum.IDLE_LUA or self.Idle_Mode == TFA.Enum.IDLE_BOTH then
		pos, ang = self:CalculateBob(pos, ang, gunbobintensity)
	end
	--local qerp1 = l_Lerp( self.IronSightsProgress, 0, self.ViewModelFlip and 1 or -1) * 10
	if not ang then return end
	--ang:RotateAroundAxis(ang:Forward(), -Qerp(self.IronSightsProgress and self.IronSightsProgress or 0, qerp1, 0))
	--End viewbob code

	if not self.ogviewmodelfov then
		self.ogviewmodelfov = self.ViewModelFOV
	end

	vmfov = self.ogviewmodelfov * fovmod_mult:GetFloat()
	vmfov = vmfov + fovmod_add:GetFloat()
	self.ViewModelFOV = vmfov

	pos, ang = self:Sway(pos, ang)
	ang:RotateAroundAxis(ang:Right(), vm_offset_ang.p)
	ang:RotateAroundAxis(ang:Up(), vm_offset_ang.y)
	ang:RotateAroundAxis(ang:Forward(), vm_offset_ang.r)
	self.IronSightsProgress = self.IronSightsProgress * 1
	--print(self.IronSightsProgress)
	ang:RotateAroundAxis(ang:Forward(), -7.5 * ( 1 - math.abs( 0.5 - self.IronSightsProgress  ) * 2 ) * ( self:GetIronSights() and 1 or 0.5 ) * ( self.ViewModelFlip and 1 or -1 ) )

	pos:Add(ang:Right() * vm_offset_pos.x)
	pos:Add(ang:Forward() * vm_offset_pos.y)
	pos:Add(ang:Up() * vm_offset_pos.z)

	if self.BlowbackEnabled and self.BlowbackCurrentRoot > 0.01 then
		--if !(  self.Blowback_PistolMode and !( self:Clip1()==-1 or self:Clip1()>0 ) ) then
		pos:Add(ang:Right() * self.BlowbackVector.x * self.BlowbackCurrentRoot)
		pos:Add(ang:Forward() * self.BlowbackVector.y * self.BlowbackCurrentRoot)
		pos:Add(ang:Up() * self.BlowbackVector.z * self.BlowbackCurrentRoot)
		--end
	end

	if self:GetHidden() then
		pos.z = -10000
	end

	if self.VMPos_Additive then
		pos:Add(ang:Right() * self.VMPos.x)
		pos:Add(ang:Forward() * self.VMPos.y)
		pos:Add(ang:Up() * self.VMPos.z)
		ang:RotateAroundAxis(ang:Right(), self.VMAng.x)
		ang:RotateAroundAxis(ang:Up(), self.VMAng.y)
		ang:RotateAroundAxis(ang:Forward(), self.VMAng.z)
	end

	return pos, ang
end

function SWEP:DoPump()
	if self.Owner:IsNPC() then
		return
	end
	_,tanim = self:PlayAnimation( self.PumpAction )
	self:SetStatus( TFA.GetStatus("pump") )
	self:SetStatusEnd( CurTime() + self:GetActivityLength( tanim, true ) )
	self:SetNextPrimaryFire( CurTime() + self:GetActivityLength( tanim, false ) )
	self:SetNextIdleAnim(math.max( self:GetNextIdleAnim(), CurTime() + self:GetActivityLength( tanim, false ) ))
end

function SWEP:ToggleInspect()
	if self:GetSprinting() or self:GetIronSights() or self:GetStatus() ~= TFA.Enum.STATUS_IDLE then return end
	self.Inspecting = not self.Inspecting
end
