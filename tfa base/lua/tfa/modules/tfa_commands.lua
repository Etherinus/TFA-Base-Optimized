local pairs = pairs
local weapons = weapons
local hook = hook
local string = string
local math = math
local cvars = cvars

local function CreateReplConVar(cvarname, cvarvalue, description)
    if CLIENT then
        return CreateConVar(cvarname, cvarvalue, {FCVAR_REPLICATED}, description)
    else
        return CreateConVar(cvarname, cvarvalue, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, description)
    end
end

local function EnsureReplConVar(cvarname, default, desc)
    if not GetConVar(cvarname) then
        CreateReplConVar(cvarname, default, desc)
    end
end

EnsureReplConVar("sv_tfa_weapon_strip", "0", "Allow the removal of empty weapons? 1 for true, 0 for false")
EnsureReplConVar("sv_tfa_spread_legacy", "0", "Use legacy spread algorithms?")
EnsureReplConVar("sv_tfa_cmenu", "1", "Allow custom context menu?")
EnsureReplConVar("sv_tfa_range_modifier", "0.5", "Controls how much the range affects damage. 0.5 => max loss is 50%.")
EnsureReplConVar("sv_tfa_allow_dryfire", "1", "Allow dryfire?")
EnsureReplConVar("sv_tfa_penetration_limit", "2", "Number of objects we can penetrate through.")
EnsureReplConVar("sv_tfa_damage_multiplier", "1", "Multiplier for TFA base projectile damage.")
EnsureReplConVar("sv_tfa_damage_mult_min", "0.95", "Lower range of random damage factor.")
EnsureReplConVar("sv_tfa_damage_mult_max", "1.05", "Upper range of random damage factor.")

local cv_dfc = CreateReplConVar("sv_tfa_default_clip", "-1", "How many clips a weapon spawns with? Negative => default values.")

function TFAUpdateDefaultClip()
    local dfc = cv_dfc:GetInt()
    local weplist = weapons.GetList()
    if not weplist or #weplist <= 0 then return end

    for _, v in pairs(weplist) do
        local cl = v.ClassName or v
        local wep = weapons.GetStored(cl)
        if wep and (wep.IsTFAWeapon or string.find(string.lower(wep.Base or ""), "tfa")) then
            wep.Primary = wep.Primary or {}

            if not wep.Primary.TrueDefaultClip then
                wep.Primary.TrueDefaultClip = wep.Primary.DefaultClip or 0
            end

            if dfc < 0 then
                wep.Primary.DefaultClip = wep.Primary.TrueDefaultClip
            else
                if wep.Primary.ClipSize and wep.Primary.ClipSize > 0 then
                    wep.Primary.DefaultClip = wep.Primary.ClipSize * dfc
                else
                    wep.Primary.DefaultClip = wep.Primary.TrueDefaultClip * dfc
                end
            end
        end
    end
end

hook.Add("InitPostEntity", "TFADefaultClipPE", TFAUpdateDefaultClip)
if TFAUpdateDefaultClip then
    TFAUpdateDefaultClip()
end

cvars.AddChangeCallback("sv_tfa_default_clip", function(_, _, _)
    TFAUpdateDefaultClip()
end, "TFAUpdateDefaultClip")

