TFA = TFA or {}

local function ensureTable(key)
    if TFA[key] == nil then
        TFA[key] = {}
    end
end

ensureTable("BO3VisionEnts")
ensureTable("BO3Indicators")
ensureTable("BO3NoModSound")
ensureTable("BO3BloodColor")
ensureTable("QEDSounds")

if TFA.BO3GiveAchievement == nil then
    function TFA.BO3GiveAchievement()
    end
end
