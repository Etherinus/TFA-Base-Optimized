TFA = TFA or {}

local hook_Add = hook.Add
local hook_Remove = hook.Remove
local hook_Run = hook.Run
local hook_Call = hook.Call
local LocalPlayer = LocalPlayer
local IsValid = IsValid
local typeFn = type

hook_Add("HUDPaint", "TFA_TRIGGERCLIENTLOAD", function()
    local lp = LocalPlayer()
    if not IsValid(lp) then return end

    if hook_Run then
        hook_Run("TFA_ClientLoad")
    else
        hook_Call("TFA_ClientLoad", GAMEMODE)
    end

    hook_Remove("HUDPaint", "TFA_TRIGGERCLIENTLOAD")
end)

local function safe_cb(cb, ...)
    if typeFn(cb) == "function" then
        cb(...)
    end
end

function TFA.GetGroupMembers(groupname, callback)
    safe_cb(callback, {})
end

function TFA.GetUserInGroup(groupname, steamid64, callback)
    safe_cb(callback, false)
end
