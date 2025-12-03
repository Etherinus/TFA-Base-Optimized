local onevec = Vector(1, 1, 1)

local function RBP(vm)
    local bc = vm:GetBoneCount()
    if not bc or bc <= 0 then
        return
    end

    for i = 0, bc - 1 do
        vm:ManipulateBoneScale(i, onevec)
        vm:ManipulateBoneAngles(i, angle_zero)
        vm:ManipulateBonePosition(i, vector_origin)
    end
end

if CLIENT then
    local CreateMaterial = CreateMaterial
    local GetRenderTarget = GetRenderTarget
    local ScrW = ScrW
    local ScrH = ScrH
    local GetViewEntity = GetViewEntity
    local LocalPlayer = LocalPlayer
    local IsValid = IsValid
    local hook_Add = hook.Add
    local render_PushRenderTarget = render.PushRenderTarget
    local render_Clear = render.Clear
    local render_PopRenderTarget = render.PopRenderTarget

    local props = {
        ["$translucent"] = 1
    }

    local TFA_RTMat = CreateMaterial("tfa_rtmaterial", "UnLitGeneric", props)
    local TFA_RTScreen = GetRenderTarget("TFA_RT_Screen", 512, 512)
    local oldVmModel = ""
    local oldWep

    local ply
    local vm
    local wep

    function TFARefreshRT()
        if not TFA_RTScreen then
            TFA_RTScreen = GetRenderTarget("TFA_RT_Screen", 512, 512)
            print("warning: TFA RT was nil")
        end

        if TFA_RTScreen:Width() ~= 512 or TFA_RTScreen:Height() ~= 512 then
            TFA_RTScreen = GetRenderTarget("TFA_RT_Screen" .. CurTime(), 512, 512)

            if TFA_RTScreen:Width() ~= 512 then
                TFA_RTScreen = GetRenderTarget("TFA_RT_Screen" .. CurTime(), 256, 256)
                print("warning: tfa rt re-patched to 256")
            end

            print("warning: tfa rt re-patched")
        end
    end

    TFA_RENDERSCREEN = false

    local function TFARenderScreen()
        if TFA_RENDERSCREEN then
            return
        end

        TFA_RENDERSCREEN = true

        ply = GetViewEntity()
        if not IsValid(ply) or not ply:IsPlayer() then
            ply = LocalPlayer()
            TFA_RENDERSCREEN = false
            return
        end

        vm = ply:GetViewModel()
        if not IsValid(vm) then
            TFA_RENDERSCREEN = false
            return
        end

        wep = ply:GetActiveWeapon()
        if not (IsValid(wep) and wep.IsTFAWeapon) then
            TFA_RENDERSCREEN = false
            return
        end

        if oldVmModel ~= vm:GetModel() or wep ~= oldWep then
            if IsValid(oldWep) then
                oldWep.MaterialCached = nil
            end

            oldWep = wep
            RBP(vm)
            vm:SetSubMaterial()
            vm:SetSkin(0)

            oldVmModel = vm:GetModel()
            TFA_RENDERSCREEN = false
            return
        end

        if not IsValid(wep) then
            TFA_RENDERSCREEN = false
            return
        end

        if wep.Skin and isnumber(wep.Skin) then
            vm:SetSkin(wep.Skin)
            wep:SetSkin(wep.Skin)
        end

        if wep.MaterialTable and not wep.MaterialCached then
            wep.MaterialCached = {}

            if #wep.MaterialTable >= 1 and #wep:GetMaterials() <= 1 then
                wep:SetMaterial(wep.MaterialTable[1])
            else
                wep:SetMaterial("")
            end

            wep:SetSubMaterial(nil, nil)
            vm:SetSubMaterial(nil, nil)

            for k, v in ipairs(wep.MaterialTable) do
                if not wep.MaterialCached[k] then
                    wep.MaterialCached[k] = true
                    vm:SetSubMaterial(k - 1, v)
                end
            end
        end

        if not wep.RTMaterialOverride or not wep.RTCode then
            TFA_RENDERSCREEN = false
            return
        end

        TFARefreshRT()
        oldVmModel = vm:GetModel()

        local scw = ScrW()
        local sch = ScrH()

        render_PushRenderTarget(TFA_RTScreen)
        render_Clear(0, 0, 0, 0, true, true)
        wep:RTCode(TFA_RTMat, scw, sch)
        render_PopRenderTarget()

        TFA_RTMat:SetTexture("$basetexture", TFA_RTScreen)
        wep.Owner:GetViewModel():SetSubMaterial(wep.RTMaterialOverride, "!tfa_rtmaterial")

        TFA_RENDERSCREEN = false
    end

    hook_Add("RenderScene", "TFASCREENS", TFARenderScreen)
end
