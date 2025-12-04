if CLIENT then
    local spawnmenu_AddToolMenuOption = spawnmenu.AddToolMenuOption
    local spawnmenu_RebuildToolMenu = spawnmenu.RebuildToolMenu
    local hook_Add = hook.Add
    local cvars_AddChangeCallback = cvars.AddChangeCallback
    local RunConsoleCommand = RunConsoleCommand
    local GetConVar = GetConVar
    local timer_Simple = timer.Simple

    local function L(key)
        if TFA and TFA.GetLangString then
            return TFA.GetLangString(key)
        end

        return key
    end

    local function addFooter(panel)
        panel:AddControl("Label", { Text = L("ui_footer") })
    end

    local function tfaOptionServer(panel)
        local tfaOptionSV = {
            Options = {},
            CVars = {},
            Label = "#Presets",
            MenuButton = "1",
            Folder = "TFA SWEP Settings Server"
        }

        tfaOptionSV.Options["#Default"] = {
            sv_tfa_ironsights_enabled = "1",
            sv_tfa_sprint_enabled = "1",
            sv_tfa_weapon_strip = "0",
            sv_tfa_allow_dryfire = "1",
            sv_tfa_damage_multiplier = "1",
            sv_tfa_default_clip = "-1",
            sv_tfa_arrow_lifetime = "30",
            sv_tfa_force_multiplier = "1",
            sv_tfa_dynamicaccuracy = "1",
            sv_tfa_range_modifier = "0.5",
            sv_tfa_spread_multiplier = "1",
            sv_tfa_bullet_penetration = "1",
            sv_tfa_reloads_legacy = "0",
            sv_tfa_reloads_enabled = "1",
            sv_tfa_cmenu = "1",
            sv_tfa_penetration_limit = "2",
            sv_tfa_door_respawn = "-1"
        }

        panel:AddControl("ComboBox", tfaOptionSV)

        panel:AddControl("CheckBox", {
            Label = L("ui_sv_allow_dryfire"),
            Command = "sv_tfa_allow_dryfire"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_sv_dynamicaccuracy"),
            Command = "sv_tfa_dynamicaccuracy"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_sv_weapon_strip"),
            Command = "sv_tfa_weapon_strip"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_sv_ironsights_enabled"),
            Command = "sv_tfa_ironsights_enabled"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_sv_sprint_enabled"),
            Command = "sv_tfa_sprint_enabled"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_sv_cmenu"),
            Command = "sv_tfa_cmenu"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_sv_bullet_penetration"),
            Command = "sv_tfa_bullet_penetration"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_sv_reloads_enabled"),
            Command = "sv_tfa_reloads_enabled"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_sv_reloads_legacy"),
            Command = "sv_tfa_reloads_legacy"
        })

        panel:AddControl("Slider", {
            Label = L("ui_sv_damage_multiplier"),
            Command = "sv_tfa_damage_multiplier",
            Type = "Float",
            Min = "0",
            Max = "5"
        })

        panel:AddControl("Slider", {
            Label = L("ui_sv_door_respawn"),
            Command = "sv_tfa_door_respawn",
            Type = "Integer",
            Min = "-1",
            Max = "120"
        })

        panel:AddControl("Slider", {
            Label = L("ui_sv_force_multiplier"),
            Command = "sv_tfa_force_multiplier",
            Type = "Float",
            Min = "0",
            Max = "5"
        })

        panel:AddControl("Slider", {
            Label = L("ui_sv_spread_multiplier"),
            Command = "sv_tfa_spread_multiplier",
            Type = "Float",
            Min = "0",
            Max = "5"
        })

        panel:AddControl("Slider", {
            Label = L("ui_sv_penetration_limit"),
            Command = "sv_tfa_penetration_limit",
            Type = "Integer",
            Min = "0",
            Max = "5"
        })

        panel:AddControl("Slider", {
            Label = L("ui_sv_default_clip"),
            Command = "sv_tfa_default_clip",
            Type = "Integer",
            Min = "-1",
            Max = "10"
        })

        panel:AddControl("Slider", {
            Label = L("ui_sv_range_modifier"),
            Command = "sv_tfa_range_modifier",
            Type = "Float",
            Min = "0",
            Max = "1"
        })

        addFooter(panel)
    end

    local function tfaOptionClient(panel)
        local tfaOptionCL = {
            Options = {},
            CVars = {},
            Label = "#Presets",
            MenuButton = "1",
            Folder = "TFA SWEP Settings Client"
        }

        tfaOptionCL.Options["#Default"] = {
            cl_tfa_forcearms = "0",
            cl_tfa_3dscope = "1",
            cl_tfa_3dscope_overlay = "0",
            cl_tfa_scope_sensitivity_autoscale = "1",
            cl_tfa_scope_sensitivity = "100",
            cl_tfa_inspection_ckey = "0",
            cl_tfa_inspection_old = "0",
            cl_tfa_ironsights_toggle = "1",
            cl_tfa_ironsights_resight = "1",
            cl_tfa_viewbob_reloading = "1",
            cl_tfa_viewbob_drawing = "0",
            sv_tfa_gunbob_intensity = "1",
            sv_tfa_viewbob_intensity = "1",
            cl_tfa_viewmodel_offset_x = "0",
            cl_tfa_viewmodel_offset_y = "0",
            cl_tfa_viewmodel_offset_z = "0",
            cl_tfa_viewmodel_offset_fov = "0",
            cl_tfa_viewmodel_flip = "0",
            cl_tfa_viewmodel_centered = "0"
        }

        panel:AddControl("ComboBox", tfaOptionCL)

        panel:AddControl("CheckBox", {
            Label = L("ui_cl_forcearms"),
            Command = "cl_tfa_forcearms"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_cl_3dscope"),
            Command = "cl_tfa_3dscope"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_cl_3dscope_overlay"),
            Command = "cl_tfa_3dscope_overlay"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_cl_viewbob_drawing"),
            Command = "cl_tfa_viewbob_drawing"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_cl_viewbob_reloading"),
            Command = "cl_tfa_viewbob_reloading"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_cl_inspection_ckey"),
            Command = "cl_tfa_inspection_ckey"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_cl_inspection_old"),
            Command = "cl_tfa_inspection_old"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_cl_ironsights_toggle"),
            Command = "cl_tfa_ironsights_toggle"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_cl_ironsights_resight"),
            Command = "cl_tfa_ironsights_resight"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_cl_scope_sensitivity_autoscale"),
            Command = "cl_tfa_scope_sensitivity_autoscale"
        })

        panel:AddControl("Slider", {
            Label = L("ui_cl_scope_sensitivity"),
            Command = "cl_tfa_scope_sensitivity",
            Type = "Integer",
            Min = "1",
            Max = "100"
        })

        panel:AddControl("Slider", {
            Label = L("ui_cl_gunbob_intensity"),
            Command = "cl_tfa_gunbob_intensity",
            Type = "Float",
            Min = "0",
            Max = "2"
        })

        panel:AddControl("Slider", {
            Label = L("ui_cl_viewbob_intensity"),
            Command = "cl_tfa_viewbob_intensity",
            Type = "Float",
            Min = "0",
            Max = "2"
        })

        panel:AddControl("Slider", {
            Label = L("ui_cl_viewmodel_offset_x"),
            Command = "cl_tfa_viewmodel_offset_x",
            Type = "Float",
            Min = "-2",
            Max = "2"
        })

        panel:AddControl("Slider", {
            Label = L("ui_cl_viewmodel_offset_y"),
            Command = "cl_tfa_viewmodel_offset_y",
            Type = "Float",
            Min = "-2",
            Max = "2"
        })

        panel:AddControl("Slider", {
            Label = L("ui_cl_viewmodel_offset_z"),
            Command = "cl_tfa_viewmodel_offset_z",
            Type = "Float",
            Min = "-2",
            Max = "2"
        })

        panel:AddControl("Slider", {
            Label = L("ui_cl_viewmodel_offset_fov"),
            Command = "cl_tfa_viewmodel_offset_fov",
            Type = "Float",
            Min = "-5",
            Max = "5"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_cl_viewmodel_centered"),
            Command = "cl_tfa_viewmodel_centered"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_cl_viewmodel_flip"),
            Command = "cl_tfa_viewmodel_flip"
        })

        addFooter(panel)
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
            sv_tfa_fx_penetration_decal = "1",
            sv_tfa_fx_impact_override = "-1",
            sv_tfa_fx_muzzlesmoke_override = "-1",
            sv_tfa_fx_ejectionsmoke_override = "-1",
            sv_tfa_fx_gas_override = "-1",
            sv_tfa_worldmodel_culldistance = "-1",
            cl_tfa_fx_impact_enabled = "1",
            cl_tfa_fx_gasblur = "1",
            cl_tfa_fx_muzzlesmoke = "1",
            cl_tfa_inspection_bokeh = "0"
        }

        panel:AddControl("ComboBox", tfaOptionPerf)

        panel:AddControl("CheckBox", {
            Label = L("ui_perf_fx_gasblur"),
            Command = "cl_tfa_fx_gasblur"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_perf_fx_muzzlesmoke"),
            Command = "cl_tfa_fx_muzzlesmoke"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_perf_fx_ejectionsmoke"),
            Command = "cl_tfa_fx_ejectionsmoke"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_perf_fx_impact"),
            Command = "cl_tfa_fx_impact_enabled"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_perf_inspection_bokeh"),
            Command = "cl_tfa_inspection_bokeh"
        })

        panel:AddControl("Label", {
            Text = L("ui_perf_overrides")
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_sv_penetration_decal"),
            Command = "sv_tfa_fx_penetration_decal"
        })

        panel:AddControl("Slider", {
            Label = L("ui_sv_fx_gas_override"),
            Command = "sv_tfa_fx_gas_override",
            Type = "Integer",
            Min = "-1",
            Max = "1"
        })

        panel:AddControl("Slider", {
            Label = L("ui_sv_fx_impact_override"),
            Command = "sv_tfa_fx_impact_override",
            Type = "Integer",
            Min = "-1",
            Max = "1"
        })

        panel:AddControl("Slider", {
            Label = L("ui_sv_fx_muzzlesmoke_override"),
            Command = "sv_tfa_fx_muzzlesmoke_override",
            Type = "Integer",
            Min = "-1",
            Max = "1"
        })

        panel:AddControl("Slider", {
            Label = L("ui_sv_fx_ejectionsmoke_override"),
            Command = "sv_tfa_fx_ejectionsmoke_override",
            Type = "Integer",
            Min = "-1",
            Max = "1"
        })

        panel:AddControl("Slider", {
            Label = L("ui_sv_worldmodel_culldistance"),
            Command = "sv_tfa_worldmodel_culldistance",
            Type = "Integer",
            Min = "-1",
            Max = "4096"
        })

        addFooter(panel)
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
            cl_tfa_hud_crosshair_color_r = "225",
            cl_tfa_hud_crosshair_color_g = "225",
            cl_tfa_hud_crosshair_color_b = "225",
            cl_tfa_hud_crosshair_color_a = "225",
            cl_tfa_hud_crosshair_color_team = "1",
            cl_tfa_hud_crosshair_outline_color_r = "5",
            cl_tfa_hud_crosshair_outline_color_g = "5",
            cl_tfa_hud_crosshair_outline_color_b = "5",
            cl_tfa_hud_crosshair_outline_color_a = "225",
            cl_tfa_hud_enabled = "1",
            cl_tfa_hud_ammodata_fadein = "0.2",
            cl_tfa_hud_hangtime = "1",
            cl_tfa_hud_crosshair_length_use_pixels = "0",
            cl_tfa_hud_crosshair_length = "1",
            cl_tfa_hud_crosshair_width = "1",
            cl_tfa_hud_crosshair_gap_scale = "1",
            cl_tfa_hud_crosshair_outline_enabled = "1",
            cl_tfa_hud_crosshair_outline_width = "1",
            cl_tfa_hud_crosshair_dot = "0",
            cl_tfa_hud_hitmarker_enabled = "1",
            cl_tfa_hud_hitmarker_solidtime = "0.1",
            cl_tfa_hud_hitmarker_fadetime = "0.3",
            cl_tfa_hud_hitmarker_scale = "1",
            cl_tfa_hud_hitmarker_color_r = "225",
            cl_tfa_hud_hitmarker_color_g = "225",
            cl_tfa_hud_hitmarker_color_b = "225",
            cl_tfa_hud_hitmarker_color_a = "225"
        }

        panel:AddControl("ComboBox", tfaTBLOptionHUD)

        panel:AddControl("CheckBox", {
            Label = L("ui_hud_custom"),
            Command = "cl_tfa_hud_enabled"
        })

        panel:AddControl("Slider", {
            Label = L("ui_hud_ammo_fadein"),
            Command = "cl_tfa_hud_ammodata_fadein",
            Type = "Float",
            Min = "0.01",
            Max = "1"
        })

        panel:AddControl("Slider", {
            Label = L("ui_hud_hangtime"),
            Command = "cl_tfa_hud_hangtime",
            Type = "Float",
            Min = "0",
            Max = "5"
        })

        panel:AddControl("Label", { Text = L("ui_crosshair_section") })

        panel:AddControl("CheckBox", {
            Label = L("ui_crosshair_custom"),
            Command = "cl_tfa_hud_crosshair_enable_custom"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_crosshair_dot"),
            Command = "cl_tfa_hud_crosshair_dot"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_crosshair_length_pixels"),
            Command = "cl_tfa_hud_crosshair_length_use_pixels"
        })

        panel:AddControl("Slider", {
            Label = L("ui_crosshair_length"),
            Command = "cl_tfa_hud_crosshair_length",
            Type = "Float",
            Min = "0",
            Max = "10"
        })

        panel:AddControl("Slider", {
            Label = L("ui_crosshair_gap_scale"),
            Command = "cl_tfa_hud_crosshair_gap_scale",
            Type = "Float",
            Min = "0",
            Max = "2"
        })

        panel:AddControl("Slider", {
            Label = L("ui_crosshair_width"),
            Command = "cl_tfa_hud_crosshair_width",
            Type = "Integer",
            Min = "0",
            Max = "3"
        })

        panel:AddControl("Color", {
            Label = L("ui_crosshair_color"),
            Red = "cl_tfa_hud_crosshair_color_r",
            Green = "cl_tfa_hud_crosshair_color_g",
            Blue = "cl_tfa_hud_crosshair_color_b",
            Alpha = "cl_tfa_hud_crosshair_color_a",
            ShowHSV = 1,
            ShowRGB = 1,
            Multiplier = 255
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_crosshair_teamcolor"),
            Command = "cl_tfa_hud_crosshair_color_team"
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_crosshair_outline"),
            Command = "cl_tfa_hud_crosshair_outline_enabled"
        })

        panel:AddControl("Slider", {
            Label = L("ui_crosshair_outline_width"),
            Command = "cl_tfa_hud_crosshair_outline_width",
            Type = "Integer",
            Min = "0",
            Max = "3"
        })

        panel:AddControl("Color", {
            Label = L("ui_crosshair_outline_color"),
            Red = "cl_tfa_hud_crosshair_outline_color_r",
            Green = "cl_tfa_hud_crosshair_outline_color_g",
            Blue = "cl_tfa_hud_crosshair_outline_color_b",
            Alpha = "cl_tfa_hud_crosshair_outline_color_a",
            ShowHSV = 1,
            ShowRGB = 1,
            Multiplier = 255
        })

        panel:AddControl("CheckBox", {
            Label = L("ui_hitmarker_enable"),
            Command = "cl_tfa_hud_hitmarker_enabled"
        })

        panel:AddControl("Slider", {
            Label = L("ui_hitmarker_solid_time"),
            Command = "cl_tfa_hud_hitmarker_solidtime",
            Type = "Float",
            Min = "0",
            Max = "1"
        })

        panel:AddControl("Slider", {
            Label = L("ui_hitmarker_fade_time"),
            Command = "cl_tfa_hud_hitmarker_fadetime",
            Type = "Float",
            Min = "0",
            Max = "1"
        })

        panel:AddControl("Slider", {
            Label = L("ui_hitmarker_scale"),
            Command = "cl_tfa_hud_hitmarker_scale",
            Type = "Float",
            Min = "0",
            Max = "5"
        })

        panel:AddControl("Color", {
            Label = L("ui_hitmarker_color"),
            Red = "cl_tfa_hud_hitmarker_color_r",
            Green = "cl_tfa_hud_hitmarker_color_g",
            Blue = "cl_tfa_hud_hitmarker_color_b",
            Alpha = "cl_tfa_hud_hitmarker_color_a",
            ShowHSV = 1,
            ShowRGB = 1,
            Multiplier = 255
        })

        addFooter(panel)
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
            Label = L("ui_debug_crosshair"),
            Command = "cl_tfa_debugcrosshair"
        })

        addFooter(panel)
    end

    local function tfaOptionLanguage(panel)
        panel:ControlHelp(L("ui_language_desc"))
        panel:ControlHelp(L("ui_language_note"))

        local combo = panel:ComboBox(L("ui_language_label"), "cl_tfa_language")

        if combo.SetSortItems then
            combo:SetSortItems(false)
        end

        local choices = { "en", "ru", "fr", "de" }

        for _, code in ipairs(choices) do
            combo:AddChoice(L("ui_language_option_" .. code), code, false)
        end

        local current = GetConVar and GetConVar("cl_tfa_language")
        local selected = current and current:GetString() or "en"

        if selected == "" then
            selected = "en"
        end

        for id, code in ipairs(choices) do
            if code == selected then
                combo:ChooseOptionID(id)
                break
            end
        end

        function combo:OnSelect(_, _, data)
            if data then
                RunConsoleCommand("cl_tfa_language", data)
            end
        end

        addFooter(panel)
    end

    function tfaAddOption()
        local category = L("ui_menu_title")

        spawnmenu_AddToolMenuOption("Options", category, "TFASwepBaseLanguage", L("ui_cat_language"), "", "", tfaOptionLanguage)
        spawnmenu_AddToolMenuOption("Options", category, "tfaOptionWeapons", L("ui_cat_client"), "", "", tfaOptionClient)
        spawnmenu_AddToolMenuOption("Options", category, "tfaOptionPerformance", L("ui_cat_performance"), "", "", tfaOptionPerformance)
        spawnmenu_AddToolMenuOption("Options", category, "TFASwepBaseCrosshair", L("ui_cat_hud"), "", "", tfaOptionHUD)
        spawnmenu_AddToolMenuOption("Options", category, "TFASwepBaseDeveloper", L("ui_cat_developer"), "", "", tfaOptionDeveloper)
        spawnmenu_AddToolMenuOption("Options", category, "TFASwepBaseServer", L("ui_cat_server"), "", "", tfaOptionServer)
    end

    local function refreshLanguage()
        if not spawnmenu_RebuildToolMenu then
            return
        end

        timer_Simple(0, function()
            if spawnmenu_RebuildToolMenu then
                spawnmenu_RebuildToolMenu()
            end
        end)
    end

    cvars_AddChangeCallback("cl_tfa_language", refreshLanguage, "tfaLangRefresh")
    hook_Add("PopulateToolMenu", "tfaAddOption", tfaAddOption)
else
    AddCSLuaFile()
end
