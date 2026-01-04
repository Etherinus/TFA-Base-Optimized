if SERVER then AddCSLuaFile() end

SWEP.Base = "tfa_bash_base"
DEFINE_BASECLASS(SWEP.Base)

local GetConVar = GetConVar
local IsValid = IsValid
local FrameTime = FrameTime

local math_Clamp = math.Clamp
local math_sqrt = math.sqrt
local math_Approach = math.Approach

local timer_Simple = timer.Simple
local pairs = pairs

SWEP.Secondary = SWEP.Secondary or {}
SWEP.ScopeAngleTransforms = SWEP.ScopeAngleTransforms or {}
SWEP.ScopeOverlayTransforms = SWEP.ScopeOverlayTransforms or { 0, 0 }
SWEP.ScopeReticule_Scale = SWEP.ScopeReticule_Scale or { 1, 1 }

SWEP.Secondary.ScopeZoom = 1
SWEP.Secondary.UseACOG = false
SWEP.Secondary.UseMilDot = false
SWEP.Secondary.UseSVD = false
SWEP.Secondary.UseParabolic = false
SWEP.Secondary.UseElcan = false
SWEP.Secondary.UseGreenDuplex = false

SWEP.RTScopeFOV = 6
SWEP.Scoped = false
SWEP.BoltAction = false
SWEP.ScopeOverlayTransformMultiplier = 0.8
SWEP.RTMaterialOverride = 1
SWEP.IronSightsSensitivity = 1
SWEP.ScopeShadow = nil
SWEP.ScopeReticule = nil
SWEP.ScopeDirt = nil
SWEP.ScopeReticule_CrossCol = false
SWEP.Scoped_3D = true
SWEP.BoltAction_3D = false
SWEP.RTOpaque = true

local cv_3dscope = GetConVar("cl_tfa_3dscope")
local cv_3dscope_overlay = GetConVar("cl_tfa_3dscope_overlay")
local cv_fov = GetConVar("fov_desired")

function SWEP:Do3DScope()
    if cv_3dscope then
        return cv_3dscope:GetBool()
    end

    if self:OwnerIsValid() and self.Owner and self.Owner.GetInfoNum then
        return self.Owner:GetInfoNum("cl_tfa_3dscope", 1) == 1
    end

    return true
end

function SWEP:Do3DScopeOverlay()
    if cv_3dscope_overlay then
        return cv_3dscope_overlay:GetBool()
    end

    return false
end

function SWEP:UpdateScopeType()
    if self:Do3DScope() then
        self.Scoped = false
        self.Scoped_3D = true

        local sec = self.Secondary or {}
        self.Secondary = sec

        if sec.ScopeZoom_Backup == nil then
            sec.ScopeZoom_Backup = sec.ScopeZoom
        end

        if self.BoltAction then
            self.BoltAction_3D = true
            self.BoltAction = self.BoltAction_Forced or false
            self.DisableChambering = true
            self.FireModeName = "BOLT-ACTION"
        end

        if sec.ScopeZoom and sec.ScopeZoom > 0 then
            self.RTScopeFOV = 90 / sec.ScopeZoom
            self.IronSightsSensitivity = math_sqrt(1 / sec.ScopeZoom)
            sec.ScopeZoom = nil
            sec.IronFOV_Backup = sec.IronFOV
            sec.IronFOV = 70
        end
    else
        self.Scoped = true
        self.Scoped_3D = false

        local sec = self.Secondary or {}
        self.Secondary = sec

        if sec.ScopeZoom_Backup then
            sec.ScopeZoom = sec.ScopeZoom_Backup
        else
            sec.ScopeZoom = 4
        end

        if self.BoltAction_3D then
            self.BoltAction = true
            self.BoltAction_3D = nil
        end

        sec.IronFOV = 90 / sec.ScopeZoom
        self.IronSightsSensitivity = 1
    end

    if cv_fov then
        self.DefaultFOV = cv_fov:GetFloat()
    elseif self.Owner and self:OwnerIsValid() then
        self.DefaultFOV = self.Owner.GetInfoNum and self.Owner:GetInfoNum("fov_desired", 90) or 90
    end
end

local function scheduleScopeUpdate(self)
    timer_Simple(0, function()
        if not IsValid(self) or not self.OwnerIsValid or not self:OwnerIsValid() then
            return
        end

        self:UpdateScopeType()

        if SERVER then
            self:CallOnClient("UpdateScopeType", "")
        end
    end)
