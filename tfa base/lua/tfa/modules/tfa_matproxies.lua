if not matproxy then return end

matproxy.Add({
    name = "PlayerWeaponColorStatic",

    init = function(self, mat, values)
        self.ResultTo = values.resultvar
    end,

    bind = function(self, mat, ent)
        if not IsValid(ent) then return end

        local owner = ent:GetOwner()
        if not IsValid(owner) or not owner:IsPlayer() then return end

        local col = owner:GetWeaponColor()
        if not isvector(col) then return end

        mat:SetVector(self.ResultTo, col)
    end
})
