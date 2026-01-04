if CLIENT then
    local spawnmenu_AddToolMenuOption = spawnmenu and spawnmenu.AddToolMenuOption
    local spawnmenu_RebuildToolMenu = spawnmenu and spawnmenu.RebuildToolMenu
    local hook_Add = hook and hook.Add
    local cvars_AddChangeCallback = cvars and cvars.AddChangeCallback
    local RunConsoleCommand = RunConsoleCommand
    local GetConVar = GetConVar
    local timer_Simple = timer and timer.Simple
    local ipairs = ipairs
    local tostring = tostring

    if not (spawnmenu_AddToolMenuOption and hook_Add) then
        return
    end

    local function L(key)
        if TFA and TFA.GetLangString then
            return TFA.GetLangString(key)
        end
        return key
    end

    local function addFooter(panel)
        if not panel or not panel.AddControl then
            return
        end
        panel:AddControl("Label", { Text = L("ui_footer") })
    end

    local function addCheck(panel, labelKey, cvar)
        panel:AddControl("CheckBox", {
            Label = L(labelKey),
            Command = cvar
        })
    end

    local function addSlider(panel, labelKey, cvar, kind, minv, maxv)
        panel:AddControl("Slider", {
            Label = L(labelKey),
            Command = cvar,
            Type = kind,
            Min = tostring(minv),
            Max = tostring(maxv)
        })
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

        addCheck(panel, "ui_sv_allow_dryfire", "sv_tfa_allow_dryfire")
        addCheck(panel, "ui_sv_dynamicaccuracy", "sv_tfa_dynamicaccuracy")
        addCheck(panel, "ui_sv_weapon_strip", "sv_tfa_weapon_strip")
        addCheck(panel, "ui_sv_ironsights_enabled", "sv_tfa_ironsights_enabled")
        addCheck(panel, "ui_sv_sprint_enabled", "sv_tfa_sprint_enabled")
        addCheck(panel, "ui_sv_cmenu", "sv_tfa_cmenu")
        addCheck(panel, "ui_sv_bullet_penetration", "sv_tfa_bullet_penetration")
        addCheck(panel, "ui_sv_reloads_enabled", "sv_tfa_reloads_enabled")
        addCheck(panel, "ui_sv_reloads_legacy", "sv_tfa_reloads_legacy")

        addSlider(panel, "ui_sv_damage_multiplier", "sv_tfa_damage_multiplier", "Float", 0, 5)
        addSlider(panel, "ui_sv_door_respawn", "sv_tfa_door_respawn", "Integer", -1, 120)
        addSlider(panel, "ui_sv_force_multiplier", "sv_tfa_force_multiplier", "Float", 0, 5)
        addSlider(panel, "ui_sv_spread_multiplier", "sv_tfa_spread_multiplier", "Float", 0, 5)
        addSlider(panel, "ui_sv_penetration_limit", "sv_tfa_penetration_limit", "Integer", 0, 5)
        addSlider(panel, "ui_sv_default_clip", "sv_tfa_default_clip", "Integer", -1, 10)
        addSlider(panel, "ui_sv_range_modifier", "sv_tfa_range_modifier", "Float", 0, 1)

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
            cl_tfa_scope_sensitivity_autoscale = "100",
            cl_tfa_scope_sensitivity = "100",
            cl_tfa_inspection_ckey = "0",
            cl_tfa_inspection_old = "0",
            cl_tfa_ironsights_toggle = "1",
            cl_tfa_ironsights_resight = "1",
            cl_tfa_viewbob_reloading = "1",
            cl_tfa_viewbob_drawing = "0",
            cl_tfa_gunbob_intensity = "1",
            cl_tfa_viewbob_intensity = "1",
            cl_tfa_viewmodel_offset_x = "0",
            cl_tfa_viewmodel_offset_y = "0",
            cl_tfa_viewmodel_offset_z = "0",
            cl_tfa_viewmodel_offset_fov = "0",
            cl_tfa_viewmodel_flip = "0",
            cl_tfa_viewmodel_centered = "0"
        }

        panel:AddControl("ComboBox", tfaOptionCL)

        addCheck(panel, "ui_cl_forcearms", "cl_tfa_forcearms")
        addCheck(panel, "ui_cl_3dscope", "cl_tfa_3dscope")
        addCheck(panel, "ui_cl_3dscope_overlay", "cl_tfa_3dscope_overlay")
        addCheck(panel, "ui_cl_viewbob_drawing", "cl_tfa_viewbob_drawing")
        addCheck(panel, "ui_cl_viewbob_reloading", "cl_tfa_viewbob_reloading")
        addCheck(panel, "ui_cl_inspection_ckey", "cl_tfa_inspection_ckey")
        addCheck(panel, "ui_cl_inspection_old", "cl_tfa_inspection_old")
        addCheck(panel, "ui_cl_ironsights_toggle", "cl_tfa_ironsights_toggle")
        addCheck(panel, "ui_cl_ironsights_resight", "cl_tfa_ironsights_resight")
        addCheck(panel, "ui_cl_scope_sensitivity_autoscale", "cl_tfa_scope_sensitivity_autoscale")

        addSlider(panel, "ui_cl_scope_sensitivity", "cl_tfa_scope_sensitivity", "Integer", 1, 100)
        addSlider(panel, "ui_cl_gunbob_intensity", "cl_tfa_gunbob_intensity", "Float", 0, 2)
        addSlider(panel, "ui_cl_viewbob_intensity", "cl_tfa_viewbob_intensity", "Float", 0, 2)

        addSlider(panel, "ui_cl_viewmodel_offset_x", "cl_tfa_viewmodel_offset_x", "Float", -2, 2)
        addSlider(panel, "ui_cl_viewmodel_offset_y", "cl_tfa_viewmodel_offset_y", "Float", -2, 2)
        addSlider(panel, "ui_cl_viewmodel_offset_z", "cl_tfa_viewmodel_offset_z", "Float", -2, 2)
        addSlider(panel, "ui_cl_viewmodel_offset_fov", "cl_tfa_viewmodel_offset_fov", "Float", -5, 5)

        addCheck(panel, "ui_cl_viewmodel_centered", "cl_tfa_viewmodel_centered")
        addCheck(panel, "ui_cl_viewmodel_flip", "cl_tfa_viewmodel_flip")

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
            cl_tfa_fx_ejectionsmoke = "1",
            cl_tfa_inspection_bokeh = "0"
        }

        panel:AddControl("ComboBox", tfaOptionPerf)

        addCheck(panel, "ui_perf_fx_gasblur", "cl_tfa_fx_gasblur")
        addCheck(panel, "ui_perf_fx_muzzlesmoke", "cl_tfa_fx_muzzlesmoke")
        addCheck(panel, "ui_perf_fx_ejectionsmoke", "cl_tfa_fx_ejectionsmoke")
        addCheck(panel, "ui_perf_fx_impact", "cl_tfa_fx_impact_enabled")
        addCheck(panel, "ui_perf_inspection_bokeh", "cl_tfa_inspection_bokeh")

        panel:AddControl("Label", { Text = L("ui_perf_overrides") })

        addCheck(panel, "ui_sv_penetration_decal", "sv_tfa_fx_penetration_decal")
        addSlider(panel, "ui_sv_fx_gas_override", "sv_tfa_fx_gas_override", "Integer", -1, 1)
        addSlider(panel, "ui_sv_fx_impact_override", "sv_tfa_fx_impact_override", "Integer", -1, 1)
        addSlider(panel, "ui_sv_fx_muzzlesmoke_override", "sv_tfa_fx_muzzlesmoke_override", "Integer", -1, 1)
        addSlider(panel, "ui_sv_fx_ejectionsmoke_override", "sv_tfa_fx_ejectionsmoke_override", "Integer", -1, 1)
        addSlider(panel, "ui_sv_worldmodel_culldistance", "sv_tfa_worldmodel_culldistance", "Integer", -1, 4096)

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

        addCheck(panel, "ui_hud_custom", "cl_tfa_hud_enabled")

        addSlider(panel, "ui_hud_ammo_fadein", "cl_tfa_hud_ammodata_fadein", "Float", 0.01, 1)
        addSlider(panel, "ui_hud_hangtime", "cl_tfa_hud_hangtime", "Float", 0, 5)

        panel:AddControl("Label", { Text = L("ui_crosshair_section") })

        addCheck(panel, "ui_crosshair_custom", "cl_tfa_hud_crosshair_enable_custom")
        addCheck(panel, "ui_crosshair_dot", "cl_tfa_hud_crosshair_dot")
        addCheck(panel, "ui_crosshair_length_pixels", "cl_tfa_hud_crosshair_length_use_pixels")

        addSlider(panel, "ui_crosshair_length", "cl_tfa_hud_crosshair_length", "Float", 0, 10)
        addSlider(panel, "ui_crosshair_gap_scale", "cl_tfa_hud_crosshair_gap_scale", "Float", 0, 2)
        addSlider(panel, "ui_crosshair_width", "cl_tfa_hud_crosshair_width", "Integer", 0, 3)

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

        addCheck(panel, "ui_crosshair_teamcolor", "cl_tfa_hud_crosshair_color_team")
        addCheck(panel, "ui_crosshair_outline", "cl_tfa_hud_crosshair_outline_enabled")
        addSlider(panel, "ui_crosshair_outline_width", "cl_tfa_hud_crosshair_outline_width", "Integer", 0, 3)

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

        addCheck(panel, "ui_hitmarker_enable", "cl_tfa_hud_hitmarker_enabled")
        addSlider(panel, "ui_hitmarker_solid_time", "cl_tfa_hud_hitmarker_solidtime", "Float", 0, 1)
        addSlider(panel, "ui_hitmarker_fade_time", "cl_tfa_hud_hitmarker_fadetime", "Float", 0, 1)
        addSlider(panel, "ui_hitmarker_scale", "cl_tfa_hud_hitmarker_scale", "Float", 0, 5)

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
        local tfaOptionDev = {
            Options = {},
            CVars = {},
            Label = "#Presets",
            MenuButton = "1",
            Folder = "TFA SWEP Settings Developer"
        }

        tfaOptionDev.Options["#Default"] = {}

        panel:AddControl("ComboBox", tfaOptionDev)
        addCheck(panel, "ui_debug_crosshair", "cl_tfa_debugcrosshair")
        addFooter(panel)
    end

    local function tfaOptionLanguage(panel)
        if panel and panel.ControlHelp then
            panel:ControlHelp(L("ui_language_desc"))
            panel:ControlHelp(L("ui_language_note"))
        end

        local combo = panel and panel.ComboBox and panel:ComboBox(L("ui_language_label"), "cl_tfa_language")
        if not combo then
            addFooter(panel)
            return
        end

        if combo.SetSortItems then
            combo:SetSortItems(false)
        end

        local choices = { "en", "ru", "fr", "de" }

        for _, code in ipairs(choices) do
            combo:AddChoice(L("ui_language_option_" .. code), code, false)
        end

        local current = GetConVar and GetConVar("cl_tfa_language")
        local selected = current and current.GetString and current:GetString() or "en"
        if selected == "" then
            selected = "en"
        end

        for id, code in ipairs(choices) do
            if code == selected then
                if combo.ChooseOptionID then
                    combo:ChooseOptionID(id)
                end
                break
            end
        end

        function combo:OnSelect(_, value, data)
            local v = data or value
            if v ~= nil then
                RunConsoleCommand("cl_tfa_language", tostring(v))
            end
        end

        addFooter(panel)
    end

    local function tfaAddOption()
        local category = L("ui_menu_title")

        spawnmenu_AddToolMenuOption("Options", category, "TFASwepBaseLanguage", L("ui_cat_language"), "", "", tfaOptionLanguage)
        spawnmenu_AddToolMenuOption("Options", category, "tfaOptionWeapons", L("ui_cat_client"), "", "", tfaOptionClient)
        spawnmenu_AddToolMenuOption("Options", category, "tfaOptionPerformance", L("ui_cat_performance"), "", "", tfaOptionPerformance)
        spawnmenu_AddToolMenuOption("Options", category, "TFASwepBaseCrosshair", L("ui_cat_hud"), "", "", tfaOptionHUD)
        spawnmenu_AddToolMenuOption("Options", category, "TFASwepBaseDeveloper", L("ui_cat_developer"), "", "", tfaOptionDeveloper)
        spawnmenu_AddToolMenuOption("Options", category, "TFASwepBaseServer", L("ui_cat_server"), "", "", tfaOptionServer)
    end

    local function refreshLanguage()
        if not (spawnmenu_RebuildToolMenu and timer_Simple) then
            return
        end

        timer_Simple(0, function()
            if spawnmenu_RebuildToolMenu then
                spawnmenu_RebuildToolMenu()
            end
        end)
    end

    if cvars_AddChangeCallback then
        cvars_AddChangeCallback("cl_tfa_language", refreshLanguage, "tfaLangRefresh")
    end

    hook_Add("PopulateToolMenu", "tfaAddOption", tfaAddOption)
else
    AddCSLuaFile()
end
