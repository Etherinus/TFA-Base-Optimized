if SERVER then AddCSLuaFile() end

EFFECT.Life = EFFECT.Life or 0.05

function EFFECT:Init(data)
	self.DieTime = CurTime() + (self.Life or 0.05)
end

function EFFECT:Think()
	return self.DieTime and CurTime() < self.DieTime
end

function EFFECT:Render()
	-- Compat stub: effects that include this base define visuals themselves
end
