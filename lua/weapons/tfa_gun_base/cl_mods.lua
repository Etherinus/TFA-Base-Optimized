--[[Thanks to Clavus.  Like seriously, SCK was brilliant. Even though you didn't include a license anywhere I could find, it's only fit to credit you.]]--
SWEP.vRenderOrder = nil
SWEP.Bodygroups_V = {}
SWEP.Bodygroups_W = {}
--[[
Function Name:  InitMods
Syntax: self:InitMods().  Should be called only once for best performance.
Returns:  Nothing.
Notes:  Creates the VElements and WElements table, and sets up mods.
Purpose:  SWEP Construction Kit Compatibility / Basic Attachments.
]]--
function SWEP:InitMods()
	--Create a new table for every weapon instance.
	self.VElements = self:CPTbl(self.VElements)
	self.WElements = self:CPTbl(self.WElements)
	self.ViewModelBoneMods = self:CPTbl(self.ViewModelBoneMods)
	self:CreateModels(self.VElements) -- create viewmodels
	self:CreateModels(self.WElements) -- create worldmodels

	--Build the bones and such.
	if self:OwnerIsValid() then
		local vm = self.Owner:GetViewModel()

		if IsValid(vm) then
			--self:ResetBonePositions(vm)
			if (self.ShowViewModel == nil or self.ShowViewModel) then
				vm:SetColor(Color(255, 255, 255, 255))
				--This hides the viewmodel, FYI, lol.
			else
				vm:SetMaterial("Debug/hsv")
			end
		end
	end
end

--[[
Function Name:  ViewModelDrawn
Syntax: self:ViewModelDrawn().  Automatically called already.
Returns:  Nothing.
Notes:  This draws the mods.
Purpose:  SWEP Construction Kit Compatibility / Basic Attachments.
]]--

function SWEP:PreDrawViewModel( vm, wep, ply )
	self:ProcessBodygroups()
	if self:GetHidden() then
		render.SetBlend(0)
	end
end

SWEP.CameraAttachmentOffsets = {{"p", 0}, {"y", 0}, {"r", 0}}
SWEP.CameraAttachment = nil
SWEP.CameraAttachments = {"camera", "attach_camera", "view", "cam", "look"}
SWEP.CameraAngCache = nil

local tmpvec = Vector(0, 0, -2000)

