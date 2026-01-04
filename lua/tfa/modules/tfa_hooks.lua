local LocalPlayer = LocalPlayer
local IsValid = IsValid
local CurTime = CurTime
local GetConVar = GetConVar

local hook_Add = hook and hook.Add
local timer_Simple = timer and timer.Simple

local netTbl = net
local net_Start = netTbl and netTbl.Start
local net_SendToServer = netTbl and netTbl.SendToServer

local Lerp = Lerp

TFA = TFA or {}

local cachedPly
local cachedWep

local function UpdateBlockingState(plyv, wep)
    if not (IsValid(wep) and wep.IsTFAWeapon) then return end
    if not (wep.CanBlock and wep.SetBashImpulse and wep.GetBashImpulse) then return end

    local shouldBlock = plyv:KeyDown(IN_ATTACK2) and true or false
    if shouldBlock ~= wep:GetBashImpulse() then
        wep:SetBashImpulse(shouldBlock)
    end
end

if hook_Add then
    hook_Add("PlayerTick", "PlayerTickTFA", function(plyv)
        local wep = plyv:GetActiveWeapon()
        if not IsValid(wep) then return end

        local pt = wep.PlayerThink
        if pt then
            pt(wep, plyv)
        end

        UpdateBlockingState(plyv, wep)
    end)

    hook_Add("PreRender", "prerender_tfabase", function()
        if not IsValid(cachedPly) then
            cachedPly = LocalPlayer()
            return
        end

        cachedWep = cachedPly:GetActiveWeapon() or cachedWep
        if IsValid(cachedWep) and cachedWep.IsTFAWeapon and cachedWep.PlayerThinkCL then
            cachedWep:PlayerThinkCL(cachedPly)
        end
    end)

    hook_Add("AllowPlayerPickup", "TFAPickupDisable", function(plyv, ent)
        if not IsValid(plyv) then return end
        if plyv.SetNW2Entity then
            plyv:SetNW2Entity("LastHeldEntity", ent)
        elseif plyv.SetNWEntity then
            plyv:SetNWEntity("LastHeldEntity", ent)
        end
    end)
end

local cv_cm = GetConVar("sv_tfa_cmenu")
local cv_cci = CLIENT and GetConVar("cl_tfa_inspection_ckey") or nil

local function PlayerBindPress(plyv, bind, pressed)
    if not pressed or not IsValid(plyv) then return end

    local wep = plyv:GetActiveWeapon() or cachedWep
    if not IsValid(wep) then return end

    if wep.ToggleInspect and bind == "+menu_context" and cv_cm and cv_cm:GetBool() then
        if not (cv_cci and cv_cci:GetBool()) then
            wep:ToggleInspect()
        elseif wep.CheckAmmo and net_Start and net_SendToServer then
            net_Start("tfaRequestFidget")
            net_SendToServer()
        end
        return true
    end
end

if hook_Add then
    hook_Add("PlayerBindPress", "TFAInspectionMenu", PlayerBindPress)
end

local cv_lr = GetConVar("sv_tfa_reloads_legacy")

local function KeyPress(plyv, key)
    if key == IN_ZOOM then
        local wep = plyv:GetActiveWeapon()
        if IsValid(wep) and wep.AltAttack then
            wep:AltAttack()
        end
    end

    if key == IN_RELOAD then
        plyv.HasTFAAmmoChek = false
        plyv.LastReloadPressed = CurTime()
    end
end

if hook_Add then
    hook_Add("KeyPress", "TFABase_KP", KeyPress)
end

local reload_threshold = 0.3

local function KeyRelease(plyv, key)
    if key ~= IN_RELOAD then return end
    if not cv_lr then cv_lr = GetConVar("sv_tfa_reloads_legacy") end
    if cv_lr and cv_lr:GetBool() then return end

    if CurTime() <= (plyv.LastReloadPressed or 0) + reload_threshold then
        plyv.LastReloadPressed = nil
        plyv.HasTFAAmmoChek = false

        local wep = plyv:GetActiveWeapon()
        if IsValid(wep) and wep.IsTFAWeapon then
            wep:Reload(true)
        end
    end
end

if hook_Add then
    hook_Add("KeyRelease", "TFABase_KR", KeyRelease)
end

local function AmmoCheckThink(plyv)
    if plyv.HasTFAAmmoChek then return end

    if plyv:KeyDown(IN_RELOAD) and CurTime() > (plyv.LastReloadPressed or 0) + reload_threshold then
        local wep = plyv:GetActiveWeapon()
        if IsValid(wep) and wep.IsTFAWeapon and wep.CheckAmmo then
            plyv.HasTFAAmmoChek = true
            wep:CheckAmmo()
        end
    end
end

if hook_Add then
    hook_Add("PlayerTick", "TFABase_KD", AmmoCheckThink)
end

function TFA.ProcessBashZoom(plyv, wepv)
    if not IsValid(wepv) then
        plyv:SetCanZoom(true)
        return
    end

    if wepv.AltAttack then
        plyv:SetCanZoom(false)
    else
        plyv:SetCanZoom(true)
    end
end

local function SwitchWeaponFix(plyv)
    if not timer_Simple then return end
    timer_Simple(0, function()
        if IsValid(plyv) then
            TFA.ProcessBashZoom(plyv, plyv:GetActiveWeapon())
        end
    end)
end

if hook_Add then
    hook_Add("PlayerSwitchWeapon", "TFABashFixZoom", SwitchWeaponFix)

    hook_Add("PlayerSpawn", "TFAExtinguishQOL", function(plyv)
        if IsValid(plyv) and plyv:IsOnFire() then
            plyv:Extinguish()
            TFA.ProcessBashZoom(plyv, plyv:GetActiveWeapon())
        end
    end)
end

local cv_cmove = GetConVar("sv_tfa_compat_movement")
local sumwep
local speedmult

if not Clockwork and hook_Add then
    hook_Add("SetupMove", "tfa_setupmove", function(plyv, movedata, commanddata)
        if not cv_cmove then
            cv_cmove = GetConVar("sv_tfa_compat_movement")
        elseif cv_cmove:GetBool() then
            return
        end

        sumwep = plyv:GetActiveWeapon() or cachedWep
        if not (IsValid(sumwep) and sumwep.IsTFAWeapon) then return end

        local prog = sumwep.IronSightsProgress
        if prog == nil then
            prog = 0
            sumwep.IronSightsProgress = 0
        end

        local ms = sumwep.MoveSpeed or 1
        local isms = sumwep.IronSightsMoveSpeed or 1

        speedmult = Lerp(prog, ms, isms)

        movedata:SetMaxClientSpeed(movedata:GetMaxClientSpeed() * speedmult)
        commanddata:SetForwardMove(commanddata:GetForwardMove() * speedmult)
        commanddata:SetSideMove(commanddata:GetSideMove() * speedmult)
    end)
end

if hook_Add then
    hook_Add("PlayerFootstep", "tfa_playerfootstep", function(plyv)
        local isc, _, wepAct = TFA.PlayerCarryingTFAWeapon(plyv)
        if isc and CLIENT and wepAct and wepAct.Footstep then
            wepAct:Footstep()
        end
    end)
end

if CLIENT and hook_Add then
    local cv_he = GetConVar("cl_tfa_hud_enabled")
    local hide = {
        CHudAmmo = true,
        CHudSecondaryAmmo = true
    }

    hook_Add("HUDShouldDraw", "tfa_hidehud", function(name)
        if not hide[name] then return end
        if cv_he and not cv_he:GetBool() then return end

        local ictfa = TFA.PlayerCarryingTFAWeapon()
        if ictfa then
            return false
        end
    end)
end
