if SERVER then
    util.AddNetworkString("tfaHitmarker")
else
    local lasthitmarkertime = -1
    local enabledcvar, solidtimecvar, fadetimecvar, scalecvar
    local rcvar, gcvar, bcvar, acvar
    local c = Color(255, 255, 255, 255)
    local spr

    net.Receive("tfaHitmarker", function()
        lasthitmarkertime = CurTime()
    end)

    hook.Add("HUDPaint", "tfaDrawHitmarker", function()
        if not enabledcvar then
            enabledcvar = GetConVar("cl_tfa_hud_hitmarker_enabled")
        end

        if enabledcvar and enabledcvar:GetBool() then
            if not spr then
                spr = Material("scope/hitmarker")
            end

            if not solidtimecvar then
                solidtimecvar = GetConVar("cl_tfa_hud_hitmarker_solidtime")
            end

            if not fadetimecvar then
                fadetimecvar = GetConVar("cl_tfa_hud_hitmarker_fadetime")
            end

            if not scalecvar then
                scalecvar = GetConVar("cl_tfa_hud_hitmarker_scale")
            end

            if not rcvar then
                rcvar = GetConVar("cl_tfa_hud_hitmarker_color_r")
            end

            if not gcvar then
                gcvar = GetConVar("cl_tfa_hud_hitmarker_color_g")
            end

            if not bcvar then
                bcvar = GetConVar("cl_tfa_hud_hitmarker_color_b")
            end

            if not acvar then
                acvar = GetConVar("cl_tfa_hud_hitmarker_color_a")
            end

            local solidtime = solidtimecvar:GetFloat()
            local fadetime = math.max(fadetimecvar:GetFloat(), 0.001)
            local scale = 0.025 * scalecvar:GetFloat()

            c.r = rcvar:GetFloat()
            c.g = gcvar:GetFloat()
            c.b = bcvar:GetFloat()

            local alpha = math.Clamp(lasthitmarkertime - CurTime() + solidtime + fadetime, 0, fadetime) / fadetime
            c.a = acvar:GetFloat() * alpha

            local w, h = ScrW(), ScrH()
            local sprw, sprh = h * scale, h * scale

            surface.SetDrawColor(c)
            surface.SetMaterial(spr)
            surface.DrawTexturedRect(w / 2 - sprw / 2, h / 2 - sprh / 2, sprw, sprh)
        end
    end)
end
