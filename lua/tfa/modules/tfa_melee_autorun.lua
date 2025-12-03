if SERVER then AddCSLuaFile() end

local game_AddDecal = game.AddDecal
local game_AddAmmoType = game.AddAmmoType
local CurTime = CurTime
local Vector = Vector
local hook_Add = hook.Add
local IsValid = IsValid
local math_abs = math.abs
local math_Clamp = math.Clamp
local Lerp = Lerp

game_AddDecal("Slash_0", "decals/slash_0")
game_AddDecal("Slash_45", "decals/slash_45")
game_AddDecal("Slash_90", "decals/slash_90")
game_AddDecal("Slash_135", "decals/slash_135")

game_AddAmmoType({
    name = "TFMSwordHitSlash",
    dmgtype = DMG_SLASH,
    tracer = TRACER_NONE
})

game_AddAmmoType({
    name = "TFMSwordHitGeneric",
    dmgtype = DMG_GENERIC,
    tracer = TRACER_NONE
})

game_AddAmmoType({
    name = "TFMSwordHitGenericSlash",
    dmgtype = DMG_SLASH,
    tracer = TRACER_NONE
})

game_AddAmmoType({
    name = "TFMSwordRayTest",
    dmgtype = 0,
    tracer = TRACER_NONE,
    plydmg = 0,
    npcdmg = 0,
    force = 0,
    minsplash = 1,
    maxsplash = 1
})

local function TFMPlayerSpawn(ply)
    ply:SetNW2Vector("TFM_SwordPosition", Vector(1, 1, 1))
    ply:SetNW2Vector("TFM_SwordNormal", Vector(1, 1, 1))
    ply:SetNW2Bool("TFM_IsSprinting", false)
    ply:SetNW2Bool("TFM_IsBlocking", false)
    ply:SetNW2Bool("TFM_IsSwinging", false)
    ply:SetNW2Float("TFM_SwingStart", CurTime())
end

hook_Add("PlayerSpawn", "TFM_PlayerSpawn", TFMPlayerSpawn)

hook_Add("EntityTakeDamage", "TFM_Block", function(ent, dmginfo)
    if not ent:IsPlayer() then
        return
    end

    local wep = ent:GetActiveWeapon()
    if not wep or not wep.IsTFAWeapon or not wep.BlockAngle then
        return
    end

    local dmgtype = dmginfo:GetDamageType()
    local blockmelee = dmginfo:IsDamageType(DMG_SLASH) or dmginfo:IsDamageType(DMG_CLUB)
    local blockninja = wep.NinjaMode
        and wep.NinjaMode == true
        and (dmginfo:IsDamageType(DMG_CRUSH) or dmginfo:IsDamageType(DMG_BULLET))

    if not blockmelee and not blockninja then
        return
    end

    if not wep:GetIronSights() then
        return
    end

    local damageinflictor = dmginfo:GetInflictor()
    if not IsValid(damageinflictor) then
        damageinflictor = dmginfo:GetAttacker()
    end

    local aimAng = ent:GetAimVector():Angle()
    local entPos = ent:GetPos()
    local infPos = IsValid(damageinflictor) and damageinflictor:GetPos() or dmginfo:GetDamagePosition()
    local deltaY = math_abs((aimAng - (infPos - entPos):Angle()).y)

    local blockthreshold = (wep.BlockAngle / 2) or 90
    if deltaY > blockthreshold then
        return
    end

    local fac = math_Clamp((CurTime() - wep:GetBlockStart() - wep.BlockWindow) / wep.BlockFadeTime, 0, 1)
    local dmgscale = Lerp(fac, wep.BlockMaximum, wep.BlockMinimum)

    dmginfo:ScaleDamage(dmgscale)
    dmginfo:SetDamagePosition(vector_origin)

    wep:EmitSound(wep.Primary.Sound_Impact_Metal or "")

    if wep.BlockAnim then
        wep:BlockAnim()
    end
end)
