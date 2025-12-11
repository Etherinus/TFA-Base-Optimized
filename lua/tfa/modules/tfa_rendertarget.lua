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
    local pairs = pairs
    local hook_Add = hook.Add
    local render_PushRenderTarget = render.PushRenderTarget
    local render_Clear = render.Clear
    local render_PopRenderTarget = render.PopRenderTarget
    local render_RenderView = render.RenderView

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
    local rtRenderData = {}

    local function hasRTMaterial(elements)
        if not elements then
            return false
        end

        for _, v in pairs(elements) do
            if istable(v) and v.material == "!tfa_rtmaterial" then
                return true
            end
        end

        return false
    end

    local function weaponNeedsRT(wep)
        if wep._TFA_RTNeedsDraw ~= nil then
            return wep._TFA_RTNeedsDraw
        end

        local needs = wep.RTMaterialOverride ~= nil and wep.RTMaterialOverride ~= false
        if not needs and wep.Scoped_3D then
            needs = true
        end

        if not needs then
            needs = hasRTMaterial(wep.VElements) or hasRTMaterial(wep.WElements)
        end

        wep._TFA_RTNeedsDraw = needs

        return needs
    end

    local function ensureScopeFOV(wep)
        local zoom = wep.Secondary and wep.Secondary.ScopeZoom

        if zoom and zoom > 0 then
            local target = 90 / zoom

            if not wep.RTScopeFOV or math.abs(wep.RTScopeFOV - target) > 0.001 then
                wep.RTScopeFOV = target
            end
        elseif not wep.RTScopeFOV or wep.RTScopeFOV <= 0 then
            wep.RTScopeFOV = 10
        end

        return wep.RTScopeFOV
    end

    local function fallbackRTCode(self, rtMat, scrw, scrh)
        if not self:OwnerIsValid() then
            return
        end

        local owner = self:GetOwner()
        if not IsValid(owner) then
            return
        end

        ensureScopeFOV(self)

        if self.IronSightsProgress and self.IronSightsProgress <= 0.01 then
            render_Clear(0, 0, 0, 255, true, true)
            return
        end

        rtRenderData.angles = owner:EyeAngles()
        rtRenderData.origin = owner:GetShootPos()
        rtRenderData.x = 0
        rtRenderData.y = 0
        rtRenderData.w = 512
        rtRenderData.h = 512
        rtRenderData.fov = self.RTScopeFOV
        rtRenderData.drawviewmodel = false
        rtRenderData.drawhud = false

        render_RenderView(rtRenderData)
    end

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
            wep._TFA_RTNeedsDraw = nil
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

        if not weaponNeedsRT(wep) then
            TFA_RENDERSCREEN = false
            return
        end

        local rtFunc = wep.RTCode

        if not rtFunc and wep.BaseClass and isfunction(wep.BaseClass.RTCode) then
            rtFunc = wep.BaseClass.RTCode
        end

        rtFunc = rtFunc or fallbackRTCode
        ensureScopeFOV(wep)

        TFARefreshRT()
        oldVmModel = vm:GetModel()

        local scw = ScrW()
        local sch = ScrH()

        render_PushRenderTarget(TFA_RTScreen)
        render_Clear(0, 0, 0, 0, true, true)
        rtFunc(wep, TFA_RTMat, scw, sch)
        render_PopRenderTarget()

        TFA_RTMat:SetTexture("$basetexture", TFA_RTScreen)
        if wep.RTMaterialOverride and wep.RTMaterialOverride >= 0 then
            wep.Owner:GetViewModel():SetSubMaterial(wep.RTMaterialOverride, "!tfa_rtmaterial")
        end

        TFA_RENDERSCREEN = false
    end

    hook_Add("RenderScene", "TFASCREENS", TFARenderScreen)
end
