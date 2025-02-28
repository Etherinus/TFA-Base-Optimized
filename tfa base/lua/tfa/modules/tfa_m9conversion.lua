if SERVER then AddCSLuaFile() end

local cv_m9c = CreateConVar("sv_tfa_conv_m9konvert", "0", {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Convert M9K to TFA at runtime?")

function TFABaseConv_DefaultInitialize(self)
    if self.Callback and self.Callback.Initialize then
        local val = self.Callback.Initialize(self)
        if val then return val end
    end

    if (not self.Primary.Damage) or (self.Primary.Damage <= 0.01) then
        self:AutoDetectDamage()
    end

    if not self.Primary.IronAccuracy then
        self.Primary.IronAccuracy = (self.Primary.Accuracy or self.Primary.Spread or 0) * 0.2
    end

    if self.MuzzleAttachment == "1" then
        self.CSMuzzleFlashes = true
    end

    if self.Akimbo then
        self.AutoDetectMuzzleAttachment = true
        self.MuzzleAttachmentRaw = 2 - self.AnimCycle
    end

    self:CreateFireModes()
    self:AutoDetectMuzzle()
    self:AutoDetectRange()

    self.DefaultHoldType = self.HoldType
    self.ViewModelFOVDefault = self.ViewModelFOV
    self.DrawCrosshairDefault = self.DrawCrosshair

    self:SetUpSpread()
    self:CorrectScopeFOV(self.DefaultFOV or (IsValid(self.Owner) and self.Owner:GetFOV() or 90))

    if CLIENT then
        self:InitMods()
        self:IconFix()
    end

    self.drawcount = 0
    self.drawcount2 = 0
    self.canholster = false

    self:DetectValidAnimations()
    self:SetDeploySpeed(0.3 / (self.SequenceLength[ACT_VM_DRAW] or 0.3))
    self:ResetEvents()
    self:DoBodyGroups()
    self:InitAttachments()

    self.IsHolding = false
    self.ViewModelFlipDefault = self.ViewModelFlip
    self:SetDrawing(true)
    self:ProcessHoldType()
    sp = game.SinglePlayer()
end

function TFABaseConv_IsScoped(tbl)
    local pn = string.lower(tbl.PrintName or "")
    local cat = string.lower(tbl.Category or "")
    local cl = string.lower(tbl.ClassName or "")
    local bn = string.lower(tbl.Base or "")

    if tbl.Scoped or tbl.IsScoped or (tbl.ScopeZoom and tbl.ScopeZoom > 0) or tbl.ScopeZooms then return true end
    if (tbl.Secondary and tbl.Secondary.ScopeZoom and tbl.Secondary.ScopeZoom > 0) then return true end
    if string.find(pn, "scope") or string.find(cl, "scope") or string.find(cat, "scope") then return true end
    if string.find(bn, "scope") or string.find(bn, "snip") or string.find(bn, "rifleman") then return true end

    return false
end

tfa_conv_overrides = tfa_conv_overrides or {
    ["m9k_usas"] = {
        ["Shotgun"] = true,
        ["ShellTime"] = 0.0
    },
    ["m9k_dbarrel"] = {
        ["data"] = { ["ironsights"] = 0 },
        ["PrimaryAttack"] = nil,
        ["SecondaryAttack"] = function(self)
            if IsValid(self) and self.OwnerIsValid and self:OwnerIsValid() then
                self:PrimaryAttack()
                self:PrimaryAttack()
            end
        end,
        ["CheckWeaponsAndAmmo"] = function() return true end
    },
    ["halo5swepsmg"] = {
        ["Initialize"] = function(self)
            TFABaseConv_DefaultInitialize(self)
            self.Primary.Spread = 0.04
            self.Primary.RPM = 800
            self.Primary.Sound = {
                "Halo5/smg/fire_1.wav",
                "Halo5/smg/fire_2.wav",
                "Halo5/smg/fire_3.wav"
            }
            if surface then
                self.Secondary.ScopeTable = {
                    scopetex = surface.GetTextureID("holo/smg_aim_down"),
                    reticletex = surface.GetTextureID("holo/holo_detail_smg")
                }
            end
        end
    },
    ["halo5swepsmg_golden"] = {
        ["Initialize"] = function(self)
            TFABaseConv_DefaultInitialize(self)
            self.Primary.Spread = 0.04
            self.Primary.RPM = 800
            self.Primary.Sound = {
                "Halo5/smg/fire_1.wav",
                "Halo5/smg/fire_2.wav",
                "Halo5/smg/fire_3.wav"
            }
            if surface then
                self.Secondary.ScopeTable = {
                    scopetex = surface.GetTextureID("holo/smg_aim_down"),
                    reticletex = surface.GetTextureID("holo/holo_detail_smg")
                }
            end
        end
    },
    ["m9k_customsil"] = {
        ["Initialize"] = function(self)
            TFABaseConv_DefaultInitialize(self)
        end
    },
    ["m9k_customsmg"] = {
        ["Initialize"] = function(self)
            TFABaseConv_DefaultInitialize(self)
        end
    },
    ["halo5swepar"] = {
        ["Initialize"] = function(self)
            TFABaseConv_DefaultInitialize(self)
            self.Primary.Spread = 0.03
            self.Primary.RPM = 600
            self.Primary.Sound = {
                "ar_h5/ar_fire_1.wav",
                "ar_h5/ar_fire_2.wav",
                "ar_h5/ar_fire_3.wav"
            }
            if surface then
                self.Secondary.ScopeTable = {
                    scopetex = surface.GetTextureID("Smart_Scope/ar_smart_scope")
                }
            end
        end
    },
    ["ryry1_r700"] = {
        ["BoltAction"] = true
    },
    ["halo5swepdmr"] = {
        ["Initialize"] = function(self)
            TFABaseConv_DefaultInitialize(self)
            self.Primary.KickUp = 1.2
            self.Primary.KickDown = 0.8
            self.Primary.Spread = 0.02
            self.Primary.Sound = {
                "weapons/h5/dmr/dmr_fire_1.wav",
                "weapons/h5/dmr/dmr_fire_2.wav",
                "weapons/h5/dmr/dmr_fire_3.wav"
            }
            if surface then
                self.Secondary.ScopeTable = {
                    scopetex = surface.GetTextureID("scope/h5_dmr")
                }
            end
        end
    },
    ["halo5swepmagnum"] = {
        ["Initialize"] = function(self)
            TFABaseConv_DefaultInitialize(self)
            self.Primary.KickUp = 1
            self.Primary.KickDown = 0.6
            self.ScopeScale = 0.1
            self.Primary.Sound = {
                "magnum/beta_ma2g_fire_1.wav",
                "magnum/beta_ma2g_fire_2.wav",
                "magnum/beta_ma2g_fire_3.wav"
            }
            if surface then
                self.Secondary.ScopeTable = {
                    scopetex = surface.GetTextureID("crosshairs/h5_magnum")
                }
            end
        end
    },
    ["halo5swepbattlerifle"] = {
        ["Initialize"] = function(self)
            self.Primary.Automatic = true
            self.OnlyBurstFire = true
            self.Primary.RPM = 650
            TFABaseConv_DefaultInitialize(self)
            self.Primary.KickUp = 0.5
            self.Primary.KickDown = 0.3
            self.ScopeScale = 0.5
            self.Primary.Spread = 0.025
            self.Primary.Sound = {
                "halo5/br/battle_rifle_fire_1.wav",
                "halo5/br/battle_rifle_fire_2.wav",
                "halo5/br/battle_rifle_fire_3.wav"
            }
            if surface then
                self.Secondary.ScopeTable = {
                    scopetex = surface.GetTextureID("h5_br_smartscope/br_smart_scope")
                }
            end
        end
    },
    ["halo5swepbrwoodland"] = {
        ["Initialize"] = function(self)
            self.Primary.Automatic = true
            self.OnlyBurstFire = true
            self.Primary.RPM = 650
            TFABaseConv_DefaultInitialize(self)
            self.Primary.KickUp = 0.5
            self.Primary.KickDown = 0.3
            self.ScopeScale = 0.5
            self.Primary.Spread = 0.025
            self.Primary.Sound = {
                "halo5/br/battle_rifle_fire_1.wav",
                "halo5/br/battle_rifle_fire_2.wav",
                "halo5/br/battle_rifle_fire_3.wav"
            }
            if surface then
                self.Secondary.ScopeTable = {
                    scopetex = surface.GetTextureID("h5_br_smartscope/br_smart_scope")
                }
            end
        end
    }
}

local ammoshelleffects = {
    ["default"] = "RifleShellEject",
    ["buckshot"] = "ShotgunShellEject",
    ["pistol"] = "ShellEject",
    ["9mm"] = "ShellEject",
    ["smg1"] = "ShellEject"
}

function TFABaseConv_IsRevolver(tbl)
    local pn = string.lower(tbl.PrintName or "")
    local cat = string.lower(tbl.Category or "")
    local cl = string.lower(tbl.ClassName or "")
    local bn = string.lower(tbl.Base or "")

    if string.find(pn, "mag") then
        if string.find(pn, "44") or string.find(pn, "357") then return true end
    elseif string.find(cl, "mag") then
        if string.find(cl, "44") or string.find(cl, "357") then return true end
    elseif string.find(pn, "colt") then
        if string.find(pn, "python") or string.find(pn, "357") or string.find(pn, "44") then return true end
    elseif string.find(cl, "colt") then
        if string.find(cl, "357") or string.find(cl, "44") then return true end
    elseif string.find(cl, "python") then
        return true
    elseif string.find(pn, "revolver") then
        return true
    elseif string.find(cat, "revolver") then
        return true
    elseif string.find(bn, "revolver") then
        return true
    elseif string.find(cl, "revolver") then
        return true
    elseif tbl.Revolver then
        return true
    end

    return false
end

function TFABaseConv_ism9k(tbl)
    if tbl.Primary and (tbl.Primary.KickDown ~= nil) then
        if (tbl.Primary.IronAccuracy) or (tbl.data and tbl.data.ironsights == 0) then
            if not string.find(tbl.Base or "", "tfa_") then
                return true
            end
        end
    end
    return false
end

local function tfaconvsingle_M9K(cn)
    if not cv_m9c:GetBool() then return end

    local tbl = weapons.GetStored(cn)
    if tbl and tbl.Base then
        if TFABaseConv_ism9k(tbl) then
            local base = tbl.Base
            local isshotgun = false

            if string.find(base, "nade") then
                tbl.Base = "tfa_nade_base"
            elseif string.find(base, "shot") then
                tbl.Base = "tfa_shotty_base"
                isshotgun = true
            elseif TFABaseConv_IsScoped(tbl) then
                tbl.Base = "tfa_scoped_base"
            else
                tbl.Base = "tfa_gun_base"
            end

            tbl.SetIronsights = function() return false end
            tbl.GetIronsights = function() return false end
            tbl.SetRunsights = function() return false end
            tbl.GetRunsights = function() return false end
            tbl.IronSight = function() return false end
            tbl.FireModes = nil

            local holdt = tbl.HoldType or ""
            local printn = tbl.PrintName or ""
            local catn = tbl.Category or ""

            if string.find(base, "knife") or string.find(printn, "knife") or string.find(printn, "melee") or
               string.find(catn, "knife") or string.find(catn, "melee") or string.find(printn, "sword") or
               string.find(holdt, "knife") or string.find(holdt, "melee") or string.find(holdt, "fist") then
                tbl.data = tbl.data or {}
                tbl.data.ironsights = 0
                tbl.WeaponLength = 8
            else
                tbl.Reload = nil
            end

            tbl.Revolver = TFABaseConv_IsRevolver(tbl)

            if not isshotgun and not tbl.BoltAction and not tbl.Revolver then
                tbl.BlowbackEnabled = true
                tbl.BlowbackVector = Vector(0, -(tbl.KickUp or 0.5) * 3, 0)
                tbl.Blowback_Shell_Effect = ammoshelleffects[tbl.Primary.Ammo or "default"] or ammoshelleffects["default"]
                tbl.LuaShellEffect = tbl.Blowback_Shell_Effect
                tbl.LuaShellEject = true
            end

            if not tbl.Primary.Spread then
                tbl.Primary.Spread = 0.02
            end
            tbl.Primary.SpreadMultiplierMax = math.Clamp(
                math.sqrt(math.sqrt((tbl.Primary.Damage or 30) / 35) * 10 / 5) * 5,
                0.01 / tbl.Primary.Spread,
                0.1 / tbl.Primary.Spread
            )
            tbl.Primary.SpreadIncrement = tbl.Primary.SpreadMultiplierMax * 60 / (tbl.Primary.RPM or 600) * 0.85 * 1.5
            tbl.Primary.SpreadRecovery = tbl.Primary.SpreadMultiplierMax * math.pow((tbl.Primary.RPM or 600) / 600, 1/3) * 0.75

            local ovr = tfa_conv_overrides[cn]
            if ovr then
                for k, v in pairs(ovr) do
                    tbl[k] = v
                end
            end

            return true
        end
    end
    return false
end

function tfa_m9k_main()
    if not weapons then return end
    local weaponlist = weapons.GetList()
    if not weaponlist then return end

    for _, v in pairs(weaponlist) do
        if v and v.ClassName and not string.find(v.ClassName, "_base") then
            local cn = v.ClassName
            tfaconvsingle_M9K(cn)
        end
    end
end

hook.Add("InitPostEntity", "TFA_M9KConv", function()
    tfa_m9k_main()
end)

tfa_m9k_main()
