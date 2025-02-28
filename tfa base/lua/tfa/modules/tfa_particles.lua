TFA_Base_Particles = TFA_Base_Particles or {
    ["tfa_muzzle_rifle"]  = "tfa_muzzleflashes",
    ["tfa_muzzle_sniper"] = "tfa_muzzleflashes",
    ["tfa_muzzle_energy"] = "tfa_muzzleflashes",
    ["tfa_muzzle_gauss"]  = "tfa_muzzleflashes",
    ["DUMMY_TFA_SMOKE"]   = "tfa_smoke"
}

local addedparts = {}
local cachedparts = {}

local function TFA_Initialize_Particles()
    for k, v in pairs(TFA_Base_Particles) do
        if not addedparts[v] then
            game.AddParticles("particles/" .. v .. ".pcf")
            addedparts[v] = true
        end

        if not cachedparts[k] and not string.find(k, "DUMMY") then
            PrecacheParticleSystem(k)
            cachedparts[k] = true
        end
    end
end

hook.Add("InitPostEntity", "TFA_Initialize_Particles", TFA_Initialize_Particles)

TFA_Initialize_Particles()
