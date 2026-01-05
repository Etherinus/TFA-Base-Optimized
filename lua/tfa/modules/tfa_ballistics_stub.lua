TFA = TFA or {}
TFA.Ballistics = TFA.Ballistics or {}

local ballistics = TFA.Ballistics
ballistics.Bullets = ballistics.Bullets or {}

local registry = ballistics.Bullets["bullet_registry"] or ballistics.Bullets.bullet_registry
if not registry then
    registry = {}
end

ballistics.Bullets["bullet_registry"] = registry
ballistics.Bullets.bullet_registry = registry
