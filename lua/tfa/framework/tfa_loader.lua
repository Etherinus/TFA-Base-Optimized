if SERVER then AddCSLuaFile() end

TFA = TFA or {}
TFA.Enum = TFA.Enum or {}

local fileFind = file.Find
local includeFn = include
local addCSLuaFile = AddCSLuaFile
local debugGetInfo = debug.getinfo
local printFn = print
local typeFn = type
local ipairs = ipairs
local stringFind = string.find

local doLoad = true
local version = 4.034
local versionString = "4.0.3.4 SV"
local changelog = "Server Final Edition"

local function marker() end
local info = debugGetInfo(marker)
local myPath = "legacy"

if info and typeFn(info) == "table" and info.short_src then
    myPath = info.short_src
end

if TFA_BASE_VERSION then
    local existingPath = TFA_FILE_PATH or ""

    if TFA_BASE_VERSION > version then
        printFn("TFA Base - newer conflicting version detected at: " .. existingPath)
        doLoad = false
    elseif TFA_BASE_VERSION < version then
        printFn("TFA Base - older conflicting version detected at: " .. existingPath)
    else
        printFn("TFA Base - equal conflicting version detected at: " .. existingPath)
    end
end

if not doLoad then
    return
end

TFA_BASE_VERSION = version
TFA_BASE_VERSION_STRING = versionString
TFA_BASE_VERSION_CHANGES = changelog
TFA_ATTACHMENTS_ENABLED = false
TFA_FILE_PATH = myPath

local function loadFolder(folder)
    local basePath = "tfa/" .. folder .. "/"
    local flist = fileFind(basePath .. "*.lua", "LUA")

    for i = 1, #flist do
        local filename = flist[i]
        local isClient = stringFind(filename, "cl_", 1, true) ~= nil
        local isServer = stringFind(filename, "sv_", 1, true) ~= nil
        local fullPath = basePath .. filename

        if SERVER and not isServer then
            addCSLuaFile(fullPath)
        end

        if (SERVER and not isClient) or (CLIENT and not isServer) then
            includeFn(fullPath)
        end
    end
end

loadFolder("enums")
loadFolder("modules")
loadFolder("external")
