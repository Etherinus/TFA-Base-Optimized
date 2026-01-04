if SERVER then AddCSLuaFile() end

SWEP.Gun = "tfa_base_template"
SWEP.Base = "tfa_gun_base"
SWEP.Category = "TFA Template"
SWEP.Manufacturer = nil
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.DrawCrosshair = true
SWEP.DrawCrosshairIS = false
SWEP.PrintName = "TFA Base Template"
SWEP.Slot = 2
SWEP.SlotPos = 73
SWEP.DrawAmmo = true
SWEP.DrawWeaponInfoBox = false
SWEP.BounceWeaponIcon = false
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true
SWEP.Weight = 30

SWEP.Primary = SWEP.Primary or {}
SWEP.Secondary = SWEP.Secondary or {}

SWEP.Primary.Sound = Sound("")
SWEP.Primary.SilencedSound = nil
SWEP.Primary.PenetrationMultiplier = 1
SWEP.Primary.Damage = 0.01
SWEP.Primary.Force = nil
SWEP.Primary.HullSize = 0
SWEP.Primary.DamageType = nil
SWEP.Primary.NumShots = 1
SWEP.Primary.Automatic = true
SWEP.Primary.RPM = 600
SWEP.Primary.RPM_Semi = nil
SWEP.Primary.RPM_Burst = nil
SWEP.Primary.BurstDelay = nil

SWEP.FiresUnderwater = false
SWEP.IronInSound = nil
SWEP.IronOutSound = nil
SWEP.CanBeSilenced = false
SWEP.Silenced = false

SWEP.SelectiveFire = false
SWEP.DisableBurstFire = false
SWEP.OnlyBurstFire = false
SWEP.DefaultFireMode = ""
SWEP.FireModeName = nil

SWEP.Primary.ClipSize = 0
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Ammo = "none"
SWEP.Primary.AmmoConsumption = 1

SWEP.DisableChambering = false

SWEP.Primary.KickUp = 0
SWEP.Primary.KickDown = 0
SWEP.Primary.KickHorizontal = 0
SWEP.Primary.StaticRecoilFactor = 0.5

SWEP.Primary.Spread = 0.01
SWEP.Primary.IronAccuracy = 0.005

SWEP.Primary.Range = -1
SWEP.Primary.RangeFalloff = -1

SWEP.MaxPenetrationCounter = 4

SWEP.IronRecoilMultiplier = 0.5
SWEP.CrouchRecoilMultiplier = 0.65
SWEP.JumpRecoilMultiplier = 1.3
SWEP.WallRecoilMultiplier = 1.1
SWEP.ChangeStateRecoilMultiplier = 1.3
SWEP.CrouchAccuracyMultiplier = 0.5
SWEP.ChangeStateAccuracyMultiplier = 1.5
SWEP.JumpAccuracyMultiplier = 2
SWEP.WalkAccuracyMultiplier = 1.35
SWEP.IronSightTime = 0.3
SWEP.NearWallTime = 0.25
SWEP.ToCrouchTime = 0.05
SWEP.WeaponLength = 40
SWEP.MoveSpeed = 1
SWEP.IronSightsMoveSpeed = 0.8
SWEP.SprintFOVOffset = 3.75

SWEP.ProjectileEntity = nil
SWEP.ProjectileVelocity = 0
SWEP.ProjectileModel = nil

SWEP.ViewModel = "models/your/path/here.mdl"
SWEP.ViewModelFOV = 65
SWEP.ViewModelFlip = false
SWEP.MaterialTable = nil
SWEP.UseHands = false
SWEP.VMPos = Vector(0, 0, 0)
SWEP.VMAng = Vector(0, 0, 0)
SWEP.VMBodyGroups = nil

SWEP.WorldModel = "models/your/wmodel/path/here.mdl"
SWEP.WMBodyGroups = nil
SWEP.HoldType = ""

