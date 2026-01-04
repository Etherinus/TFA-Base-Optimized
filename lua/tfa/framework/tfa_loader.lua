if SERVER then AddCSLuaFile() end

TFA = TFA or {}
TFA.Enum = TFA.Enum or {}

local SERVER = SERVER
local CLIENT = CLIENT

local fileFind = file.Find
local includeFn = include
local addCSLuaFile = AddCSLuaFile
local debugGetInfo = debug.getinfo
local printFn = print
local typeFn = type

local ipairs = ipairs
local tableSort = table.sort
local stringSub = string.sub

local version = 4.034
local versionString = "4.0.3.4 SV"
local changelog = "Server Final Edition"

local function marker() end
local info = debugGetInfo(marker, "S")
local myPath = "legacy"

if info and typeFn(info) == "table" then
    myPath = info.short_src or info.source or myPath
end

do
    local existing = TFA_BASE_VERSION
    if existing then
        local existingPath = TFA_FILE_PATH or ""

        if existing > version then
            printFn("TFA Base - newer conflicting version detected at: " .. tostring(existingPath))
            return
        end

        if existing == version then
            printFn("TFA Base - equal conflicting version detected at: " .. tostring(existingPath))
            return
        end

        printFn("TFA Base - older conflicting version detected at: " .. tostring(existingPath))
    end
end

TFA_BASE_VERSION = version
TFA_BASE_VERSION_STRING = versionString
TFA_BASE_VERSION_CHANGES = changelog
TFA_ATTACHMENTS_ENABLED = false
TFA_FILE_PATH = myPath

local function loadFolder(folder)
    if typeFn(folder) ~= "string" or folder == "" then return end

    local basePath = "tfa/" .. folder .. "/"
    local flist = fileFind(basePath .. "*.lua", "LUA")
    if not flist or #flist == 0 then return end

    tableSort(flist)

    local isServerRealm = SERVER == true
    local isClientRealm = CLIENT == true

    for i = 1, #flist do
        local filename = flist[i]
        local prefix = stringSub(filename, 1, 3)

        local isClient = prefix == "cl_"
        local isServer = prefix == "sv_"

        local fullPath = basePath .. filename

        if isServerRealm and not isServer then
            addCSLuaFile(fullPath)
        end

        if (isServerRealm and not isClient) or (isClientRealm and not isServer) then
            includeFn(fullPath)
        end
    end
end

loadFolder("enums")
loadFolder("modules")
loadFolder("external")
