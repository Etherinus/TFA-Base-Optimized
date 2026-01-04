if SERVER then
    local util_AddNetworkString = util and util.AddNetworkString
    local net_Receive = net and net.Receive
    local net_ReadBool = net and net.ReadBool
    local net_ReadEntity = net and net.ReadEntity
    local net_ReadString = net and net.ReadString
    local IsValid = IsValid

    if util_AddNetworkString then
        util_AddNetworkString("tfaSoundEvent")
        util_AddNetworkString("tfa_base_muzzle_mp")
        util_AddNetworkString("tfaInspect")
        util_AddNetworkString("tfaShotgunInterrupt")
        util_AddNetworkString("tfaRequestFidget")
    end

    if net_Receive then
        net_Receive("tfaInspect", function(_, client)
            if net_ReadBool then
                net_ReadBool()
            end

            if IsValid(client) and client:IsPlayer() and client:Alive() then
                local wep = client:GetActiveWeapon()
                if IsValid(wep) and wep.ToggleInspect then
                    wep:ToggleInspect()
                end
            end
        end)

        net_Receive("tfaRequestFidget", function(_, client)
            if not IsValid(client) then return end
            local wep = client:GetActiveWeapon()
            if IsValid(wep) and wep.CheckAmmo then
                wep:CheckAmmo()
            end
        end)

        net_Receive("tfaShotgunInterrupt", function(_, client)
            if not (IsValid(client) and client:IsPlayer() and client:Alive()) then
                return
            end

            local wep = client:GetActiveWeapon()
            if IsValid(wep) and wep.ShotgunInterrupt then
                wep:ShotgunInterrupt()
            end
        end)

        net_Receive("tfa_base_muzzle_mp", function(_, plyv)
            if not IsValid(plyv) then return end
            local wep = plyv:GetActiveWeapon()
            if IsValid(wep) and wep.ShootEffectsCustom then
                wep:ShootEffectsCustom()
            end
        end)
    end
else
    local net_Receive = net and net.Receive
    local net_ReadEntity = net and net.ReadEntity
    local net_ReadString = net and net.ReadString
    local IsValid = IsValid

    if net_Receive then
        net_Receive("tfaSoundEvent", function()
            if not (net_ReadEntity and net_ReadString) then return end
            local wep = net_ReadEntity()
            local snd = net_ReadString()

            if IsValid(wep) and snd and snd ~= "" then
                wep:EmitSound(snd)
            end
        end)

        net_Receive("tfa_base_muzzle_mp", function()
            if not net_ReadEntity then return end
            local wep = net_ReadEntity()

            if IsValid(wep) and wep.ShootEffectsCustom then
                wep:ShootEffectsCustom(true)
            end
        end)
    end
end
