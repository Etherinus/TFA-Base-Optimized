TFA_Base_Particles = TFA_Base_Particles or {
    tfa_muzzle_rifle = "tfa_muzzleflashes",
    tfa_muzzle_sniper = "tfa_muzzleflashes",
    tfa_muzzle_energy = "tfa_muzzleflashes",
    tfa_muzzle_gauss = "tfa_muzzleflashes",
    DUMMY_TFA_SMOKE = "tfa_smoke"
}

local addedparts = addedparts or {}
local cachedparts = cachedparts or {}

local pairs = pairs
local string_find = string.find
local string_lower = string.lower
local file_Exists = file and file.Exists
local game_AddParticles = game and game.AddParticles
local PrecacheParticleSystem = PrecacheParticleSystem
local hook_Add = hook and hook.Add

local function addParticleFile(pcfName)
    if not (pcfName and file_Exists and game_AddParticles) then
        return false
    end

    local key = string_lower(pcfName)
    if addedparts[key] then
        return true
    end

    local path = "particles/" .. pcfName .. ".pcf"
    if not file_Exists(path, "GAME") then
        return false
    end

    game_AddParticles(path)
    addedparts[key] = true

    return true
end

local function precacheIfPresent(name)
    if not name then
        return false
    end

    if cachedparts[name] ~= nil then
        return cachedparts[name]
    end

    if not PrecacheParticleSystem then
        cachedparts[name] = false
        return false
    end

    local ok = PrecacheParticleSystem(name)
    cachedparts[name] = ok ~= false

    return cachedparts[name]
end

function TFA.HasParticleSystem(name)
    return cachedparts[name] == true
end

local function TFA_Initialize_Particles()
    for name, pcf in pairs(TFA_Base_Particles) do
        if not string_find(name, "DUMMY", 1, true) then
            if addParticleFile(pcf) then
                precacheIfPresent(name)
            else
                cachedparts[name] = false
            end
        else
            cachedparts[name] = false
        end
    end
end

if hook_Add then
    hook_Add("InitPostEntity", "TFA_Initialize_Particles", TFA_Initialize_Particles)
end

TFA_Initialize_Particles()
