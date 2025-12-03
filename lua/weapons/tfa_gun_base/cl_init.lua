--[[ Load up our shared code. ]]--

include('shared.lua')

--[[ Include these modules, because they're clientside.]]--

if CLIENT then
	for k,v in pairs(SWEP.ClSIDE_MODULES) do
		include(v)
	end
end

--[[ Include these modules, because they're shared.]]--

if CLIENT then
	for k,v in pairs(SWEP.SH_MODULES) do
		include(v)
	end
end

--[[Actual clientside values]]--

SWEP.DrawAmmo				= true				--Should draw the default HL2 ammo counter
SWEP.DrawWeaponInfoBox			= false				-- Should draw the weapon info box
SWEP.BounceWeaponIcon   			= false				-- Should the weapon icon bounce?
