local string = string
local math = math
local table = table
local ipairs = ipairs
local http = http
local hook = hook
local CurTime = CurTime
local IsValid = IsValid
local LocalPlayer = LocalPlayer

hook.Add("HUDPaint", "TFA_TRIGGERCLIENTLOAD", function()
    if IsValid(LocalPlayer()) then
        hook.Call("TFA_ClientLoad")
        hook.Remove("HUDPaint", "TFA_TRIGGERCLIENTLOAD")
    end
end)

local function noop_callback(cb, ...)
    if type(cb) == "function" then
        cb(...)
    end
end

function TFA.GetGroupMembers(groupname, callback)
    noop_callback(callback, {})
end

function TFA.GetUserInGroup(groupname, steamid64, callback)
    noop_callback(callback, false)
end
