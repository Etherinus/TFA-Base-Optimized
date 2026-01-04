local game_AddAmmoType = game and game.AddAmmoType
if not game_AddAmmoType then return end

local defs = {
    { id = "tfbow_arrow", dmgtype = DMG_CLUB, tracer = 0, minsplash = 5, maxsplash = 5, lang = "Arrows" },
    { id = "tfbow_bolt", dmgtype = DMG_CLUB, tracer = 0, minsplash = 5, maxsplash = 5, lang = "Bolts" }
}

for i = 1, #defs do
    local d = defs[i]
    game_AddAmmoType({
        name = d.id,
        dmgtype = d.dmgtype,
        tracer = d.tracer,
        minsplash = d.minsplash,
        maxsplash = d.maxsplash
    })

    if CLIENT and language and language.Add then
        language.Add(d.id .. "_ammo", d.lang)
    end
end
