local meta = FindMetaTable("Weapon")

if meta then
    function meta:IsTFA()
        return self.IsTFAWeapon or false
    end
end
