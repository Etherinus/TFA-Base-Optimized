AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local function IterateModuleList(t, fn)
	if not istable(t) then return end

	if #t > 0 then
		for i = 1, #t do
			local v = t[i]
			if isstring(v) and v ~= "" then
				fn(v)
			end
		end
	else
		for _, v in pairs(t) do
			if isstring(v) and v ~= "" then
				fn(v)
			end
		end
	end
end

IterateModuleList(SWEP.SV_MODULES, include)

IterateModuleList(SWEP.SH_MODULES, function(v)
	AddCSLuaFile(v)
	include(v)
end)

IterateModuleList(SWEP.ClSIDE_MODULES, AddCSLuaFile)

if game.SinglePlayer() then
	IterateModuleList(SWEP.ClSIDE_MODULES, include)
end

SWEP.Weight = 60
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true
