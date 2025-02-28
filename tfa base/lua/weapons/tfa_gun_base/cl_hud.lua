local CMIX_MULT = 1
local c1t = {}
local c2t = {}

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
			c1t[k] = Lerp(fac, v, (c1t[k] / 255 * c2t[k] / 255) * 255)
		else
			c1t[k] = Lerp(fac, v, c2t[k])
		end
	end

	return Color(c1t.r, c1t.g, c1t.b, c1t.a)
end

local c_red = Color(255, 0, 0, 255)
local c_grn = Color(0, 255, 0, 255)

local hostilenpcmaps = {
	["gm_lasers"] = true,
	["gm_locals"] = true,
	["gm_raid"] = true,
	["gm_slam"] = true
}

local mymap

local function GetTeamColor(ent)
	if not cl_tfa_hud_crosshair_color_teamcvar then
		cl_tfa_hud_crosshair_color_teamcvar = GetConVar("cl_tfa_hud_crosshair_color_team")
	end

	if not cl_tfa_hud_crosshair_color_teamcvar:GetBool() then return color_white end

	if not mymap then
		mymap = game.GetMap()
	end

	local ply = LocalPlayer()
	if not IsValid(ply) then return color_white end

	if ent:IsPlayer() then
		if GAMEMODE.TeamBased then
			if ent:Team() == ply:Team() then
				return c_grn
			else
				return c_red
			end
		end

		return c_red
	end

	if ent:IsNPC() then
		local disp = ent:GetNW2Int("tfa_disposition", -1)

		if disp > 0 then
			if disp == (D_FR or 2) or disp == (D_HT or 1) then
				return c_red
			else
				return c_grn
			end
		end

		if IsFriendEntityName(ent:GetClass()) and not hostilenpcmaps[mymap] then
			return c_grn
		else
			return c_red
		end
	end

	return color_white
end

local function RoundDecimals(number, decimals)
	local decfactor = math.pow(10, decimals)

	return math.Round(tonumber(number) * decfactor) / decfactor
end

--[[
Function Name:  DoInspectionDerma
Syntax: self:DoInspectionDerma( ).
Returns:  Nothing.
Notes:    Used to manage our Derma.
Purpose:  Used to manage our Derma.
]]--
local titlefont = nil
local descriptionfont = nil
local smallfont = nil

