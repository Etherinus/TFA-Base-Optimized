TFA = TFA or {}
TFA.Attachments = TFA.Attachments or {}
TFA.Attachments.Atts = TFA.Attachments.Atts or {}

local ColorFn = Color

TFA.Attachments.Colors = TFA.Attachments.Colors or {
    active = ColorFn(252, 151, 50, 255),
    error = ColorFn(225, 0, 0, 255),
    background = ColorFn(15, 15, 15, 64),
    primary = ColorFn(245, 245, 245, 255),
    secondary = ColorFn(153, 253, 220, 255),
    ["+"] = ColorFn(128, 255, 128, 255),
    ["-"] = ColorFn(255, 128, 128, 255),
    ["="] = ColorFn(192, 192, 192, 255)
}

TFA.Attachments.UIPadding = TFA.Attachments.UIPadding or 2
TFA.Attachments.Path = TFA.Attachments.Path or "tfa/att/"

TFA_ATTACHMENT_ISUPDATING = TFA_ATTACHMENT_ISUPDATING or false

local pairs = pairs
local ipairs = ipairs
local string_find = string.find
local string_Replace = string.Replace
local table_insert = table.insert
local table_sort = table.sort
local includeFn = include
local setmetatable = setmetatable
local file_Find = file.Find
local istable = istable
local rawget = rawget
local SERVER = SERVER
local hook_Run = hook.Run
local ProtectedCall = ProtectedCall or pcall

local function basefunc(t, k)
    if k == "Base" then return end

    local base = rawget(t, "Base")
    if not base then return end

    local bt = TFA.Attachments.Atts[base]
    if bt then
        return bt[k]
    end
end

local function patchInheritance(tbl, basetbl, visited)
    if not istable(tbl) then return end

    visited = visited or {}
    if visited[tbl] then return end
    visited[tbl] = true

    if not basetbl then
        local base = rawget(tbl, "Base")
        if base then
            basetbl = TFA.Attachments.Atts[base]
            if istable(basetbl) then
                patchInheritance(basetbl, nil, visited)
            end
        end
    end

    if not istable(basetbl) then return end

    for k, v in pairs(tbl) do
        if istable(v) then
            local bv = basetbl[k]
            if istable(bv) then
                patchInheritance(v, bv, visited)
            end
        end
    end

    for k, v in pairs(basetbl) do
        if rawget(tbl, k) == nil then
            tbl[k] = v
        end
    end
end

function TFARegisterAttachment(att)
    if not att then return end

    local id = att.ID or att.Name
    if not id or id == "" then return end

    if id ~= "base" then
        att.Base = att.Base or "base"
    end

    TFA.Attachments.Atts[id] = att
end

local function buildLoadList(path)
    local baseFiles = file_Find(path .. "*base*", "LUA", "namedesc") or {}
    local allFiles = file_Find(path .. "*", "LUA", "namedesc") or {}

    table_sort(baseFiles)
    table_sort(allFiles)

    local baseSet = {}
    for i = 1, #baseFiles do
        baseSet[baseFiles[i]] = true
    end

    for i = 1, #allFiles do
        local f = allFiles[i]
        if not baseSet[f] and not string_find(f, "base", 1, true) then
            baseFiles[#baseFiles + 1] = f
        end
    end

    return baseFiles
end

function TFAUpdateAttachments()
    if TFA_ATTACHMENT_ISUPDATING then return end

    TFA.AttachmentColors = TFA.Attachments.Colors
    TFA.Attachments.Atts = {}

    TFA_ATTACHMENT_ISUPDATING = true

    local path = TFA.Attachments.Path
    local files = buildLoadList(path)

    local oldAttachment = ATTACHMENT

    for i = 1, #files do
        local v = files[i]
        local filepath = path .. v

        local att = {}
        att.ID = string_Replace(v, ".lua", "")

        ATTACHMENT = att

        if SERVER then
            AddCSLuaFile(filepath)
        end

        includeFn(filepath)

        setmetatable(att, { __index = basefunc })
        TFARegisterAttachment(att)
    end

    ATTACHMENT = oldAttachment

    local visited = {}
    for _, v in pairs(TFA.Attachments.Atts) do
        patchInheritance(v, nil, visited)
    end

    ProtectedCall(function()
        if hook_Run then
            hook_Run("TFAAttachmentsLoaded")
        else
            hook.Call("TFAAttachmentsLoaded", GAMEMODE)
        end
    end)

    TFA_ATTACHMENT_ISUPDATING = false
    TFA_ATTACHMENTS_LOADED_ONCE = true
end

hook.Add("InitPostEntity", "TFAUpdateAttachmentsIPE", function()
    if not TFA_ATTACHMENTS_LOADED_ONCE then
        TFAUpdateAttachments()
    end
end)

if not TFA_ATTACHMENTS_LOADED_ONCE then
    TFAUpdateAttachments()
end
