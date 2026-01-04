ATTACHMENT = ATTACHMENT or {}

ATTACHMENT.Name = "Base Attachment"
ATTACHMENT.Description = { color_white, "Line1", color_black, "Line2" }
ATTACHMENT.Icon = nil
ATTACHMENT.IconScale = 0.7
ATTACHMENT.Type = "none"

local ATT = ATTACHMENT

local pairs = pairs
local IsValid = IsValid
local table_remove = table.remove

local NIL = {}

local function ensureBodygroupState(wep)
    if not wep.VMBodyGroups then wep.VMBodyGroups = {} end
    if not wep.WMBodyGroups then wep.WMBodyGroups = {} end

    if not wep.OGVMBodyGroups then wep.OGVMBodyGroups = {} end
    if not wep.OGWMBodyGroups then wep.OGWMBodyGroups = {} end

    if not wep.AttachmentBodygroups then wep.AttachmentBodygroups = {} end

    if not wep.__tfa_bg_vm_base then wep.__tfa_bg_vm_base = {} end
    if not wep.__tfa_bg_wm_base then wep.__tfa_bg_wm_base = {} end
    if not wep.__tfa_bg_vm_stack then wep.__tfa_bg_vm_stack = {} end
    if not wep.__tfa_bg_wm_stack then wep.__tfa_bg_wm_stack = {} end
    if not wep.__tfa_bg_attach_keys then wep.__tfa_bg_attach_keys = {} end
end