function SWEP:ViewModelDrawn()
	render.SetBlend(1)

	if self.DrawHands then
		self:DrawHands()
	end

	local vm = self.Owner:GetViewModel()
	if not IsValid(vm) then return end
	if not self:GetOwner().GetHands then return end

	if self.UseHands then
		local hands = self:GetOwner():GetHands()

		if IsValid(hands) then
			if not self:GetHidden() then
				hands:SetParent(vm)
			else
				hands:SetParent(nil)
				hands:SetPos(tmpvec)
			end
		end
	end

	if self.UpdateBonePositions then
		self:UpdateBonePositions(vm)
	end

	if not self.CameraAttachment then
		self.CameraAttachment = -1

		if istable(self.CameraAttachments) then
			for _, v in ipairs(self.CameraAttachments) do
				local attid = vm:LookupAttachment(v)

				if attid and attid > 0 then
					self.CameraAttachment = attid
					break
				end
			end
		end
	end

	if self.CameraAttachment and self.CameraAttachment > 0 then
		local angpos = vm:GetAttachment(self.CameraAttachment)

		if angpos and angpos.Ang then
			local angv = angpos.Ang
			local off = vm:WorldToLocalAngles(angv)
			local spd = 10
			local cycl = vm:GetCycle()
			local dissipatestart = 0
			self.CameraAngCache = self.CameraAngCache or off

			for _, v in pairs(self.CameraAttachmentOffsets) do
				local offtype = v[1]
				local offang = v[2]

				if offtype == "p" then
					off:RotateAroundAxis(off:Right(), offang)
				elseif offtype == "y" then
					off:RotateAroundAxis(off:Up(), offang)
				elseif offtype == "r" then
					off:RotateAroundAxis(off:Forward(), offang)
				end
			end

			if self.ViewModelFlip then
				off = Angle()
			end

			local actind = vm:GetSequenceActivity(vm:GetSequence())

			if (actind == ACT_VM_DRAW or actind == ACT_VM_HOLSTER_EMPTY or actind == ACT_VM_DRAW_SILENCED) and vm:GetCycle() < 0.05 then
				self.CameraAngCache.p = 0
				self.CameraAngCache.y = 0
				self.CameraAngCache.r = 0
			end

			if (actind == ACT_VM_HOLSTER or actind == ACT_VM_HOLSTER_EMPTY) and cycl > dissipatestart then
				self.CameraAngCache.p = self.CameraAngCache.p * (1 - cycl) / (1 - dissipatestart)
				self.CameraAngCache.y = self.CameraAngCache.y * (1 - cycl) / (1 - dissipatestart)
				self.CameraAngCache.r = self.CameraAngCache.r * (1 - cycl) / (1 - dissipatestart)
			end

			self.CameraAngCache.p = math.ApproachAngle(self.CameraAngCache.p, off.p, (self.CameraAngCache.p - off.p) * FrameTime() * spd)
			self.CameraAngCache.y = math.ApproachAngle(self.CameraAngCache.y, off.y, (self.CameraAngCache.y - off.y) * FrameTime() * spd)
			self.CameraAngCache.r = math.ApproachAngle(self.CameraAngCache.r, off.r, (self.CameraAngCache.r - off.r) * FrameTime() * spd)
		else
			self.CameraAngCache.p = 0
			self.CameraAngCache.y = 0
			self.CameraAngCache.r = 0
		end
	end

	if self.VElements then
		self:CreateModels(self.VElements, true)

		if (not self.vRenderOrder) then
			-- // we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs(self.VElements) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
		end

		for _, name in ipairs(self.vRenderOrder or {}) do
			local v = self.VElements[name]
			local aktiv = v.active
			if aktiv ~= nil and aktiv == false then continue end

			if (not v) then
				self.vRenderOrder = nil
				break
			end

			if v.type == "Quad" and v.draw_func_outer then continue end
			if (v.hide) then continue end
			local model = v.curmodel
			local sprite = v.spritemat
			if (not v.bone) then continue end
			local pos, ang = self:GetBoneOrientation(self.VElements, v, vm)
			if (not pos) then continue end

			if (v.type == "Model" and IsValid(model)) then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				model:SetAngles(ang)

				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end

				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() ~= v.material) then
					model:SetMaterial(v.material)
				end

				if (v.skin and v.skin ~= model:GetSkin()) then
					model:SetSkin(v.skin)
				end

				if v.bonemerge then
					model:SetParent(self.OwnerViewModel or self)

					if not model:IsEffectActive(EF_BONEMERGE) then
						v.curmodel:AddEffects(EF_BONEMERGE)
						v.curmodel:AddEffects(EF_BONEMERGE_FASTCULL)
						v.curmodel:SetMoveType(MOVETYPE_NONE)
						v.curmodel:SetPos(Vector(0, 0, 0))
						v.curmodel:SetAngles(Angle(0, 0, 0))
					end
				elseif model:IsEffectActive(EF_BONEMERGE) then
					model:RemoveEffects(EF_BONEMERGE)
					model:SetParent(nil)
				end

				render.SetColorModulation(v.color.r / 255, v.color.g / 255, v.color.b / 255)
				render.SetBlend(v.color.a / 255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
			elseif (v.type == "Sprite" and sprite) then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
			elseif (v.type == "Quad" and v.draw_func) then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				cam.Start3D2D(drawpos, ang, v.size)
				render.PushFilterMin(TEXFILTER.ANISOTROPIC)
				render.PushFilterMag(TEXFILTER.ANISOTROPIC)
				v.draw_func(self)
				render.PopFilterMin()
				render.PopFilterMag()
				cam.End3D2D()
			end
		end
	end

	if not self.UseHands and self.ViewModelDrawnPost then
		self:ViewModelDrawnPost()
	end
end

function SWEP:ViewModelDrawnPost()
	if not self:VMIV() then return end

	if self.VElements then
		for _, name in ipairs(self.vRenderOrder or {}) do
			local v = self.VElements[name]

			if (not v) then
				self.vRenderOrder = nil
				break
			end

			local aktiv = v.active
			if aktiv ~= nil and aktiv == false then continue end

			if v.type ~= "Quad" then continue end
			if not v.draw_func_outer then continue end
			if (v.hide) then continue end
			if (not v.bone) then continue end
			local pos, ang = self:GetBoneOrientation(self.VElements, v, self.OwnerViewModel)
			if (not pos) then continue end
			local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
			v.draw_func_outer(self, drawpos, ang, v.size)
		end
	end
end

hook.Add("PostDrawPlayerHands", "TFAHandsDrawn", function(hands, vm, ply, wep)
	if wep.ViewModelDrawnPost then
		wep:ViewModelDrawnPost()
	end
end)

SWEP.wRenderOrder = nil
--[[
Function Name:  DrawWorldModel
Syntax: self:DrawWorldModel().  Automatically called already.
Returns:  Nothing.
Notes:  This draws the world model, plus its attachments.
Purpose:  SWEP Construction Kit Compatibility / Basic Attachments.
]]--
local culldistancecvar = GetConVar("sv_tfa_worldmodel_culldistance")

function SWEP:DrawWorldModel()
	local ply = self:GetOwner()

	if IsValid(ply) and ply.SetupBones then
		ply:SetupBones()
		ply:InvalidateBoneCache()
		self:InvalidateBoneCache()
	end

	if IsValid(ply) and culldistancecvar and ply:GetPos():Distance(LocalPlayer():EyePos()) > culldistancecvar:GetFloat() and culldistancecvar:GetInt() ~= -1 then return end

	if (self.ShowWorldModel == nil or self.ShowWorldModel or not self:OwnerIsValid()) then
		if game.SinglePlayer() or CLIENT then
			if IsValid(ply) and self.Offset and self.Offset.Pos and self.Offset.Ang then
				local handBone = ply:LookupBone("ValveBiped.Bip01_R_Hand")

				if handBone then
					--local pos, ang = ply:GetBonePosition(handBone)
					local pos, ang
					local mat = ply:GetBoneMatrix(handBone)

					if mat then
						pos, ang = mat:GetTranslation(), mat:GetAngles()
					else
						pos, ang = ply:GetBonePosition(handBone)
					end

					pos = pos + ang:Forward() * self.Offset.Pos.Forward + ang:Right() * self.Offset.Pos.Right + ang:Up() * self.Offset.Pos.Up
					ang:RotateAroundAxis(ang:Up(), self.Offset.Ang.Up)
					ang:RotateAroundAxis(ang:Right(), self.Offset.Ang.Right)
					ang:RotateAroundAxis(ang:Forward(), self.Offset.Ang.Forward)
					self:SetRenderOrigin(pos)
					self:SetRenderAngles(ang)
					--if self.Offset.Scale and ( !self.MyModelScale or ( self.Offset and self.MyModelScale!=self.Offset.Scale ) ) then
					self:SetModelScale(self.Offset.Scale or 1, 0)
					self.MyModelScale = self.Offset.Scale
					--end
				end
			else
				self:SetRenderOrigin(nil)
				self:SetRenderAngles(nil)

				if not self.MyModelScale or self.MyModelScale ~= 1 then
					self:SetModelScale(1, 0)
					self.MyModelScale = 1
				end
			end
		end

		self:DrawModel()
	end

	if self.SetupBones then
		self:SetupBones()
	end

	self:UpdateWMBonePositions(self)
	if not self.WElements then return end
	self:CreateModels(self.WElements)

	if (not self.wRenderOrder) then
		self.wRenderOrder = {}

		for k, v in pairs(self.WElements) do
			if (v.type == "Model") then
				table.insert(self.wRenderOrder, 1, k)
			elseif (v.type == "Sprite" or v.type == "Quad") then
				table.insert(self.wRenderOrder, k)
			end
		end
	end

	local bone_ent = self:GetOwner() and self:GetOwner() or self

	for _, name in pairs(self.wRenderOrder or {}) do
		local v = self.WElements[name]

		if (not v) then
			self.wRenderOrder = nil
			break
		end

		local aktiv = v.active
		if aktiv ~= nil and aktiv == false then continue end

		if (v.hide) then continue end
		local pos, ang

		if (v.bone) then
			pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent)
		else
			pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand")
		end

		if (not pos) then continue end
		local model = v.curmodel
		local sprite = v.spritemat

		if (v.type == "Model" and IsValid(model)) then
			if not v.bonemerge then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				model:SetAngles(ang)
			end

			-- //model:SetModelScale(v.size)
			local matrix = Matrix()
			matrix:Scale(v.size)
			model:EnableMatrix("RenderMultiply", matrix)

			if (v.material == "") then
				model:SetMaterial("")
			elseif (model:GetMaterial() ~= v.material) then
				model:SetMaterial(v.material)
			end

			if (v.skin and v.skin ~= model:GetSkin()) then
				model:SetSkin(v.skin)
			end

			if (v.bodygroup) then
				for l, n in pairs(v.bodygroup) do
					if (model:GetBodygroup(l) ~= n) then
						model:SetBodygroup(l, n)
					end
				end
			end

			if (v.surpresslightning) then
				render.SuppressEngineLighting(true)
			end

			render.SetColorModulation(v.color.r / 255, v.color.g / 255, v.color.b / 255)
			render.SetBlend(v.color.a / 255)

			if v.bonemerge then
				model:SetParent(self)

				if not model:IsEffectActive(EF_BONEMERGE) then
					model:AddEffects(EF_BONEMERGE)
				end
			elseif model:IsEffectActive(EF_BONEMERGE) then
				model:RemoveEffects(EF_BONEMERGE)
				model:SetParent(nil)
			end

			model:DrawModel()
			render.SetBlend(1)
			render.SetColorModulation(1, 1, 1)

			if (v.surpresslightning) then
				render.SuppressEngineLighting(false)
			end
		elseif (v.type == "Sprite" and sprite) then
			local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			render.SetMaterial(sprite)
			render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
		elseif (v.type == "Quad" and v.draw_func) then
			local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
			cam.Start3D2D(drawpos, ang, v.size)
			v.draw_func(self)
			cam.End3D2D()
		end
	end
