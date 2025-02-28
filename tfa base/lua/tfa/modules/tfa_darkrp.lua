local TFA_PocketBlock = {
    ["tfa_ammo_357"] = true,
    ["tfa_ammo_ar2"] = true,
    ["tfa_ammo_buckshot"] = true,
    ["tfa_ammo_c4"] = true,
    ["tfa_ammo_frags"] = true,
    ["tfa_ammo_ieds"] = true,
    ["tfa_ammo_nervegas"] = true,
    ["tfa_ammo_nuke"] = true,
    ["tfa_ammo_pistol"] = true,
    ["tfa_ammo_proxmines"] = true,
    ["tfa_ammo_rockets"] = true,
    ["tfa_ammo_smg"] = true,
    ["tfa_ammo_sniper_rounds"] = true,
    ["tfa_ammo_stickynades"] = true,
    ["tfa_ammo_winchester"] = true
}

local function TFA_PockBlock(_, wep)
    if not IsValid(wep) then return end
    local class = wep:GetClass()
    if TFA_PocketBlock[class] then
        return false
    end
end

hook.Add("canPocket", "TFA_PockBlock", TFA_PockBlock)