SWEP.Offset = {
    Pos = { Up = 0, Right = 0, Forward = 0 },
    Ang = { Up = -1, Right = -2, Forward = 178 },
    Scale = 1
}

SWEP.ThirdPersonReloadDisable = false

SWEP.IronSightsSensitivity = 1
SWEP.BoltAction = false
SWEP.Scoped = false
SWEP.ScopeOverlayThreshold = 0.875
SWEP.BoltTimerOffset = 0.25
SWEP.ScopeScale = 0.5
SWEP.ReticleScale = 0.7

SWEP.Secondary.UseACOG = false
SWEP.Secondary.UseMilDot = false
SWEP.Secondary.UseSVD = false
SWEP.Secondary.UseParabolic = false
SWEP.Secondary.UseElcan = false
SWEP.Secondary.UseGreenDuplex = false

if surface then
    SWEP.Secondary.ScopeTable = nil
end

SWEP.Shotgun = false
SWEP.ShellTime = 0.35

SWEP.RunSightsPos = Vector(0, 0, 0)
SWEP.RunSightsAng = Vector(0, 0, 0)

SWEP.data = SWEP.data or {}
SWEP.data.ironsights = 1
SWEP.Secondary.IronFOV = 0
SWEP.IronSightsPos = Vector(0, 0, 0)
SWEP.IronSightsAng = Vector(0, 0, 0)

SWEP.ShootWhileDraw = false
SWEP.AllowReloadWhileDraw = false
SWEP.SightWhileDraw = false
SWEP.AllowReloadWhileHolster = true
SWEP.ShootWhileHolster = true
SWEP.SightWhileHolster = false
SWEP.UnSightOnReload = true
SWEP.AllowReloadWhileSprinting = false
SWEP.AllowReloadWhileNearWall = false
SWEP.SprintBobMult = 1.5
SWEP.IronBobMult = 0
SWEP.IronBobMultWalk = 0.2
SWEP.AllowViewAttachment = true

SWEP.BlowbackEnabled = false
SWEP.BlowbackVector = Vector(0, -1, 0)
SWEP.BlowbackCurrentRoot = 0
SWEP.BlowbackCurrent = 0
SWEP.BlowbackBoneMods = nil
SWEP.Blowback_Only_Iron = true
SWEP.Blowback_PistolMode = false
SWEP.Blowback_Shell_Enabled = true
SWEP.Blowback_Shell_Effect = "ShellEject"

SWEP.DoProceduralReload = false
SWEP.ProceduralReloadTime = 1

SWEP.IronSightHoldTypeOverride = ""
SWEP.SprintHoldTypeOverride = ""

SWEP.ForceDryFireOff = true
SWEP.DisableIdleAnimations = true
SWEP.ForceEmptyFireOff = true

SWEP.SequenceEnabled = {}
SWEP.SequenceLength = {}
SWEP.SequenceLengthOverride = {}

SWEP.SmokeParticles = {}
SWEP.ShellAttachment = "2"
SWEP.MuzzleAttachment = "1"
SWEP.MuzzleAttachmentRaw = nil
SWEP.DoMuzzleFlash = true
SWEP.CustomMuzzleFlash = true
SWEP.AutoDetectMuzzleAttachment = false
SWEP.MuzzleFlashEffect = nil

SWEP.LuaShellEject = false
SWEP.LuaShellEjectDelay = 0
SWEP.LuaShellEffect = nil

SWEP.Tracer = 0
SWEP.TracerName = nil
SWEP.TracerCount = 3
SWEP.TracerLua = false
SWEP.TracerDelay = 0.01

SWEP.ImpactEffect = nil
SWEP.ImpactDecal = nil

SWEP.EventTable = {}

SWEP.RTMaterialOverride = nil
SWEP.RTOpaque = false
SWEP.RTCode = function(self)
end

SWEP.Akimbo = false
SWEP.AnimCycle = 0
