local FindMetaTable = FindMetaTable
local meta = FindMetaTable and FindMetaTable("Weapon") or nil

if meta and not meta.IsTFA then
    function meta:IsTFA()
        return self.IsTFAWeapon or false
    end
end