function SWEP:MakeFonts()
	if not titlefont then
		surface.CreateFont("TFA_INSPECTION_TITLE", {
			font = "Aral", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
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
			font = "Aral", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
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
			font = "Aral", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
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
	local xx, ww, blockw, padw
	xx = w * 0.7
	ww = w - xx
	blockw = math.floor(ww / 15)
	padw = math.floor(ww / 10)
	surface.SetDrawColor(ColorAlpha(TFA_INSPECTIONPANEL.BackgroundColor, (TFA_INSPECTIONPANEL.Alpha or 0) / 2))

	for i = 0, 9 do
		surface.DrawRect(xx, 2, blockw, h - 5)
		xx = math.floor(xx + padw)
	end

	xx = w * 0.7
	surface.SetDrawColor(TFA_INSPECTIONPANEL.BackgroundColor)

	for i = 0, myself.Bars - 1 do
		surface.DrawRect(xx + 1, 3, blockw, h - 5)
		xx = math.floor(xx + padw)
	end

	xx = w * 0.7
	surface.SetDrawColor(TFA_INSPECTIONPANEL.SecondaryColor)

	for i = 0, myself.Bars - 1 do
		surface.DrawRect(xx, 2, blockw, h - 5)
		xx = math.floor(xx + padw)
	end
end

local function TextShadowPaint(myself, w, h)
	if not myself.TextColor then
		myself.TextColor = ColorAlpha(color_white,0)
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
	[1] = {
		x = 0,
		y = -233
	},
	[2] = {
		x = 186,
		y = -111
	},
	[3] = {
		x = 186,
		y = 111
	},
	[4] = {
		x = 0,
		y = 233
	},
	[5] = {
		x = -186,
		y = 111
	},
	[6] = {
		x = -186,
		y = -111
	}
}

SWEP.AmmoTypeStrings = {
	["pistol"] = "Generic Pistol",
	["smg1"] = "Generic SMG",
	["ar2"] = "Generic Rifle",
	["buckshot"] = "Generic Shotgun",
	["357"] = "Generic Revolver",
	["SniperPenetratedRound"] = "Generic Sniper"
}

local function hexpaint1(myself, w, h)
	if not IsValid(myself.Wep) then return end

	if not myself.iconmat then
		myself.iconmat = surface.GetTextureID(myself.icon)
	end

	local mys_isactive = myself.Wep.AttachmentCache[myself.attachment].active

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
	if not IsValid(myself.Wep) then return end

	if not myself.iconmat then
		myself.iconmat = surface.GetTextureID(myself.icon)
	end

	local mys_isactive = true

	for kkk, vvv in pairs(myself.Wep.AttachmentCache) do
		if vvv.key == myself.key and vvv.active then
			mys_isactive = false
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
		if tab.atts and tab.cat and tab.anchor then
			self.AttachmentUICache[tab.cat] = {
				key = keyv,
				attachment = tab.anchor.att or 1,
				x = tab.anchor.xoff or 0,
				y = tab.anchor.yoff or 0,
				atts = {}
			}

			for k, attid in pairs(tab.atts) do
				local tbl = TFA_ATT[attid]

				if tbl then
					self.AttachmentUICache[tab.cat].atts[attid] = {
						title = tbl.Name or "Generic Attachment",
						icon = tbl.Icon or "vgui/inspectionhud/qmark",
						iconscale = tbl.IconScale or 0.7,
						desc = tbl.Description or {color_white, "Generic Attachment Description"}
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

	TFA_INSPECTIONPANEL.Think = function(myself, w, h)
		local ply = LocalPlayer()

		if not IsValid(ply) then
			myself:Remove()

			return
		end

		local wep = ply:GetActiveWeapon()

		if not IsValid(wep) or not wep.IsTFAWeapon or wep.InspectingProgress <= 0.01 then
			myself:Remove()

			return
		end

		myself.Player = ply
		myself.Weapon = wep
	end

	TFA_INSPECTIONPANEL.Paint = function(myself, w, h)
		local wep = self

		if IsValid(wep) then
			myself.Alpha = wep.InspectingProgress * 255
			myself.PrimaryColor = ColorAlpha(INSPECTION_PRIMARYCOLOR, TFA_INSPECTIONPANEL.Alpha)
			myself.SecondaryColor = ColorAlpha(INSPECTION_SECONDARYCOLOR, TFA_INSPECTIONPANEL.Alpha)
			myself.BackgroundColor = ColorAlpha(INSPECTION_BACKGROUND, TFA_INSPECTIONPANEL.Alpha)
			myself.ActiveColor = ColorAlpha(INSPECTION_ACTIVECOLOR, TFA_INSPECTIONPANEL.Alpha)

			if not myself.SideBar then
				myself.SideBar = surface.GetTextureID("vgui/inspectionhud/sidebar")
			end

			if not myself.Hex then
				myself.Hex = surface.GetTextureID("vgui/inspectionhud/hex")
			end
		end
	end

	--Derma_DrawBackgroundBlur( myself, SysTime()-wep.InspectingProgress )
	--draw.NoTexture()
	--surface.SetDrawColor(ColorAlpha(INSPECTION_BACKGROUND,TFA_INSPECTIONPANEL.Alpha*0.25))
	--surface.DrawRect(0,0,w,h)
	local screenwidth, screenheight = ScrW(), ScrH()
	local hv = math.Round(screenheight * 0.8)
	local contentpanel = vgui.Create("DPanel", TFA_INSPECTIONPANEL)
	contentpanel:SetPos(32, (screenheight - hv) / 2)
	contentpanel:DockPadding(32 + pad, pad, pad, pad)
	contentpanel:SetSize(screenwidth - 32, hv)

	contentpanel.Paint = function(myself, w, h)
		local mycol = TFA_INSPECTIONPANEL.SecondaryColor
		if not mycol then return end
		surface.SetDrawColor(mycol)
		surface.SetTexture(TFA_INSPECTIONPANEL.SideBar or 1)
		surface.DrawTexturedRect(0, 0, 32, h)
	end

	local lbound = 32 + pad
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
	--Space things out for block1
	local spacer = contentpanel:Add("DPanel")
	spacer:Dock(TOP)
	spacer:SetSize(screenwidth - lbound, 64)
	spacer.Paint = function() end
	--First stat block
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
	rpmtext.Text = infotextpad .. "Firerate: " .. math.floor(self.Primary.RPM) .. "RPM"

	rpmtext.Think = function(myself)
		myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
	end

	rpmtext.Font = "TFA_INSPECTION_SMALL"
	rpmtext:Dock(TOP)
	rpmtext:SetSize(screenwidth - lbound, 24)
	rpmtext.Paint = TextShadowPaint
	local capacitytext = contentpanel:Add("DPanel")
	capacitytext.Text = infotextpad .. "Capacity: " .. self.Primary.ClipSize .. (self:CanChamber() and (self.Akimbo and " + 2" or " + 1") or "") .. " Rounds"

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
		ammotypetext.Text = infotextpad .. "Ammo: " .. (self.AmmoTypeStrings[self.Primary.Ammo or "ammo"] or language.GetPhrase(an .. "_ammo"))

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

	makertext.Text = infotextpad .. "Maker: " .. mymaker

	makertext.Think = function(myself)
		myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
	end

	makertext.Font = "TFA_INSPECTION_SMALL"
	makertext:Dock(TOP)
	makertext:SetSize(screenwidth - lbound, 24)
	makertext.Paint = TextShadowPaint

	--Attachment block (title and description of an attachment)
	TFA_INSPECTIONPANEL.UpdateAttachment = function(attid)
		if IsValid(contentpanel.attpanel) then
			contentpanel.attpanel:Remove()
		end

		contentpanel.attpanel = contentpanel:Add("DPanel")
		contentpanel.attpanel.Paint = function(myself, w, h) end
		local tbl = TFA_ATT[attid]
		if not tbl then return end
		local header = contentpanel.attpanel:Add("DPanel")
		print(tbl.Name)
		header.Text = tbl.Name or "New Attachment"

		header.Think = function(myself)
			myself.TextColor = TFA_INSPECTIONPANEL.PrimaryColor
		end

		header.Font = "TFA_INSPECTION_TITLE"
		header:Dock(TOP)
		header:SetSize(screenwidth - lbound, 64)
		header.Paint = TextShadowPaint
		local c = TFA_INSPECTIONPANEL.PrimaryColor

		if tbl.Description then
			for k, line in pairs(tbl.Description) do
				if type(line) == "vector" then
					c.r = line.x
					c.g = line.y
					c.b = line.z
				elseif type(line) == "table" then
					c.r = line.r
					c.g = line.g
					c.b = line.b
					c.a = line.a
				elseif type(line) == "string" then
					local descline = contentpanel.attpanel:Add("DPanel")
					descline.Text = line or "New Attachment"
					descline.c = c

					descline.Think = function(myself)
						myself.TextColor = ColorAlpha(myself.c, TFA_INSPECTIONPANEL.Alpha)
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

	--Bottom block (bars and such)
	local statspanel = contentpanel:Add("DPanel")
	statspanel:SetSize(screenwidth - lbound, 144)
	statspanel.Paint = function() end
	statspanel:Dock(BOTTOM)
	--Accuracy
	local accuracypanel = statspanel:Add("DPanel")
	accuracypanel:SetSize(400, 24)

	accuracypanel.Think = function(myself)
		if not IsValid(self) then return end
		myself.Bars = math.Clamp(math.Round((1 - (self.Secondary.Ironsights ~= 0 and (self.Primary.IronAccuracy or self.Primary.IronSpread) or (self.Primary.Spread or self.Primary.Accuracy)) / worstaccuracy) * 10), 0, 10)
	end

	accuracypanel.Paint = PanelPaintBars
	accuracypanel:Dock(TOP)
	local accuracytext = accuracypanel:Add("DPanel")

	accuracytext.Think = function(myself)
		if not IsValid(self) then return end
		local accuracystr = "Accuracy: " .. math.Round((self.Primary.Spread or self.Primary.Accuracy) * 90) .. "°"

		if self.Secondary.Ironsights ~= 0 then
			accuracystr = accuracystr .. " || " .. math.Round((self.Primary.IronAccuracy or self.Primary.IronSpread) * 90) .. "°"
		end

		myself.Text = accuracystr
		myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
	end

	accuracytext.Font = "TFA_INSPECTION_SMALL"
	accuracytext:Dock(LEFT)
	accuracytext:SetSize(screenwidth - lbound, 24)
	accuracytext.Paint = TextShadowPaint
	--Firerate
	local fireratepanel = statspanel:Add("DPanel")
	fireratepanel:SetSize(400, 24)

	fireratepanel.Think = function(myself)
		if not IsValid(self) then return end
		myself.Bars = math.Clamp(math.Round(self.Primary.RPM / bestrpm * 10), 0, 10)
	end

	fireratepanel.Paint = PanelPaintBars
	fireratepanel:Dock(TOP)
	local fireratetext = fireratepanel:Add("DPanel")

	fireratetext.Think = function(myself)
		if not IsValid(self) then return end
		local fireratestr = "Firerate: " .. self.Primary.RPM .. "RPM"
		myself.Text = fireratestr
		myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
	end

	fireratetext.Font = "TFA_INSPECTION_SMALL"
	fireratetext:Dock(LEFT)
	fireratetext:SetSize(screenwidth - lbound, 24)
	fireratetext.Paint = TextShadowPaint
	--Mobility
	local mobilitypanel = statspanel:Add("DPanel")
	mobilitypanel:SetSize(400, 24)

	mobilitypanel.Think = function(myself)
		if not IsValid(self) then return end
		myself.Bars = math.Clamp(math.Round((self.MoveSpeed - worstmove) / (1 - worstmove) * 10), 0, 10)
	end

	mobilitypanel.Paint = PanelPaintBars
	mobilitypanel:Dock(TOP)
	local mobilitytext = mobilitypanel:Add("DPanel")

	mobilitytext.Think = function(myself)
		if not IsValid(self) then return end
		myself.Text = "Mobility: " .. math.Round(self.MoveSpeed * 100) .. "%"
		myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
	end

	mobilitytext.Font = "TFA_INSPECTION_SMALL"
	mobilitytext:Dock(LEFT)
	mobilitytext:SetSize(screenwidth - lbound, 24)
	mobilitytext.Paint = TextShadowPaint
	--Damage
	local damagepanel = statspanel:Add("DPanel")
	damagepanel:SetSize(400, 24)

	damagepanel.Think = function(myself)
		if not IsValid(self) then return end
		myself.Bars = math.Clamp(math.Round((self.Primary.Damage * math.Round(self.Primary.NumShots * 0.75)) / bestdamage * 10), 0, 10)
	end

	damagepanel.Paint = PanelPaintBars
	damagepanel:Dock(TOP)
	local damagetext = damagepanel:Add("DPanel")

	damagetext.Think = function(myself)
		if not IsValid(self) then return end
		local dmgstr = "Damage: " .. math.Round(self.Primary.Damage)

		if self.Primary.NumShots ~= 1 then
			dmgstr = dmgstr .. "x" .. math.Round(self.Primary.NumShots)
		end

		myself.Text = dmgstr
		myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
	end

	damagetext.Font = "TFA_INSPECTION_SMALL"
	damagetext:Dock(LEFT)
	damagetext:SetSize(screenwidth - lbound, 24)
	damagetext.Paint = TextShadowPaint
	--Range
	local rangepanel = statspanel:Add("DPanel")
	rangepanel:SetSize(400, 24)

	rangepanel.Think = function(myself)
		if not IsValid(self) then return end
		myself.Bars = math.Clamp(math.Round(self.Primary.Range / bestrange * 10), 0, 10)
	end

	rangepanel.Paint = PanelPaintBars
	rangepanel:Dock(TOP)
	local rangetext = rangepanel:Add("DPanel")
	rangetext.Text = rangestr

	rangetext.Think = function(myself)
		if not IsValid(self) then return end
		rangestr = "Range: " .. math.Round(feettokm(sourcetofeet(self.Primary.Range)) * 100) / 100 .. "K"
		myself.Text = rangestr
		myself.TextColor = TFA_INSPECTIONPANEL.SecondaryColor
	end

	rangetext.Font = "TFA_INSPECTION_SMALL"
	rangetext:Dock(LEFT)
	rangetext:SetSize(screenwidth - lbound, 24)
	rangetext.Paint = TextShadowPaint
	--Stability
	local stabilitypanel = statspanel:Add("DPanel")
	stabilitypanel:SetSize(400, 24)

	stabilitypanel.Think = function(myself)
		if not IsValid(self) then return end
		myself.Bars = math.Clamp(math.Round((1 - math.abs(self.Primary.KickUp + self.Primary.KickDown) / 2 / worstrecoil) * 10), 0, 10)
	end

	stabilitypanel.Paint = PanelPaintBars
	stabilitypanel:Dock(TOP)
	local stabilitytext = stabilitypanel:Add("DPanel")
	stabilitytext.Text = stabilitystr

	stabilitytext.Think = function(myself)
		if not IsValid(self) then return end
		stabilitystr = "Stability: " .. math.Clamp(math.Round((1 - math.abs(self.Primary.KickUp + self.Primary.KickDown) / 2 / 1) * 100), 0, 100) .. "%"
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

	if not IsValid(TFA_INSPECTIONPANEL) then return end
	if not self:OwnerIsValid() then return end

	if not self.AttachmentUICache then
		self:BuildAttachmentUICache()
	end

	cam.Start3D()
	cam.End3D()
	local vm = self.Owner:GetViewModel()
	local attachmentpanelsize = attachmentpanelscale * ScrH()
	local padfac = 0.1

	if not TFA_INSPECTIONPANEL.AttachmentPanels then
		TFA_INSPECTIONPANEL.AttachmentPanels = {}

		for category, tab in pairs(self.AttachmentUICache) do
			local i = tab.attachment
			local anchor_x, anchor_y = tab.x, tab.y
			local att = vm:GetAttachment(i)

			if att and att.Pos and att.Ang then
				TFA_INSPECTIONPANEL.AttachmentPanels[i] = TFA_INSPECTIONPANEL:Add("DPanel")
				local p = TFA_INSPECTIONPANEL.AttachmentPanels[i]
				p = TFA_INSPECTIONPANEL.AttachmentPanels[i]
				p:SetSize(attachmentpanelsize + attachmentpanelsize * padfac * 2, attachmentpanelsize + attachmentpanelsize * padfac * 2)
				local hexsize = attachmentpanelsize / 3.5
				local centerx, centery = attachmentpanelsize / 2 + attachmentpanelsize * padfac, attachmentpanelsize / 2 + attachmentpanelsize * padfac
				local hexi = 0
				local ts = att.Pos:ToScreen()
				p.anchor_x = anchor_x * ScrW()
				p.anchor_y = anchor_y * ScrH()
				ts.x = math.Clamp(ts.x + p.anchor_x, attachmentpanelsize / 2, ScrW() - attachmentpanelsize / 2)
				ts.y = math.Clamp(ts.y + p.anchor_y, attachmentpanelsize / 2, ScrH() - attachmentpanelsize / 2)
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
					local ang = math.NormalizeAngle(-90 + (myself.activehex - 1) * 60)

					if not myself.ang then
						myself.ang = ang
					end

					myself.ang = math.ApproachAngle(myself.ang, ang, (ang - myself.ang) * delta * 15)
					myself.ang = math.NormalizeAngle(myself.ang)
					local rads = math.rad(myself.ang)
					local xx, yy = w / 2 + hexsize / 2, h / 2 + hexsize / 2
					local wuv = hexsize / 2
					local gapscale = 0.25
					draw.NoTexture()
					surface.SetDrawColor(TFA_INSPECTIONPANEL.PrimaryColor)
					surface.SetMaterial(myself.selbar)
					surface.DrawTexturedRectRotated(xx + math.cos(rads) * wuv * gapscale, yy + math.sin(rads) * wuv * gapscale, wuv * (1 - gapscale) * 2, wuv * (1 - gapscale) * 2, -myself.ang)
					draw.SimpleText(myself.key, "TFA_INSPECTION_SMALL", xx, yy, TFA_INSPECTIONPANEL.PrimaryColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end

				for kk, vv in pairs(tab.atts) do
					hexi = hexi + 1
					local hex = p:Add("DPanel")
					local xoff, yoff = hexpositions[hexi].x / 260 * hexsize, hexpositions[hexi].y / 260 * hexsize
					hex:SetPos(centerx + xoff, centery + yoff)
					hex:SetSize(hexsize, hexsize)
					hex.icon = vv.icon
					hex.iconscale = vv.iconscale
					hex.attachment = kk
					hex.parent = p
					hex.hexi = hexi
					hex.Wep = self
					hex.Paint = hexpaint1

					if hexi >= 5 then break end
				end

				hexi = hexi + 1
				local hex = p:Add("DPanel")
				local xoff, yoff = hexpositions[hexi].x / 260 * hexsize, hexpositions[hexi].y / 260 * hexsize
				hex:SetPos(centerx + xoff, centery + yoff)
				hex:SetSize(hexsize, hexsize)
				hex.icon = "vgui/inspectionhud/no"
				hex.iconscale = 0.7
				hex.key = tab.key
				hex.parent = p
				hex.hexi = hexi
				hex.Wep = self
				hex.Paint = hexpaint2
			else
				break
			end
		end
	end

	--Update Attachment Panel Positions
	for i = 1, attachmentcount do
		local att = vm:GetAttachment(i)

		if att and att.Pos and att.Ang then
			if not IsValid(TFA_INSPECTIONPANEL.AttachmentPanels[i]) then return end
			local p = TFA_INSPECTIONPANEL.AttachmentPanels[i]
			p = TFA_INSPECTIONPANEL.AttachmentPanels[i]
			local ts = att.Pos:ToScreen()
			ts.x = math.Clamp(ts.x + p.anchor_x, attachmentpanelsize / 2, ScrW() - attachmentpanelsize / 2)
			ts.y = math.Clamp(ts.y + p.anchor_y, attachmentpanelsize / 2, ScrH() - attachmentpanelsize / 2)
			p:SetPos(ts.x - attachmentpanelsize / 2, ts.y - attachmentpanelsize / 2)
		else
			break
		end
	end
end

--[[
Function Name:  DrawHUD
Syntax: self:DrawHUD( ).
Returns:  Nothing.
Notes:    Used to draw the HUD.  Can you read?
Purpose:  HUD
]]--
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
	cam.Start3D() --Workaround for vec:ToScreen()
	cam.End3D()

	if not cvar_tfa_inspection_old:GetBool() then
		self:DoInspectionDerma()
	end

	--Crosshair
	local drawcrossy
	drawcrossy = self.DrawCrosshairDefault

	if not drawcrossy then
		drawcrossy = self.DrawCrosshair
	end

	local stat = self:GetStatus()

	self.clrelp = self.clrelp or 0
	self.clrelp = math.Approach(self.clrelp, TFA.Enum.ReloadStatus[stat] and 0 or 1, ((TFA.Enum.ReloadStatus[stat] and 0 or 1) - self.clrelp) * FrameTime() * 15)
	local crossa = crossa_cvar:GetFloat() * math.pow(math.min(1 - ((self.IronSightsProgress and not self.DrawCrosshairIS) and self.IronSightsProgress or 0), 1 - self.SprintProgress, 1 - self.CLOldNearWallProgress, 1 - self.InspectingProgress, self.clrelp), 2)
	local outa = outa_cvar:GetFloat() * math.pow(math.min(1 - ((self.IronSightsProgress and not self.DrawCrosshairIS) and self.IronSightsProgress or 0), 1 - self.SprintProgress, 1 - self.CLOldNearWallProgress, 1 - self.InspectingProgress, self.clrelp), 2)
	self.DrawCrosshair = false

	if drawcrossy then
		if crosscustomenable_cvar:GetBool() then
			if IsValid(LocalPlayer()) and self.Owner == LocalPlayer() then
				ply = LocalPlayer()

				if not ply.interpposx then
					ply.interpposx = ScrW() / 2
				end

				if not ply.interpposy then
					ply.interpposy = ScrH() / 2
				end

				local x, y -- local, always
				local s_cone = self:CalculateConeRecoil()

				-- If we're drawing the local player, draw the crosshair where they're aiming
				-- instead of in the center of the screen.
				if (self.Owner:ShouldDrawLocalPlayer() and not ply:GetNW2Bool("ThirtOTS", false)) then
					local tr = util.GetPlayerTrace(self.Owner)
					tr.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_MONSTER + CONTENTS_WINDOW + CONTENTS_DEBRIS + CONTENTS_GRATE + CONTENTS_AUX -- This controls what the crosshair will be projected onto.
					local trace = util.TraceLine(tr)
					local coords = trace.HitPos:ToScreen()
					coords.x = math.Clamp(coords.x, 0, ScrW())
					coords.y = math.Clamp(coords.y, 0, ScrH())
					ply.interpposx = math.Approach(ply.interpposx, coords.x, (ply.interpposx - coords.x) * FrameTime() * 7.5)
					ply.interpposy = math.Approach(ply.interpposy, coords.y, (ply.interpposy - coords.y) * FrameTime() * 7.5)
					x, y = ply.interpposx, ply.interpposy
					-- Center of screen
				else
					x, y = ScrW() / 2.0, ScrH() / 2.0
				end

				if not self.selftbl then
					self.selftbl = {ply, self}
				end

				local crossr, crossg, crossb, crosslen, crosshairwidth, drawdot, teamcol
				local targent = util.QuickTrace(ply:GetShootPos(), ply:EyeAngles():Forward() * 999999999, self.selftbl).Entity
				teamcol = GetTeamColor(targent)
				crossr = crossr_cvar:GetFloat()
				crossg = crossg_cvar:GetFloat()
				crossb = crossb_cvar:GetFloat()
				crosslen = crosslen_cvar:GetFloat() * 0.01
				crosscol.r = crossr
				crosscol.g = crossg
				crosscol.b = crossb
				crosscol.a = crossa
				crosscol = ColorMix(crosscol, teamcol, 1, CMIX_MULT)
				crossr = crosscol.r
				crossg = crosscol.g
				crossb = crosscol.b
				crossa = crosscol.a
				crosshairwidth = crosshairwidth_cvar:GetFloat()
				drawdot = drawdot_cvar:GetBool()
				local scale = (s_cone * 90) / self.Owner:GetFOV() * ScrH() / 1.44 * cgapscale_cvar:GetFloat()
				local gap = scale
				local length = 1

				if not clen_usepixels:GetBool() then
					length = gap + ScrH() * 1.777 * crosslen
				else
					length = gap + crosslen * 100
				end

				--Outline
				if outline_enabled_cvar:GetBool() then
					local outr, outg, outb, outlinewidth
					outr = outr_cvar:GetFloat()
					outg = outg_cvar:GetFloat()
					outb = outb_cvar:GetFloat()
					outlinewidth = outlinewidth_cvar:GetFloat()
					surface.SetDrawColor(outr, outg, outb, outa)
					surface.DrawRect(math.Round(x - length - outlinewidth) - crosshairwidth / 2, math.Round(y - outlinewidth) - crosshairwidth / 2, math.Round(length - gap + outlinewidth * 2) + crosshairwidth, math.Round(outlinewidth * 2) + crosshairwidth) -- Left
					surface.DrawRect(math.Round(x + gap - outlinewidth) - crosshairwidth / 2, math.Round(y - outlinewidth) - crosshairwidth / 2, math.Round(length - gap + outlinewidth * 2) + crosshairwidth, math.Round(outlinewidth * 2) + crosshairwidth) -- Right
					surface.DrawRect(math.Round(x - outlinewidth) - crosshairwidth / 2, math.Round(y - length - outlinewidth) - crosshairwidth / 2, math.Round(outlinewidth * 2) + crosshairwidth, math.Round(length - gap + outlinewidth * 2) + crosshairwidth) -- Top
					surface.DrawRect(math.Round(x - outlinewidth) - crosshairwidth / 2, math.Round(y + gap - outlinewidth) - crosshairwidth / 2, math.Round(outlinewidth * 2) + crosshairwidth, math.Round(length - gap + outlinewidth * 2) + crosshairwidth) -- Bottom

					if drawdot then
						surface.DrawRect(math.Round(x - outlinewidth) - crosshairwidth / 2, math.Round(y - outlinewidth) - crosshairwidth / 2, math.Round(outlinewidth * 2) + crosshairwidth, math.Round(outlinewidth * 2) + crosshairwidth) --Dot
					end
				end

				--Main Crosshair
				surface.SetDrawColor(crossr, crossg, crossb, crossa)
				surface.DrawRect(math.Round(x - length) - crosshairwidth / 2, math.Round(y) - crosshairwidth / 2, math.Round(length - gap) + crosshairwidth, crosshairwidth) -- Left
				surface.DrawRect(math.Round(x + gap) - crosshairwidth / 2, math.Round(y) - crosshairwidth / 2, math.Round(length - gap) + crosshairwidth, crosshairwidth) -- Right
				surface.DrawRect(math.Round(x) - crosshairwidth / 2, math.Round(y - length) - crosshairwidth / 2, crosshairwidth, math.Round(length - gap) + crosshairwidth) -- Top
				surface.DrawRect(math.Round(x) - crosshairwidth / 2, math.Round(y + gap) - crosshairwidth / 2, crosshairwidth, math.Round(length - gap) + crosshairwidth) -- Bottom

				if drawdot then
					surface.DrawRect(math.Round(x) - crosshairwidth / 2, math.Round(y) - crosshairwidth / 2, crosshairwidth, crosshairwidth) --dot
				end
			end
		else
			if math.min(1 - self.IronSightsProgress, 1 - self.SprintProgress) > 0.5 then
				self.DrawCrosshair = true
			end
		end
	end

	--Ammo

	self:DrawHUDAmmo() --so it's swappable easily
end

function SWEP:DrawHUDBackground()
	--Scope Overlay
	if self.IronSightsProgress > self:GetStat("ScopeOverlayThreshold") and self.Scoped and not self.Scoped_3D then
		self:DrawScopeOverlay()
	end
end

function SWEP:DrawScopeOverlay()
	local tbl = nil

	if self.Secondary.UseACOG then
		tbl = TFA_SCOPE_ACOG
	end

	if self.Secondary.UseMilDot then
		tbl = TFA_SCOPE_MILDOT
	end

	if self.Secondary.UseSVD then
		tbl = TFA_SCOPE_SVD
	end

	if self.Secondary.UseParabolic then
		tbl = TFA_SCOPE_PARABOLIC
	end

	if self.Secondary.UseElcan then
		tbl = TFA_SCOPE_ELCAN
	end

	if self.Secondary.UseGreenDuplex then
		tbl = TFA_SCOPE_GREENDUPLEX
	end

	if self.Secondary.UseAimpoint then
		tbl = TFA_SCOPE_AIMPOINT
	end

	if self.Secondary.UseMatador then
		tbl = TFA_SCOPE_MATADOR
	end

	if self.Secondary.ScopeTable then
		tbl = self.Secondary.ScopeTable
	end

	if not tbl then
		tbl = TFA_SCOPE_MILDOT
	end

	w, h = ScrW(), ScrH()

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
				dimension = dimension * self:GetStat("ScopeScale") ^ 2 * TFA_SCOPE_SCOPESCALE
			elseif k == "reticletex" then
				dimension = dimension * (self:GetStat("ReticleScale") and self:GetStat("ReticleScale") or 1) ^ 2 * (TFA_SCOPE_RETICLESCALE and TFA_SCOPE_RETICLESCALE or 1)
			else
				dimension = dimension * self:GetStat("ReticleScale") ^ 2 * TFA_SCOPE_DOTSCALE
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
local lfm,fm = 0,0

SWEP.TextCol = Color(255, 255, 255, 255) --Primary text color
SWEP.TextColContrast = Color(32, 32, 32, 255) --Secondary Text Color (used for shadow)

function SWEP:DrawHUDAmmo()

	if self.Primary.Ammo == "none" or self.Primary.Ammo == "" then return end

	local stat = self:GetStatus()

	if self.BoltAction then
		if stat == TFA.Enum.STATUS_SHOOTING then
			if not self.LastBoltShoot then
				self.LastBoltShoot = CurTime()
			end
			if CurTime() > self.LastBoltShoot + self.BoltTimerOffset then
				issighting = false
			end
		elseif self.LastBoltShoot then
			self.LastBoltShoot = nil
		end
	end

	fm = self:GetFireMode()

	targbool = ( stat ~= TFA.Enum.STATUS_IDLE and stat ~= TFA.Enum.STATUS_SHOOTING and not TFA.Enum.HolsterStatus[stat] ) or fm ~= lfm or ( self.Inspecting and cvar_tfa_inspection_old:GetBool() )
	targbool = targbool or ( stat == TFA.Enum.STATUS_SHOOTING and self.LastBoltShoot and CurTime() > self.LastBoltShoot + self.BoltTimerOffset)
	targ = targbool and 1 or 0

	lfm = fm

	if targ == 1 then
		lactive = CurTime()
	end

	if CurTime() < lactive + hudhangtime_cvar:GetFloat() then
		targ = 1
	end

	if self.Owner:KeyDown(IN_RELOAD) then
		targ = 1
	end

	self.CLAmmoProgress = math.Approach( self.CLAmmoProgress, targ, (targ - self.CLAmmoProgress ) * TFA.FrameTime() * 2 / hudfade_cvar:GetFloat() )

	local mzpos = self:GetMuzzlePos()

	if self.Akimbo then
		self.MuzzleAttachmentRaw = self.MuzzleAttachmentRaw2 or 1
	end

	if mzpos and mzpos.Pos and not self:GetHidden() and hudenabled_cvar:GetBool() then
		local pos = mzpos.Pos
		local textsize = self.textsize and self.textsize or 1
		local pl = LocalPlayer() and LocalPlayer() or self.Owner
		local ang = pl:EyeAngles() --(angpos.Ang):Up():Angle()
		local myalpha = 225 * self.CLAmmoProgress
		if myalpha <= 0 then return end
		ang:RotateAroundAxis(ang:Right(), 90)
		ang:RotateAroundAxis(ang:Up(), -90)
		ang:RotateAroundAxis(ang:Forward(), 0)
		pos = pos + ang:Right() * (self.textupoffset and self.textupoffset or -2 * (textsize / 1))
		pos = pos + ang:Up() * (self.textfwdoffset and self.textfwdoffset or 0 * (textsize / 1))
		pos = pos + ang:Forward() * (self.textrightoffset and self.textrightoffset or -1 * (textsize / 1))
		local postoscreen = pos:ToScreen()
		xx = postoscreen.x
		yy = postoscreen.y

		if self.InspectingProgress < 0.01 and self.Primary.Ammo ~= "" and self.Primary.Ammo ~= 0 then
			local str

			if self.Primary.ClipSize and self.Primary.ClipSize ~= -1 then
				if self.Akimbo then
					str = string.upper("MAG: " .. math.ceil(self:Clip1() / 2))

					if (self:Clip1() > self.Primary.ClipSize) then
						str = string.upper("MAG: " .. math.ceil(self:Clip1() / 2 ) - 1 .. " + " .. ( math.ceil(self:Clip1() / 2) - math.ceil(self.Primary.ClipSize / 2)))
					end
				else
					str = string.upper("MAG: " .. self:Clip1())

					if (self:Clip1() > self.Primary.ClipSize) then
						str = string.upper("MAG: " .. self.Primary.ClipSize .. " + " .. (self:Clip1() - self.Primary.ClipSize))
					end
				end

				draw.DrawText(str, "TFASleek", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
				draw.DrawText(str, "TFASleek", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
				str = string.upper("RESERVE: " .. self:Ammo1())
				yy = yy + TFASleekFontHeight
				xx = xx - TFASleekFontHeight / 3
				draw.DrawText(str, "TFASleekMedium", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
				draw.DrawText(str, "TFASleekMedium", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
				yy = yy + TFASleekFontHeightMedium
				xx = xx - TFASleekFontHeightMedium / 3
			else
				str = string.upper("AMMO: " .. self:Ammo1())
				draw.DrawText(str, "TFASleek", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
				draw.DrawText(str, "TFASleek", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
				yy = yy + TFASleekFontHeightMedium
				xx = xx - TFASleekFontHeightMedium / 3
			end

			str = string.upper( self:GetFireModeName() .. ( #self.FireModes > 2 and " | +" or "" ) )
			draw.DrawText(str, "TFASleekSmall", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
			draw.DrawText(str, "TFASleekSmall", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
			yy = yy + TFASleekFontHeightSmall
			xx = xx - TFASleekFontHeightSmall / 3

			local angpos2

			if self.Akimbo then
				angpos2 = self.Owner:ShouldDrawLocalPlayer() and self:GetAttachment( 2 ) or self.OwnerViewModel:GetAttachment( 2 )
			else
				angpos2 = self.Owner:ShouldDrawLocalPlayer() and self:GetAttachment(self.MuzzleAttachmentRaw or self:LookupAttachment(self.MuzzleAttachment)) or self.Owner:GetViewModel():GetAttachment(self.MuzzleAttachmentRaw or self.Owner:GetViewModel():LookupAttachment(self.MuzzleAttachment))
			end

			if angpos2 then
				local pos2 = angpos2.Pos
				ts2 = pos2:ToScreen()

				if self.Akimbo then
					xx, yy = ts2.x, ts2.y


					if self.Primary.ClipSize and self.Primary.ClipSize ~= -1 then
						str = string.upper("MAG: " .. math.floor(self:Clip1() / 2))

						if ( math.floor(self:Clip1() / 2) > math.floor(self.Primary.ClipSize / 2) ) then
							str = string.upper("MAG: " .. math.floor(self:Clip1() / 2 ) - 1 .. " + " .. ( math.floor(self:Clip1() / 2) - math.floor(self.Primary.ClipSize / 2)))
						end

						draw.DrawText(str, "TFASleek", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
						draw.DrawText(str, "TFASleek", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
						str = string.upper("RESERVE: " .. self:Ammo1())
						yy = yy + TFASleekFontHeight
						xx = xx - TFASleekFontHeight / 3
						draw.DrawText(str, "TFASleekMedium", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
						draw.DrawText(str, "TFASleekMedium", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
						yy = yy + TFASleekFontHeightMedium
						xx = xx - TFASleekFontHeightMedium / 3
					else
						str = string.upper("AMMO: " .. self:Ammo1())
						draw.DrawText(str, "TFASleek", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
						draw.DrawText(str, "TFASleek", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
						yy = yy + TFASleekFontHeightMedium
						xx = xx - TFASleekFontHeightMedium / 3
					end

					str = string.upper( self:GetFireModeName() .. ( #self.FireModes > 2 and " | +" or "" ) )
					draw.DrawText(str, "TFASleekSmall", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
					draw.DrawText(str, "TFASleekSmall", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
				end
			end

			if self.Secondary.Ammo and self.Secondary.Ammo ~= "" and self.Secondary.Ammo ~= "none" and self.Secondary.Ammo ~= 0 and not self.Akimbo then
				if self.Secondary.ClipSize and self.Secondary.ClipSize ~= -1 then
					str = (self:Clip2() > self.Secondary.ClipSize) and string.upper("ALT-MAG: " .. self.Secondary.ClipSize .. " + " .. (self:Clip2() - self.Primary.ClipSize)) or string.upper("ALT-MAG: " .. self:Clip2())

					draw.DrawText(str, "TFASleekSmall", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
					draw.DrawText(str, "TFASleekSmall", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
					str = string.upper("ALT-RESERVE: " .. self:Ammo2())
					yy = yy + TFASleekFontHeight
					xx = xx - TFASleekFontHeight / 3
					draw.DrawText(str, "TFASleekSmall", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
					draw.DrawText(str, "TFASleekSmall", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
					yy = yy + TFASleekFontHeightMedium
					xx = xx - TFASleekFontHeightMedium / 3
				else
					str = string.upper("ALT-AMMO: " .. self:Ammo2())
					draw.DrawText(str, "TFASleekSmall", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
					draw.DrawText(str, "TFASleekSmall", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
					yy = yy + TFASleekFontHeightMedium
					xx = xx - TFASleekFontHeightMedium / 3
				end
			end
		elseif cvar_tfa_inspection_old:GetBool() then
			local str = string.upper("DAMAGE: " .. RoundDecimals(self.Primary.Damage, 1))

			if self.Primary.NumShots and self.Primary.NumShots > 1 then
				str = str .. "x" .. math.Round(self.Primary.NumShots)
			end

			yy = yy - 100
			yy = math.Clamp(yy, 0, ScrH())
			xx = math.Clamp(xx, 250, ScrW())
			draw.DrawText(str, "TFASleek", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
			draw.DrawText(str, "TFASleek", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
			yy = yy + TFASleekFontHeight
			str = string.upper("RPM: " .. RoundDecimals(self.Primary.RPM, 1))
			draw.DrawText(str, "TFASleek", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
			draw.DrawText(str, "TFASleek", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
			yy = yy + TFASleekFontHeight
			str = string.upper("Range: " .. RoundDecimals(self.Primary.Range / 16000 * 0.305, 3) .. "KM")
			draw.DrawText(str, "TFASleek", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
			draw.DrawText(str, "TFASleek", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
			yy = yy + TFASleekFontHeight
			str = string.upper("Spread: " .. RoundDecimals(self.Primary.Spread and self.Primary.Spread or self.Primary.Accuracy, 2))
			draw.DrawText(str, "TFASleek", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
			draw.DrawText(str, "TFASleek", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
			yy = yy + TFASleekFontHeight
			str = string.upper("Spread Max: " .. RoundDecimals(self.Primary.SpreadMultiplierMax, 2))
			draw.DrawText(str, "TFASleek", xx + 1, yy + 1, ColorAlpha(self.TextColContrast, myalpha), TEXT_ALIGN_RIGHT)
			draw.DrawText(str, "TFASleek", xx, yy, ColorAlpha(self.TextCol, myalpha), TEXT_ALIGN_RIGHT)
			yy = yy + TFASleekFontHeight
		end
	end
end