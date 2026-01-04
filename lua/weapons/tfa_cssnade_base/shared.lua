if SERVER then AddCSLuaFile() end

SWEP.Base = "tfa_nade_base"
DEFINE_BASECLASS("tfa_nade_base")

SWEP.Category = "TFA CS:S"
SWEP.PrintName = "CS:S Grenade"
SWEP.Type = "Grenade"

SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.MuzzleFlashEffect = ""
SWEP.DisableIdleAnimations = false

SWEP.Primary = SWEP.Primary or {}

function SWEP:Initialize()
    self.ProjectileEntity = self.Primary.Round
    self.ProjectileVelocity = self.Velocity or 550
    self.ProjectileModel = nil

    BaseClass.Initialize(self)
end

function SWEP:Deploy()
    if self.SetNW2Bool then
        self:SetNW2Bool("Ready", false)
        self:SetNW2Bool("Underhanded", false)
    end

    if self.CleanParticles then
        self:CleanParticles()
    end

    return BaseClass.Deploy(self)
end
