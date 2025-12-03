if CLIENT then
    local CreateClientConVar = CreateClientConVar
    local Material = Material
    local render_UpdateScreenEffectTexture = render.UpdateScreenEffectTexture
    local render_GetScreenEffectTexture = render.GetScreenEffectTexture
    local render_GetResolvedFullFrameDepth = render.GetResolvedFullFrameDepth
    local render_SetMaterial = render.SetMaterial
    local render_DrawScreenQuad = render.DrawScreenQuad
    local DrawColorModify = DrawColorModify
    local cam_IgnoreZ = cam.IgnoreZ
    local hook_Add = hook.Add
    local LocalPlayer = LocalPlayer
    local IsValid = IsValid

    local doblur = CreateClientConVar("cl_tfa_inspection_bokeh", 0, true, false)
    local tfablurintensity = 0
    local blur_mat = Material("pp/bokehblur")

    local colorTab = {
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"] = 1,
        ["$pp_colour_colour"] = 1,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    }

    local function MyDrawBokehDOF()
        if not doblur:GetBool() then
            return
        end

        render_UpdateScreenEffectTexture()
        blur_mat:SetTexture("$BASETEXTURE", render_GetScreenEffectTexture())
        blur_mat:SetTexture("$DEPTHTEXTURE", render_GetResolvedFullFrameDepth())
        blur_mat:SetFloat("$size", tfablurintensity * 6)
        blur_mat:SetFloat("$focus", 0)
        blur_mat:SetFloat("$focusradius", 0.1)

        render_SetMaterial(blur_mat)
        render_DrawScreenQuad()
    end

    hook_Add("PreDrawViewModel", "PreDrawViewModel_TFA_INSPECT", function(vm, ply, weapon)
        tfablurintensity = 0

        local lp = LocalPlayer()
        if not IsValid(lp) then
            return
        end

        local wep = lp:GetActiveWeapon()
        if not IsValid(wep) then
            return
        end

        tfablurintensity = wep.CLInspectingProgress or 0

        local its = tfablurintensity * 10
        if its > 0.01 then
            if doblur and doblur:GetBool() then
                MyDrawBokehDOF()
            end

            colorTab["$pp_colour_brightness"] = -tfablurintensity * 0.02
            colorTab["$pp_colour_contrast"] = 1 - tfablurintensity * 0.1

            DrawColorModify(colorTab)
            cam_IgnoreZ(true)
        end
    end)

    hook_Add("NeedsDepthPass", "NeedsDepthPass_TFA_Inspect", function()
        if not doblur:GetBool() then
            return
        end

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