end

--[[
Function Name:  GetBoneOrientation
Syntax: self:GetBoneOrientation( base bone mod table, bone mod table, entity, bone override ).
Returns:  Position, Angle.
Notes:  This is a very specific function for a specific purpose, and shouldn't be used generally to get a bone's orientation.
Purpose:  SWEP Construction Kit Compatibility / Basic Attachments.
]]
--
function SWEP:GetBoneOrientation(basetabl, tabl, ent, bone_override)
	local bone, pos, ang
	if not IsValid(ent) then return Vector(0, 0, 0), Angle(0, 0, 0) end

	if (tabl.rel and tabl.rel ~= "") then
		local v = basetabl[tabl.rel]
		if (not v) then return end

		if v.bonemerge and v.curmodel and ent ~= v.curmodel then
			v.curmodel:SetupBones()

			if tabl.bone == nil or tabl.bone == "" then
				pos, ang = self:GetBoneOrientation(basetabl, v, v.curmodel, 0)
			else
				pos, ang = self:GetBoneOrientation(basetabl, v, v.curmodel, tabl.bone)
			end

			if (not pos) then return end
		else
			--As clavus states in his original code, don't make your elements named the same as a bone, because recursion.
			pos, ang = self:GetBoneOrientation(basetabl, v, ent)
			if (not pos) then return end
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
			-- For mirrored viewmodels.  You might think to scale negatively on X, but this isn't the case.
		end
	else
		if isnumber(bone_override) then
			bone = bone_override
		else
			bone = ent:LookupBone(bone_override or tabl.bone)
		end

		if (not bone) or (bone == -1) then return end
		pos, ang = Vector(0, 0, 0), Angle(0, 0, 0)
		local m = ent:GetBoneMatrix(bone)

		if (m) then
			pos, ang = m:GetTranslation(), m:GetAngles()
		end

		if (IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() and ent == self:GetOwner():GetViewModel() and self.ViewModelFlip) then
			ang.r = -ang.r
		end
	end

	return pos, ang
