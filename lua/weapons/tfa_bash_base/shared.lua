if SERVER then AddCSLuaFile() end

SWEP.Base = "tfa_gun_base"
DEFINE_BASECLASS(SWEP.Base)

local IsValid = IsValid
local CurTime = CurTime
local timer_Simple = timer.Simple
local DamageInfo = DamageInfo
local Vector = Vector

local math_sqrt = math.sqrt
local math_random = math.random

local util_TraceHull = util.TraceHull
local game_SinglePlayer = game.SinglePlayer
local game_GetTimeScale = game.GetTimeScale

SWEP.Secondary = SWEP.Secondary or {}
SWEP.Secondary.BashDamage = 25
SWEP.Secondary.BashSound = Sound("TFA.Bash")
SWEP.Secondary.BashHitSound = Sound("TFA.BashWall")
SWEP.Secondary.BashHitSound_Flesh = Sound("TFA.BashFlesh")
SWEP.Secondary.BashLength = 54
SWEP.Secondary.BashDelay = 0.2
SWEP.Secondary.BashDamageType = DMG_SLASH
SWEP.Secondary.BashEnd = nil

SWEP.BashBase = true
SWEP.DTapActivities = SWEP.DTapActivities or {}

function SWEP:BashForce(ent, force, pos, now)
    if not IsValid(ent) or not ent.GetPhysicsObjectNum then
        return
    end

    if not now then
        timer_Simple(0, function()
            if IsValid(self) and self.OwnerIsValid and self:OwnerIsValid() and IsValid(ent) then
                self:BashForce(ent, force, pos, true)
            end
        end)

        return
    end

    if ent.GetRagdollEntity then
        ent = ent:GetRagdollEntity() or ent
    end

    local phys = ent:GetPhysicsObjectNum(0)
    if not IsValid(phys) then
        return
    end

    if ent:IsPlayer() or ent:IsNPC() then
        ent:SetVelocity(force * 0.1)
        phys:SetVelocity(phys:GetVelocity() + force * 0.1)
        return
    end

    phys:ApplyForceOffset(force, pos)
end

local function bashcallback(_, tr, _, wep)
    if not IsValid(wep) then
        return
    end

    local owner = wep:GetOwner()
    if not IsValid(owner) then
        return
    end

    local ent = tr and tr.Entity
    if not (IsValid(ent) and ent.TakeDamageInfo) then
        return
    end

    local dmgAmt = (wep.Secondary and wep.Secondary.BashDamage) or 25
    local dmgType = (wep.Secondary and wep.Secondary.BashDamageType) or DMG_SLASH

    local dmg = DamageInfo()
    dmg:SetAttacker(owner)
    dmg:SetInflictor(wep)
    dmg:SetDamagePosition(owner:GetShootPos())
    dmg:SetDamageForce(owner:GetAimVector() * dmgAmt)
    dmg:SetDamage(dmgAmt)
    dmg:SetDamageType(dmgType)

    ent:TakeDamageInfo(dmg)

    local force = owner:GetAimVector() * (math_sqrt(dmgAmt / 80) * 32 * 80)
    wep:BashForce(ent, force, tr.HitPos)
end

function SWEP:HandleDoor(slashtrace)
    if CLIENT then
        return
    end

    local ent = slashtrace and slashtrace.Entity
    if not IsValid(ent) then
        return
    end

    local cls = ent:GetClass()
    if cls ~= "func_door_rotating" and cls ~= "prop_door_rotating" then
        return
    end

    local ply = self:GetOwner()
    if not IsValid(ply) then
        return
    end

    ply:EmitSound("ambient/materials/door_hit1.wav", 100, math_random(80, 120))

    local oldname = ply:GetName()
    local tmpname = "bashingpl" .. ply:EntIndex()

    ply:SetName(tmpname)
    ent:SetKeyValue("Speed", "500")
    ent:SetKeyValue("Open Direction", "Both directions")
    ent:SetKeyValue("opendir", "0")
    ent:Fire("unlock", "", 0.01)
    ent:Fire("openawayfrom", tmpname, 0.01)

    timer_Simple(0.02, function()
        if IsValid(ply) then
            ply:SetName(oldname)
        end
    end)

    timer_Simple(0.3, function()
        if IsValid(ent) then
            ent:SetKeyValue("Speed", "100")
        end
    end)
end

