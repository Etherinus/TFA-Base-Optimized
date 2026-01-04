local Vector = Vector
local angle_zero = angle_zero
local vector_origin = vector_origin
local istable = istable
local isnumber = isnumber
local isfunction = isfunction
local ipairs = ipairs
local pairs = pairs
local CurTime = CurTime
local print = print
local math_abs = math.abs

local onevec = Vector and Vector(1, 1, 1) or nil

local function RBP(vm)
    if not (vm and vm.GetBoneCount and vm.ManipulateBoneScale and vm.ManipulateBoneAngles and vm.ManipulateBonePosition) then
        return
    end

    local bc = vm:GetBoneCount()
    if not bc or bc <= 0 then
        return
    end

    for i = 0, bc - 1 do
        if onevec then
            vm:ManipulateBoneScale(i, onevec)
        end
        if angle_zero then
            vm:ManipulateBoneAngles(i, angle_zero)
        end
        if vector_origin then
            vm:ManipulateBonePosition(i, vector_origin)
        end
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
    local hook_Add = hook and hook.Add
    local render_PushRenderTarget = render and render.PushRenderTarget
    local render_Clear = render and render.Clear
    local render_PopRenderTarget = render and render.PopRenderTarget
    local render_RenderView = render and render.RenderView

    if not (CreateMaterial and GetRenderTarget and hook_Add and render_PushRenderTarget and render_Clear and render_PopRenderTarget and render_RenderView) then
        return
    end

    local function ClearSubMaterials(ent)
        if not (IsValid(ent) and ent.SetSubMaterial and ent.GetMaterials) then
            return
        end

        local mats = ent:GetMaterials()
        local count = mats and #mats or 0
        for i = 0, count - 1 do
            ent:SetSubMaterial(i, nil)
        end
    end

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

    local function weaponNeedsRT(wepobj)
        if wepobj._TFA_RTNeedsDraw ~= nil then
            return wepobj._TFA_RTNeedsDraw
        end

        local needs = wepobj.RTMaterialOverride ~= nil and wepobj.RTMaterialOverride ~= false
        if not needs and wepobj.Scoped_3D then
            needs = true
        end

        if not needs then
            needs = hasRTMaterial(wepobj.VElements) or hasRTMaterial(wepobj.WElements)
        end

        wepobj._TFA_RTNeedsDraw = needs
        return needs
    end

    local function ensureScopeFOV(wepobj)
        local zoom = wepobj.Secondary and wepobj.Secondary.ScopeZoom

        if zoom and zoom > 0 then
            local target = 90 / zoom
            if not wepobj.RTScopeFOV or math_abs(wepobj.RTScopeFOV - target) > 0.001 then
                wepobj.RTScopeFOV = target
            end
        elseif not wepobj.RTScopeFOV or wepobj.RTScopeFOV <= 0 then
            wepobj.RTScopeFOV = 10
        end

        return wepobj.RTScopeFOV
    end

    local function fallbackRTCode(self, rtMat, scrw, scrh)
        if self.OwnerIsValid and not self:OwnerIsValid() then
            return
        end

        local owner = self.GetOwner and self:GetOwner() or self.Owner
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
        if not (IsValid(ply) and ply.IsPlayer and ply:IsPlayer()) then
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

        local vmModel = vm.GetModel and vm:GetModel() or ""
        if oldVmModel ~= vmModel or wep ~= oldWep then
            if IsValid(oldWep) then
                oldWep.MaterialCached = nil
            end

            oldWep = wep
            wep._TFA_RTNeedsDraw = nil

            RBP(vm)

            if vm.SetMaterial then
                vm:SetMaterial("")
            end
            ClearSubMaterials(vm)

            if vm.SetSkin then
                vm:SetSkin(0)
            end

            oldVmModel = vmModel
            TFA_RENDERSCREEN = false
            return
        end

        if wep.Skin and isnumber(wep.Skin) and vm.SetSkin and wep.SetSkin then
            vm:SetSkin(wep.Skin)
            wep:SetSkin(wep.Skin)
        end

        if wep.MaterialTable and not wep.MaterialCached then
            wep.MaterialCached = {}

            if wep.SetMaterial and wep.GetMaterials then
                local mats = wep:GetMaterials()
                local mcount = mats and #mats or 0
                if #wep.MaterialTable >= 1 and mcount <= 1 then
                    wep:SetMaterial(wep.MaterialTable[1] or "")
                else
                    wep:SetMaterial("")
                end
            end

            ClearSubMaterials(wep)
            ClearSubMaterials(vm)

            if vm.SetSubMaterial then
                for k, v in ipairs(wep.MaterialTable) do
                    if not wep.MaterialCached[k] then
                        wep.MaterialCached[k] = true
                        vm:SetSubMaterial(k - 1, v)
                    end
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
        oldVmModel = vmModel

        local scw = ScrW()
        local sch = ScrH()

        render_PushRenderTarget(TFA_RTScreen)
        render_Clear(0, 0, 0, 0, true, true)
        rtFunc(wep, TFA_RTMat, scw, sch)
        render_PopRenderTarget()

        if TFA_RTMat and TFA_RTMat.SetTexture then
            TFA_RTMat:SetTexture("$basetexture", TFA_RTScreen)
        end

        local override = wep.RTMaterialOverride
        if override and override >= 0 then
            if vm.SetSubMaterial then
                vm:SetSubMaterial(override, "!tfa_rtmaterial")
            end
        end

        TFA_RENDERSCREEN = false
    end

    hook_Add("RenderScene", "TFASCREENS", TFARenderScreen)
end
