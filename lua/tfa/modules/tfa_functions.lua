TFA = TFA or {}
local TFA = TFA

TFA.DegreesToAccuracy = TFA.DegreesToAccuracy or (math.pi / 180)

local game_SinglePlayerFn = game and game.SinglePlayer
local tmpsp = game_SinglePlayerFn and game_SinglePlayerFn() or false

local GetConVar = GetConVar
local game_GetTimeScale = game and game.GetTimeScale
local Entity = Entity
local LocalPlayer = LocalPlayer
local IsValid = IsValid
local FrameTime = FrameTime
local SysTime = SysTime

local math_Clamp = math.Clamp
local math_Round = math.Round

local pairs = pairs
local istable = istable
local isstring = isstring
local string_sub = string.sub

local sound_Add = sound and sound.Add
local game_AddAmmoType = game and game.AddAmmoType
local language_Add = language and language.Add

local hook_Add = hook and hook.Add

local gas_cl_enabled = GetConVar("cl_tfa_fx_gasblur")
local gas_sv_enabled = GetConVar("sv_tfa_fx_gas_override")
local sv_cheats_cv = GetConVar("sv_cheats")
local host_timescale_cv = GetConVar("host_timescale")

local ft = 0.01
local lastSys

local SoundChars = {
    [string.byte("*")] = true,
    [string.byte("#")] = true,
    [string.byte("@")] = true,
    [string.byte(">")] = true,
    [string.byte("<")] = true,
    [string.byte("^")] = true,
    [string.byte("(")] = true,
    [string.byte(")")] = true,
    [string.byte("}")] = true,
    [string.byte("$")] = true,
    [string.byte("!")] = true,
    [string.byte("?")] = true
}

local SoundCharByName = {
    STREAM = "*",
    DRYMIX = "#",
    OMNI = "@",
    DOPPLER = ">",
    DIRECTIONAL = "<",
    DISTVARIANT = "^",
    SPATIALSTEREO_LOOP = "(",
    SPATIALSTEREO = ")",
    FASTPITCH = "}",
    CRITICAL = "$",
    SENTENCE = "!",
    USERVOX = "?"
}

local DefaultSoundChar = ")"

local SoundChannels = {
    shoot = CHAN_WEAPON,
    shootwrap = CHAN_STATIC,
    misc = CHAN_AUTO
}

function TFA.PatchSound(path, kind)
    if not path or path == "" then
        return DefaultSoundChar
    end

    local first = string_sub(path, 1, 1)
    local b = string.byte(first)
    local actualPath = SoundChars[b] and string_sub(path, 2) or path

    local kindstr = kind or DefaultSoundChar
    if kindstr ~= DefaultSoundChar and #kindstr > 1 then
        kindstr = SoundCharByName[kindstr] or DefaultSoundChar
    end

    return kindstr .. actualPath
end

local function addSound(id, path, kind, channel, level)
    if not sound_Add or not id then return end

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
        return
    end

    if istable(path) then
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

function TFA.AddSound(id, channel, volume, level, pitch, path, kindv)
    if not sound_Add or not id then return end

    channel = channel or CHAN_AUTO
    volume = volume or 1
    level = level or 75

    local sndpath = path
    local pitchval = pitch

    if sndpath == nil and (isstring(pitch) or istable(pitch)) then
        sndpath = pitch
        pitchval = nil
    end

    if isstring(sndpath) then
        sndpath = TFA.PatchSound(sndpath, kindv)
    elseif istable(sndpath) then
        local patched = {}
        for k, v in pairs(sndpath) do
            patched[k] = TFA.PatchSound(v, kindv)
        end
        sndpath = patched
    else
        return
    end

    if not pitchval then
        pitchval = { 97, 103 }
    elseif not istable(pitchval) then
        pitchval = { pitchval, pitchval }
    end

    sound_Add({
        name = id,
        channel = channel,
        volume = volume,
        level = level,
        pitch = pitchval,
        sound = sndpath
    })
end

function TFA.AddFireSound(id, path, wrap, kindv)
    local kind = kindv or DefaultSoundChar
    local channel = wrap and SoundChannels.shootwrap or SoundChannels.shoot
    addSound(id, path, kind, channel, 120)
end

function TFA.AddWeaponSound(id, path, kindv)
    local kind = kindv or DefaultSoundChar
    addSound(id, path, kind, SoundChannels.misc, 80)
end

local AmmoTypes = {}

function TFA.AddAmmo(id, name)
    if not game_AddAmmoType or not id or not name then
        return id
    end

    local existing = AmmoTypes[name]
    if existing then
        return existing
    end

    AmmoTypes[name] = id
    game_AddAmmoType({ name = id })

    if language_Add then
        language_Add(id .. "_ammo", name)
    end

    return id
end

if hook_Add and SysTime and FrameTime and game_GetTimeScale and math_Clamp then
    hook_Add("Think", "TFAFrameTimeThink", function()
        local curSys = SysTime()
        local prev = lastSys or curSys
        local delta = curSys - prev

        local ts = game_GetTimeScale()
        if ts then
            ft = delta * ts
        else
            ft = delta
        end

        local frameFt = FrameTime()
        if ft > frameFt then
            ft = frameFt
        end

        ft = math_Clamp(ft, 0, 1 / 30)

        if not sv_cheats_cv then
            sv_cheats_cv = GetConVar("sv_cheats")
        end
        if not host_timescale_cv then
            host_timescale_cv = GetConVar("host_timescale")
        end

        if sv_cheats_cv and sv_cheats_cv:GetBool() and host_timescale_cv and host_timescale_cv:GetFloat() < 1 then
            ft = ft * host_timescale_cv:GetFloat()
        end

        lastSys = curSys
    end)
end

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

    if not gas_cl_enabled then
        gas_cl_enabled = GetConVar("cl_tfa_fx_gasblur")
    end
    if not gas_sv_enabled then
        gas_sv_enabled = GetConVar("sv_tfa_fx_gas_override")
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

    if not muzzlesmoke_cl_enabled then
        muzzlesmoke_cl_enabled = GetConVar("cl_tfa_fx_muzzlesmoke")
    end
    if not muzzlesmoke_sv_enabled then
        muzzlesmoke_sv_enabled = GetConVar("sv_tfa_fx_muzzlesmoke_override")
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

    if not ejectionsmoke_cl_enabled then
        ejectionsmoke_cl_enabled = GetConVar("cl_tfa_fx_ejectionsmoke")
    end
    if not ejectionsmoke_sv_enabled then
        ejectionsmoke_sv_enabled = GetConVar("sv_tfa_fx_ejectionsmoke_override")
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

    if not ricofx_cl_enabled then
        ricofx_cl_enabled = GetConVar("cl_tfa_fx_impact_ricochet_enabled")
    end
    if not ricofx_sv_enabled then
        ricofx_sv_enabled = GetConVar("sv_tfa_fx_ricochet_override")
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
        elseif tmpsp then
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