function SWEP:AltAttack()
    if self.Secondary and self.Secondary.CanBash == false then
        return
    end

    if not (self.OwnerIsValid and self:OwnerIsValid()) then
        return
    end

    local stat = self:GetStatus()
    if not (TFA and TFA.Enum and TFA.Enum.ReadyStatus and TFA.Enum.ReadyStatus[stat]) then
        return
    end

    if self:IsSafety() then
        return
    end

    local owner = self:GetOwner()
    local vm = IsValid(owner) and owner:GetViewModel() or nil

    self:SendWeaponAnim(ACT_VM_HITCENTER)

    if owner.Vox then
        owner:Vox("bash", 0)
    end

    local ht = self.HoldType
    local altanim = (ht == "ar2" or ht == "shotgun" or ht == "crossbow" or ht == "physgun")
    owner:AnimRestartGesture(0, altanim and ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND or ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2, true)

    self.unpredbash = true
    timer_Simple(0.1, function()
        if IsValid(self) then
            self.unpredbash = false
        end
    end)

    local now = CurTime()
    local seqDur = (IsValid(vm) and vm.SequenceDuration and vm:SequenceDuration()) or 0.5
    local endTime = self.Secondary and self.Secondary.BashEnd
    local ov = self.SequenceLengthOverride and self.SequenceLengthOverride[ACT_VM_HITCENTER]
    local bashLen = endTime or ov or seqDur

    self:SetNextIdleAnim(now + seqDur)
    self:SetNextPrimaryFire(now + bashLen)
    self:SetNextSecondaryFire(now + bashLen)

    if IsFirstTimePredicted() then
        self:EmitSound(self.Secondary.BashSound)
    end

    self:SetStatus(TFA.Enum.STATUS_BASHING)
    self:SetStatusEnd(self:GetNextPrimaryFire())

    self:SetNW2Float("BashTTime", now + (self.Secondary.BashDelay or 0.2))
end

local ttime = -1
local mins = Vector(-10, -5, 0)
local maxs = Vector(10, 5, 5)

function SWEP:Think2()
    ttime = self:GetNW2Float("BashTTime", -1)

    if ttime ~= -1 and CurTime() > ttime then
        self:SetNW2Float("BashTTime", -1)

        local owner = self:GetOwner()
        if not IsValid(owner) then
            BaseClass.Think2(self)
            return
        end

        local pos = owner:GetShootPos()
        local av = owner:EyeAngles():Forward()

        local slash = self._tfa_bash_slash
        if not slash then
            slash = { mins = mins, maxs = maxs }
            self._tfa_bash_slash = slash
        end

        slash.start = pos
        slash.endpos = pos + (av * (self.Secondary.BashLength or 54))
        slash.filter = owner

        local slashtrace = util_TraceHull(slash)
        local dmgAmt = (self.Secondary and self.Secondary.BashDamage) or 25

        if slashtrace.Hit then
            self:HandleDoor(slashtrace)

            if not (game_SinglePlayer() and CLIENT) then
                local matType = slashtrace.MatType
                local snd = ((matType == MAT_FLESH or matType == MAT_ALIENFLESH) and self.Secondary.BashHitSound_Flesh) or self.Secondary.BashHitSound
                self:EmitSound(snd)
            end

            if game_GetTimeScale() > 0.99 then
                if not self._tfa_bash_cb then
                    self._tfa_bash_cb = function(a, b, c)
                        bashcallback(a, b, c, self)
                    end
                end

                local bullets = self._tfa_bash_bullets
                if not bullets then
                    bullets = {
                        Damage = 1,
                        Force = 1,
                        HullSize = 10,
                        Tracer = 0
                    }
                    self._tfa_bash_bullets = bullets
                end

                bullets.Attacker = owner
                bullets.Inflictor = self
                bullets.Distance = (self.Secondary.BashLength or 54) + 10
                bullets.Src = pos
                bullets.Dir = av
                bullets.Callback = self._tfa_bash_cb

                owner:FireBullets(bullets)
            else
                local dmgType = (self.Secondary and self.Secondary.BashDamageType) or DMG_SLASH

                local dmg = DamageInfo()
                dmg:SetAttacker(owner)
                dmg:SetInflictor(self)
                dmg:SetDamagePosition(pos)
                dmg:SetDamageForce(owner:GetAimVector() * dmgAmt)
                dmg:SetDamage(dmgAmt)
                dmg:SetDamageType(dmgType)

                local ent = slashtrace.Entity
                if IsValid(ent) and ent.TakeDamageInfo then
                    ent:TakeDamageInfo(dmg)
                end
            end

            local ent = slashtrace.Entity
            if IsValid(ent) and ent.GetPhysicsObject then
                local phys

                if ent.IsRagdoll and ent:IsRagdoll() then
                    phys = ent:GetPhysicsObjectNum(slashtrace.PhysicsBone or 0)
                else
                    phys = ent:GetPhysicsObject()
                end

                if IsValid(phys) then
                    local push = owner:GetAimVector() * dmgAmt * 0.5

                    if ent:IsPlayer() or ent:IsNPC() then
                        ent:SetVelocity(push)
                        phys:SetVelocity(phys:GetVelocity() + push)
                    else
                        phys:ApplyForceOffset(push, slashtrace.HitPos)
                    end
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

function SWEP:GetBashing()
    if not (self.OwnerIsValid and self:OwnerIsValid()) then
        return false
    end

    local owner = self:GetOwner()
    local vm = self.OwnerViewModel
    if not IsValid(vm) and IsValid(owner) then
        vm = owner:GetViewModel()
        self.OwnerViewModel = vm
    end

    if not (IsValid(vm) and vm.GetSequence and vm.GetSequenceActivity and vm.GetCycle) then
        return false
    end

    local seq = vm:GetSequence()
    local actid = vm:GetSequenceActivity(seq)
    local cy = vm:GetCycle()

    return ((actid == ACT_VM_HITCENTER) and cy > 0 and cy < 0.65) or (self.unpredbash == true)
end
