if SERVER then
    util.AddNetworkString("tfaHitmarker")
else
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

    local lasthitmarkertime = -1
    local enabledcvar
    local solidtimecvar
    local fadetimecvar
    local scalecvar
    local rcvar
    local gcvar
    local bcvar
    local acvar

    local c = Color(255, 255, 255, 255)
    local spr

    net.Receive("tfaHitmarker", function()
        lasthitmarkertime = CurTime()
    end)

    hook.Add("HUDPaint", "tfaDrawHitmarker", function()
        enabledcvar = enabledcvar or GetConVar("cl_tfa_hud_hitmarker_enabled")

        if not enabledcvar or not enabledcvar:GetBool() then
            return
        end

        if not spr then
            spr = Material("scope/hitmarker")
        end

        solidtimecvar = solidtimecvar or GetConVar("cl_tfa_hud_hitmarker_solidtime")
        fadetimecvar = fadetimecvar or GetConVar("cl_tfa_hud_hitmarker_fadetime")
        scalecvar = scalecvar or GetConVar("cl_tfa_hud_hitmarker_scale")

        rcvar = rcvar or GetConVar("cl_tfa_hud_hitmarker_color_r")
        gcvar = gcvar or GetConVar("cl_tfa_hud_hitmarker_color_g")
        bcvar = bcvar or GetConVar("cl_tfa_hud_hitmarker_color_b")
        acvar = acvar or GetConVar("cl_tfa_hud_hitmarker_color_a")

        local solidtime = solidtimecvar:GetFloat()
        local fadetime = math_max(fadetimecvar:GetFloat(), 0.001)
        local scale = 0.025 * scalecvar:GetFloat()

        c.r = rcvar:GetFloat()
        c.g = gcvar:GetFloat()
        c.b = bcvar:GetFloat()

        local alpha = math_Clamp(lasthitmarkertime - CurTime() + solidtime + fadetime, 0, fadetime) / fadetime
        c.a = acvar:GetFloat() * alpha

        if c.a <= 0 then
            return
        end

        local w = ScrW()
        local h = ScrH()

        local sprw = h * scale
        local sprh = h * scale

        surface_SetDrawColor(c)
        surface_SetMaterial(spr)
        surface_DrawTexturedRect(w * 0.5 - sprw * 0.5, h * 0.5 - sprh * 0.5, sprw, sprh)
    end)
end
