local game_AddAmmoType = game.AddAmmoType

game_AddAmmoType({
    name = "tfbow_arrow",
    dmgtype = DMG_CLUB,
    tracer = 0,
    minsplash = 5,
    maxsplash = 5
})

if CLIENT then
    local language_Add = language.Add
    language_Add("tfbow_arrow_ammo", "Arrows")
end

game_AddAmmoType({
    name = "tfbow_bolt",
    dmgtype = DMG_CLUB,
    tracer = 0,
    minsplash = 5,
    maxsplash = 5
})

if CLIENT then
    local language_Add = language.Add
    language_Add("tfbow_bolt_ammo", "Bolts")
end
