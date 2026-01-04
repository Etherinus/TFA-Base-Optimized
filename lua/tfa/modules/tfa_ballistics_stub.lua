TFA = TFA or {}
TFA.Ballistics = TFA.Ballistics or {}

local ballistics = TFA.Ballistics
ballistics.Bullets = ballistics.Bullets or {}

local bullets = ballistics.Bullets
local registry = bullets.bullet_registry or bullets["bullet_registry"]
if not registry then
    registry = {}
end

bullets.bullet_registry = registry
bullets["bullet_registry"] = registry
