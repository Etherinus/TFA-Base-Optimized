local tmpmat
local fname

function TFA.PrecacheDirectory(dir, typev)
    if not typev then
        typev = ""

        if string.find(dir, "material") then
            typev = "mat"
        elseif string.find(dir, "model") then
            typev = "mdl"
        elseif string.find(dir, "sound") then
            typev = "snd"
        end
    end

    local files, directories = file.Find(dir .. "*", "GAME")

    for _, fdir in pairs(directories) do
        if fdir ~= ".svn" and fdir ~= ".git" then
            TFA.PrecacheDirectory(dir .. fdir .. "/", typev)
        end
    end

    for _, v in pairs(files) do
        fname = string.lower(dir .. v)

        if (string.find(v, ".vmt") or string.find(v, ".vtf") or string.find(v, ".png"))
           and (typev == "" or typev == "mat") then
            tmpmat = Material(string.Replace(fname, ".vmt", ""))
            tmpmat:GetKeyValues()
        elseif string.find(v, ".mdl") and (typev == "" or typev == "mdl") then
            util.PrecacheModel(fname)
        elseif (string.find(v, ".wav") or string.find(v, ".mp3")) and (typev == "" or typev == "snd") then
            util.PrecacheSound(fname)
        end
    end
end
