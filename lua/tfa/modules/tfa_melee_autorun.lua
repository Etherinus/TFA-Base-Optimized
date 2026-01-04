if SERVER then AddCSLuaFile() end

local game_AddDecal = game and game.AddDecal
local game_AddAmmoType = game and game.AddAmmoType
local CurTime = CurTime
local Vector = Vector
local IsValid = IsValid
local hook_Add = hook and hook.Add
local math_abs = math.abs
local math_Clamp = math.Clamp
local Lerp = Lerp
local AngleDifference = math.AngleDifference
local vector_origin = vector_origin

if game_AddDecal then
    game_AddDecal("Slash_0", "decals/slash_0")
    game_AddDecal("Slash_45", "decals/slash_45")
    game_AddDecal("Slash_90", "decals/slash_90")
    game_AddDecal("Slash_135", "decals/slash_135")
end

if game_AddAmmoType then
    game_AddAmmoType({ name = "TFMSwordHitSlash", dmgtype = DMG_SLASH, tracer = TRACER_NONE })
    game_AddAmmoType({ name = "TFMSwordHitGeneric", dmgtype = DMG_GENERIC, tracer = TRACER_NONE })
    game_AddAmmoType({ name = "TFMSwordHitGenericSlash", dmgtype = DMG_SLASH, tracer = TRACER_NONE })
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
end

local function SetNW2VectorSafe(ply, k, v)
    if ply.SetNW2Vector then
        ply:SetNW2Vector(k, v)
    elseif ply.SetNWVector then
        ply:SetNWVector(k, v)
    end
end

local function SetNW2BoolSafe(ply, k, v)
    if ply.SetNW2Bool then
        ply:SetNW2Bool(k, v)
    elseif ply.SetNWBool then
        ply:SetNWBool(k, v)
    end
end

local function SetNW2FloatSafe(ply, k, v)
    if ply.SetNW2Float then
        ply:SetNW2Float(k, v)
    elseif ply.SetNWFloat then
        ply:SetNWFloat(k, v)
    end
end

local function TFMPlayerSpawn(ply)
    if not IsValid(ply) then return end
    local one = Vector and Vector(1, 1, 1) or vector_origin
    SetNW2VectorSafe(ply, "TFM_SwordPosition", one)
    SetNW2VectorSafe(ply, "TFM_SwordNormal", one)
    SetNW2BoolSafe(ply, "TFM_IsSprinting", false)
    SetNW2BoolSafe(ply, "TFM_IsBlocking", false)
    SetNW2BoolSafe(ply, "TFM_IsSwinging", false)
    SetNW2FloatSafe(ply, "TFM_SwingStart", CurTime())
end

if hook_Add then
    hook_Add("PlayerSpawn", "TFM_PlayerSpawn", TFMPlayerSpawn)

    hook_Add("EntityTakeDamage", "TFM_Block", function(ent, dmginfo)
        if not (ent and ent.IsPlayer and ent:IsPlayer()) then
            return
        end

        local wep = ent:GetActiveWeapon()
        if not (wep and wep.IsTFAWeapon and wep.BlockAngle) then
            return
        end

        if not (wep.GetIronSights and wep.GetBlockStart) then
            return
        end

        local dmgtype = dmginfo:GetDamageType()
        local blockmelee = dmginfo:IsDamageType(DMG_SLASH) or dmginfo:IsDamageType(DMG_CLUB)

        local ninja = wep.NinjaMode == true
        local blockninja = ninja and (dmginfo:IsDamageType(DMG_CRUSH) or dmginfo:IsDamageType(DMG_BULLET))

        if not blockmelee and not blockninja then
            return
        end

        if not wep:GetIronSights() then
            return
        end

        local inf = dmginfo:GetInflictor()
        if not IsValid(inf) then
            inf = dmginfo:GetAttacker()
        end

        local entPos = ent:GetPos()
        local infPos = IsValid(inf) and inf:GetPos() or dmginfo:GetDamagePosition()
        local aimAng = ent:GetAimVector():Angle()
        local dirAng = (infPos - entPos):Angle()

        local dy
        if AngleDifference then
            dy = math_abs(AngleDifference(aimAng.y, dirAng.y))
        else
            dy = math_abs((aimAng - dirAng).y)
        end

        local half = (wep.BlockAngle or 180) * 0.5
        if dy > half then
            return
        end

        local fade = wep.BlockFadeTime or 0
        if fade <= 0 then
            return
        end

        local start = wep:GetBlockStart() or 0
        local window = wep.BlockWindow or 0
        local fac = math_Clamp((CurTime() - start - window) / fade, 0, 1)
        local dmgscale = Lerp(fac, wep.BlockMaximum or 1, wep.BlockMinimum or 0.1)

        dmginfo:ScaleDamage(dmgscale)
        dmginfo:SetDamagePosition(vector_origin)

        local pri = wep.Primary
        local snd = pri and pri.Sound_Impact_Metal or ""
        if snd ~= "" and wep.EmitSound then
            wep:EmitSound(snd)
        end

        if wep.BlockAnim then
            wep:BlockAnim()
        end
    end)
end
