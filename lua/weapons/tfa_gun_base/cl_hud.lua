local CMIX_MULT = 1
local c1t = {}
local c2t = {}

local IsValid = IsValid
local Lerp = Lerp
local Color = Color
local ColorAlpha = ColorAlpha
local LocalPlayer = LocalPlayer
local ScrW = ScrW
local ScrH = ScrH
local FrameTime = FrameTime
local RealTime = RealTime

local math_abs = math.abs
local math_ceil = math.ceil
local math_clamp = math.Clamp
local math_cos = math.cos
local math_floor = math.floor
local math_min = math.min
local math_normalizeAngle = math.NormalizeAngle
local math_pow = math.pow
local math_rad = math.rad
local math_round = math.Round
local math_Approach = math.Approach
local math_ApproachAngle = math.ApproachAngle

local surface = surface
local draw = draw
local util = util
local vgui = vgui
local cam = cam
local game = game
local language = language

local color_white = color_white
local color_black = color_black

local function ColorMix(c1, c2, fac, t)
    c1t.r = c1.r
    c1t.g = c1.g
    c1t.b = c1.b
    c1t.a = c1.a

    c2t.r = c2.r
    c2t.g = c2.g
    c2t.b = c2.b
    c2t.a = c2.a

    for k, v in pairs(c1t) do
        if t == CMIX_MULT then
            local mul = (v / 255) * (c2t[k] / 255) * 255
            c1t[k] = Lerp(fac, v, mul)
        else
            c1t[k] = Lerp(fac, v, c2t[k])
        end
    end

    return Color(c1t.r, c1t.g, c1t.b, c1t.a)
end

local c_red = Color(255, 0, 0, 255)
local c_grn = Color(0, 255, 0, 255)

local function SafeTextureID(path)
    if not path or path == "" then
        return surface.GetTextureID("vgui/white")
    end

    local id = surface.GetTextureID(path)
    if id == 0 then
        id = surface.GetTextureID("no_material")
    end

    if id == 0 then
        id = surface.GetTextureID("vgui/white")
    end

    return id
end

local function L(key)
    if TFA and TFA.GetLangString then
        return TFA.GetLangString(key)
    end

    return key
end

local hostilenpcmaps = {
    ["gm_lasers"] = true,
    ["gm_locals"] = true,
    ["gm_raid"] = true,
    ["gm_slam"] = true
}

local mymap
local cl_tfa_hud_crosshair_color_teamcvar

local function GetTeamColor(ent)
    if not cl_tfa_hud_crosshair_color_teamcvar then
        cl_tfa_hud_crosshair_color_teamcvar = GetConVar("cl_tfa_hud_crosshair_color_team")
    end

    if cl_tfa_hud_crosshair_color_teamcvar and not cl_tfa_hud_crosshair_color_teamcvar:GetBool() then
        return color_white
    end

    if not mymap then
        mymap = game.GetMap()
    end

    local ply = LocalPlayer()
    if not IsValid(ply) then
        return color_white
    end

    if not IsValid(ent) then
        return color_white
    end

    if ent:IsPlayer() then
        if GAMEMODE and GAMEMODE.TeamBased then
            if ent:Team() == ply:Team() then
                return c_grn
            end
            return c_red
        end

        return c_red
    end

    if ent:IsNPC() then
        local disp = ent:GetNW2Int("tfa_disposition", -1)

        if disp > 0 then
            if disp == (D_FR or 2) or disp == (D_HT or 1) then
                return c_red
            end
            return c_grn
        end

        if IsFriendEntityName(ent:GetClass()) and not hostilenpcmaps[mymap] then
            return c_grn
        end

        return c_red
    end

    return color_white
end

local function RoundDecimals(num, decimals)
    local decfactor = math_pow(10, decimals)
    return math_round(tonumber(num) * decfactor) / decfactor
end

local titlefont
local descriptionfont
local smallfont

function SWEP:MakeFonts()
    if not titlefont then
        surface.CreateFont("TFA_INSPECTION_TITLE", {
            font = "Aral",
            size = 64,
            weight = 500,
            blursize = 0,
            scanlines = 0,
            antialias = true,
            underline = false,
            italic = false,
            strikeout = false,
            symbol = false,
            rotary = false,
            shadow = false,
            additive = false,
            outline = false
        })

        titlefont = true
    end

    if not descriptionfont then
        surface.CreateFont("TFA_INSPECTION_DESCR", {
            font = "Aral",
            size = 32,
            weight = 500,
            blursize = 0,
            scanlines = 0,
            antialias = true,
            underline = false,
            italic = false,
            strikeout = false,
            symbol = false,
            rotary = false,
            shadow = false,
            additive = false,
            outline = false
        })

        descriptionfont = true
    end

    if not smallfont then
        surface.CreateFont("TFA_INSPECTION_SMALL", {
            font = "Aral",
            size = 24,
            weight = 500,
            blursize = 0,
            scanlines = 0,
            antialias = true,
            underline = false,
            italic = false,
            strikeout = false,
            symbol = false,
            rotary = false,
            shadow = false,
            additive = false,
            outline = false
        })

        smallfont = true
    end
end

local function PanelPaintBars(myself, w, h)
    w = 400

    local xx = w * 0.7
    local ww = w - xx
    local blockw = math_floor(ww / 15)
    local padw = math_floor(ww / 10)

    surface.SetDrawColor(ColorAlpha(TFA_INSPECTIONPANEL.BackgroundColor, (TFA_INSPECTIONPANEL.Alpha or 0) / 2))

    for _ = 0, 9 do
        surface.DrawRect(xx, 2, blockw, h - 5)
        xx = math_floor(xx + padw)
    end

    xx = w * 0.7
    surface.SetDrawColor(TFA_INSPECTIONPANEL.BackgroundColor)

    for _ = 0, myself.Bars - 1 do
        surface.DrawRect(xx + 1, 3, blockw, h - 5)
        xx = math_floor(xx + padw)
    end

    xx = w * 0.7
    surface.SetDrawColor(TFA_INSPECTIONPANEL.SecondaryColor)

    for _ = 0, myself.Bars - 1 do
        surface.DrawRect(xx, 2, blockw, h - 5)
        xx = math_floor(xx + padw)
    end
end

