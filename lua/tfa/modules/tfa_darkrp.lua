local IsValid = IsValid
local hook_Add = hook.Add

local block = {
    tfa_ammo_357 = true,
    tfa_ammo_ar2 = true,
    tfa_ammo_buckshot = true,
    tfa_ammo_c4 = true,
    tfa_ammo_frags = true,
    tfa_ammo_ieds = true,
    tfa_ammo_nervegas = true,
    tfa_ammo_nuke = true,
    tfa_ammo_pistol = true,
    tfa_ammo_proxmines = true,
    tfa_ammo_rockets = true,
    tfa_ammo_smg = true,
    tfa_ammo_sniper_rounds = true,
    tfa_ammo_stickynades = true,
    tfa_ammo_winchester = true
}

hook_Add("canPocket", "TFA_PockBlock", function(_, wep)
    if not IsValid(wep) then return end
    if block[wep:GetClass()] then
        return false
    end
end)