local function upsertStack(stack, attachID, val)
    for i = #stack, 1, -1 do
        local it = stack[i]
        if it and it[1] == attachID then
            table_remove(stack, i)
            break
        end
    end
    stack[#stack + 1] = { attachID, val }
end

local function removeFromStack(stack, attachID)
    for i = #stack, 1, -1 do
        local it = stack[i]
        if it and it[1] == attachID then
            table_remove(stack, i)
            return true
        end
    end
    return false
end

local function resolveBase(baseTbl, k)
    local base = baseTbl[k]
    if base == NIL or base == nil then return 0 end
    return base
end

local function captureBaseIfNeeded(wep, baseTbl, ogTbl, curTbl, k)
    if baseTbl[k] ~= nil then return end

    local cur = curTbl[k]
    baseTbl[k] = cur == nil and NIL or cur

    if ogTbl[k] == nil then
        ogTbl[k] = cur or 0
    end
end

local function applyGroupStack(wep, attachID, groupTbl, baseTbl, stackTbl, ogTbl, keysOut)
    local i = 0
    for k, v in pairs(groupTbl) do
        i = i + 1
        keysOut[i] = k

        captureBaseIfNeeded(wep, baseTbl, ogTbl, groupTbl == wep.VMBodyGroups and wep.VMBodyGroups or wep.WMBodyGroups, k)

        local stack = stackTbl[k]
        if not stack then
            stack = {}
            stackTbl[k] = stack
        end

        upsertStack(stack, attachID, v)
        if groupTbl == wep.VMBodyGroups then
            wep.VMBodyGroups[k] = v
        else
            wep.WMBodyGroups[k] = v
        end
    end

    for j = i + 1, #keysOut do
        keysOut[j] = nil
    end
end

local function applyBodygroups(wep, attachID)
    local data = wep.AttachmentBodygroups and wep.AttachmentBodygroups[attachID]
    if not data then return end

    local vg = data.V
    local wg = data.W
    if not vg and not wg then return end

    local attachKeys = wep.__tfa_bg_attach_keys
    local keyEntry = attachKeys[attachID]
    if not keyEntry then
        keyEntry = { V = {}, W = {} }
        attachKeys[attachID] = keyEntry
    end

    if vg then
        applyGroupStack(wep, attachID, vg, wep.__tfa_bg_vm_base, wep.__tfa_bg_vm_stack, wep.OGVMBodyGroups, keyEntry.V)
    else
        local kv = keyEntry.V
        for j = 1, #kv do kv[j] = nil end
    end

    if wg then
        applyGroupStack(wep, attachID, wg, wep.__tfa_bg_wm_base, wep.__tfa_bg_wm_stack, wep.OGWMBodyGroups, keyEntry.W)
    else
        local kw = keyEntry.W
        for j = 1, #kw do kw[j] = nil end
    end
end

local function revertGroupStack(wep, attachID, baseTbl, stackTbl, ogTbl, curTbl, keys)
    for i = 1, #keys do
        local k = keys[i]
        local stack = stackTbl[k]
        if stack and removeFromStack(stack, attachID) then
            local top = stack[#stack]
            if top then
                curTbl[k] = top[2] or 0
            else
                curTbl[k] = resolveBase(baseTbl, k)
                stackTbl[k] = nil
                baseTbl[k] = nil
                ogTbl[k] = nil
            end
        end
    end
end

local function revertBodygroups(wep, attachID)
    local attachKeys = wep.__tfa_bg_attach_keys
    local keyEntry = attachKeys and attachKeys[attachID]

    if keyEntry then
        local kv = keyEntry.V
        local kw = keyEntry.W

        if kv and #kv > 0 then
            revertGroupStack(wep, attachID, wep.__tfa_bg_vm_base, wep.__tfa_bg_vm_stack, wep.OGVMBodyGroups, wep.VMBodyGroups, kv)
        end

        if kw and #kw > 0 then
            revertGroupStack(wep, attachID, wep.__tfa_bg_wm_base, wep.__tfa_bg_wm_stack, wep.OGWMBodyGroups, wep.WMBodyGroups, kw)
        end

        attachKeys[attachID] = nil
        return
    end

    local data = wep.AttachmentBodygroups and wep.AttachmentBodygroups[attachID]
    if not data then return end

    local vg = data.V
    local wg = data.W

    if vg then
        local keys = {}
        local n = 0
        for k in pairs(vg) do
            n = n + 1
            keys[n] = k
        end
        revertGroupStack(wep, attachID, wep.__tfa_bg_vm_base, wep.__tfa_bg_vm_stack, wep.OGVMBodyGroups, wep.VMBodyGroups, keys)
    end

    if wg then
        local keys = {}
        local n = 0
        for k in pairs(wg) do
            n = n + 1
            keys[n] = k
        end
        revertGroupStack(wep, attachID, wep.__tfa_bg_wm_base, wep.__tfa_bg_wm_stack, wep.OGWMBodyGroups, wep.WMBodyGroups, keys)
    end
end

function ATT:DoIronSights(wep)
    if not self.IronSightsPos and not self.IronSightsAng then return end

    if not wep.__tfa_og_is_pos_set then
        wep.__tfa_og_is_pos_set = true
        wep.__tfa_og_is_pos = wep.IronSightsPos
    end

    if not wep.__tfa_og_is_ang_set then
        wep.__tfa_og_is_ang_set = true
        wep.__tfa_og_is_ang = wep.IronSightsAng
    end

    if self.IronSightsPos ~= nil then
        wep.IronSightsPos = self.IronSightsPos
    end

    if self.IronSightsAng ~= nil then
        wep.IronSightsAng = self.IronSightsAng
    end
end

function ATT:RevertIronSights(wep)
    if not self.IronSightsPos and not self.IronSightsAng then return end

    if wep.__tfa_og_is_pos_set then
        wep.IronSightsPos = wep.__tfa_og_is_pos
    end

    if wep.__tfa_og_is_ang_set then
        wep.IronSightsAng = wep.__tfa_og_is_ang
    end
end

function ATT:AttachBase(wep)
    if not IsValid(wep) then return end

    self:DoIronSights(wep)

    if self.Type ~= "bodygroup" then return end

    local id = self.ID
    if id == nil then return end

    ensureBodygroupState(wep)

    local abg = wep.AttachmentBodygroups
    if abg[id] == nil then
        abg[id] = {}
    end

    applyBodygroups(wep, id)

    local doBG = wep.DoBodyGroups
    if doBG then
        doBG(wep)
    end
end

function ATT:DetachBase(wep)
    if not IsValid(wep) then return end

    self:RevertIronSights(wep)

    if self.Type ~= "bodygroup" then return end

    local id = self.ID
    if id == nil then return end

    ensureBodygroupState(wep)

    local abg = wep.AttachmentBodygroups
    if abg[id] == nil then
        abg[id] = {}
    end

    revertBodygroups(wep, id)

    local doBG = wep.DoBodyGroups
    if doBG then
        doBG(wep)
    end
end

function ATT:Attach(wep)
    if not IsValid(wep) then return end
end

function ATT:Detach(wep)
    if not IsValid(wep) then return end
end

if not TFA_ATTACHMENT_ISUPDATING then
    TFAUpdateAttachments()
end
