if SERVER then AddCSLuaFile() end

local CurTime = CurTime

EFFECT.Life = EFFECT.Life or 0.05

function EFFECT:Init()
    local life = self.Life or 0.05
    self.DieTime = CurTime() + life
end

function EFFECT:Think()
    local dt = self.DieTime
    if not dt then
        return false
    end
    return CurTime() < dt
end

function EFFECT:Render()
end
