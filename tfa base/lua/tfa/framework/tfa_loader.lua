if SERVER then AddCSLuaFile() end

TFA = TFA or {}

local do_load = true
local version = 4.034
local version_string = "4.0.3.4 SV"
local changelog = [[Server Final Edition]]

local function testFunc() end
local my_path = debug.getinfo(testFunc)
my_path = (my_path and type(my_path) == "table" and my_path.short_src) and my_path.short_src or "legacy"

if TFA_BASE_VERSION then
    if TFA_BASE_VERSION > version then
        print("You have a newer, conflicting version of TFA Base located at: " .. (TFA_FILE_PATH or ""))
        do_load = false
    elseif TFA_BASE_VERSION < version then
        print("You have an older, conflicting version of TFA Base located at: " .. (TFA_FILE_PATH or ""))
    else
        print("You have an equal, conflicting version of TFA Base located at: " .. (TFA_FILE_PATH or ""))
    end
end

if do_load then
    TFA_BASE_VERSION = version
    TFA_BASE_VERSION_STRING = version_string
    TFA_BASE_VERSION_CHANGES = changelog
    TFA_ATTACHMENTS_ENABLED = false
    TFA_FILE_PATH = my_path

    TFA.Enum = TFA.Enum or {}

    local function LoadFolder(folder)
        local flist = file.Find("tfa/" .. folder .. "/*.lua", "LUA")
        for _, filename in ipairs(flist) do
            local isClient = filename:find("cl_")
            local isServer = filename:find("sv_")

            if SERVER and not isServer then
                AddCSLuaFile("tfa/" .. folder .. "/" .. filename)
            end

            if (SERVER and not isClient) or (CLIENT and not isServer) then
                include("tfa/" .. folder .. "/" .. filename)
            end
        end
    end

    LoadFolder("enums")
    LoadFolder("modules")
    LoadFolder("external")
end
