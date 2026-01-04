TFAFlareParts = TFAFlareParts or {}
TFAVMAttachments = TFAVMAttachments or {}

local ply
local vm
local wep

if CLIENT then
    local hook_Add = hook and hook.Add
    local pairs = pairs
    local IsValid = IsValid
    local WorldToLocal = WorldToLocal
    local LocalToWorld = LocalToWorld
    local FrameTime = FrameTime
    local vector_origin = vector_origin
    local table_insert = table.insert
    local table_RemoveByValue = table.RemoveByValue
    local timer_Simple = timer and timer.Simple

    if hook_Add then
        hook_Add("PostDrawViewModel", "TFAMuzzleUpdate", function(vmod, plyv)
            vm = vmod
            ply = plyv

            TFAVMAttachments[1] = vmod and vmod.GetAttachment and vmod:GetAttachment(1) or nil

            for k, v in pairs(TFAFlareParts) do
                if v and v.ThinkFunc then
                    v:ThinkFunc()
                else
                    TFAFlareParts[k] = nil
                end
            end
        end)
    end

    function TFARegPartThink(particle, partfunc)
        if not particle or not partfunc then
            return
        end

        particle.ThinkFunc = partfunc

        if IsValid(particle.FollowEnt) and particle.Att and particle.GetPos and particle.GetAngles then
            local angpos = particle.FollowEnt:GetAttachment(particle.Att)
            if angpos and angpos.Pos then
                particle.OffPos = WorldToLocal(particle:GetPos(), particle:GetAngles(), angpos.Pos, angpos.Ang)
            end
        end

        table_insert(TFAFlareParts, particle)

        if timer_Simple and particle.GetDieTime then
            local t = particle:GetDieTime()
            if t == nil then t = 0 end
            if t < 0 then t = 0 end

            timer_Simple(t, function()
                if particle then
                    table_RemoveByValue(TFAFlareParts, particle)
                end
            end)
        end
    end

    function TFAMuzzlePartFunc(self, first)
        if self.isfirst == nil then
            self.isfirst = false
            first = true
        end

        if not (IsValid(ply) and IsValid(vm)) then
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
            if first and owent.GetVelocity then
                firvel = owent:GetVelocity() * FrameTime() * 1.1
            end

            if self.Att and self.OffPos and self.GetVelocity and self.SetPos and self.GetAngles and self.GetPos then
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
