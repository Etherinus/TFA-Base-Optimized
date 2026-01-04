if CLIENT then
    local CreateClientConVar = CreateClientConVar
    local Material = Material
    local render = render
    local DrawColorModify = DrawColorModify
    local cam = cam
    local hook_Add = hook and hook.Add
    local LocalPlayer = LocalPlayer
    local IsValid = IsValid
    local ipairs = ipairs
    local player_GetAll = player and player.GetAll

    if not hook_Add then
        return
    end

    local doblur = CreateClientConVar and CreateClientConVar("cl_tfa_inspection_bokeh", "0", true, false) or { GetBool = function() return false end }
    local tfablurintensity = 0
    local blur_mat = Material and Material("pp/bokehblur") or nil

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

    local function setIgnoreZ(on)
        if cam and cam.IgnoreZ then
            cam.IgnoreZ(on and true or false)
        end
    end

    local function MyDrawBokehDOF()
        if not (doblur and doblur.GetBool and doblur:GetBool()) then
            return
        end

        if not blur_mat then
            return
        end

        if not (render and render.UpdateScreenEffectTexture and render.GetScreenEffectTexture and render.SetMaterial and render.DrawScreenQuad) then
            return
        end

        render.UpdateScreenEffectTexture()

        local base = render.GetScreenEffectTexture()
        if base then
            blur_mat:SetTexture("$BASETEXTURE", base)
        end

        if render.GetResolvedFullFrameDepth then
            local depth = render.GetResolvedFullFrameDepth()
            if depth then
                blur_mat:SetTexture("$DEPTHTEXTURE", depth)
            end
        end

        blur_mat:SetFloat("$size", tfablurintensity * 6)
        blur_mat:SetFloat("$focus", 0)
        blur_mat:SetFloat("$focusradius", 0.1)

        render.SetMaterial(blur_mat)
        render.DrawScreenQuad()
    end

    hook_Add("PreDrawViewModel", "PreDrawViewModel_TFA_INSPECT", function()
        tfablurintensity = 0
        setIgnoreZ(false)

        local lp = LocalPlayer()
        if not IsValid(lp) then
            return
        end

        local wep = lp:GetActiveWeapon()
        if not IsValid(wep) then
            return
        end

        tfablurintensity = wep.CLInspectingProgress or 0
        if tfablurintensity <= 0.01 then
            return
        end

        if doblur and doblur.GetBool and doblur:GetBool() then
            MyDrawBokehDOF()
        end

        colorTab["$pp_colour_brightness"] = -tfablurintensity * 0.02
        colorTab["$pp_colour_contrast"] = 1 - tfablurintensity * 0.1

        if DrawColorModify then
            DrawColorModify(colorTab)
        end

        setIgnoreZ(true)
    end)

    hook_Add("NeedsDepthPass", "NeedsDepthPass_TFA_Inspect", function()
        if not (doblur and doblur.GetBool and doblur:GetBool()) then
            return
        end

        if tfablurintensity > 0.01 then
            if DOFModeHack then
                DOFModeHack(true)
            end
            return true
        end
    end)

    hook_Add("PreDrawOpaqueRenderables", "tfaweaponspredrawopaque", function()
        if not player_GetAll then
            return
        end

        for _, pl in ipairs(player_GetAll()) do
            local wep = IsValid(pl) and pl:GetActiveWeapon() or nil
            if IsValid(wep) and wep.IsTFAWeapon and wep.PreDrawOpaqueRenderables then
                wep:PreDrawOpaqueRenderables()
            end
        end
    end)
end
