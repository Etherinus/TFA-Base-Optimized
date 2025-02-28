include("shared.lua")
local cv_ht = GetConVar("host_timescale")

--[[---------------------------------------------------------
Name: Draw
Purpose: Draw the model in-game.
Remember, the things you render first will be underneath!
---------------------------------------------------------]]
function ENT:Draw()
    local ang, tmpang
    tmpang = self:GetAngles()
    ang = tmpang

    if not self.roll then
        self.roll = 0
    end

    local phobj = self:GetPhysicsObject()

    if IsValid(phobj) then
        self.roll = self.roll + phobj:GetVelocity():Length() / 3600 * cv_ht:GetFloat()
    end

    ang:RotateAroundAxis(ang:Forward(), self.roll)
    self:SetAngles(ang)
    self:DrawModel() -- Draw the model.
    self:SetAngles(tmpang)
    --self:SetModel("models/props_junk/watermelon01
end