end

--[[
Function Name:  CleanModels
Syntax: self:CleanModels( elements table ).
Returns:   Nothing.
Notes:  Removes all existing models.
Purpose:  SWEP Construction Kit Compatibility / Basic Attachments.
]]--
function SWEP:CleanModels(tabl)
	if (not tabl) then return end

	for k, v in pairs(tabl) do
		if (v.type == "Model" and v.curmodel) then
			if v.curmodel and v.curmodel.Remove then
				timer.Simple(0, function()
					if v.curmodel and v.curmodel.Remove then
						v.curmodel:Remove()
					end

					v.curmodel = nil
				end)
			else
				v.curmodel = nil
			end
		elseif (v.type == "Sprite" and v.sprite and v.sprite ~= "" and (not v.spritemat or v.cursprite ~= v.sprite)) then
			v.cursprite = nil
			v.spritemat = nil
		end
	end
end

--[[
Function Name:  CreateModels
Syntax: self:CreateModels( elements table ).
Returns:   Nothing.
Notes:  Creates the elements for whatever you give it.
Purpose:  SWEP Construction Kit Compatibility / Basic Attachments.
]]--
function SWEP:CreateModels(tabl)
	if (not tabl) then return end

	for k, v in pairs(tabl) do
		if (v.type == "Model" and v.model and (not IsValid(v.curmodel) or v.curmodelname ~= v.model) and v.model ~= "" ) then
			v.curmodel = ClientsideModel(v.model, RENDERGROUP_VIEWMODEL)

			if (IsValid(v.curmodel)) then
				v.curmodel:SetPos(self:GetPos())
				v.curmodel:SetAngles(self:GetAngles())
				v.curmodel:SetParent(self)
				v.curmodel:SetNoDraw(true)

				if v.material then
					v.curmodel:SetMaterial(v.material or "")
				end
				if v.skin then
					v.curmodel:SetSkin(v.skin)
				end

				if (v.bodygroup) then
					for l, b in pairs(v.bodygroup) do
						if (type(l) == "number") and (v.curmodel:GetBodygroup(l) ~= b) then
							v.curmodel:SetBodygroup(l, b)
						end
					end
				end

				local matrix = Matrix()
				matrix:Scale(v.size)
				v.curmodel:EnableMatrix("RenderMultiply", matrix)
				v.curmodelname = v.model
			else
				v.curmodel = nil
			end
			-- // make sure we create a unique name based on the selected options
		elseif (v.type == "Sprite" and v.sprite and v.sprite ~= "" and (not v.spritemat or v.cursprite ~= v.sprite)) then
			local name = v.sprite .. "-"

			local params = {
				["$basetexture"] = v.sprite
			}

			local tocheck = {"nocull", "additive", "vertexalpha", "vertexcolor", "ignorez"}

			for i, j in pairs(tocheck) do
				if (v[j]) then
					params["$" .. j] = 1
					name = name .. "1"
				else
					name = name .. "0"
				end
			end

			v.cursprite = v.sprite
			v.spritemat = CreateMaterial(name, "UnlitGeneric", params)
		end
	end
