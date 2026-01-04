local IsValid = IsValid
local CurTime = CurTime
local timer_Simple = timer.Simple
local math_Clamp = math.Clamp
local math_floor = math.floor
local surface = surface
local render = render
local util = util
local net = net
local ParticleEffectAttach = ParticleEffectAttach
local PATTACH_POINT_FOLLOW = PATTACH_POINT_FOLLOW
local DamageInfo = DamageInfo
local EffectData = EffectData
local math_sqrt = math.sqrt

function SWEP:FireAnimationEvent(pos, ang, event, options)
    if self.CustomMuzzleFlash or not self.MuzzleFlashEnabled then
        if event == 21 then
            return true
        end

        if event == 5003 then
            return true
        end

        if event == 5001 or event == 5011 or event == 5021 or event == 5031 then
            if self.AutoDetectMuzzleAttachment then
                self.MuzzleAttachmentRaw = math_Clamp(math_floor((event - 4991) / 10), 1, 4)

                if net and net.Start then
                    net.Start("tfa_base_muzzle_mp")
                    net.SendToServer()
                end

                timer_Simple(0, function()
                    if IsValid(self) then
                        self:ShootEffectsCustom(true)
                    end
                end)
            end

            return true
        end
    end

    if self.LuaShellEject and event ~= 5004 then
        return true
    end
end

function SWEP:MakeMuzzleSmoke(entity, attachment)
    self:CleanParticles()

    local ht = self.DefaultHoldType or self.HoldType
    if not (CLIENT and TFA and TFA.GetMZSmokeEnabled and TFA.GetMZSmokeEnabled()) then
        return
    end

    if not (IsValid(entity) and attachment and attachment ~= 0) then
        return
    end

    local pfx = self.SmokeParticles and self.SmokeParticles[ht]
    if not pfx or pfx == "" then
        return
    end

    ParticleEffectAttach(pfx, PATTACH_POINT_FOLLOW, entity, attachment)
end

function SWEP:DoImpactEffect(tr, dmgtype)
    if tr.HitSky then
        return true
    end

    local ib = self.BashBase and self.GetBashing and self:GetBashing()
    local dmginfo = DamageInfo()
    dmginfo:SetDamageType(dmgtype)

    local isSlash = dmginfo:IsDamageType(DMG_SLASH)
    local bashSlash = ib and self.Secondary and self.Secondary.BashDamageType == DMG_SLASH and tr.MatType ~= MAT_FLESH and tr.MatType ~= MAT_ALIENFLESH
    local wepSlash = self.DamageType == DMG_SLASH

    if isSlash or bashSlash or wepSlash then
        util.Decal("ManhackCut", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
        return true
    end

    if ib and self.Secondary and self.Secondary.BashDamageType == DMG_GENERIC then
        return true
    end

    if ib then
        return
    end

    if IsValid(self) then
        self:ImpactEffectFunc(tr.HitPos, tr.HitNormal, tr.MatType)
    end

    if self.ImpactDecal and self.ImpactDecal ~= "" then
        util.Decal(self.ImpactDecal, tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
        return true
    end
end

local impact_cl_enabled = GetConVar("cl_tfa_fx_impact_enabled")
local impact_sv_enabled = GetConVar("sv_tfa_fx_impact_override")

function SWEP:ImpactEffectFunc(pos, normal, mattype)
    local enabled = true

    if impact_cl_enabled then
        enabled = impact_cl_enabled:GetBool()
    end

    if impact_sv_enabled and impact_sv_enabled:GetInt() >= 0 then
        enabled = impact_sv_enabled:GetBool()
    end

    if not enabled then
        return
    end

    local fx = EffectData()
    fx:SetOrigin(pos)
    fx:SetNormal(normal)

    if self.CanDustEffect and self:CanDustEffect(mattype) then
        util.Effect("tfa_dust_impact", fx)
    end

    if self.CanSparkEffect and self:CanSparkEffect(mattype) then
        util.Effect("tfa_metal_impact", fx)
    end

    local owner = self.GetOwner and self:GetOwner() or self.Owner
    if IsValid(owner) then
        fx:SetEntity(owner)
    end

    fx:SetMagnitude(mattype or 0)

    local dmg = (self.Primary and self.Primary.Damage) or 30
    if dmg <= 0 then
        dmg = 30
    end

    fx:SetScale(math_sqrt(dmg / 30))
    util.Effect("tfa_bullet_impact", fx)

    if self.ImpactEffect then
        util.Effect(self.ImpactEffect, fx)
    end
end
