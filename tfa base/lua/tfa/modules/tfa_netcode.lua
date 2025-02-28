if SERVER then
    local wep, ply

    util.AddNetworkString("tfaSoundEvent")
    util.AddNetworkString("tfa_base_muzzle_mp")
    util.AddNetworkString("tfaInspect")
    util.AddNetworkString("tfaShotgunInterrupt")
    util.AddNetworkString("tfaRequestFidget")
    -- util.AddNetworkString("tfaAltAttack")

    net.Receive("tfaInspect", function(_, client)
        local mybool = net.ReadBool()
        mybool = mybool and 1 or 0

        if IsValid(client) and client:IsPlayer() and client:Alive() then
            ply = client
            wep = ply:GetActiveWeapon()
            if IsValid(wep) and wep.ToggleInspect then
                wep:ToggleInspect()
            end
        end
    end)

    net.Receive("tfaRequestFidget", function(_, client)
        wep = client:GetActiveWeapon()
        if IsValid(wep) and wep.CheckAmmo then
            wep:CheckAmmo()
        end
    end)

    net.Receive("tfaShotgunInterrupt", function(_, client)
        if IsValid(client) and client:IsPlayer() and client:Alive() then
            ply = client
            wep = ply:GetActiveWeapon()
            if IsValid(wep) and wep.ShotgunInterrupt then
                wep:ShotgunInterrupt()
            end
        end
    end)

    net.Receive("tfa_base_muzzle_mp", function(_, plyv)
        wep = plyv:GetActiveWeapon()
        if IsValid(wep) and wep.ShootEffectsCustom then
            wep:ShootEffectsCustom()
        end
    end)
else
    local wep, snd

    net.Receive("tfaSoundEvent", function()
        wep = net.ReadEntity()
        snd = net.ReadString()
        if IsValid(wep) and snd and snd ~= "" then
            wep:EmitSound(snd)
        end
    end)

    net.Receive("tfa_base_muzzle_mp", function()
        wep = net.ReadEntity()
        if IsValid(wep) and wep.ShootEffectsCustom then
            wep:ShootEffectsCustom(true)
        end
    end)
end
