if SERVER then
	AddCSLuaFile()
	AddCSLuaFile("tfa/compat/tfa_networkvar_compat.lua")
	AddCSLuaFile("tfa/muzzleflash_base.lua")
end

include("tfa/framework/tfa_loader.lua")
include("tfa/compat/tfa_networkvar_compat.lua")
