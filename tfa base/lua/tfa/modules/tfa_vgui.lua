if CLIENT then
    local function tfaOptionServer(panel)
        local tfaOptionSV = {
            Options = {},
            CVars = {},
            Label = "#Presets",
            MenuButton = "1",
            Folder = "TFA SWEP Settings Server"
        }

        tfaOptionSV.Options["#Default"] = {
            sv_tfa_ironsights_enabled    = "1",
            sv_tfa_sprint_enabled        = "1",
            sv_tfa_weapon_strip          = "0",
            sv_tfa_allow_dryfire         = "1",
            sv_tfa_damage_multiplier     = "1",
            sv_tfa_default_clip          = "-1",
            sv_tfa_arrow_lifetime        = "30",
            sv_tfa_force_multiplier      = "1",
            sv_tfa_dynamicaccuracy       = "1",
            sv_tfa_range_modifier        = "0.5",
            sv_tfa_spread_multiplier     = "1",
            sv_tfa_bullet_penetration    = "1",
            sv_tfa_reloads_legacy        = "0",
            sv_tfa_reloads_enabled       = "1",
            sv_tfa_cmenu                 = "1",
            sv_tfa_penetration_limit     = "2",
            sv_tfa_door_respawn          = "-1"
        }

        panel:AddControl("ComboBox", tfaOptionSV)

        panel:AddControl("CheckBox", {
            Label = "Require reload keypress",
            Command = "sv_tfa_allow_dryfire"
        })
        panel:AddControl("CheckBox", {
            Label = "Dynamic Accuracy",
            Command = "sv_tfa_dynamicaccuracy"
        })
        panel:AddControl("CheckBox", {
            Label = "Strip Empty Weapons",
            Command = "sv_tfa_weapon_strip"
        })
        panel:AddControl("CheckBox", {
            Label = "Enable Ironsights",
            Command = "sv_tfa_ironsights_enabled"
        })
        panel:AddControl("CheckBox", {
            Label = "Enable Modern-Style Sprinting",
            Command = "sv_tfa_sprint_enabled"
        })
        panel:AddControl("CheckBox", {
            Label = "Enable Custom C-Menu",
            Command = "sv_tfa_cmenu"
        })
        panel:AddControl("CheckBox", {
            Label = "Enable Bullet Penetration",
            Command = "sv_tfa_bullet_penetration"
        })
        panel:AddControl("CheckBox", {
            Label = "Enable Reloading",
            Command = "sv_tfa_reloads_enabled"
        })
        panel:AddControl("CheckBox", {
            Label = "Enable Legacy-Style Reloading",
            Command = "sv_tfa_reloads_legacy"
        })
        panel:AddControl("Slider", {
            Label = "Damage Multiplier",
            Command = "sv_tfa_damage_multiplier",
            Type = "Float",
            Min = "0",
            Max = "5"
        })
        panel:AddControl("Slider", {
            Label = "Door Respawn Time",
            Command = "sv_tfa_door_respawn",
            Type = "Integer",
            Min = "-1",
            Max = "120"
        })
        panel:AddControl("Slider", {
            Label = "Impact Force Multiplier",
            Command = "sv_tfa_force_multiplier",
            Type = "Float",
            Min = "0",
            Max = "5"
        })
        panel:AddControl("Slider", {
            Label = "Spread Multiplier",
            Command = "sv_tfa_spread_multiplier",
            Type = "Float",
            Min = "0",
            Max = "5"
        })
        panel:AddControl("Slider", {
            Label = "Penetration Count Limit",
            Command = "sv_tfa_penetration_limit",
            Type = "Integer",
            Min = "0",
            Max = "5"
        })
        panel:AddControl("Slider", {
            Label = "Default Clip Count (-1 = default)",
            Command = "sv_tfa_default_clip",
            Type = "Integer",
            Min = "-1",
            Max = "10"
        })
        panel:AddControl("Slider", {
            Label = "Bullet Range Damage Degradation",
            Command = "sv_tfa_range_modifier",
            Type = "Float",
            Min = "0",
            Max = "1"
        })

        panel:AddControl("Label", {
            Text = "Creator of TFA Base By TheForgottenArchitect\nOptimizer of TFA Base By Etherinus"
        })
    end

    local function tfaOptionClient(panel)
        local tfaOptionCL = {
            Options = {},
            CVars   = {},
            Label   = "#Presets",
            MenuButton = "1",
            Folder  = "TFA SWEP Settings Client"
        }

        tfaOptionCL.Options["#Default"] = {
            cl_tfa_forcearms               = "0",
            cl_tfa_3dscope                 = "1",
            cl_tfa_3dscope_overlay         = "0",
            cl_tfa_scope_sensitivity_autoscale = "1",
            cl_tfa_scope_sensitivity       = "100",
            cl_tfa_inspection_ckey         = "0",
            cl_tfa_inspection_old          = "0",
            cl_tfa_ironsights_toggle       = "1",
            cl_tfa_ironsights_resight      = "1",
            cl_tfa_viewbob_reloading       = "1",
            cl_tfa_viewbob_drawing         = "0",
            sv_tfa_gunbob_intensity        = "1",
            sv_tfa_viewbob_intensity       = "1",
            cl_tfa_viewmodel_offset_x      = "0",
            cl_tfa_viewmodel_offset_y      = "0",
            cl_tfa_viewmodel_offset_z      = "0",
            cl_tfa_viewmodel_offset_fov    = "0",
            cl_tfa_viewmodel_flip          = "0",
            cl_tfa_viewmodel_centered      = "0"
        }

        panel:AddControl("ComboBox", tfaOptionCL)

        panel:AddControl("CheckBox", {
            Label = "Force Refugee Arms",
            Command = "cl_tfa_forcearms"
        })
        panel:AddControl("CheckBox", {
            Label = "Enable 3D Scopes (Re-Draw Gun After Changing)",
            Command = "cl_tfa_3dscope"
        })
        panel:AddControl("CheckBox", {
            Label = "Enable 3D Scope Shadows (Re-Draw Gun After Changing)",
            Command = "cl_tfa_3dscope_overlay"
        })
        panel:AddControl("CheckBox", {
            Label = "Use Viewbob While Drawing",
            Command = "cl_tfa_viewbob_drawing"
        })
        panel:AddControl("CheckBox", {
            Label = "Use Viewbob While Reloading",
            Command = "cl_tfa_viewbob_reloading"
        })
        panel:AddControl("CheckBox", {
            Label = "Context Key Inspection",
            Command = "cl_tfa_inspection_ckey"
        })
        panel:AddControl("CheckBox", {
            Label = "Legacy Text Inspection",
            Command = "cl_tfa_inspection_old"
        })
        panel:AddControl("CheckBox", {
            Label = "Toggle Ironsights",
            Command = "cl_tfa_ironsights_toggle"
        })
        panel:AddControl("CheckBox", {
            Label = "Preserve Sights On Reload, Sprint, etc.",
            Command = "cl_tfa_ironsights_resight"
        })
        panel:AddControl("CheckBox", {
            Label = "Compensate sensitivity for FOV",
            Command = "cl_tfa_scope_sensitivity_autoscale"
        })
        panel:AddControl("Slider", {
            Label = "Scope sensitivity",
            Command = "cl_tfa_scope_sensitivity",
            Type = "Integer",
            Min = "1",
            Max = "100"
        })
        panel:AddControl("Slider", {
            Label = "Gun Bob Intensity",
            Command = "cl_tfa_gunbob_intensity",
            Type = "Float",
            Min = "0",
            Max = "2"
        })
        panel:AddControl("Slider", {
            Label = "View Bob Intensity",
            Command = "cl_tfa_viewbob_intensity",
            Type = "Float",
            Min = "0",
            Max = "2"
        })
        panel:AddControl("Slider", {
            Label = "Viewmodel Offset - X",
            Command = "cl_tfa_viewmodel_offset_x",
            Type = "Float",
            Min = "-2",
            Max = "2"
        })
        panel:AddControl("Slider", {
            Label = "Viewmodel Offset - Y",
            Command = "cl_tfa_viewmodel_offset_y",
            Type = "Float",
            Min = "-2",
            Max = "2"
        })
        panel:AddControl("Slider", {
            Label = "Viewmodel Offset - Z",
            Command = "cl_tfa_viewmodel_offset_z",
            Type = "Float",
            Min = "-2",
            Max = "2"
        })
        panel:AddControl("Slider", {
            Label = "Viewmodel Offset - FOV",
            Command = "cl_tfa_viewmodel_offset_fov",
            Type = "Float",
            Min = "-5",
            Max = "5"
        })
        panel:AddControl("CheckBox", {
            Label = "Centered Viewmodel",
            Command = "cl_tfa_viewmodel_centered"
        })
        panel:AddControl("CheckBox", {
            Label = "Left Handed Viewmodel (Buggy)",
            Command = "cl_tfa_viewmodel_flip"
        })
        panel:AddControl("Label", {
            Text = "Creator of TFA Base By TheForgottenArchitect\nOptimizer of TFA Base By Etherinus"
        })
    end

    local function tfaOptionPerformance(panel)
        local tfaOptionPerf = {
            Options = {},
            CVars = {},
            Label = "#Presets",
            MenuButton = "1",
            Folder = "TFA SWEP Settings Performance"
        }

        tfaOptionPerf.Options["#Default"] = {
            sv_tfa_fx_penetration_decal        = "1",
            sv_tfa_fx_impact_override          = "-1",
            sv_tfa_fx_muzzlesmoke_override     = "-1",
            sv_tfa_fx_ejectionsmoke_override   = "-1",
            sv_tfa_fx_gas_override             = "-1",
            sv_tfa_worldmodel_culldistance     = "-1",
            cl_tfa_fx_impact_enabled           = "1",
            cl_tfa_fx_gasblur                  = "1",
            cl_tfa_fx_muzzlesmoke              = "1",
            cl_tfa_inspection_bokeh            = "0"
        }

        panel:AddControl("ComboBox", tfaOptionPerf)

        panel:AddControl("CheckBox", {
            Label = "Use Gas Blur",
            Command = "cl_tfa_fx_gasblur"
        })
        panel:AddControl("CheckBox", {
            Label = "Use Muzzle Smoke Trails",
            Command = "cl_tfa_fx_muzzlesmoke"
        })
        panel:AddControl("CheckBox", {
            Label = "Use Ejection Smoke",
            Command = "cl_tfa_fx_ejectionsmoke"
        })
        panel:AddControl("CheckBox", {
            Label = "Use Custom Impact FX",
            Command = "cl_tfa_fx_impact_enabled"
        })
        panel:AddControl("CheckBox", {
            Label = "Use Inspection BokehDOF",
            Command = "cl_tfa_inspection_bokeh"
        })
        panel:AddControl("Label", {
            Text = "Performance Overrides (Serverside)"
        })
        panel:AddControl("CheckBox", {
            Label = "Use Penetration Decal (SV)",
            Command = "sv_tfa_fx_penetration_decal"
        })
        panel:AddControl("Slider", {
            Label = "Gas Blur Effect Override (-1 to leave clientside)",
            Command = "sv_tfa_fx_gas_override",
            Type = "Integer",
            Min = "-1",
            Max = "1"
        })
        panel:AddControl("Slider", {
            Label = "Impact Effect Override (-1 to leave clientside)",
            Command = "sv_tfa_fx_impact_override",
            Type = "Integer",
            Min = "-1",
            Max = "1"
        })
        panel:AddControl("Slider", {
            Label = "Muzzle Smoke Effect Override (-1 to leave clientside)",
            Command = "sv_tfa_fx_muzzlesmoke_override",
            Type = "Integer",
            Min = "-1",
            Max = "1"
        })
        panel:AddControl("Slider", {
            Label = "Ejection Smoke Effect Override (-1 to leave clientside)",
            Command = "sv_tfa_fx_ejectionsmoke_override",
            Type = "Integer",
            Min = "-1",
            Max = "1"
        })
        panel:AddControl("Slider", {
            Label = "World Model Cull Distance (-1 to disable)",
            Command = "sv_tfa_worldmodel_culldistance",
            Type = "Integer",
            Min = "-1",
            Max = "4096"
        })
        panel:AddControl("Label", {
            Text = "Creator of TFA Base By TheForgottenArchitect\nOptimizer of TFA Base By Etherinus"
        })
    end

    local function tfaOptionHUD(panel)
        local tfaTBLOptionHUD = {
            Options = {},
            CVars = {},
            Label = "#Presets",
            MenuButton = "1",
            Folder = "TFA SWEP Settings HUD"
        }

        tfaTBLOptionHUD.Options["#Default"] = {
            cl_tfa_hud_crosshair_enable_custom = "1",
            cl_tfa_hud_crosshair_color_r       = "225",
            cl_tfa_hud_crosshair_color_g       = "225",
            cl_tfa_hud_crosshair_color_b       = "225",
            cl_tfa_hud_crosshair_color_a       = "225",
            cl_tfa_hud_crosshair_color_team    = "1",
            cl_tfa_hud_crosshair_outline_color_r = "5",
            cl_tfa_hud_crosshair_outline_color_g = "5",
            cl_tfa_hud_crosshair_outline_color_b = "5",
            cl_tfa_hud_crosshair_outline_color_a = "225",
            cl_tfa_hud_enabled                 = "1",
            cl_tfa_hud_ammodata_fadein         = "0.2",
            cl_tfa_hud_hangtime                = "1",
            cl_tfa_hud_crosshair_length_use_pixels = "0",
            cl_tfa_hud_crosshair_length        = "1",
            cl_tfa_hud_crosshair_width         = "1",
            cl_tfa_hud_crosshair_gap_scale     = "1",
            cl_tfa_hud_crosshair_outline_enabled = "1",
            cl_tfa_hud_crosshair_outline_width = "1",
            cl_tfa_hud_crosshair_dot           = "0",
            cl_tfa_hud_hitmarker_enabled       = "1",
            cl_tfa_hud_hitmarker_solidtime     = "0.1",
            cl_tfa_hud_hitmarker_fadetime      = "0.3",
            cl_tfa_hud_hitmarker_scale         = "1",
            cl_tfa_hud_hitmarker_color_r       = "225",
            cl_tfa_hud_hitmarker_color_g       = "225",
            cl_tfa_hud_hitmarker_color_b       = "225",
            cl_tfa_hud_hitmarker_color_a       = "225"
        }

        panel:AddControl("ComboBox", tfaTBLOptionHUD)

        panel:AddControl("CheckBox", {
            Label = "Use Custom HUD",
            Command = "cl_tfa_hud_enabled"
        })
        panel:AddControl("Slider", {
            Label = "Ammo HUD Fadein Time",
            Command = "cl_tfa_hud_ammodata_fadein",
            Type = "Float",
            Min = "0.01",
            Max = "1"
        })
        panel:AddControl("Slider", {
            Label = "HUD Hang Time (after a reload, etc.)",
            Command = "cl_tfa_hud_hangtime",
            Type = "Float",
            Min = "0",
            Max = "5"
        })

        panel:AddControl("Label", {Text = "-Crosshair Options-"})

        panel:AddControl("CheckBox", {
            Label = "Use Custom Crosshair",
            Command = "cl_tfa_hud_crosshair_enable_custom"
        })
        panel:AddControl("CheckBox", {
            Label = "Use Crosshair Dot",
            Command = "cl_tfa_hud_crosshair_dot"
        })
        panel:AddControl("CheckBox", {
            Label = "Crosshair Length In Pixels?",
            Command = "cl_tfa_hud_crosshair_length_use_pixels"
        })
        panel:AddControl("Slider", {
            Label = "Crosshair Length",
            Command = "cl_tfa_hud_crosshair_length",
            Type = "Float",
            Min = "0",
            Max = "10"
        })
        panel:AddControl("Slider", {
            Label = "Crosshair Gap Scale",
            Command = "cl_tfa_hud_crosshair_gap_scale",
            Type = "Float",
            Min = "0",
            Max = "2"
        })
        panel:AddControl("Slider", {
            Label = "Crosshair Width",
            Command = "cl_tfa_hud_crosshair_width",
            Type = "Integer",
            Min = "0",
            Max = "3"
        })
        panel:AddControl("Color", {
            Label = "Crosshair Color",
            Red = "cl_tfa_hud_crosshair_color_r",
            Green = "cl_tfa_hud_crosshair_color_g",
            Blue = "cl_tfa_hud_crosshair_color_b",
            Alpha = "cl_tfa_hud_crosshair_color_a",
            ShowHSV = 1,
            ShowRGB = 1,
            Multiplier = 255
        })
        panel:AddControl("CheckBox", {
            Label = "Enable Crosshair Teamcolor",
            Command = "cl_tfa_hud_crosshair_color_team"
        })
        panel:AddControl("CheckBox", {
            Label = "Enable Crosshair Outline",
            Command = "cl_tfa_hud_crosshair_outline_enabled"
        })
        panel:AddControl("Slider", {
            Label = "Crosshair Outline Width",
            Command = "cl_tfa_hud_crosshair_outline_width",
            Type = "Integer",
            Min = "0",
            Max = "3"
        })
        panel:AddControl("Color", {
            Label = "Crosshair Outline Color",
            Red = "cl_tfa_hud_crosshair_outline_color_r",
            Green = "cl_tfa_hud_crosshair_outline_color_g",
            Blue = "cl_tfa_hud_crosshair_outline_color_b",
            Alpha = "cl_tfa_hud_crosshair_outline_color_a",
            ShowHSV = 1,
            ShowRGB = 1,
            Multiplier = 255
        })

        panel:AddControl("CheckBox", {
            Label = "Enable Hitmarker",
            Command = "cl_tfa_hud_hitmarker_enabled"
        })
        panel:AddControl("Slider", {
            Label = "Hitmarker Solid Time",
            Command = "cl_tfa_hud_hitmarker_solidtime",
            Type = "Float",
            Min = "0",
            Max = "1"
        })
        panel:AddControl("Slider", {
            Label = "Hitmarker Fade Time",
            Command = "cl_tfa_hud_hitmarker_fadetime",
            Type = "Float",
            Min = "0",
            Max = "1"
        })
        panel:AddControl("Slider", {
            Label = "Hitmarker Scale",
            Command = "cl_tfa_hud_hitmarker_scale",
            Type = "Float",
            Min = "0",
            Max = "5"
        })
        panel:AddControl("Color", {
            Label = "Hitmarker Color",
            Red = "cl_tfa_hud_hitmarker_color_r",
            Green = "cl_tfa_hud_hitmarker_color_g",
            Blue = "cl_tfa_hud_hitmarker_color_b",
            Alpha = "cl_tfa_hud_hitmarker_color_a",
            ShowHSV = 1,
            ShowRGB = 1,
            Multiplier = 255
        })

        panel:AddControl("Label", {
            Text = "Creator of TFA Base By TheForgottenArchitect\nOptimizer of TFA Base By Etherinus"
        })
    end

    local function tfaOptionDeveloper(panel)
        local tfaOptionPerf = {
            Options = {},
            CVars = {},
            Label = "#Presets",
            MenuButton = "1",
            Folder = "TFA SWEP Settings Developer"
        }
        tfaOptionPerf.Options["#Default"] = {}
        panel:AddControl("ComboBox", tfaOptionPerf)

        panel:AddControl("CheckBox", {
            Label = "Force Debug Crosshair",
            Command = "cl_tfa_debugcrosshair"
        })

        panel:AddControl("Label", {
            Text = "Creator of TFA Base By TheForgottenArchitect\nOptimizer of TFA Base By Etherinus"
        })
    end

    function tfaAddOption()
        spawnmenu.AddToolMenuOption("Options", "TFA SWEP Base Settings", "tfaOptionWeapons", "Weapon Behavior, Clientside", "", "", tfaOptionClient)
        spawnmenu.AddToolMenuOption("Options", "TFA SWEP Base Settings", "tfaOptionPerformance", "Performance", "", "", tfaOptionPerformance)
        spawnmenu.AddToolMenuOption("Options", "TFA SWEP Base Settings", "TFASwepBaseCrosshair", "HUD / Crosshair", "", "", tfaOptionHUD)
        spawnmenu.AddToolMenuOption("Options", "TFA SWEP Base Settings", "TFASwepBaseDeveloper", "Developer", "", "", tfaOptionDeveloper)
        spawnmenu.AddToolMenuOption("Options", "TFA SWEP Base Settings", "TFASwepBaseServer", "Admin / Server", "", "", tfaOptionServer)
    end

    hook.Add("PopulateToolMenu", "tfaAddOption", tfaAddOption)
else
    AddCSLuaFile()
end
