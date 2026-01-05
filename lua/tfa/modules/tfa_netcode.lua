if SERVER then
    local util_AddNetworkString = util.AddNetworkString
    local net_Receive = net.Receive
    local net_ReadBool = net.ReadBool
    local net_ReadEntity = net.ReadEntity
    local net_ReadString = net.ReadString
    local IsValid = IsValid

    util_AddNetworkString("tfaSoundEvent")
    util_AddNetworkString("tfa_base_muzzle_mp")
    util_AddNetworkString("tfaInspect")
    util_AddNetworkString("tfaShotgunInterrupt")
    util_AddNetworkString("tfaRequestFidget")

    local wep
    local ply

    net_Receive("tfaInspect", function(_, client)
        local mybool = net_ReadBool()
        mybool = mybool and 1 or 0

        if IsValid(client) and client:IsPlayer() and client:Alive() then
            ply = client
            wep = ply:GetActiveWeapon()

            if IsValid(wep) and wep.ToggleInspect then
                wep:ToggleInspect()
            end
        end
    end)

    net_Receive("tfaRequestFidget", function(_, client)
        wep = client:GetActiveWeapon()

        if IsValid(wep) and wep.CheckAmmo then
            wep:CheckAmmo()
        end
    end)

    net_Receive("tfaShotgunInterrupt", function(_, client)
        if not IsValid(client) or not client:IsPlayer() or not client:Alive() then
            return
        end

        ply = client
        wep = ply:GetActiveWeapon()

        if IsValid(wep) and wep.ShotgunInterrupt then
            wep:ShotgunInterrupt()
        end
    end)

    net_Receive("tfa_base_muzzle_mp", function(_, plyv)
        wep = plyv:GetActiveWeapon()

        if IsValid(wep) and wep.ShootEffectsCustom then
            wep:ShootEffectsCustom()
        end
    end)
else
    local net_Receive = net.Receive
    local net_ReadEntity = net.ReadEntity
    local net_ReadString = net.ReadString
    local IsValid = IsValid

    local wep
    local snd

    net_Receive("tfaSoundEvent", function()
        wep = net_ReadEntity()
        snd = net_ReadString()

        if IsValid(wep) and snd and snd ~= "" then
            wep:EmitSound(snd)
        end
    end)

    net_Receive("tfa_base_muzzle_mp", function()
        wep = net_ReadEntity()

        if IsValid(wep) and wep.ShootEffectsCustom then
            wep:ShootEffectsCustom(true)
        end
    end)
end