EnsureReplConVar("sv_tfa_unique_slots", "1", "Give TFA-based Weapons unique slots? RESTART AFTER CHANGING.")
EnsureReplConVar("sv_tfa_spread_multiplier", "1", "Increase => more spread, decrease => less.")
EnsureReplConVar("sv_tfa_force_multiplier", "1", "Arrow force multiplier, not velocity.")
EnsureReplConVar("sv_tfa_dynamicaccuracy", "1", "Dynamic accuracy? e.g. more accurate on crouch, less accurate on jump.")
EnsureReplConVar("sv_tfa_ammo_detonation", "1", "Ammo Detonation? Shoot ammo to explode.")
if not GetConVar("sv_tfa_ammo_detonation_mode") then
    CreateConVar("sv_tfa_ammo_detonation_mode", "2", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Ammo Detonation Mode? 0=Bullets,1=Blast,2=Mix")
end
if not GetConVar("sv_tfa_ammo_detonation_chain") then
    CreateConVar("sv_tfa_ammo_detonation_chain", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Chain ammo boxes? (0=No, 1=Yes)")
end
EnsureReplConVar("sv_tfa_scope_gun_speed_scale", "0", "Scale player sensitivity by movement speed while scoped?")
EnsureReplConVar("sv_tfa_bullet_penetration", "1", "Allow bullet penetration?")
EnsureReplConVar("sv_tfa_holdtype_dynamic", "1", "Allow dynamic holdtype?")
EnsureReplConVar("sv_tfa_arrow_lifetime", "30", "Arrow lifetime.")

EnsureReplConVar("sv_tfa_fx_ejectionsmoke_override", "-1", "-1 => let clients pick, 0 => force off, 1 => force on")
EnsureReplConVar("sv_tfa_fx_muzzlesmoke_override", "-1", "-1 => let clients pick, 0 => force off, 1 => force on")
EnsureReplConVar("sv_tfa_fx_gas_override", "-1", "-1 => let clients pick, 0 => force off, 1 => force on")
EnsureReplConVar("sv_tfa_fx_impact_override", "-1", "-1 => let clients pick, 0 => force off, 1 => force on")
EnsureReplConVar("sv_tfa_worldmodel_culldistance", "640", "-1 => unculled, else feet*16.")
EnsureReplConVar("sv_tfa_reloads_legacy", "0", "Use legacy reload logic?")
EnsureReplConVar("sv_tfa_fx_penetration_decal", "1", "Decals on other side of penetrated object?")
EnsureReplConVar("sv_tfa_ironsights_enabled", "1", "Enable ironsights? (Scopes still allowed if disabled.)")
if not GetConVar("sv_tfa_sprint_enabled") then
    CreateConVar("sv_tfa_sprint_enabled", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Enable sprinting? 0 => can shoot while IN_SPEED.")
end
EnsureReplConVar("sv_tfa_reloads_enabled", "1", "Enable reloading? 0 => shoot from ammo pool.")
EnsureReplConVar("sv_tfa_compat_movement", "0", "Enable movement compatibility mode?")
EnsureReplConVar("sv_tfa_net_idles", "0", "Enable idle anims at cost of big net traffic?")
EnsureReplConVar("sv_tfa_net_shells", "0", "Enable MP shell ejection at cost of net traffic?")
EnsureReplConVar("sv_tfa_net_muzzles", "0", "Enable MP muzzle flashes at cost of net traffic?")

if CLIENT then
    local function EnsureClientConVar(name, default, save, userdata)
        if not GetConVar(name) then
            CreateClientConVar(name, default, save, userdata)
        end
    end

    EnsureClientConVar("cl_tfa_forcearms", "1", true, true)
    EnsureClientConVar("cl_tfa_inspection_old", "0", true, true)
    EnsureClientConVar("cl_tfa_inspection_ckey", "0", true, true)
    EnsureClientConVar("cl_tfa_viewbob_intensity", "1", true, false)
    EnsureClientConVar("cl_tfa_gunbob_intensity", "1", true, false)
    EnsureClientConVar("cl_tfa_3dscope", "1", true, true)
    EnsureClientConVar("cl_tfa_3dscope_overlay", "0", true, true)
    EnsureClientConVar("cl_tfa_scope_sensitivity_autoscale", "100", true, true)
    EnsureClientConVar("cl_tfa_scope_sensitivity", "100", true, true)
    EnsureClientConVar("cl_tfa_ironsights_toggle", "1", true, true)
    EnsureClientConVar("cl_tfa_ironsights_resight", "1", true, true)

    EnsureClientConVar("cl_tfa_hud_crosshair_length", "1", true, false)
    EnsureClientConVar("cl_tfa_hud_crosshair_length_use_pixels", "0", true, false)
    EnsureClientConVar("cl_tfa_hud_crosshair_width", "1", true, false)
    EnsureClientConVar("cl_tfa_hud_crosshair_enable_custom", "1", true, false)
    EnsureClientConVar("cl_tfa_hud_crosshair_gap_scale", "1", true, false)
    EnsureClientConVar("cl_tfa_hud_crosshair_dot", "0", true, false)

    EnsureClientConVar("cl_tfa_hud_crosshair_color_r", "225", true, false)
    EnsureClientConVar("cl_tfa_hud_crosshair_color_g", "225", true, false)
    EnsureClientConVar("cl_tfa_hud_crosshair_color_b", "225", true, false)
    EnsureClientConVar("cl_tfa_hud_crosshair_color_a", "200", true, false)
    EnsureClientConVar("cl_tfa_hud_crosshair_color_team", "1", true, false)

    EnsureClientConVar("cl_tfa_hud_crosshair_outline_color_r", "5", true, false)
    EnsureClientConVar("cl_tfa_hud_crosshair_outline_color_g", "5", true, false)
    EnsureClientConVar("cl_tfa_hud_crosshair_outline_color_b", "5", true, false)
    EnsureClientConVar("cl_tfa_hud_crosshair_outline_color_a", "200", true, false)
    EnsureClientConVar("cl_tfa_hud_crosshair_outline_width", "1", true, false)
    EnsureClientConVar("cl_tfa_hud_crosshair_outline_enabled", "1", true, false)

    EnsureClientConVar("cl_tfa_hud_hitmarker_enabled", "1", true, false)
    EnsureClientConVar("cl_tfa_hud_hitmarker_fadetime", "0.3", true, false)
    EnsureClientConVar("cl_tfa_hud_hitmarker_solidtime", "0.1", true, false)
    EnsureClientConVar("cl_tfa_hud_hitmarker_scale", "1", true, false)
    EnsureClientConVar("cl_tfa_hud_hitmarker_color_r", "225", true, false)
    EnsureClientConVar("cl_tfa_hud_hitmarker_color_g", "225", true, false)
    EnsureClientConVar("cl_tfa_hud_hitmarker_color_b", "225", true, false)
    EnsureClientConVar("cl_tfa_hud_hitmarker_color_a", "200", true, false)

    EnsureClientConVar("cl_tfa_hud_ammodata_fadein", "0.2", true, false)
    EnsureClientConVar("cl_tfa_hud_hangtime", "1", true, true)
    EnsureClientConVar("cl_tfa_hud_enabled", "1", true, false)
    EnsureClientConVar("cl_tfa_fx_gasblur", "0", true, true)
    EnsureClientConVar("cl_tfa_fx_muzzlesmoke", "1", true, true)
    EnsureClientConVar("cl_tfa_fx_ejectionsmoke", "1", true, true)
    EnsureClientConVar("cl_tfa_fx_impact_enabled", "1", true, true)

    EnsureClientConVar("cl_tfa_viewbob_drawing", "0", true, false)
    EnsureClientConVar("cl_tfa_viewbob_reloading", "1", true, false)

    EnsureClientConVar("cl_tfa_viewmodel_offset_x", "0", true, false)
    EnsureClientConVar("cl_tfa_viewmodel_offset_y", "0", true, false)
    EnsureClientConVar("cl_tfa_viewmodel_offset_z", "0", true, false)
    EnsureClientConVar("cl_tfa_viewmodel_offset_fov", "0", true, false)
    EnsureClientConVar("cl_tfa_viewmodel_multiplier_fov", "1", true, false)
    EnsureClientConVar("cl_tfa_viewmodel_flip", "0", true, false)
    EnsureClientConVar("cl_tfa_viewmodel_centered", "0", true, false)
    EnsureClientConVar("cl_tfa_debugcrosshair", "0", true, false)
end
