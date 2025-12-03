TFA_Base_Particles = TFA_Base_Particles or {
    tfa_muzzle_rifle = "tfa_muzzleflashes",
    tfa_muzzle_sniper = "tfa_muzzleflashes",
    tfa_muzzle_energy = "tfa_muzzleflashes",
    tfa_muzzle_gauss = "tfa_muzzleflashes",
    DUMMY_TFA_SMOKE = "tfa_smoke"
}

local addedparts = {}
local cachedparts = {}

local pairs = pairs
local string_find = string.find
local string_lower = string.lower
local string_sub = string.sub
local file_Find = file.Find
local file_Exists = file.Exists
local game_AddParticles = game.AddParticles
local PrecacheParticleSystem = PrecacheParticleSystem
local hook_Add = hook.Add

local function addParticleFile(pcfName)
    if not pcfName then return false end

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
    if not name or cachedparts[name] ~= nil then
        return cachedparts[name]
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

hook_Add("InitPostEntity", "TFA_Initialize_Particles", TFA_Initialize_Particles)

TFA_Initialize_Particles()
