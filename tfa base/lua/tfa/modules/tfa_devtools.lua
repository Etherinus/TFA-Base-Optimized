local cv_dbc
local w, h
local lply

hook.Add("HUDPaint", "tfa_debugcrosshair", function()
    if not cv_dbc then
        cv_dbc = GetConVar("cl_tfa_debugcrosshair")
    end

    if not cv_dbc or not cv_dbc:GetBool() then return end

    if not w then
        w = ScrW()
    end

    if not h then
        h = ScrH()
    end

    if not IsValid(lply) then
        lply = LocalPlayer()
    end

    if not IsValid(lply) or not lply:IsAdmin() then return end

    surface.SetDrawColor(color_white)
    surface.DrawRect(w / 2 - 1, h / 2 - 1, 2, 2)
end)
