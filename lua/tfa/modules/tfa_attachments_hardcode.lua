local pairs = pairs
local ipairs = ipairs
local istable = istable
local isfunction = isfunction
local typeFn = type
local weapons = weapons
local table_Copy = table.Copy
local pcall = pcall

TFA = TFA or {}
TFA.INS2 = TFA.INS2 or {}

local defaultScopes = {
    "ins2_si_mx4",
    "ins2_si_mosin"
}

local ForceAttachment = {
    tfa_ins2_svu = "ins2_si_mosin",
    tfa_ins2_svd = "ins2_si_mosin"
}

local attachmentCorrectionsPre = {}

local attachmentCorrections = {
    ins2_si_eotech = { VElements = { sight_eotech = { active = true } } },
    ins2_si_kobra = { VElements = { sight_kobra = { active = true } } },
    ins2_si_rds = { VElements = { sight_rds = { active = true } } },
    ins2_si_2xrds = { VElements = { scope_2xrds = { active = true } } },
    ins2_si_c79 = { VElements = { scope_c79 = { active = true } } },
    ins2_si_po4x = { VElements = { scope_po4x = { active = true } } },
    ins2_si_mx4 = { VElements = { scope_mx4 = { active = true } } },
    ins2_si_mosin = { VElements = { scope_mosin = { active = true } } }
}

local defaultValue = {
    IronFOV = 70,
    IronSightMoveSpeed = 0.9,
    RTScopeFOV = 6
}

function TFA.INS2.AnimateSight()
end

local function ApplyWeaponTableRecursive(source, target, wep)
    if not source or not target then return end

    for k, v in pairs(source) do
        if istable(v) then
            local tv = target[k]
            if not istable(tv) then
                tv = {}
                target[k] = tv
            end
            ApplyWeaponTableRecursive(v, tv, wep)
        elseif not isfunction(v) then
            local tv = target[k]
            if tv == nil or typeFn(tv) == typeFn(v) then
                target[k] = v
            end
        end
    end

    for k, v in pairs(source) do
        if isfunction(v) then
            local ent = wep or target
            local ok, val = pcall(v, ent, target[k] or defaultValue[k])
            if ok and typeFn(val) ~= "function" then
                target[k] = val
            end
        end
    end
end

function TFAApplyAttachment(attName, wep)
    if not attName or not wep then return end

    local atts = TFA.Attachments and TFA.Attachments.Atts
    if not atts then return end

    local attachment = atts[attName]
    if not attachment then return end

    local pre = attachmentCorrectionsPre[attName]
    if pre then
        ApplyWeaponTableRecursive(pre, wep, wep)
    end

    local attachFn = attachment.Attach
    if attachFn then
        local copy = table_Copy and table_Copy(attachment) or attachment
        attachFn(copy, wep)
    end

    local wt = attachment.WeaponTable
    if wt then
        ApplyWeaponTableRecursive(wt, wep, wep)
    end

    local post = attachmentCorrections[attName]
    if post then
        ApplyWeaponTableRecursive(post, wep, wep)
    end
end

function TFASelectAttachment(wepClass, attachments)
    if not attachments or not attachments.atts then return end

    local atts = attachments.atts
    local indexByName = {}

    for i = 1, #atts do
        indexByName[atts[i]] = i
    end

    local sel

    for i = 1, #defaultScopes do
        local idx = indexByName[defaultScopes[i]]
        if idx then
            sel = idx
            break
        end
    end

    local forced = ForceAttachment[wepClass]
    if forced then
        local idx = indexByName[forced]
        if idx then
            sel = idx
        end
    end

    if sel then
        attachments.sel = sel
    end
end

function TFAApplyAttachmentOuter(wep)
    if not wep or not wep.Attachments then return end

    local className = wep.ClassName or ""
    if not weapons.IsBasedOn(className, "tfa_gun_base") then return end

    for _, attachmentSlot in pairs(wep.Attachments) do
        TFASelectAttachment(className, attachmentSlot)

        local sel = attachmentSlot.sel
        local atts = attachmentSlot.atts
        if sel and atts and sel >= 1 then
            local attName = atts[sel]
            if attName then
                TFAApplyAttachment(attName, wep)
            end
        end
    end
end
