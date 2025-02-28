local pairs = pairs
local ipairs = ipairs
local istable = istable
local isfunction = isfunction
local type = type
local weapons = weapons

TFA.INS2 = TFA.INS2 or {}

local defaultScopes = {
    "ins2_si_mx4",
    "ins2_si_mosin"
}

local ForceAttachment = {
    ["tfa_ins2_svu"] = "ins2_si_mosin",
    ["tfa_ins2_svd"] = "ins2_si_mosin"
}

local attachmentCorrectionsPre = {}

local attachmentCorrections = {
    ["ins2_si_eotech"] = {
        ["VElements"] = {
            ["sight_eotech"] = { ["active"] = true }
        }
    },
    ["ins2_si_kobra"] = {
        ["VElements"] = {
            ["sight_kobra"] = { ["active"] = true }
        }
    },
    ["ins2_si_rds"] = {
        ["VElements"] = {
            ["sight_rds"] = { ["active"] = true }
        }
    },
    ["ins2_si_2xrds"] = {
        ["VElements"] = {
            ["scope_2xrds"] = { ["active"] = true }
        }
    },
    ["ins2_si_c79"] = {
        ["VElements"] = {
            ["scope_c79"] = { ["active"] = true }
        }
    },
    ["ins2_si_po4x"] = {
        ["VElements"] = {
            ["scope_po4x"] = { ["active"] = true }
        }
    },
    ["ins2_si_mx4"] = {
        ["VElements"] = {
            ["scope_mx4"] = { ["active"] = true }
        }
    },
    ["ins2_si_mosin"] = {
        ["VElements"] = {
            ["scope_mosin"] = { ["active"] = true }
        }
    }
}

local defaultValue = {
    ["IronFOV"] = 70,
    ["IronSightMoveSpeed"] = 0.9,
    ["RTScopeFOV"] = 6
}

function TFA.INS2.AnimateSight()

end

local function ApplyWeaponTableRecursive(source, target, wepom)
    if not source or not target then return end

    for k, v in pairs(source) do
        if istable(v) then
            target[k] = target[k] or {}
            ApplyWeaponTableRecursive(v, target[k], wepom)
        elseif target[k] == nil then
            target[k] = v
        elseif type(target[k]) == type(v) then
            target[k] = v
        end
    end

    for k, v in pairs(source) do
        if isfunction(v) then
            local ent = wepom or target
            local succ, val = pcall(v, ent, target[k] or defaultValue[k])
            if succ and type(val) ~= "function" then
                target[k] = val
            end
        end
    end
end

function TFAApplyAttachment(attName, wep)
    if not attName or not wep then return end
    local attachment = TFA.Attachments.Atts[attName]
    if not attachment then return end

    ApplyWeaponTableRecursive(attachmentCorrectionsPre[attName], wep, wep)

    if attachment.Attach then
        attachment.Attach(table.Copy(attachment), wep)
    end

    ApplyWeaponTableRecursive(attachment.WeaponTable, wep, wep)
    ApplyWeaponTableRecursive(attachmentCorrections[attName], wep, wep)
end

function TFASelectAttachment(wepClass, attachments)
    for _, scopeName in ipairs(defaultScopes) do
        local found
        for selIndex, attName in pairs(attachments.atts) do
            if attName == scopeName then
                found = true
                attachments.sel = selIndex
                break
            end
        end
        if found then break end
    end

    for selIndex, attName in pairs(attachments.atts) do
        if ForceAttachment[wepClass] == attName then
            attachments.sel = selIndex
        end
    end
end

function TFAApplyAttachmentOuter(wep)
    if not wep.Attachments then return end
    if weapons.IsBasedOn(wep.ClassName or "", "tfa_gun_base") then
        for _, attachmentSlot in pairs(wep.Attachments) do
            TFASelectAttachment(wep, attachmentSlot)
            if attachmentSlot.sel and attachmentSlot.atts and attachmentSlot.sel >= 0 then
                local attName = attachmentSlot.atts[attachmentSlot.sel]
                TFAApplyAttachment(attName, wep)
            end
        end
    end
end
