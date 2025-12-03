TFA = TFA or {}

local tmpsp = game.SinglePlayer()

local GetConVar = GetConVar
local game_GetTimeScale = game.GetTimeScale
local game_SinglePlayer = game.SinglePlayer
local Entity = Entity
local LocalPlayer = LocalPlayer
local IsValid = IsValid
local math_Clamp = math.Clamp
local math_Round = math.Round
local pairs = pairs
local istable = istable
local isstring = isstring
local string_sub = string.sub
local string_lower = string.lower
local string_find = string.find
local sound_Add = sound.Add
local FrameTime = FrameTime
local SysTime = SysTime

local gas_cl_enabled = GetConVar("cl_tfa_fx_gasblur")
local gas_sv_enabled = GetConVar("sv_tfa_fx_gas_override")
local sv_cheats_cv = GetConVar("sv_cheats")
local host_timescale_cv = GetConVar("host_timescale")

local ft = 0.01
local LastSys

local SoundChars = {
    ["*"] = "STREAM",
    ["#"] = "DRYMIX",
    ["@"] = "OMNI",
    [">"] = "DOPPLER",
    ["<"] = "DIRECTIONAL",
    ["^"] = "DISTVARIANT",
    ["("] = "SPATIALSTEREO_LOOP",
    [")"] = "SPATIALSTEREO",
    ["}"] = "FASTPITCH",
    ["$"] = "CRITICAL",
    ["!"] = "SENTENCE",
    ["?"] = "USERVOX"
}

local DefaultSoundChar = ")"

local SoundChannels = {
    shoot = CHAN_WEAPON,
    shootwrap = CHAN_STATIC,
    misc = CHAN_AUTO
}

function TFA.PatchSound(path, kind)
    local firstChar = string_sub(path, 1, 1)
    local actualPath

    if SoundChars[firstChar] then
        actualPath = string_sub(path, 2)
    else
        actualPath = path
    end

    local kindstr = kind or DefaultSoundChar

    if #kindstr > 1 then
        local found = false

        for c, name in pairs(SoundChars) do
            if name == kind then
                kindstr = c
                found = true
                break
            end
        end

        if not found then
            kindstr = DefaultSoundChar
        end
    end

    return kindstr .. actualPath
end

local function addSound(id, path, kind, channel, level)
    local pitch = { 97, 103 }

    if isstring(path) then
        sound_Add({
            name = id,
            channel = channel,
            volume = 1,
            level = level,
            pitch = pitch,
            sound = TFA.PatchSound(path, kind)
        })
    elseif istable(path) then
        local patched = {}

        for k, v in pairs(path) do
            patched[k] = TFA.PatchSound(v, kind)
        end

        sound_Add({
            name = id,
            channel = channel,
            volume = 1,
            level = level,
            pitch = pitch,
            sound = patched
        })
    end
end

function TFA.AddFireSound(id, path, wrap, kindv)
    local kind = kindv or DefaultSoundChar
    local channel = wrap and SoundChannels.shootwrap or SoundChannels.shoot

    addSound(id, path, kind, channel, 120)
end

function TFA.AddWeaponSound(id, path, kindv)
    local kind = kindv or DefaultSoundChar
    local channel = SoundChannels.misc

    addSound(id, path, kind, channel, 80)
end

local AmmoTypes = {}

function TFA.AddAmmo(id, name)
    if AmmoTypes[name] then
        return AmmoTypes[name]
    end

    AmmoTypes[name] = id
    game.AddAmmoType({ name = id })

    if language then
        language.Add(id .. "_ammo", name)
    end

    return id
end

hook.Add("Think", "TFAFrameTimeThink", function()
    local curSys = SysTime()
    local delta = curSys - (LastSys or curSys)

    ft = delta * game_GetTimeScale()

    local frameFt = FrameTime()
    if ft > frameFt then
        ft = frameFt
    end

    ft = math_Clamp(ft, 0, 1 / 30)

    if sv_cheats_cv:GetBool() and host_timescale_cv:GetFloat() < 1 then
        ft = ft * host_timescale_cv:GetFloat()
    end

    LastSys = curSys
end)

