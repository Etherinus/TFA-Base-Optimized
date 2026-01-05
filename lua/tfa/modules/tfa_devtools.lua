if not CLIENT then return end

local GetConVar = GetConVar
local ScrW = ScrW
local ScrH = ScrH
local LocalPlayer = LocalPlayer
local IsValid = IsValid

local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawRect = surface.DrawRect
local color_white = color_white

local cv_dbc

hook.Add("HUDPaint", "tfa_debugcrosshair", function()
    cv_dbc = cv_dbc or GetConVar("cl_tfa_debugcrosshair")
    if not cv_dbc or not cv_dbc:GetBool() then
        return
    end

    local lp = LocalPlayer()
    if not IsValid(lp) or not lp:IsAdmin() then
        return
    end

    local w = ScrW()
    local h = ScrH()

    surface_SetDrawColor(color_white)
    surface_DrawRect(w * 0.5 - 1, h * 0.5 - 1, 2, 2)
end)