end

function SWEP:Initialize()
    self:UpdateScopeType()
    scheduleScopeUpdate(self)
    BaseClass.Initialize(self)
end

function SWEP:Deploy(...)
    if SERVER and self:OwnerIsValid() then
        self:CallOnClient("UpdateScopeType", "")
    end

    self:UpdateScopeType()
    scheduleScopeUpdate(self)

    return BaseClass.Deploy(self, ...)
end

if CLIENT then
    local surface = surface
    local render = render
    local cam = cam
    local draw = draw

    local Color = Color
    local Material = Material
    local EyeAngles = EyeAngles

    local surface_GetTextureID = surface.GetTextureID
    local surface_SetDrawColor = surface.SetDrawColor
    local surface_SetMaterial = surface.SetMaterial
    local surface_SetTexture = surface.SetTexture
    local surface_DrawRect = surface.DrawRect
    local surface_DrawTexturedRect = surface.DrawTexturedRect
    local surface_DrawTexturedRectUV = surface.DrawTexturedRectUV
    local draw_NoTexture = draw.NoTexture

    local render_Clear = render.Clear
    local render_SetScissorRect = render.SetScissorRect
    local render_RenderView = render.RenderView
    local render_OverrideAlphaWriteEnable = render.OverrideAlphaWriteEnable

    local cam_Start2D = cam.Start2D
    local cam_End2D = cam.End2D

    local cv_flip = GetConVar("cl_tfa_viewmodel_flip")

    local cv_cc_r = GetConVar("cl_tfa_hud_crosshair_color_r")
    local cv_cc_g = GetConVar("cl_tfa_hud_crosshair_color_g")
    local cv_cc_b = GetConVar("cl_tfa_hud_crosshair_color_b")
    local cv_cc_a = GetConVar("cl_tfa_hud_crosshair_color_a")

    local cd = {}
    local crosscol = Color(255, 255, 255, 255)

    SWEP.RTCode = function(self, rt, scrw, scrh)
        if not self:VMIV() then
            return
        end

        local owner = self:GetOwner()
        if not IsValid(owner) then
            return
        end

        local vm = self.OwnerViewModel
        if not IsValid(vm) then
            vm = owner:GetViewModel()
            self.OwnerViewModel = vm
        end

        if not IsValid(vm) then
            return
        end

        if not self.myshadowmask then
            self.myshadowmask = surface_GetTextureID(self.ScopeShadow or "vgui/scope_shadowmask_test")
        end

        if not self.myreticule then
            self.myreticule = Material(self.ScopeReticule or "scope/gdcw_scopesightonly")
        end

        if not self.mydirt then
            self.mydirt = Material(self.ScopeDirt or "vgui/scope_dirt")
        end

        if not self.LastOwnerPos then
            self.LastOwnerPos = owner:GetShootPos()
        end

        local shootPos = owner:GetShootPos()
        local owoff = shootPos - self.LastOwnerPos
        self.LastOwnerPos = shootPos

        local att = vm:GetAttachment(3)
        if not att then
            return
        end

        local pos = att.Pos - owoff
        local scrpos = pos:ToScreen()

        scrpos.x = scrpos.x - scrw * 0.5 + (self.ScopeOverlayTransforms[1] or 0)
        scrpos.y = scrpos.y - scrh * 0.5 + (self.ScopeOverlayTransforms[2] or 0)

        scrpos.x = math_Clamp(scrpos.x, -1024, 1024) * (self.ScopeOverlayTransformMultiplier or 0.8)
        scrpos.y = math_Clamp(scrpos.y, -1024, 1024) * (self.ScopeOverlayTransformMultiplier or 0.8)

        if not self.scrpos then
            self.scrpos = { x = scrpos.x, y = scrpos.y }
        end

        local s = self.scrpos
        s.x = math_Approach(s.x, scrpos.x, (scrpos.x - s.x) * FrameTime() * 10)
        s.y = math_Approach(s.y, scrpos.y, (scrpos.y - s.y) * FrameTime() * 10)
        scrpos = s

        render_OverrideAlphaWriteEnable(true, true)
        surface_SetDrawColor(255, 255, 255, 255)
        surface_DrawRect(-512, -512, 1024, 1024)

        local ang = EyeAngles()
        local angPos = vm:GetAttachment(3)
        if angPos then
            ang = angPos.Ang

            if cv_flip and cv_flip:GetBool() then
                ang.y = -ang.y
            end

            for _, v in pairs(self.ScopeAngleTransforms or {}) do
                local axis = v and v[1]
                local deg = v and v[2]
                if axis == "P" then
                    ang:RotateAroundAxis(ang:Right(), deg)
                elseif axis == "Y" then
                    ang:RotateAroundAxis(ang:Up(), deg)
                elseif axis == "R" then
                    ang:RotateAroundAxis(ang:Forward(), deg)
                end
            end
        end

        cd.angles = ang
        cd.origin = shootPos
        cd.x = 0
        cd.y = 0

        local scopeOffset = self.RTScopeOffset or { 0, 0 }
        local scopeScale = self.RTScopeScale or { 1, 1 }

        local rtow, rtoh = scopeOffset[1] or 0, scopeOffset[2] or 0
        local rtw, rth = 512 * (scopeScale[1] or 1), 512 * (scopeScale[2] or 1)

        cd.w = rtw
        cd.h = rth
        cd.fov = self.RTScopeFOV or 10
        cd.drawviewmodel = false
        cd.drawhud = false

        render_Clear(0, 0, 0, 255, true, true)
        render_SetScissorRect(rtow, rtoh, rtw + rtow, rth + rtoh, true)

        if (self.IronSightsProgress or 0) > 0.01 and self.Scoped_3D then
            render_RenderView(cd)
        end

        render_SetScissorRect(0, 0, rtw, rth, false)
        render_OverrideAlphaWriteEnable(false, true)

        cam_Start2D()
        draw_NoTexture()

        surface_SetTexture(self.myshadowmask)
        surface_SetDrawColor(255, 255, 255, 255)

        if self:Do3DScopeOverlay() then
            surface_DrawTexturedRect(scrpos.x + rtow - rtw * 0.5, scrpos.y + rtoh - rth * 0.5, rtw * 2, rth * 2)
        end

        if self.ScopeReticule_CrossCol and cv_cc_r and cv_cc_g and cv_cc_b and cv_cc_a then
            crosscol.r = cv_cc_r:GetFloat()
            crosscol.g = cv_cc_g:GetFloat()
            crosscol.b = cv_cc_b:GetFloat()
            crosscol.a = cv_cc_a:GetFloat()
            surface_SetDrawColor(crosscol)
        else
            surface_SetDrawColor(255, 255, 255, 255)
        end

        surface_SetMaterial(self.myreticule)

        local retScale = self.ScopeReticule_Scale or { 1, 1 }
        local tmpborderw = rtw * (1 - (retScale[1] or 1)) * 0.5
        local tmpborderh = rth * (1 - (retScale[2] or 1)) * 0.5

        surface_DrawTexturedRect(rtow + tmpborderw, rtoh + tmpborderh, rtw - tmpborderw * 2, rth - tmpborderh * 2)

        surface_SetDrawColor(0, 0, 0, 255)
        draw_NoTexture()

        if self:Do3DScopeOverlay() then
            surface_DrawRect(scrpos.x - 2048 + rtow, -1024 + rtoh, 2048, 2048)
            surface_DrawRect(scrpos.x + rtw + rtow, -1024 + rtoh, 2048, 2048)
            surface_DrawRect(-1024 + rtow, scrpos.y - 2048 + rtoh, 2048, 2048)
            surface_DrawRect(-1024 + rtow, scrpos.y + rth + rtoh, 2048, 2048)
        end

        local isp = self.IronSightsProgress or 0
        local fade = math_Clamp((math_Clamp(isp - 0.75, 0, 0.25) * 4), 0, 1)
        local blackAlpha = math_Clamp(255 - 255 * fade, 0, 255)
        surface_SetDrawColor(0, 0, 0, blackAlpha)
        surface_DrawRect(-1024 + rtow, -1024 + rtoh, 2048, 2048)

        surface_SetMaterial(self.mydirt)
        surface_SetDrawColor(255, 255, 255, 128)
        surface_DrawTexturedRect(0, 0, rtw, rth)

        surface_SetDrawColor(255, 255, 255, 64)
        surface_DrawTexturedRectUV(rtow, rtoh, rtw, rth, 2, 0, 0, 2)

        cam_End2D()
    end
end
