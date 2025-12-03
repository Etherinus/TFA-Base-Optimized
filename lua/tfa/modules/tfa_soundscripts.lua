if SERVER then AddCSLuaFile() end

sound.Add({
    name = "Weapon_Bow.1",
    channel = CHAN_STATIC,
    volume = 1,
    sound = {
        "weapons/tfbow/fire1.wav",
        "weapons/tfbow/fire2.wav",
        "weapons/tfbow/fire3.wav"
    }
})

sound.Add({
    name = "Weapon_Bow.boltpull",
    channel = CHAN_USER_BASE + 11,
    volume = 1,
    sound = {
        "weapons/tfbow/pull1.wav",
        "weapons/tfbow/pull2.wav",
        "weapons/tfbow/pull3.wav"
    }
})

sound.Add({
    name = "TFA.Bash",
    channel = CHAN_USER_BASE + 13,
    volume = 1,
    sound = {
        "weapons/tfa/bash1.wav",
        "weapons/tfa/bash2.wav"
    },
    pitch = { 97, 103 }
})

sound.Add({
    name = "TFA.BashWall",
    channel = CHAN_USER_BASE + 13,
    volume = 1,
    sound = "weapons/melee/rifle_swing_hit_world.wav",
    pitch = { 97, 103 }
})

sound.Add({
    name = "TFA.BashFlesh",
    channel = CHAN_USER_BASE + 13,
    volume = 1,
    sound = {
        "weapons/melee/rifle_swing_hit_infected7.wav",
        "weapons/melee/rifle_swing_hit_infected8.wav",
        "weapons/melee/rifle_swing_hit_infected9.wav",
        "weapons/melee/rifle_swing_hit_infected10.wav",
        "weapons/melee/rifle_swing_hit_infected11.wav",
        "weapons/melee/rifle_swing_hit_infected12.wav"
    },
    pitch = { 97, 103 }
})

sound.Add({
    name = "TFA.IronIn",
    channel = CHAN_USER_BASE + 13,
    volume = 1,
    sound = { "weapons/tfa/ironin.wav" },
    pitch = { 97, 103 }
})

sound.Add({
    name = "TFA.IronOut",
    channel = CHAN_USER_BASE + 13,
    volume = 1,
    sound = { "weapons/tfa/ironout.wav" },
    pitch = { 97, 103 }
})

sound.Add({
    name = "Weapon_Pistol.Empty2",
    channel = CHAN_USER_BASE + 11,
    volume = 1,
    level = 80,
    sound = { "weapons/pistol/pistol_empty.wav" },
    pitch = { 97, 103 }
})

sound.Add({
    name = "Weapon_AR2.Empty2",
    channel = CHAN_USER_BASE + 11,
    volume = 1,
    level = 80,
    sound = { "weapons/ar2/ar2_empty.wav" },
    pitch = { 97, 103 }
})
