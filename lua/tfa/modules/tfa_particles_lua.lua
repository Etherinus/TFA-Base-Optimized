TFAFlareParts = TFAFlareParts or {}
TFAVMAttachments = TFAVMAttachments or {}

local ply
local vm
local wep

if CLIENT then
    local hook_Add = hook.Add
    local pairs = pairs
    local IsValid = IsValid
    local WorldToLocal = WorldToLocal
    local LocalToWorld = LocalToWorld
    local FrameTime = FrameTime
    local vector_origin = vector_origin
    local table_insert = table.insert
    local table_RemoveByValue = table.RemoveByValue
    local timer_Simple = timer.Simple

    hook_Add("PostDrawViewModel", "TFAMuzzleUpdate", function(vmod, plyv)
        vm = vmod
        ply = plyv

        TFAVMAttachments[1] = vmod:GetAttachment(1)

        for k, v in pairs(TFAFlareParts) do
            if v and v.ThinkFunc then
                v:ThinkFunc()
            else
                TFAFlareParts[k] = nil
            end
        end
    end)

    function TFARegPartThink(particle, partfunc)
        if not particle or not partfunc then
            return
        end

        particle.ThinkFunc = partfunc

        if IsValid(particle.FollowEnt) and particle.Att then
            local angpos = particle.FollowEnt:GetAttachment(particle.Att)
            if angpos and angpos.Pos then
                particle.OffPos = WorldToLocal(particle:GetPos(), particle:GetAngles(), angpos.Pos, angpos.Ang)
            end
        end

        table_insert(TFAFlareParts, particle)

        timer_Simple(particle:GetDieTime(), function()
            if particle then
                table_RemoveByValue(TFAFlareParts, particle)
            end
        end)
    end

    function TFAMuzzlePartFunc(self, first)
        if self.isfirst == nil then
            self.isfirst = false
            first = true
        end

        if not IsValid(ply) or not IsValid(vm) then
            return
        end

        wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep.IsCurrentlyScoped and wep:IsCurrentlyScoped() then
            return
        end

        if IsValid(self.FollowEnt) then
            local owent = self.FollowEnt.Owner or self.FollowEnt
            if not IsValid(owent) then
                return
            end

            local firvel = vector_origin
            if first then
                firvel = owent:GetVelocity() * FrameTime() * 1.1
            end

            if self.Att and self.OffPos then
                local angpos

                if self.FollowEnt == vm then
                    angpos = TFAVMAttachments[self.Att]
                else
                    angpos = self.FollowEnt:GetAttachment(self.Att)
                end

                if angpos and angpos.Pos then
                    local tmppos = LocalToWorld(self.OffPos, self:GetAngles(), angpos.Pos, angpos.Ang)
                    local npos = tmppos + self:GetVelocity() * FrameTime()
                    self.OffPos = WorldToLocal(npos + firvel * 0.5, self:GetAngles(), angpos.Pos, angpos.Ang)
                    self:SetPos(npos + firvel)
                end
            end
        end
    end
end
