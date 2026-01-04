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

IterateModuleList(SWEP.ClSIDE_MODULES, include)
IterateModuleList(SWEP.SH_MODULES, include)

SWEP.DrawAmmo = true
SWEP.DrawWeaponInfoBox = false
SWEP.BounceWeaponIcon = false
