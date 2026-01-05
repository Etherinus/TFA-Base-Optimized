TFA = TFA or {}

local tmpmat
local fname
local precached_dirs = {}

local string_find = string.find
local string_lower = string.lower
local string_Replace = string.Replace
local file_Find = file.Find
local Material = Material
local util_PrecacheModel = util.PrecacheModel
local util_PrecacheSound = util.PrecacheSound
local pairs = pairs

function TFA.PrecacheDirectory(dir, typev)
    if not typev then
        typev = ""

        if string_find(dir, "material", 1, true) then
            typev = "mat"
        elseif string_find(dir, "model", 1, true) then
            typev = "mdl"
        elseif string_find(dir, "sound", 1, true) then
            typev = "snd"
        end
    end

    local cachekey = string_lower(dir) .. "|" .. tostring(typev)
    if precached_dirs[cachekey] then
        return
    end

    precached_dirs[cachekey] = true

    local files, directories = file_Find(dir .. "*", "GAME")

    for _, fdir in pairs(directories) do
        if fdir ~= ".svn" and fdir ~= ".git" then
            TFA.PrecacheDirectory(dir .. fdir .. "/", typev)
        end
    end

    for _, v in pairs(files) do
        fname = string_lower(dir .. v)

        if (string_find(v, ".vmt", 1, true) or string_find(v, ".vtf", 1, true) or string_find(v, ".png", 1, true))
            and (typev == "" or typev == "mat")
        then
            tmpmat = Material(string_Replace(fname, ".vmt", ""))
            tmpmat:GetKeyValues()
        elseif string_find(v, ".mdl", 1, true) and (typev == "" or typev == "mdl") then
            util_PrecacheModel(fname)
        elseif (string_find(v, ".wav", 1, true) or string_find(v, ".mp3", 1, true)) and (typev == "" or typev == "snd") then
            util_PrecacheSound(fname)
        end
    end
end
