if SERVER then
    local util_AddNetworkString = util and util.AddNetworkString
    if util_AddNetworkString then
        util_AddNetworkString("tfaHitmarker")
    end
    return
end

local CurTime = CurTime
local GetConVar = GetConVar
local ScrW = ScrW
local ScrH = ScrH

local math_max = math.max
local math_Clamp = math.Clamp

local Material = Material
local surface_SetDrawColor = surface.SetDrawColor
local surface_SetMaterial = surface.SetMaterial
local surface_DrawTexturedRect = surface.DrawTexturedRect

local hook_Add = hook and hook.Add
local net_Receive = net and net.Receive

local lastHit = -1

local cv_enabled
local cv_solid
local cv_fade
local cv_scale
local cv_r
local cv_g
local cv_b
local cv_a

local col = Color(255, 255, 255, 255)
local spr

if net_Receive then
    net_Receive("tfaHitmarker", function()
        lastHit = CurTime()
    end)
end

if hook_Add then
    hook_Add("HUDPaint", "tfaDrawHitmarker", function()
        if not cv_enabled then cv_enabled = GetConVar("cl_tfa_hud_hitmarker_enabled") end
        if not cv_enabled or not cv_enabled:GetBool() then return end

        if not spr then
            spr = Material("scope/hitmarker")
        end

        if not cv_solid then cv_solid = GetConVar("cl_tfa_hud_hitmarker_solidtime") end
        if not cv_fade then cv_fade = GetConVar("cl_tfa_hud_hitmarker_fadetime") end
        if not cv_scale then cv_scale = GetConVar("cl_tfa_hud_hitmarker_scale") end

        if not cv_r then cv_r = GetConVar("cl_tfa_hud_hitmarker_color_r") end
        if not cv_g then cv_g = GetConVar("cl_tfa_hud_hitmarker_color_g") end
        if not cv_b then cv_b = GetConVar("cl_tfa_hud_hitmarker_color_b") end
        if not cv_a then cv_a = GetConVar("cl_tfa_hud_hitmarker_color_a") end

        local solid = cv_solid and cv_solid:GetFloat() or 0.1
        local fade = cv_fade and cv_fade:GetFloat() or 0.3
        fade = math_max(fade, 0.001)

        local scaleMul = cv_scale and cv_scale:GetFloat() or 1
        local scale = 0.025 * scaleMul

        col.r = cv_r and cv_r:GetFloat() or 255
        col.g = cv_g and cv_g:GetFloat() or 255
        col.b = cv_b and cv_b:GetFloat() or 255

        local now = CurTime()
        local remain = (lastHit + solid + fade) - now
        if remain <= 0 then return end

        local alpha = math_Clamp(remain / fade, 0, 1)
        local baseA = cv_a and cv_a:GetFloat() or 200
        col.a = baseA * alpha

        if col.a <= 0 then return end

        local w = ScrW()
        local h = ScrH()

        local sz = h * scale

        surface_SetDrawColor(col)
        surface_SetMaterial(spr)
        surface_DrawTexturedRect(w * 0.5 - sz * 0.5, h * 0.5 - sz * 0.5, sz, sz)
    end)
end