function TFA.FrameTime()
    return ft
end

function TFA.GetGasEnabled()
    if tmpsp then
        local ent = Entity(1)
        if IsValid(ent) then
            return math_Round(ent:GetInfoNum("cl_tfa_fx_gasblur", 0)) ~= 0
        end

        return false
    end

    local enabled = gas_cl_enabled and gas_cl_enabled:GetBool() or false

    if gas_sv_enabled and gas_sv_enabled:GetInt() ~= -1 then
        enabled = gas_sv_enabled:GetBool()
    end

    return enabled
end

local ejectionsmoke_cl_enabled = GetConVar("cl_tfa_fx_ejectionsmoke")
local ejectionsmoke_sv_enabled = GetConVar("sv_tfa_fx_ejectionsmoke_override")
local muzzlesmoke_cl_enabled = GetConVar("cl_tfa_fx_muzzlesmoke")
local muzzlesmoke_sv_enabled = GetConVar("sv_tfa_fx_muzzlesmoke_override")

function TFA.GetMZSmokeEnabled()
    if tmpsp then
        local ent = Entity(1)
        if IsValid(ent) then
            return math_Round(ent:GetInfoNum("cl_tfa_fx_muzzlesmoke", 0)) ~= 0
        end

        return false
    end

    local enabled = muzzlesmoke_cl_enabled and muzzlesmoke_cl_enabled:GetBool() or false

    if muzzlesmoke_sv_enabled and muzzlesmoke_sv_enabled:GetInt() ~= -1 then
        enabled = muzzlesmoke_sv_enabled:GetBool()
    end

    return enabled
end

function TFA.GetEJSmokeEnabled()
    if tmpsp then
        local ent = Entity(1)
        if IsValid(ent) then
            return math_Round(ent:GetInfoNum("cl_tfa_fx_ejectionsmoke", 0)) ~= 0
        end

        return false
    end

    local enabled = ejectionsmoke_cl_enabled and ejectionsmoke_cl_enabled:GetBool() or false

    if ejectionsmoke_sv_enabled then
        local mode = ejectionsmoke_sv_enabled:GetInt()

        if mode == 0 then
            enabled = false
        elseif mode == 1 then
            enabled = true
        end
    end

    return enabled
end

local ricofx_cl_enabled = GetConVar("cl_tfa_fx_impact_ricochet_enabled")
local ricofx_sv_enabled = GetConVar("sv_tfa_fx_ricochet_override")

function TFA.GetRicochetEnabled()
    if tmpsp then
        local ent = Entity(1)
        if IsValid(ent) then
            return math_Round(ent:GetInfoNum("cl_tfa_fx_impact_ricochet_enabled", 0)) ~= 0
        end

        return false
    end

    local enabled = ricofx_cl_enabled and ricofx_cl_enabled:GetBool() or false

    if ricofx_sv_enabled and ricofx_sv_enabled:GetInt() ~= -1 then
        enabled = ricofx_sv_enabled:GetBool()
    end

    return enabled
end

function TFA.PlayerCarryingTFAWeapon(ply)
    if not ply then
        if CLIENT then
            local lp = LocalPlayer()
            if IsValid(lp) then
                ply = lp
            else
                return false, nil, nil
            end
        elseif game_SinglePlayer() then
            ply = Entity(1)
        else
            return false, nil, nil
        end
    end

    if not (IsValid(ply) and ply:IsPlayer() and ply:Alive()) then
        return false, ply, nil
    end

    local wep = ply:GetActiveWeapon()

    if IsValid(wep) then
        if wep.IsTFAWeapon then
            return true, ply, wep
        end

        return false, ply, wep
    end

    return false, ply, nil
end