end

--[[
Function Name:  UpdateBonePositions
Syntax: self:UpdateBonePositions( viewmodel ).
Returns:   Nothing.
Notes:   Updates the bones for a viewmodel.
Purpose:  SWEP Construction Kit Compatibility / Basic Attachments.
]]--
local bpos, bang
local onevec = Vector(1, 1, 1)
local getKeys = table.GetKeys
local function appendTable(t, t2)
	for i = 1, #t2 do
		t[#t + 1] = t2[i]
	end
end
SWEP.ChildrenScaled = {}
SWEP.ViewModelBoneMods_Children = {}
function SWEP:ScaleChildBoneMods(ent,bone,cumulativeScale)
	if self.ChildrenScaled[bone] then
		return
	end
	self.ChildrenScaled[bone] = true
	local boneid = ent:LookupBone(bone)
	if not boneid then return end
	local curScale = (cumulativeScale or Vector(1,1,1)) * 1
	if self.ViewModelBoneMods[bone] then
		curScale = curScale * self.ViewModelBoneMods[bone].scale
	end
	local ch = ent:GetChildBones(boneid)
	if ch and #ch > 0 then
		for _, boneChild in ipairs(ch) do
			self:ScaleChildBoneMods(ent,ent:GetBoneName(boneChild),curScale)
		end
	end
	if self.ViewModelBoneMods[bone] then
		self.ViewModelBoneMods[bone].scale = curScale
	else
		self.ViewModelBoneMods_Children[bone] = {
			["pos"] = vector_origin,
			["angle"] = angle_zero,
			["scale"] = curScale * 1
		}
	end
end

function SWEP:UpdateBonePositions(vm)
	local vmbm = self:GetStat("ViewModelBoneMods")
	if vmbm then
		local stat = self:GetStatus()

		if not self.BlowbackBoneMods then
			self.BlowbackBoneMods = {}
			self.BlowbackCurrent = 0
		end

		if not self.HasSetMetaVMBM then
			for k,v in pairs(self.ViewModelBoneMods) do
				if v.scale and v.scale.x ~= 1 or v.scale.y ~= 1 or v.scale.z ~= 1 then
					self:ScaleChildBoneMods(vm,k)
				end
			end
			for _,v in pairs(self.BlowbackBoneMods) do
				v.pos_og = v.pos
				v.angle_og = v.angle
				v.scale_og = v.scale or onevec
			end
			self.HasSetMetaVMBM = true
			self.ViewModelBoneMods["wepEnt"] = self
			setmetatable(self.ViewModelBoneMods,{ __index = function(t,k)
				if not IsValid(self) then return end
				if self.ViewModelBoneMods_Children[k] then return self.ViewModelBoneMods_Children[k] end
				if not self.BlowbackBoneMods[k] then return end
				if not ( self.SequenceEnabled[ACT_VM_RELOAD_EMPTY] and TFA.Enum.ReloadStatus[stat] and self.Blowback_PistolMode ) then
					self.BlowbackBoneMods[k].pos = self.BlowbackBoneMods[k].pos_og * self.BlowbackCurrent
					self.BlowbackBoneMods[k].angle = self.BlowbackBoneMods[k].angle_og * self.BlowbackCurrent
					self.BlowbackBoneMods[k].scale = Lerp(self.BlowbackCurrent, onevec, self.BlowbackBoneMods[k].scale_og)
					return self.BlowbackBoneMods[k]
				end
			end})
		end

		if not ( self.SequenceEnabled[ACT_VM_RELOAD_EMPTY] and TFA.Enum.ReloadStatus[stat] and self.Blowback_PistolMode ) then
			self.BlowbackCurrent = math.Approach(self.BlowbackCurrent, 0, self.BlowbackCurrent * FrameTime() * 30)
		end

		local keys = getKeys(self.ViewModelBoneMods)
		appendTable(keys, getKeys(self.BlowbackBoneMods))
		appendTable(keys, getKeys(self.ViewModelBoneMods_Children))

		for _,k in pairs(keys) do
			local v = self.ViewModelBoneMods[k]
			if not v then continue end
			local bone = vm:LookupBone(k)
			if not bone then continue end

			if vm:GetManipulateBoneScale(bone) ~= v.scale then
				vm:ManipulateBoneScale(bone, v.scale)
			end

			if vm:GetManipulateBoneAngles(bone) ~= v.angle then
				vm:ManipulateBoneAngles(bone, v.angle)
			end

			if vm:GetManipulateBonePosition(bone) ~= v.pos then
				vm:ManipulateBonePosition(bone, v.pos)
			end
		end
	elseif self.BlowbackBoneMods then
		for bonename, tbl in pairs(self.BlowbackBoneMods) do
			local bone = vm:LookupBone(bonename)

			if bone and bone >= 0 then
				bpos = tbl.pos * self.BlowbackCurrent
				bang = tbl.angle * self.BlowbackCurrent
				vm:ManipulateBonePosition(bone, bpos)
				vm:ManipulateBoneAngles(bone, bang)
			end
		end
	end
end

--[[
Function Name:  ResetBonePositions
Syntax: self:ResetBonePositions( viewmodel ).
Returns:   Nothing.
Notes:   Resets the bones for a viewmodel.
Purpose:  SWEP Construction Kit Compatibility / Basic Attachments.
]]--
function SWEP:ResetBonePositions(val)
	if SERVER then
		self:CallOnClient("ResetBonePositions", "")

		return
	end

	vm = self.Owner:GetViewModel()
	if not IsValid(vm) then return end
	if (not vm:GetBoneCount()) then return end

	for i = 0, vm:GetBoneCount() do
		vm:ManipulateBoneScale(i, Vector(1, 1, 1))
		vm:ManipulateBoneAngles(i, Angle(0, 0, 0))
		vm:ManipulateBonePosition(i, vector_origin)
	end
end

--[[
Function Name:  UpdateWMBonePositions
Syntax: self:UpdateWMBonePositions( worldmodel ).
Returns:   Nothing.
Notes:   Updates the bones for a worldmodel.
Purpose:  SWEP Construction Kit Compatibility / Basic Attachments.
]]
--
function SWEP:UpdateWMBonePositions(wm)
	if not self.WorldModelBoneMods then
		self.WorldModelBoneMods = {}
	end

	local WM_BoneMods = self:GetStat("WorldModelBoneMods", self.WorldModelBoneMods)

	if table.Count(WM_BoneMods) > 0 then
		if (not wm:GetBoneCount()) then return end
		local wbones = {}
		local loopthrough

		for i = 0, wm:GetBoneCount() do
			local bonename = wm:GetBoneName(i)

			if (WM_BoneMods[bonename]) then
				wbones[bonename] = WM_BoneMods[bonename]
			else
				wbones[bonename] = {
					scale = onevec,
					pos = vector_origin,
					angle = angle_zero
				}
			end
		end

		loopthrough = wbones

		for k, v in pairs(loopthrough) do
			local bone = wm:LookupBone(k)
			if (not bone) or (bone == -1) then continue end
			local s = Vector(v.scale.x, v.scale.y, v.scale.z)
			local p = Vector(v.pos.x, v.pos.y, v.pos.z)
			local childscale = Vector(1, 1, 1)
			local cur = wm:GetBoneParent(bone)

			while (cur ~= -1) do
				local pscale = loopthrough[wm:GetBoneName(cur)].scale
				childscale = childscale * pscale
				cur = wm:GetBoneParent(cur)
			end

			s = s * childscale

			if wm:GetManipulateBoneScale(bone) ~= s then
				wm:ManipulateBoneScale(bone, s)
			end

			if wm:GetManipulateBoneAngles(bone) ~= v.angle then
				wm:ManipulateBoneAngles(bone, v.angle)
			end

			if wm:GetManipulateBonePosition(bone) ~= p then
				wm:ManipulateBonePosition(bone, p)
			end
		end
	end
end

--[[
Function Name:  ResetWMBonePositions
Syntax: self:ResetWMBonePositions( worldmodel ).
Returns:   Nothing.
Notes:   Resets the bones for a worldmodel.
Purpose:  SWEP Construction Kit Compatibility / Basic Attachments.
]]
--
function SWEP:ResetWMBonePositions(wm)
	if SERVER then
		self:CallOnClient("ResetWMBonePositions", "")

		return
	end

	if not wm then
		wm = self
	end

	if not IsValid(wm) then return end
	if (not wm:GetBoneCount()) then return end

	for i = 0, wm:GetBoneCount() do
		wm:ManipulateBoneScale(i, Vector(1, 1, 1))
		wm:ManipulateBoneAngles(i, Angle(0, 0, 0))
		wm:ManipulateBonePosition(i, vector_origin)
	end
end
