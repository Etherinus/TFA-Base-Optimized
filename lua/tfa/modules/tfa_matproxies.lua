local matproxyTbl = matproxy
if not matproxyTbl or not matproxyTbl.Add then return end

local IsValid = IsValid
local isvector = isvector

matproxyTbl.Add({
    name = "PlayerWeaponColorStatic",

    init = function(self, mat, values)
        self.ResultTo = values and values.resultvar or nil
    end,

    bind = function(self, mat, ent)
        if not self.ResultTo then return end
        if not IsValid(ent) then return end

        local owner = ent:GetOwner()
        if not (IsValid(owner) and owner.IsPlayer and owner:IsPlayer()) then
            return
        end

        local col = owner:GetWeaponColor()
        if not isvector(col) then
            return
        end

        mat:SetVector(self.ResultTo, col)
    end
})
