TFA = TFA or {}
TFA.Enum = TFA.Enum or {}
TFA.ENUM_COUNTER = TFA.ENUM_COUNTER or 0

local upper = string.upper
local ipairs = ipairs

local function gen(input)
    return "STATUS_" .. upper(tostring(input))
end

function TFA.AddStatus(input)
    local key = gen(input)

    if not TFA.Enum[key] then
        TFA.Enum[key] = TFA.ENUM_COUNTER
        TFA.ENUM_COUNTER = TFA.ENUM_COUNTER + 1
    end
end

function TFA.GetStatus(input)
    local key = gen(input)

    if not TFA.Enum[key] then
        TFA.AddStatus(input)
    end

    return TFA.Enum[key]
end

local statusList = {
    "idle",
    "draw",
    "holster",
    "holster_final",
    "holster_ready",
    "reloading",
    "reloading_wait",
    "reloading_shotgun_start",
    "reloading_shotgun_start_shell",
    "reloading_shotgun_loop",
    "reloading_shotgun_end",
    "shooting",
    "silencer_toggle",
    "bashing",
    "inspecting",
    "fidget",
    "pump",
    "grenade_pull",
    "grenade_ready",
    "grenade_throw"
}

for i = 1, #statusList do
    TFA.AddStatus(statusList[i])
end

TFA.Enum.HolsterStatus = {
    [TFA.Enum.STATUS_HOLSTER] = true,
    [TFA.Enum.STATUS_HOLSTER_FINAL] = true,
    [TFA.Enum.STATUS_HOLSTER_READY] = true
}

TFA.Enum.ReloadStatus = {
    [TFA.Enum.STATUS_RELOADING] = true,
    [TFA.Enum.STATUS_RELOADING_WAIT] = true,
    [TFA.Enum.STATUS_RELOADING_SHOTGUN_START] = true,
    [TFA.Enum.STATUS_RELOADING_SHOTGUN_LOOP] = true,
    [TFA.Enum.STATUS_RELOADING_SHOTGUN_END] = true
}

TFA.Enum.ReadyStatus = {
    [TFA.Enum.STATUS_IDLE] = true,
    [TFA.Enum.STATUS_INSPECTING] = true,
    [TFA.Enum.STATUS_FIDGET] = true
}

TFA.Enum.IronStatus = {
    [TFA.Enum.STATUS_IDLE] = true,
    [TFA.Enum.STATUS_SHOOTING] = true,
    [TFA.Enum.STATUS_PUMP] = true
}
