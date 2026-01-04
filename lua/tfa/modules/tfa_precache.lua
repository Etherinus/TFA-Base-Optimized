TFA = TFA or {}

local precached_dirs = {}

local string_find = string.find
local string_lower = string.lower
local file_Find = file and file.Find
local Material = CLIENT and Material or nil
local util_PrecacheModel = util and util.PrecacheModel
local util_PrecacheSound = util and util.PrecacheSound
local pairs = pairs
local tostring = tostring

local function isMatFile(vlower)
    local ext = vlower:sub(-4)
    if ext == ".vmt" or ext == ".vtf" then
        return true
    end
    if vlower:sub(-4) == ".png" then
        return true
    end
    return false
end

local function isModelFile(vlower)
    return vlower:sub(-4) == ".mdl"
end

local function isSoundFile(vlower)
    local ext = vlower:sub(-4)
    return ext == ".wav" or ext == ".mp3"
end

function TFA.PrecacheDirectory(dir, typev)
    if not (dir and file_Find) then
        return
    end

    if not typev then
        typev = ""

        local dl = string_lower(dir)
        if string_find(dl, "material", 1, true) then
            typev = "mat"
        elseif string_find(dl, "model", 1, true) then
            typev = "mdl"
        elseif string_find(dl, "sound", 1, true) then
            typev = "snd"
        end
    end

    local cachekey = string_lower(dir) .. "|" .. tostring(typev)
    if precached_dirs[cachekey] then
        return
    end
    precached_dirs[cachekey] = true

    local files, directories = file_Find(dir .. "*", "GAME")
    files = files or {}
    directories = directories or {}

    for _, fdir in pairs(directories) do
        if fdir ~= ".svn" and fdir ~= ".git" then
            TFA.PrecacheDirectory(dir .. fdir .. "/", typev)
        end
    end

    for _, v in pairs(files) do
        local vlower = string_lower(v)
        local full = dir .. v

        if isMatFile(vlower) and (typev == "" or typev == "mat") then
            if Material then
                local matPath = full
                if vlower:sub(-4) == ".vmt" then
                    matPath = full:sub(1, -5)
                end
                local m = Material(matPath)
                if m and m.GetKeyValues then
                    m:GetKeyValues()
                end
            end
        elseif isModelFile(vlower) and (typev == "" or typev == "mdl") then
            if util_PrecacheModel then
                util_PrecacheModel(full)
            end
        elseif isSoundFile(vlower) and (typev == "" or typev == "snd") then
            if util_PrecacheSound then
                util_PrecacheSound(full)
            end
        end
    end
end