local function TextShadowPaint(myself, w, h)
    if not myself.TextColor then
        myself.TextColor = ColorAlpha(color_white, 0)
    end

    draw.NoTexture()
    draw.SimpleText(myself.Text, myself.Font, 2, 2, ColorAlpha(color_black, myself.TextColor.a), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.SimpleText(myself.Text, myself.Font, 0, 0, myself.TextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

local function kmtofeet(km)
    return km * 3280.84
end

local function feettokm(feet)
    return feet / 3280.84
end

local function feettosource(feet)
    return feet * 16
end

local function sourcetofeet(u)
    return u / 16
end

local pad = 4
local sidebar_width = 16
local infotextpad = "  "
local INSPECTION_BACKGROUND = Color(15, 15, 15, 64)
local INSPECTION_ACTIVECOLOR = Color(255, 147, 4, 255)
local INSPECTION_PRIMARYCOLOR = Color(245, 245, 245, 255)
local INSPECTION_SECONDARYCOLOR = Color(153, 253, 220, 255)
local worstaccuracy = 0.06
local bestrpm = 1200
local worstmove = 0.8
local bestdamage = 100
local bestrange = feettosource(kmtofeet(1))
local worstrecoil = 1
local attachmentpanelscale = 1 / 4
local attachmentcount = 16

local hexpositions = {
    [1] = { x = 0, y = -233 },
    [2] = { x = 186, y = -111 },
    [3] = { x = 186, y = 111 },
    [4] = { x = 0, y = 233 },
    [5] = { x = -186, y = 111 },
    [6] = { x = -186, y = -111 }
}

SWEP.AmmoTypeStrings = {
    ["pistol"] = "hud_ammo_generic_pistol",
    ["smg1"] = "hud_ammo_generic_smg",
    ["ar2"] = "hud_ammo_generic_rifle",
    ["buckshot"] = "hud_ammo_generic_shotgun",
    ["357"] = "hud_ammo_generic_revolver",
    ["SniperPenetratedRound"] = "hud_ammo_generic_sniper"
}

local function hexpaint1(myself, w, h)
    if not IsValid(myself.Wep) then
        return
    end

    if not myself.iconmat then
        myself.iconmat = SafeTextureID(myself.icon)
    end

    local cache = myself.Wep.AttachmentCache
    local node = cache and cache[myself.attachment]
    local mys_isactive = node and node.active

    if mys_isactive then
        myself.parent.activehex = myself.hexi
    end

    local mycol = mys_isactive and TFA_INSPECTIONPANEL.ActiveColor or TFA_INSPECTIONPANEL.PrimaryColor
    surface.SetDrawColor(mycol)
    surface.SetTexture(TFA_INSPECTIONPANEL.Hex or 1)
    surface.DrawTexturedRect(0, 0, w, h)
    surface.SetTexture(myself.iconmat or 1)
    surface.DrawTexturedRect(w * (1 - myself.iconscale) / 2, h * (1 - myself.iconscale) / 2, w * myself.iconscale, h * myself.iconscale)
end

local function hexpaint2(myself, w, h)
    if not IsValid(myself.Wep) then
        return
    end

    if not myself.iconmat then
        myself.iconmat = SafeTextureID(myself.icon)
    end

    local mys_isactive = true

    for _, vvv in pairs(myself.Wep.AttachmentCache or {}) do
        if vvv.key == myself.key and vvv.active then
            mys_isactive = false
            break
        end
    end

    if mys_isactive then
        myself.parent.activehex = myself.hexi
    end

    local mycol = mys_isactive and TFA_INSPECTIONPANEL.ActiveColor or TFA_INSPECTIONPANEL.PrimaryColor
    surface.SetDrawColor(mycol)
    surface.SetTexture(TFA_INSPECTIONPANEL.Hex or 1)
    surface.DrawTexturedRect(0, 0, w, h)
    surface.SetTexture(myself.iconmat or 1)
    surface.DrawTexturedRect(w * (1 - myself.iconscale) / 2, h * (1 - myself.iconscale) / 2, w * myself.iconscale, h * myself.iconscale)
end

function SWEP:BuildAttachmentUICache()
    self.AttachmentUICache = {}
    self.AttachmentCache = self.AttachmentCache or {}
    self.Attachments = self.Attachments or {}

    for keyv, tab in pairs(self.Attachments) do
        if tab and tab.atts and tab.cat and tab.anchor then
            self.AttachmentUICache[tab.cat] = {
                key = keyv,
                attachment = tab.anchor.att or 1,
                x = tab.anchor.xoff or 0,
                y = tab.anchor.yoff or 0,
                atts = {}
            }

            for _, attid in pairs(tab.atts) do
                local tbl = TFA_ATT and TFA_ATT[attid]
                if tbl then
                    self.AttachmentUICache[tab.cat].atts[attid] = {
                        title = tbl.Name or "Generic Attachment",
                        icon = tbl.Icon or "vgui/inspectionhud/qmark",
                        iconscale = tbl.IconScale or 0.7,
                        desc = tbl.Description or { color_white, "Generic Attachment Description" }
                    }
                end
            end
        end
    end
end

function SWEP:GenerateInspectionDerma()
    TFA_INSPECTIONPANEL = vgui.Create("DPanel")
    TFA_INSPECTIONPANEL:SetSize(ScrW(), ScrH())
    self:MakeFonts()

    TFA_INSPECTIONPANEL.Think = function(myself)
        local ply = LocalPlayer()
        if not IsValid(ply) then
            myself:Remove()
            return
        end

        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or not wep.IsTFAWeapon or (wep.InspectingProgress or 0) <= 0.01 then
            myself:Remove()
            return
        end

        myself.Player = ply
        myself.Weapon = wep
    end

    TFA_INSPECTIONPANEL.Paint = function(myself, w, h)
        local wep = self
        if not IsValid(wep) then
            return
        end

        myself.Alpha = (wep.InspectingProgress or 0) * 255
        myself.PrimaryColor = ColorAlpha(INSPECTION_PRIMARYCOLOR, myself.Alpha)
        myself.SecondaryColor = ColorAlpha(INSPECTION_SECONDARYCOLOR, myself.Alpha)
        myself.BackgroundColor = ColorAlpha(INSPECTION_BACKGROUND, myself.Alpha)
        myself.ActiveColor = ColorAlpha(INSPECTION_ACTIVECOLOR, myself.Alpha)

        if not myself.SideBar then
            myself.SideBar = SafeTextureID("vgui/inspectionhud/sidebar")
        end

        if not myself.Hex then
            myself.Hex = SafeTextureID("vgui/inspectionhud/hex")
        end
    end

    local screenwidth, screenheight = ScrW(), ScrH()
    local hv = math_round(screenheight * 0.8)
    local contentpanel = vgui.Create("DPanel", TFA_INSPECTIONPANEL)
    contentpanel:SetPos(sidebar_width, (screenheight - hv) / 2)
    contentpanel:DockPadding(sidebar_width + pad, pad, pad, pad)
    contentpanel:SetSize(screenwidth - sidebar_width, hv)

    contentpanel.Paint = function(myself, w, h)
        local mycol = TFA_INSPECTIONPANEL.SecondaryColor
        if not mycol then
            return
        end

        surface.SetDrawColor(mycol)
        surface.SetTexture(TFA_INSPECTIONPANEL.SideBar or 1)
        surface.DrawTexturedRect(0, 0, sidebar_width, h)
    end

    local lbound = sidebar_width + pad

    local titletext = contentpanel:Add("DPanel")
    titletext.Text = self.PrintName or "TFA Weapon"
    titletext.Think = function(myself)
        myself.TextColor = TFA_INSPECTIONPANEL.PrimaryColor
    end
    titletext.Font = "TFA_INSPECTION_TITLE"
    titletext:Dock(TOP)
    titletext:SetSize(screenwidth - lbound, 64)
    titletext.Paint = TextShadowPaint

    local typetext = contentpanel:Add("DPanel")
    typetext.Text = self:GetType()
    typetext.Think = function(myself)
        myself.TextColor = TFA_INSPECTIONPANEL.PrimaryColor
    end
    typetext.Font = "TFA_INSPECTION_DESCR"
    typetext:Dock(TOP)
    typetext:SetSize(screenwidth - lbound, 32)
    typetext.Paint = TextShadowPaint

    local spacer = contentpanel:Add("DPanel")
    spacer:Dock(TOP)
    spacer:SetSize(screenwidth - lbound, 64)
    spacer.Paint = function() end

    local descriptiontext = contentpanel:Add("DPanel")
    descriptiontext.Text = (self.Description or self.Category) or self.Base
    descriptiontext.Think = function(myself)
        myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
    end
    descriptiontext.Font = "TFA_INSPECTION_SMALL"
    descriptiontext:Dock(TOP)
    descriptiontext:SetSize(screenwidth - lbound, 24)
    descriptiontext.Paint = TextShadowPaint

    local rpmtext = contentpanel:Add("DPanel")
    rpmtext.Text = string.format("%s%s: %sRPM", infotextpad, L("hud_inspect_firerate"), math_floor((self.Primary and self.Primary.RPM) or 0))
    rpmtext.Think = function(myself)
        myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
    end
    rpmtext.Font = "TFA_INSPECTION_SMALL"
    rpmtext:Dock(TOP)
    rpmtext:SetSize(screenwidth - lbound, 24)
    rpmtext.Paint = TextShadowPaint

    local capacitytext = contentpanel:Add("DPanel")
    local canChamber = self.CanChamber and self:CanChamber()
    local chamber = canChamber and (self.Akimbo and " + 2" or " + 1") or ""
    capacitytext.Text = string.format("%s%s: %s%s %s", infotextpad, L("hud_inspect_capacity"), (self.Primary and self.Primary.ClipSize) or 0, chamber, L("hud_inspect_rounds"))
    capacitytext.Think = function(myself)
        myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
    end
    capacitytext.Font = "TFA_INSPECTION_SMALL"
    capacitytext:Dock(TOP)
    capacitytext:SetSize(screenwidth - lbound, 24)
    capacitytext.Paint = TextShadowPaint

    local an = game.GetAmmoName(self:GetPrimaryAmmoType())
    if an and an ~= "" and string.len(an) > 1 then
        local ammotypetext = contentpanel:Add("DPanel")
        local ammoKey = (self.Primary and self.Primary.Ammo) or "ammo"
        local ammoName = self.AmmoTypeStrings[ammoKey] or language.GetPhrase(an .. "_ammo")
        ammotypetext.Text = string.format("%s%s: %s", infotextpad, L("hud_inspect_ammo"), L(ammoName))
        ammotypetext.Think = function(myself)
            myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
        end
        ammotypetext.Font = "TFA_INSPECTION_SMALL"
        ammotypetext:Dock(TOP)
        ammotypetext:SetSize(screenwidth - lbound, 24)
        ammotypetext.Paint = TextShadowPaint
    end

    local makertext = contentpanel:Add("DPanel")
    local mymaker = self.Manufacturer or self.Author
    if not mymaker or string.Trim(mymaker) == "" then
        mymaker = "The Forgotten Architect"
    end
    makertext.Text = string.format("%s%s: %s", infotextpad, L("hud_inspect_maker"), mymaker)
    makertext.Think = function(myself)
        myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
    end
    makertext.Font = "TFA_INSPECTION_SMALL"
    makertext:Dock(TOP)
    makertext:SetSize(screenwidth - lbound, 24)
    makertext.Paint = TextShadowPaint

    TFA_INSPECTIONPANEL.UpdateAttachment = function(attid)
        if IsValid(contentpanel.attpanel) then
            contentpanel.attpanel:Remove()
        end

        contentpanel.attpanel = contentpanel:Add("DPanel")
        contentpanel.attpanel.Paint = function() end

        local tbl = TFA_ATT and TFA_ATT[attid]
        if not tbl then
            return
        end

        local header = contentpanel.attpanel:Add("DPanel")
        header.Text = tbl.Name or "New Attachment"
        header.Think = function(myself)
            myself.TextColor = TFA_INSPECTIONPANEL.PrimaryColor
        end
        header.Font = "TFA_INSPECTION_TITLE"
        header:Dock(TOP)
        header:SetSize(screenwidth - lbound, 64)
        header.Paint = TextShadowPaint

        local baseCol = TFA_INSPECTIONPANEL.PrimaryColor or color_white
        local c = Color(baseCol.r, baseCol.g, baseCol.b, baseCol.a)

        if tbl.Description then
            for _, line in pairs(tbl.Description) do
                local t = type(line)
                if t == "vector" then
                    c.r = line.x
                    c.g = line.y
                    c.b = line.z
                elseif t == "table" then
                    c.r = line.r
                    c.g = line.g
                    c.b = line.b
                    c.a = line.a
                elseif t == "string" then
                    local descline = contentpanel.attpanel:Add("DPanel")
                    descline.Text = line or "New Attachment"
                    descline.c = Color(c.r, c.g, c.b, c.a)

                    descline.Think = function(myself)
                        myself.TextColor = ColorAlpha(myself.c, TFA_INSPECTIONPANEL.Alpha or 0)
                    end

                    descline.Font = "TFA_INSPECTION_DESCR"
                    descline:Dock(TOP)
                    descline:SetSize(screenwidth - lbound, 32)
                    descline.Paint = TextShadowPaint
                end
            end
        end

        contentpanel.attpanel:SizeToContents()
    end

    local statspanel = contentpanel:Add("DPanel")
    statspanel:SetSize(screenwidth - lbound, 144)
    statspanel.Paint = function() end
    statspanel:Dock(BOTTOM)

    local accuracypanel = statspanel:Add("DPanel")
    accuracypanel:SetSize(400, 24)
    accuracypanel.Think = function(myself)
        if not IsValid(self) then
            return
        end

        local spread = (self.Primary and (self.Primary.Spread or self.Primary.Accuracy)) or 0
        local ironspread = (self.Primary and (self.Primary.IronAccuracy or self.Primary.IronSpread)) or spread
        local useIron = self.Secondary and self.Secondary.Ironsights ~= 0
        local val = useIron and ironspread or spread
        myself.Bars = math_clamp(math_round((1 - (val / worstaccuracy)) * 10), 0, 10)
    end
    accuracypanel.Paint = PanelPaintBars
    accuracypanel:Dock(TOP)

    local accuracytext = accuracypanel:Add("DPanel")
    accuracytext.Think = function(myself)
        if not IsValid(self) then
            return
        end

        local spread = (self.Primary and (self.Primary.Spread or self.Primary.Accuracy)) or 0
        local ironspread = (self.Primary and (self.Primary.IronAccuracy or self.Primary.IronSpread)) or spread

        local accuracystr = L("hud_inspect_accuracy") .. ": " .. math_round(spread * 90) .. "°"
        if self.Secondary and self.Secondary.Ironsights ~= 0 then
            accuracystr = accuracystr .. " || " .. math_round(ironspread * 90) .. "°"
        end

        myself.Text = accuracystr
        myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
    end
    accuracytext.Font = "TFA_INSPECTION_SMALL"
    accuracytext:Dock(LEFT)
    accuracytext:SetSize(screenwidth - lbound, 24)
    accuracytext.Paint = TextShadowPaint

    local fireratepanel = statspanel:Add("DPanel")
    fireratepanel:SetSize(400, 24)
    fireratepanel.Think = function(myself)
        if not IsValid(self) then
            return
        end
        local rpm = (self.Primary and self.Primary.RPM) or 0
        myself.Bars = math_clamp(math_round(rpm / bestrpm * 10), 0, 10)
    end
    fireratepanel.Paint = PanelPaintBars
    fireratepanel:Dock(TOP)

    local fireratetext = fireratepanel:Add("DPanel")
    fireratetext.Think = function(myself)
        if not IsValid(self) then
            return
        end
        local rpm = (self.Primary and self.Primary.RPM) or 0
        myself.Text = L("hud_inspect_firerate") .. ": " .. rpm .. "RPM"
        myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
    end
    fireratetext.Font = "TFA_INSPECTION_SMALL"
    fireratetext:Dock(LEFT)
    fireratetext:SetSize(screenwidth - lbound, 24)
    fireratetext.Paint = TextShadowPaint

    local mobilitypanel = statspanel:Add("DPanel")
    mobilitypanel:SetSize(400, 24)
    mobilitypanel.Think = function(myself)
        if not IsValid(self) then
            return
        end
        local mv = self.MoveSpeed or 1
        myself.Bars = math_clamp(math_round((mv - worstmove) / (1 - worstmove) * 10), 0, 10)
    end
    mobilitypanel.Paint = PanelPaintBars
    mobilitypanel:Dock(TOP)

    local mobilitytext = mobilitypanel:Add("DPanel")
    mobilitytext.Think = function(myself)
        if not IsValid(self) then
            return
        end
        local mv = self.MoveSpeed or 1
        myself.Text = L("hud_inspect_mobility") .. ": " .. math_round(mv * 100) .. "%"
        myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
    end
    mobilitytext.Font = "TFA_INSPECTION_SMALL"
    mobilitytext:Dock(LEFT)
    mobilitytext:SetSize(screenwidth - lbound, 24)
    mobilitytext.Paint = TextShadowPaint

    local damagepanel = statspanel:Add("DPanel")
    damagepanel:SetSize(400, 24)
    damagepanel.Think = function(myself)
        if not IsValid(self) then
            return
        end

        local dmg = (self.Primary and self.Primary.Damage) or 0
        local shots = (self.Primary and self.Primary.NumShots) or 1
        myself.Bars = math_clamp(math_round((dmg * math_round(shots * 0.75)) / bestdamage * 10), 0, 10)
    end
    damagepanel.Paint = PanelPaintBars
    damagepanel:Dock(TOP)

    local damagetext = damagepanel:Add("DPanel")
    damagetext.Think = function(myself)
        if not IsValid(self) then
            return
        end

        local dmg = (self.Primary and self.Primary.Damage) or 0
        local shots = (self.Primary and self.Primary.NumShots) or 1

        local dmgstr = L("hud_inspect_damage") .. ": " .. math_round(dmg)
        if shots ~= 1 then
            dmgstr = dmgstr .. "x" .. math_round(shots)
        end

        myself.Text = dmgstr
        myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
    end
    damagetext.Font = "TFA_INSPECTION_SMALL"
    damagetext:Dock(LEFT)
    damagetext:SetSize(screenwidth - lbound, 24)
    damagetext.Paint = TextShadowPaint

    local rangepanel = statspanel:Add("DPanel")
    rangepanel:SetSize(400, 24)
    rangepanel.Think = function(myself)
        if not IsValid(self) then
            return
        end

        local range = (self.Primary and self.Primary.Range) or 0
        myself.Bars = math_clamp(math_round(range / bestrange * 10), 0, 10)
    end
    rangepanel.Paint = PanelPaintBars
    rangepanel:Dock(TOP)

    local rangetext = rangepanel:Add("DPanel")
    rangetext.Think = function(myself)
        if not IsValid(self) then
            return
        end

        local range = (self.Primary and self.Primary.Range) or 0
        local rangestr = L("hud_inspect_range") .. ": " .. (math_round(feettokm(sourcetofeet(range)) * 100) / 100) .. "K"
        myself.Text = rangestr
        myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
    end
    rangetext.Font = "TFA_INSPECTION_SMALL"
    rangetext:Dock(LEFT)
    rangetext:SetSize(screenwidth - lbound, 24)
    rangetext.Paint = TextShadowPaint

    local stabilitypanel = statspanel:Add("DPanel")
    stabilitypanel:SetSize(400, 24)
    stabilitypanel.Think = function(myself)
        if not IsValid(self) then
            return
        end

        local ku = (self.Primary and self.Primary.KickUp) or 0
        local kd = (self.Primary and self.Primary.KickDown) or 0
        myself.Bars = math_clamp(math_round((1 - math_abs(ku + kd) / 2 / worstrecoil) * 10), 0, 10)
    end
    stabilitypanel.Paint = PanelPaintBars
    stabilitypanel:Dock(TOP)

    local stabilitytext = stabilitypanel:Add("DPanel")
    stabilitytext.Think = function(myself)
        if not IsValid(self) then
            return
        end

        local ku = (self.Primary and self.Primary.KickUp) or 0
        local kd = (self.Primary and self.Primary.KickDown) or 0
        local stabilitystr = L("hud_inspect_stability") .. ": " .. math_clamp(math_round((1 - math_abs(ku + kd) / 2 / 1) * 100), 0, 100) .. "%"
        myself.Text = stabilitystr
        myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
    end
    stabilitytext.Font = "TFA_INSPECTION_SMALL"
    stabilitytext:Dock(LEFT)
    stabilitytext:SetSize(screenwidth - lbound, 24)
    stabilitytext.Paint = TextShadowPaint
end

function SWEP:DoInspectionDerma()
    self.InspectingProgress = self.InspectingProgress or 0

    if not IsValid(TFA_INSPECTIONPANEL) and self.InspectingProgress > 0.01 then
        self:GenerateInspectionDerma()
    end

    if not IsValid(TFA_INSPECTIONPANEL) then
        return
    end

    if not self.OwnerIsValid or not self:OwnerIsValid() then
        return
    end

    if not self.AttachmentUICache then
        self:BuildAttachmentUICache()
    end

    cam.Start3D()
    cam.End3D()

    local owner = self.GetOwner and self:GetOwner() or self.Owner
    if not IsValid(owner) then
        return
    end

    local vm = owner:GetViewModel()
    if not IsValid(vm) then
        return
    end

    local attachmentpanelsize = attachmentpanelscale * ScrH()
    local padfac = 0.1

    if not TFA_INSPECTIONPANEL.AttachmentPanels then
        TFA_INSPECTIONPANEL.AttachmentPanels = {}

        for _, tab in pairs(self.AttachmentUICache or {}) do
            local i = tab.attachment
            local anchor_x, anchor_y = tab.x, tab.y
            local att = vm:GetAttachment(i)

            if att and att.Pos and att.Ang then
                TFA_INSPECTIONPANEL.AttachmentPanels[i] = TFA_INSPECTIONPANEL:Add("DPanel")
                local p = TFA_INSPECTIONPANEL.AttachmentPanels[i]

                p:SetSize(attachmentpanelsize + attachmentpanelsize * padfac * 2, attachmentpanelsize + attachmentpanelsize * padfac * 2)

                local hexsize = attachmentpanelsize / 3.5
                local centerx = attachmentpanelsize / 2 + attachmentpanelsize * padfac
                local centery = attachmentpanelsize / 2 + attachmentpanelsize * padfac
                local hexi = 0

                local ts = att.Pos:ToScreen()
                p.anchor_x = anchor_x * ScrW()
                p.anchor_y = anchor_y * ScrH()

                ts.x = math_clamp(ts.x + p.anchor_x, attachmentpanelsize / 2, ScrW() - attachmentpanelsize / 2)
                ts.y = math_clamp(ts.y + p.anchor_y, attachmentpanelsize / 2, ScrH() - attachmentpanelsize / 2)
                p:SetPos(ts.x - attachmentpanelsize / 2 - attachmentpanelsize * padfac, ts.y - attachmentpanelsize / 2 - attachmentpanelsize * padfac)

                p.activehex = -1
                p.key = tab.key

                p.Paint = function(myself, w, h)
                    if not myself.selbar then
                        myself.selbar = Material("vgui/inspectionhud/selector_bar")
                    end

                    if not myself.lastpaint then
                        myself.lastpaint = RealTime() - FrameTime()
                    end

                    local delta = RealTime() - myself.lastpaint
                    myself.lastpaint = RealTime()

                    local ang = math_normalizeAngle(-90 + (myself.activehex - 1) * 60)
                    if not myself.ang then
                        myself.ang = ang
                    end

                    myself.ang = math_ApproachAngle(myself.ang, ang, math_abs(ang - myself.ang) * delta * 15)
                    myself.ang = math_normalizeAngle(myself.ang)

                    local rads = math_rad(myself.ang)
                    local xx = w / 2 + hexsize / 2
                    local yy = h / 2 + hexsize / 2
                    local wuv = hexsize / 2
                    local gapscale = 0.25

                    draw.NoTexture()
                    surface.SetDrawColor(TFA_INSPECTIONPANEL.PrimaryColor)
                    surface.SetMaterial(myself.selbar)
                    surface.DrawTexturedRectRotated(xx + math_cos(rads) * wuv * gapscale, yy + math.sin(rads) * wuv * gapscale, wuv * (1 - gapscale) * 2, wuv * (1 - gapscale) * 2, -myself.ang)
                    draw.SimpleText(myself.key, "TFA_INSPECTION_SMALL", xx, yy, TFA_INSPECTIONPANEL.PrimaryColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                for kk, vv in pairs(tab.atts or {}) do
                    hexi = hexi + 1
                    local hex = p:Add("DPanel")

                    local pos = hexpositions[hexi]
                    if not pos then
                        break
                    end

                    local xoff = pos.x / 260 * hexsize
                    local yoff = pos.y / 260 * hexsize

                    hex:SetPos(centerx + xoff, centery + yoff)
                    hex:SetSize(hexsize, hexsize)
                    hex.icon = vv.icon
                    hex.iconscale = vv.iconscale
                    hex.attachment = kk
                    hex.parent = p
                    hex.hexi = hexi
                    hex.Wep = self
                    hex.Paint = hexpaint1

                    if hexi >= 5 then
                        break
                    end
                end

                hexi = hexi + 1
                local hex = p:Add("DPanel")
                local pos = hexpositions[hexi]
                if pos then
                    local xoff = pos.x / 260 * hexsize
                    local yoff = pos.y / 260 * hexsize
                    hex:SetPos(centerx + xoff, centery + yoff)
                    hex:SetSize(hexsize, hexsize)
                    hex.icon = "vgui/inspectionhud/no"
                    hex.iconscale = 0.7
                    hex.key = tab.key
                    hex.parent = p
                    hex.hexi = hexi
                    hex.Wep = self
                    hex.Paint = hexpaint2
                end
            end
        end
    end

    for i = 1, attachmentcount do
        local att = vm:GetAttachment(i)
        if not (att and att.Pos and att.Ang) then
            break
        end

        local p = TFA_INSPECTIONPANEL.AttachmentPanels[i]
        if IsValid(p) then
            local ts = att.Pos:ToScreen()
            ts.x = math_clamp(ts.x + (p.anchor_x or 0), attachmentpanelsize / 2, ScrW() - attachmentpanelsize / 2)
            ts.y = math_clamp(ts.y + (p.anchor_y or 0), attachmentpanelsize / 2, ScrH() - attachmentpanelsize / 2)
            p:SetPos(ts.x - attachmentpanelsize / 2, ts.y - attachmentpanelsize / 2)
        end
    end
end

local crosscol = Color(255, 255, 255, 255)
local crossa_cvar = GetConVar("cl_tfa_hud_crosshair_color_a")
local outa_cvar = GetConVar("cl_tfa_hud_crosshair_outline_color_a")
local crosscustomenable_cvar = GetConVar("cl_tfa_hud_crosshair_enable_custom")
local crossr_cvar = GetConVar("cl_tfa_hud_crosshair_color_r")
local crossg_cvar = GetConVar("cl_tfa_hud_crosshair_color_g")
local crossb_cvar = GetConVar("cl_tfa_hud_crosshair_color_b")
local crosslen_cvar = GetConVar("cl_tfa_hud_crosshair_length")
local crosshairwidth_cvar = GetConVar("cl_tfa_hud_crosshair_width")
local drawdot_cvar = GetConVar("cl_tfa_hud_crosshair_dot")
local clen_usepixels = GetConVar("cl_tfa_hud_crosshair_length_use_pixels")
local outline_enabled_cvar = GetConVar("cl_tfa_hud_crosshair_outline_enabled")
local outr_cvar = GetConVar("cl_tfa_hud_crosshair_outline_color_r")
local outg_cvar = GetConVar("cl_tfa_hud_crosshair_outline_color_g")
local outb_cvar = GetConVar("cl_tfa_hud_crosshair_outline_color_b")
local outlinewidth_cvar = GetConVar("cl_tfa_hud_crosshair_outline_width")
local hudenabled_cvar = GetConVar("cl_tfa_hud_enabled")
local cvar_tfa_inspection_old = GetConVar("cl_tfa_inspection_old")
local cgapscale_cvar = GetConVar("cl_tfa_hud_crosshair_gap_scale")

function SWEP:DrawHUD()
    self.CLOldNearWallProgress = self.CLOldNearWallProgress or 0

    cam.Start3D()
    cam.End3D()

    if cvar_tfa_inspection_old and not cvar_tfa_inspection_old:GetBool() then
        self:DoInspectionDerma()
    end

    local drawcrossy = self.DrawCrosshairDefault
    if drawcrossy == nil then
        drawcrossy = self.DrawCrosshair
    end

    local stat = self:GetStatus()

    self.clrelp = self.clrelp or 0
    local relTarget = (TFA and TFA.Enum and TFA.Enum.ReloadStatus and TFA.Enum.ReloadStatus[stat]) and 0 or 1
    self.clrelp = math_Approach(self.clrelp, relTarget, math_abs(relTarget - self.clrelp) * FrameTime() * 15)

    local isProg = (self.IronSightsProgress and not self.DrawCrosshairIS) and self.IronSightsProgress or 0
    local minfac = math_min(1 - isProg, 1 - (self.SprintProgress or 0), 1 - (self.CLOldNearWallProgress or 0), 1 - (self.InspectingProgress or 0), self.clrelp)
    local powfac = math_pow(math_min(minfac, 1), 2)

    local crossa = (crossa_cvar and crossa_cvar:GetFloat() or 255) * powfac
    local outa = (outa_cvar and outa_cvar:GetFloat() or 255) * powfac

    self.DrawCrosshair = false

    if drawcrossy then
        if crosscustomenable_cvar and crosscustomenable_cvar:GetBool() then
            local owner = self.GetOwner and self:GetOwner() or self.Owner
            local ply = LocalPlayer()

            if IsValid(ply) and IsValid(owner) and owner == ply then
                ply.interpposx = ply.interpposx or (ScrW() / 2)
                ply.interpposy = ply.interpposy or (ScrH() / 2)

                local x, y
                local s_cone = self.CalculateConeRecoil and self:CalculateConeRecoil() or 0

                if owner:ShouldDrawLocalPlayer() and not ply:GetNW2Bool("ThirtOTS", false) then
                    local tr = util.GetPlayerTrace(owner)
                    tr.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_MONSTER + CONTENTS_WINDOW + CONTENTS_DEBRIS + CONTENTS_GRATE + CONTENTS_AUX
                    local trace = util.TraceLine(tr)
                    local coords = trace.HitPos:ToScreen()
                    coords.x = math_clamp(coords.x, 0, ScrW())
                    coords.y = math_clamp(coords.y, 0, ScrH())

                    local dx = coords.x - ply.interpposx
                    local dy = coords.y - ply.interpposy
                    ply.interpposx = math_Approach(ply.interpposx, coords.x, math_abs(dx) * FrameTime() * 7.5)
                    ply.interpposy = math_Approach(ply.interpposy, coords.y, math_abs(dy) * FrameTime() * 7.5)

                    x, y = ply.interpposx, ply.interpposy
                else
                    x, y = ScrW() / 2.0, ScrH() / 2.0
                end

                if not self.selftbl then
                    self.selftbl = { ply, self }
                end

                local targent = util.QuickTrace(ply:GetShootPos(), ply:EyeAngles():Forward() * 999999999, self.selftbl).Entity
                local teamcol = GetTeamColor(targent)

                local crossr = crossr_cvar and crossr_cvar:GetFloat() or 255
                local crossg = crossg_cvar and crossg_cvar:GetFloat() or 255
                local crossb = crossb_cvar and crossb_cvar:GetFloat() or 255
                local crosslen = (crosslen_cvar and crosslen_cvar:GetFloat() or 0) * 0.01

                crosscol.r = crossr
                crosscol.g = crossg
                crosscol.b = crossb
                crosscol.a = crossa

                local mixed = ColorMix(crosscol, teamcol, 1, CMIX_MULT)
                crossr, crossg, crossb, crossa = mixed.r, mixed.g, mixed.b, mixed.a

                local crosshairwidth = crosshairwidth_cvar and crosshairwidth_cvar:GetFloat() or 1
                local drawdot = drawdot_cvar and drawdot_cvar:GetBool() or false

                local fov = owner:GetFOV()
                if fov <= 0 then
                    fov = 90
                end

                local scale = (s_cone * 90) / fov * ScrH() / 1.44 * (cgapscale_cvar and cgapscale_cvar:GetFloat() or 1)
                local gap = scale
                local length

                if clen_usepixels and not clen_usepixels:GetBool() then
                    length = gap + ScrH() * 1.777 * crosslen
                else
                    length = gap + (crosslen * 100)
                end

                if outline_enabled_cvar and outline_enabled_cvar:GetBool() then
                    local outr = outr_cvar and outr_cvar:GetFloat() or 0
                    local outg = outg_cvar and outg_cvar:GetFloat() or 0
                    local outb = outb_cvar and outb_cvar:GetFloat() or 0
                    local ow = outlinewidth_cvar and outlinewidth_cvar:GetFloat() or 0

                    surface.SetDrawColor(outr, outg, outb, outa)

                    surface.DrawRect(math_round(x - length - ow) - crosshairwidth / 2, math_round(y - ow) - crosshairwidth / 2, math_round(length - gap + ow * 2) + crosshairwidth, math_round(ow * 2) + crosshairwidth)
                    surface.DrawRect(math_round(x + gap - ow) - crosshairwidth / 2, math_round(y - ow) - crosshairwidth / 2, math_round(length - gap + ow * 2) + crosshairwidth, math_round(ow * 2) + crosshairwidth)
                    surface.DrawRect(math_round(x - ow) - crosshairwidth / 2, math_round(y - length - ow) - crosshairwidth / 2, math_round(ow * 2) + crosshairwidth, math_round(length - gap + ow * 2) + crosshairwidth)
                    surface.DrawRect(math_round(x - ow) - crosshairwidth / 2, math_round(y + gap - ow) - crosshairwidth / 2, math_round(ow * 2) + crosshairwidth, math_round(length - gap + ow * 2) + crosshairwidth)

                    if drawdot then
                        surface.DrawRect(math_round(x - ow) - crosshairwidth / 2, math_round(y - ow) - crosshairwidth / 2, math_round(ow * 2) + crosshairwidth, math_round(ow * 2) + crosshairwidth)
                    end
                end

                surface.SetDrawColor(crossr, crossg, crossb, crossa)
                surface.DrawRect(math_round(x - length) - crosshairwidth / 2, math_round(y) - crosshairwidth / 2, math_round(length - gap) + crosshairwidth, crosshairwidth)
                surface.DrawRect(math_round(x + gap) - crosshairwidth / 2, math_round(y) - crosshairwidth / 2, math_round(length - gap) + crosshairwidth, crosshairwidth)
                surface.DrawRect(math_round(x) - crosshairwidth / 2, math_round(y - length) - crosshairwidth / 2, crosshairwidth, math_round(length - gap) + crosshairwidth)
                surface.DrawRect(math_round(x) - crosshairwidth / 2, math_round(y + gap) - crosshairwidth / 2, crosshairwidth, math_round(length - gap) + crosshairwidth)

                if drawdot then
                    surface.DrawRect(math_round(x) - crosshairwidth / 2, math_round(y) - crosshairwidth / 2, crosshairwidth, crosshairwidth)
                end
            end
        else
            if math_min(1 - (self.IronSightsProgress or 0), 1 - (self.SprintProgress or 0)) > 0.5 then
                self.DrawCrosshair = true
            end
        end
    end

    self:DrawHUDAmmo()
end

function SWEP:DrawHUDBackground()
    if self.IronSightsProgress > self:GetStat("ScopeOverlayThreshold") and self.Scoped and not self.Scoped_3D then
        self:DrawScopeOverlay()
    end
end

function SWEP:DrawScopeOverlay()
    local tbl

    if self.Secondary and self.Secondary.UseACOG then
        tbl = TFA_SCOPE_ACOG
    elseif self.Secondary and self.Secondary.UseMilDot then
        tbl = TFA_SCOPE_MILDOT
    elseif self.Secondary and self.Secondary.UseSVD then
        tbl = TFA_SCOPE_SVD
    elseif self.Secondary and self.Secondary.UseParabolic then
        tbl = TFA_SCOPE_PARABOLIC
    elseif self.Secondary and self.Secondary.UseElcan then
        tbl = TFA_SCOPE_ELCAN
    elseif self.Secondary and self.Secondary.UseGreenDuplex then
        tbl = TFA_SCOPE_GREENDUPLEX
    elseif self.Secondary and self.Secondary.UseAimpoint then
        tbl = TFA_SCOPE_AIMPOINT
    elseif self.Secondary and self.Secondary.UseMatador then
        tbl = TFA_SCOPE_MATADOR
    end

    if self.Secondary and self.Secondary.ScopeTable then
        tbl = self.Secondary.ScopeTable
    end

    if not tbl then
        tbl = TFA_SCOPE_MILDOT
    end

    local w, h = ScrW(), ScrH()

    for k, v in pairs(tbl) do
        local dimension = h

        if k == "ScopeBorder" then
            if istable(v) then
                surface.SetDrawColor(v)
            else
                surface.SetDrawColor(color_black)
            end

            surface.DrawRect(0, 0, w / 2 - dimension / 2, dimension)
            surface.DrawRect(w / 2 + dimension / 2, 0, w / 2 - dimension / 2, dimension)
        elseif k == "ScopeMaterial" then
            surface.SetMaterial(v)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(w / 2 - dimension / 2, (h - dimension) / 2, dimension, dimension)
        elseif k == "ScopeOverlay" then
            surface.SetMaterial(v)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(0, 0, w, h)
        elseif k == "ScopeCrosshair" then
            local t = type(v)

            if t == "IMaterial" then
                surface.SetMaterial(v)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawTexturedRect(w / 2 - dimension / 4, h / 2 - dimension / 4, dimension / 2, dimension / 2)
            elseif t == "table" then
                if not v.cached then
                    v.cached = true
                    v.r = v.r or v.x or v[1] or 0
                    v.g = v.g or v.y or v[2] or v[1] or 0
                    v.b = v.b or v.z or v[3] or v[1] or 0
                    v.a = v.a or v[4] or 255
                    v.s = v.Scale or v.scale or v.s or 0.25
                end

                surface.SetDrawColor(v.r, v.g, v.b, v.a)

                if v.Material then
                    surface.SetMaterial(v.Material)
                    surface.DrawTexturedRect(w / 2 - dimension * v.s / 2, h / 2 - dimension * v.s / 2, dimension * v.s, dimension * v.s)
                elseif v.Texture then
                    surface.SetTexture(v.Texture)
                    surface.DrawTexturedRect(w / 2 - dimension * v.s / 2, h / 2 - dimension * v.s / 2, dimension * v.s, dimension * v.s)
                else
                    surface.DrawRect(w / 2 - dimension * v.s / 2, h / 2, dimension * v.s, 1)
                    surface.DrawRect(w / 2, h / 2 - dimension * v.s / 2, 1, dimension * v.s)
                end
            end
        else
            if k == "scopetex" then
                dimension = dimension * (self:GetStat("ScopeScale") ^ 2) * TFA_SCOPE_SCOPESCALE
            elseif k == "reticletex" then
                local rs = self:GetStat("ReticleScale") or 1
                local rsc = TFA_SCOPE_RETICLESCALE or 1
                dimension = dimension * (rs ^ 2) * rsc
            else
                dimension = dimension * (self:GetStat("ReticleScale") ^ 2) * TFA_SCOPE_DOTSCALE
            end

            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetTexture(v)
            surface.DrawTexturedRect(w / 2 - dimension / 2, (h - dimension) / 2, dimension, dimension)
        end
    end
end

function SWEP:DrawHUD3D2D()
end

SWEP.CLAmmoProgress = 0
local targ, lactive = 0, -1
local targbool = false
local hudhangtime_cvar = GetConVar("cl_tfa_hud_hangtime")
local hudfade_cvar = GetConVar("cl_tfa_hud_ammodata_fadein")
local lfm, fm = 0, 0
local issighting = false

SWEP.TextCol = Color(255, 255, 255, 255)
SWEP.TextColContrast = Color(32, 32, 32, 255)

function SWEP:DrawHUDAmmo()
    if not self.Primary or self.Primary.Ammo == "none" or self.Primary.Ammo == "" then
        return
    end

    local owner = self.GetOwner and self:GetOwner() or self.Owner
    if not IsValid(owner) then
        return
    end

    local stat = self:GetStatus()

    if self.BoltAction then
        if stat == TFA.Enum.STATUS_SHOOTING then
            if not self.LastBoltShoot then
                self.LastBoltShoot = CurTime()
            end

            if CurTime() > self.LastBoltShoot + (self.BoltTimerOffset or 0) then
                issighting = false
            end
        elseif self.LastBoltShoot then
            self.LastBoltShoot = nil
        end
    end

    fm = self.GetFireMode and self:GetFireMode() or 0

    targbool = (stat ~= TFA.Enum.STATUS_IDLE and stat ~= TFA.Enum.STATUS_SHOOTING and not (TFA.Enum.HolsterStatus and TFA.Enum.HolsterStatus[stat])) or fm ~= lfm or (self.Inspecting and cvar_tfa_inspection_old and cvar_tfa_inspection_old:GetBool())
    targbool = targbool or (stat == TFA.Enum.STATUS_SHOOTING and self.LastBoltShoot and CurTime() > self.LastBoltShoot + (self.BoltTimerOffset or 0))
    targ = targbool and 1 or 0

    lfm = fm

    if targ == 1 then
        lactive = CurTime()
    end

    if hudhangtime_cvar and CurTime() < lactive + hudhangtime_cvar:GetFloat() then
        targ = 1
    end

    if owner:KeyDown(IN_RELOAD) then
        targ = 1
    end

    local fade = hudfade_cvar and hudfade_cvar:GetFloat() or 0.2
    if fade <= 0 then
        fade = 0.2
    end

    local ft = (TFA and TFA.FrameTime and TFA.FrameTime()) or FrameTime()
    self.CLAmmoProgress = math_Approach(self.CLAmmoProgress, targ, math_abs(targ - self.CLAmmoProgress) * ft * 2 / fade)

    local mzpos = self.GetMuzzlePos and self:GetMuzzlePos() or nil

    if self.Akimbo then
        self.MuzzleAttachmentRaw = self.MuzzleAttachmentRaw2 or 1
    end

    if not (mzpos and mzpos.Pos) then
        return
    end

    if self.GetHidden and self:GetHidden() then
        return
    end

    if hudenabled_cvar and not hudenabled_cvar:GetBool() then
        return
    end

    local pos = mzpos.Pos
    local textsize = self.textsize or 1
    local pl = LocalPlayer() or owner
    local ang = pl:EyeAngles()

    local myalpha = 225 * self.CLAmmoProgress
    if myalpha <= 0 then
        return
    end

    ang:RotateAroundAxis(ang:Right(), 90)
    ang:RotateAroundAxis(ang:Up(), -90)
    ang:RotateAroundAxis(ang:Forward(), 0)

    pos = pos + ang:Right() * (self.textupoffset or (-2 * (textsize / 1)))
    pos = pos + ang:Up() * (self.textfwdoffset or 0)
    pos = pos + ang:Forward() * (self.textrightoffset or (-1 * (textsize / 1)))

    local postoscreen = pos:ToScreen()
    local xx = postoscreen.x
    local yy = postoscreen.y

    local labelMag = string.upper(L("hud_inspect_mag"))
    local labelReserve = string.upper(L("hud_inspect_reserve"))
    local labelAmmoShort = string.upper(L("hud_inspect_ammo_short"))
    local labelAltMag = string.upper(L("hud_inspect_alt_mag"))
    local labelAltReserve = string.upper(L("hud_inspect_alt_reserve"))
    local labelAltAmmo = string.upper(L("hud_inspect_alt_ammo"))
    local labelRpm = string.upper(L("hud_inspect_rpm"))
    local labelDamage = string.upper(L("hud_inspect_damage"))
    local labelRange = string.upper(L("hud_inspect_range"))
    local labelSpread = string.upper(L("hud_inspect_spread"))
    local labelSpreadMax = string.upper(L("hud_inspect_spread_max"))

    if (self.InspectingProgress or 0) < 0.01 and self.Primary.Ammo ~= "" and self.Primary.Ammo ~= 0 then
        local str

        if self.Primary.ClipSize and self.Primary.ClipSize ~= -1 then
            if self.Akimbo then
                str = labelMag .. ": " .. math_ceil(self:Clip1() / 2)

                if self:Clip1() > self.Primary.ClipSize then
                    str = labelMag .. ": " .. (math_ceil(self:Clip1() / 2) - 1) .. " + " .. (math_ceil(self:Clip1() / 2) - math_ceil(self.Primary.ClipSize / 2))
                end
            else
                str = labelMag .. ": " .. self:Clip1()

                if self:Clip1() > self.Primary.ClipSize then
                    str = labelMag .. ": " .. self.Primary.ClipSize .. " + " .. (self:Clip1() - self.Primary.ClipSize)
                end
            end

            draw.DrawText(str, "TFASleek", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
            draw.DrawText(str, "TFASleek", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)

            str = labelReserve .. ": " .. self:Ammo1()
            yy = yy + TFASleekFontHeight
            xx = xx - TFASleekFontHeight / 3

            draw.DrawText(str, "TFASleekMedium", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
            draw.DrawText(str, "TFASleekMedium", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)

            yy = yy + TFASleekFontHeightMedium
            xx = xx - TFASleekFontHeightMedium / 3
        else
            str = labelAmmoShort .. ": " .. self:Ammo1()
            draw.DrawText(str, "TFASleek", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
            draw.DrawText(str, "TFASleek", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)

            yy = yy + TFASleekFontHeightMedium
            xx = xx - TFASleekFontHeightMedium / 3
        end

        local fmName = self.GetFireModeName and self:GetFireModeName() or ""
        local fmCount = (self.FireModes and #self.FireModes) or 0
        str = string.upper(fmName .. (fmCount > 2 and " | +" or ""))

        draw.DrawText(str, "TFASleekSmall", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
        draw.DrawText(str, "TFASleekSmall", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)

        yy = yy + TFASleekFontHeightSmall
        xx = xx - TFASleekFontHeightSmall / 3

        local angpos2
        if self.Akimbo then
            if owner:ShouldDrawLocalPlayer() then
                angpos2 = self:GetAttachment(2)
            else
                angpos2 = self.OwnerViewModel and self.OwnerViewModel:GetAttachment(2) or nil
            end
        else
            if owner:ShouldDrawLocalPlayer() then
                local attid = self.MuzzleAttachmentRaw or (self.LookupAttachment and self:LookupAttachment(self.MuzzleAttachment)) or 1
                angpos2 = self:GetAttachment(attid)
            else
                local vm = owner:GetViewModel()
                if IsValid(vm) then
                    local attid = self.MuzzleAttachmentRaw or vm:LookupAttachment(self.MuzzleAttachment)
                    angpos2 = vm:GetAttachment(attid)
                end
            end
        end

        if self.Akimbo and angpos2 then
            local pos2 = angpos2.Pos
            local ts2 = pos2:ToScreen()
            xx, yy = ts2.x, ts2.y

            if self.Primary.ClipSize and self.Primary.ClipSize ~= -1 then
                str = labelMag .. ": " .. math_floor(self:Clip1() / 2)

                if math_floor(self:Clip1() / 2) > math_floor(self.Primary.ClipSize / 2) then
                    str = labelMag .. ": " .. (math_floor(self:Clip1() / 2) - 1) .. " + " .. (math_floor(self:Clip1() / 2) - math_floor(self.Primary.ClipSize / 2))
                end

                draw.DrawText(str, "TFASleek", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
                draw.DrawText(str, "TFASleek", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)

                str = labelReserve .. ": " .. self:Ammo1()
                yy = yy + TFASleekFontHeight
                xx = xx - TFASleekFontHeight / 3

                draw.DrawText(str, "TFASleekMedium", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
                draw.DrawText(str, "TFASleekMedium", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)

                yy = yy + TFASleekFontHeightMedium
                xx = xx - TFASleekFontHeightMedium / 3
            else
                str = labelAmmoShort .. ": " .. self:Ammo1()
                draw.DrawText(str, "TFASleek", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
                draw.DrawText(str, "TFASleek", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)

                yy = yy + TFASleekFontHeightMedium
                xx = xx - TFASleekFontHeightMedium / 3
            end

            str = string.upper(fmName .. (fmCount > 2 and " | +" or ""))
            draw.DrawText(str, "TFASleekSmall", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
            draw.DrawText(str, "TFASleekSmall", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
        end

        if self.Secondary and self.Secondary.Ammo and self.Secondary.Ammo ~= "" and self.Secondary.Ammo ~= "none" and self.Secondary.Ammo ~= 0 and not self.Akimbo then
            if self.Secondary.ClipSize and self.Secondary.ClipSize ~= -1 then
                local over = self:Clip2() > self.Secondary.ClipSize
                if over then
                    str = labelAltMag .. ": " .. self.Secondary.ClipSize .. " + " .. (self:Clip2() - self.Secondary.ClipSize)
                else
                    str = labelAltMag .. ": " .. self:Clip2()
                end

                draw.DrawText(str, "TFASleekSmall", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
                draw.DrawText(str, "TFASleekSmall", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)

                str = labelAltReserve .. ": " .. self:Ammo2()
                yy = yy + TFASleekFontHeight
                xx = xx - TFASleekFontHeight / 3

                draw.DrawText(str, "TFASleekSmall", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
                draw.DrawText(str, "TFASleekSmall", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)

                yy = yy + TFASleekFontHeightMedium
                xx = xx - TFASleekFontHeightMedium / 3
            else
                str = labelAltAmmo .. ": " .. self:Ammo2()
                draw.DrawText(str, "TFASleekSmall", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
                draw.DrawText(str, "TFASleekSmall", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)

                yy = yy + TFASleekFontHeightMedium
                xx = xx - TFASleekFontHeightMedium / 3
            end
        end
    elseif cvar_tfa_inspection_old and cvar_tfa_inspection_old:GetBool() then
        local str = labelDamage .. ": " .. RoundDecimals((self.Primary and self.Primary.Damage) or 0, 1)

        if self.Primary and self.Primary.NumShots and self.Primary.NumShots > 1 then
            str = str .. "x" .. math_round(self.Primary.NumShots)
        end

        yy = yy - 100
        yy = math_clamp(yy, 0, ScrH())
        xx = math_clamp(xx, 250, ScrW())

        draw.DrawText(str, "TFASleek", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
        draw.DrawText(str, "TFASleek", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)

        yy = yy + TFASleekFontHeight
        str = labelRpm .. ": " .. RoundDecimals((self.Primary and self.Primary.RPM) or 0, 1)

        draw.DrawText(str, "TFASleek", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
        draw.DrawText(str, "TFASleek", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)

        yy = yy + TFASleekFontHeight
        local range = (self.Primary and self.Primary.Range) or 0
        str = labelRange .. ": " .. RoundDecimals(range / 16000 * 0.305, 3) .. "KM"

        draw.DrawText(str, "TFASleek", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
        draw.DrawText(str, "TFASleek", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)

        yy = yy + TFASleekFontHeight
        local spread = (self.Primary and (self.Primary.Spread or self.Primary.Accuracy)) or 0
        str = labelSpread .. ": " .. RoundDecimals(spread, 2)

        draw.DrawText(str, "TFASleek", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
        draw.DrawText(str, "TFASleek", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)

        yy = yy + TFASleekFontHeight
        str = labelSpreadMax .. ": " .. RoundDecimals((self.Primary and self.Primary.SpreadMultiplierMax) or 0, 2)

        draw.DrawText(str, "TFASleek", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
        draw.DrawText(str, "TFASleek", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)

        yy = yy + TFASleekFontHeight
    end
end
