if CLIENT then
    local doblur = CreateClientConVar("cl_tfa_inspection_bokeh", 0, true, false)
    local tfablurintensity = 0
    local blur_mat = Material("pp/bokehblur")

    local colorTab = {
        ["$pp_colour_addr"]       = 0,
        ["$pp_colour_addg"]       = 0,
        ["$pp_colour_addb"]       = 0,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"]   = 1,
        ["$pp_colour_colour"]     = 1,
        ["$pp_colour_mulr"]       = 0,
        ["$pp_colour_mulg"]       = 0,
        ["$pp_colour_mulb"]       = 0
    }

    local function MyDrawBokehDOF()
        if not doblur:GetBool() then return end

        render.UpdateScreenEffectTexture()
        blur_mat:SetTexture("$BASETEXTURE", render.GetScreenEffectTexture())
        blur_mat:SetTexture("$DEPTHTEXTURE", render.GetResolvedFullFrameDepth())
        blur_mat:SetFloat("$size", tfablurintensity * 6)
        blur_mat:SetFloat("$focus", 0)
        blur_mat:SetFloat("$focusradius", 0.1)

        render.SetMaterial(blur_mat)
        render.DrawScreenQuad()
    end

    hook.Add("PreDrawViewModel", "PreDrawViewModel_TFA_INSPECT", function(vm, ply, weapon)
        tfablurintensity = 0
        local localPly = LocalPlayer()
        if not IsValid(localPly) then return end

        local wep = localPly:GetActiveWeapon()
        if not IsValid(wep) then return end

        tfablurintensity = wep.CLInspectingProgress or 0
        local its = tfablurintensity * 10

        if its > 0.01 then
            if doblur and doblur:GetBool() then
                MyDrawBokehDOF()
            end

            colorTab["$pp_colour_brightness"] = -tfablurintensity * 0.02
            colorTab["$pp_colour_contrast"]   = 1 - tfablurintensity * 0.1

            DrawColorModify(colorTab)
            cam.IgnoreZ(true)
        end
    end)

    hook.Add("NeedsDepthPass", "NeedsDepthPass_TFA_Inspect", function()
        if not doblur:GetBool() then return end

        if tfablurintensity > 0.01 then
            DOFModeHack(true)
            return true
        end
    end)
end

hook.Add("PreDrawOpaqueRenderables", "tfaweaponspredrawopaque", function()
    for _, pl in ipairs(player.GetAll()) do
        local wep = pl:GetActiveWeapon()
        if IsValid(wep) and wep.IsTFAWeapon and wep.PreDrawOpaqueRenderables then
            wep:PreDrawOpaqueRenderables()
        end
    end
end)
