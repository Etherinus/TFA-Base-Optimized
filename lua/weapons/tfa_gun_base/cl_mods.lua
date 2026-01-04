SWEP.vRenderOrder = nil
SWEP.Bodygroups_V = {}
SWEP.Bodygroups_W = {}

function SWEP:InitMods()
	self.VElements = self:CPTbl(self.VElements)
	self.WElements = self:CPTbl(self.WElements)
	self.ViewModelBoneMods = self:CPTbl(self.ViewModelBoneMods)

	self:CreateModels(self.VElements)
	self:CreateModels(self.WElements)

	if self:OwnerIsValid() then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			if self.ShowViewModel == nil or self.ShowViewModel then
				vm:SetColor(Color(255, 255, 255, 255))
			else
				vm:SetMaterial("Debug/hsv")
			end
		end
	end
end

function SWEP:PreDrawViewModel(vm, wep, ply)
	self:ProcessBodygroups()
	if self:GetHidden() then
		render.SetBlend(0)
	end
end

SWEP.CameraAttachmentOffsets = { { "p", 0 }, { "y", 0 }, { "r", 0 } }
SWEP.CameraAttachment = nil
SWEP.CameraAttachments = { "camera", "attach_camera", "view", "cam", "look" }
SWEP.CameraAngCache = nil

local tmpvec = Vector(0, 0, -2000)

function SWEP:ViewModelDrawn()
	render.SetBlend(1)

	if self.DrawHands then
		self:DrawHands()
	end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	local vm = owner:GetViewModel()
	if not IsValid(vm) then return end

	self.OwnerViewModel = vm

	if not owner.GetHands then return end

	if self.UseHands then
		local hands = owner:GetHands()
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
			for i = 1, #self.CameraAttachments do
				local name = self.CameraAttachments[i]
				local attid = vm:LookupAttachment(name)
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
			local off = vm:WorldToLocalAngles(angpos.Ang)
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

		if not self.vRenderOrder then
			self.vRenderOrder = {}

			for k, v in pairs(self.VElements) do
				if v and v.type == "Model" then
					table.insert(self.vRenderOrder, 1, k)
				elseif v and (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
		end

		for i = 1, #(self.vRenderOrder or {}) do
			local name = self.vRenderOrder[i]
			local v = self.VElements[name]

			if not v then
				self.vRenderOrder = nil
				break
			end

			local aktiv = v.active
			if aktiv ~= nil and aktiv == false then
				goto cont_v
			end

			if v.type == "Quad" and v.draw_func_outer then
				goto cont_v
			end

			if v.hide then
				goto cont_v
			end

			if (not v.bone) and (not v.bonemerge) then
				goto cont_v
			end

			local pos, ang = self:GetBoneOrientation(self.VElements, v, vm)

			if (not pos) and (not v.bonemerge) then
				goto cont_v
			end

			if v.bonemerge then
				pos = pos or vector_origin
				ang = ang or angle_zero
			end

			local model = v.curmodel
			local sprite = v.spritemat

			if v.type == "Model" and IsValid(model) then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)

				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)

				if v.surpresslightning then
					render.SuppressEngineLighting(true)
				end

				if v.material == "" then
					model:SetMaterial("")
				elseif model:GetMaterial() ~= v.material then
					model:SetMaterial(v.material)
				end

				if v.skin and v.skin ~= model:GetSkin() then
					model:SetSkin(v.skin)
				end

				if v.bonemerge then
					model:SetParent(self.OwnerViewModel or self)

					if not model:IsEffectActive(EF_BONEMERGE) then
						model:AddEffects(EF_BONEMERGE)
						model:AddEffects(EF_BONEMERGE_FASTCULL)
						model:SetMoveType(MOVETYPE_NONE)
						model:SetPos(vector_origin)
						model:SetAngles(angle_zero)
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

				if v.surpresslightning then
					render.SuppressEngineLighting(false)
				end
			elseif v.type == "Sprite" and sprite then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
			elseif v.type == "Quad" and v.draw_func then
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

			::cont_v::
		end
	end

	if not self.UseHands and self.ViewModelDrawnPost then
		self:ViewModelDrawnPost()
	end
end

function SWEP:ViewModelDrawnPost()
	if not self:VMIV() then return end
	if not self.VElements then return end

	for i = 1, #(self.vRenderOrder or {}) do
		local name = self.vRenderOrder[i]
		local v = self.VElements[name]

		if not v then
			self.vRenderOrder = nil
			break
		end

		local aktiv = v.active
		if aktiv ~= nil and aktiv == false then
			goto cont_post
		end

		if v.type ~= "Quad" then
			goto cont_post
		end

		if not v.draw_func_outer then
			goto cont_post
		end

		if v.hide then
			goto cont_post
		end

		if not v.bone then
			goto cont_post
		end

		local pos, ang = self:GetBoneOrientation(self.VElements, v, self.OwnerViewModel)
		if not pos then
			goto cont_post
		end

		local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z

		ang:RotateAroundAxis(ang:Up(), v.angle.y)
		ang:RotateAroundAxis(ang:Right(), v.angle.p)
		ang:RotateAroundAxis(ang:Forward(), v.angle.r)

		v.draw_func_outer(self, drawpos, ang, v.size)

		::cont_post::
	end
end

hook.Add("PostDrawPlayerHands", "TFAHandsDrawn", function(hands, vm, ply, wep)
	if not IsValid(wep) then return end
	if not wep.ViewModelDrawnPost then return end
	wep:ViewModelDrawnPost()
end)

SWEP.wRenderOrder = nil
local culldistancecvar = GetConVar("sv_tfa_worldmodel_culldistance")

function SWEP:DrawWorldModel()
	local ply = self:GetOwner()

	if IsValid(ply) and ply.SetupBones then
		ply:SetupBones()
		ply:InvalidateBoneCache()
		self:InvalidateBoneCache()
	end

	local lp = LocalPlayer()
	if IsValid(ply) and IsValid(lp) and culldistancecvar and culldistancecvar:GetInt() ~= -1 then
		if ply:GetPos():Distance(lp:EyePos()) > culldistancecvar:GetFloat() then
			return
		end
	end

	if self.ShowWorldModel == nil or self.ShowWorldModel or not self:OwnerIsValid() then
		if IsValid(ply) and self.Offset and self.Offset.Pos and self.Offset.Ang then
			local handBone = ply:LookupBone("ValveBiped.Bip01_R_Hand")

			if handBone then
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

				local sc = self.Offset.Scale or 1
				self:SetModelScale(sc, 0)
				self.MyModelScale = sc
			end
		else
			self:SetRenderOrigin(nil)
			self:SetRenderAngles(nil)

			if not self.MyModelScale or self.MyModelScale ~= 1 then
				self:SetModelScale(1, 0)
				self.MyModelScale = 1
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

	if not self.wRenderOrder then
		self.wRenderOrder = {}

		for k, v in pairs(self.WElements) do
			if v and v.type == "Model" then
				table.insert(self.wRenderOrder, 1, k)
			elseif v and (v.type == "Sprite" or v.type == "Quad") then
				table.insert(self.wRenderOrder, k)
			end
		end
	end

	local bone_ent = IsValid(ply) and ply or self

	for i = 1, #(self.wRenderOrder or {}) do
		local name = self.wRenderOrder[i]
		local v = self.WElements[name]

		if not v then
			self.wRenderOrder = nil
			break
		end

		local aktiv = v.active
		if aktiv ~= nil and aktiv == false then
			goto cont_w
		end

		if v.hide then
			goto cont_w
		end

		local pos, ang

		if v.bone then
			pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent)
		else
			pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand")
		end

		if not pos then
			goto cont_w
		end

		local model = v.curmodel
		local sprite = v.spritemat

		if v.type == "Model" and IsValid(model) then
			if not v.bonemerge then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)

				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
			end

			local matrix = Matrix()
			matrix:Scale(v.size)
			model:EnableMatrix("RenderMultiply", matrix)

			if v.material == "" then
				model:SetMaterial("")
			elseif model:GetMaterial() ~= v.material then
				model:SetMaterial(v.material)
			end

			if v.skin and v.skin ~= model:GetSkin() then
				model:SetSkin(v.skin)
			end

			if v.bodygroup then
				for l, n in pairs(v.bodygroup) do
					if model:GetBodygroup(l) ~= n then
						model:SetBodygroup(l, n)
					end
				end
			end

			if v.surpresslightning then
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

			if v.surpresslightning then
				render.SuppressEngineLighting(false)
			end
		elseif v.type == "Sprite" and sprite then
			local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			render.SetMaterial(sprite)
			render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
		elseif v.type == "Quad" and v.draw_func then
			local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z

			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

			cam.Start3D2D(drawpos, ang, v.size)
			v.draw_func(self)
			cam.End3D2D()
		end

		::cont_w::
	end
end

function SWEP:GetBoneOrientation(basetabl, tabl, ent, bone_override)
	if not IsValid(ent) then return vector_origin, angle_zero end

	if tabl.rel and tabl.rel ~= "" then
		local v = basetabl[tabl.rel]
		if not v then return end

		if v.bonemerge and v.curmodel and ent ~= v.curmodel then
			v.curmodel:SetupBones()

			local bo = tabl.bone
			if bo == nil or bo == "" then
				return self:GetBoneOrientation(basetabl, v, v.curmodel, 0)
			end

			return self:GetBoneOrientation(basetabl, v, v.curmodel, bo)
		end

		local pos, ang = self:GetBoneOrientation(basetabl, v, ent)
		if not pos then return end

		pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z

		ang:RotateAroundAxis(ang:Up(), v.angle.y)
		ang:RotateAroundAxis(ang:Right(), v.angle.p)
		ang:RotateAroundAxis(ang:Forward(), v.angle.r)

		return pos, ang
	end

	local bone
	if isnumber(bone_override) then
		bone = bone_override
	else
		bone = ent:LookupBone(bone_override or tabl.bone)
	end

	if not bone or bone == -1 then return end

	local m = ent:GetBoneMatrix(bone)
	if not m then return vector_origin, angle_zero end

	local pos, ang = m:GetTranslation(), m:GetAngles()

	local owner = self:GetOwner()
	if IsValid(owner) and owner:IsPlayer() and ent == owner:GetViewModel() and self.ViewModelFlip then
		ang.r = -ang.r
	end

	return pos, ang
end

function SWEP:CleanModels(tabl)
	if not tabl then return end

	for _, v in pairs(tabl) do
		if v.type == "Model" and v.curmodel then
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
		elseif v.type == "Sprite" and v.sprite and v.sprite ~= "" and (not v.spritemat or v.cursprite ~= v.sprite) then
			v.cursprite = nil
			v.spritemat = nil
		end
	end
end

function SWEP:CreateModels(tabl)
	if not tabl then return end

	for _, v in pairs(tabl) do
		if v.type == "Model" and v.model and (not IsValid(v.curmodel) or v.curmodelname ~= v.model) and v.model ~= "" then
			v.curmodel = ClientsideModel(v.model, RENDERGROUP_VIEWMODEL)

			if IsValid(v.curmodel) then
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

				if v.bodygroup then
					for l, b in pairs(v.bodygroup) do
						if type(l) == "number" and v.curmodel:GetBodygroup(l) ~= b then
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
		elseif v.type == "Sprite" and v.sprite and v.sprite ~= "" and (not v.spritemat or v.cursprite ~= v.sprite) then
			local name = v.sprite .. "-"

			local params = {
				["$basetexture"] = v.sprite
			}

			local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }

			for i = 1, #tocheck do
				local j = tocheck[i]
				if v[j] then
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

local bpos, bang
local onevec = Vector(1, 1, 1)

SWEP.ChildrenScaled = {}
SWEP.ViewModelBoneMods_Children = {}

function SWEP:ScaleChildBoneMods(ent, bone, cumulativeScale)
	if self.ChildrenScaled[bone] then return end
	self.ChildrenScaled[bone] = true

	local boneid = ent:LookupBone(bone)
	if boneid == nil or boneid < 0 then return end

	local curScale
	if cumulativeScale then
		curScale = cumulativeScale * 1
	else
		curScale = Vector(1, 1, 1)
	end

	local bm = self.ViewModelBoneMods and self.ViewModelBoneMods[bone]
	if bm and bm.scale then
		curScale = curScale * bm.scale
	end

	local ch = ent:GetChildBones(boneid)
	if ch and #ch > 0 then
		for i = 1, #ch do
			local boneChild = ch[i]
			self:ScaleChildBoneMods(ent, ent:GetBoneName(boneChild), curScale)
		end
	end

	if bm and bm.scale then
		bm.scale = curScale
	else
		self.ViewModelBoneMods_Children[bone] = {
			pos = vector_origin,
			angle = angle_zero,
			scale = curScale * 1
		}
	end
end

function SWEP:UpdateBonePositions(vm)
	local vmbm = self:GetStat("ViewModelBoneMods")
	if vmbm then
		self.ViewModelBoneMods = self.ViewModelBoneMods or {}
		self._tfa_vmbm_stat = self:GetStatus()

		if not self.BlowbackBoneMods then
			self.BlowbackBoneMods = {}
			self.BlowbackCurrent = 0
		end

		if not self.HasSetMetaVMBM then
			for k, v in pairs(self.ViewModelBoneMods) do
				if v and v.scale and (v.scale.x ~= 1 or v.scale.y ~= 1 or v.scale.z ~= 1) then
					self:ScaleChildBoneMods(vm, k)
				end
			end

			for _, v in pairs(self.BlowbackBoneMods) do
				v.pos_og = v.pos
				v.angle_og = v.angle
				v.scale_og = v.scale or onevec
			end

			self.HasSetMetaVMBM = true
			self.ViewModelBoneMods.wepEnt = self

			local wep = self
			setmetatable(self.ViewModelBoneMods, {
				__index = function(t, k)
					if not IsValid(wep) then return end

					local ch = wep.ViewModelBoneMods_Children
					if ch and ch[k] then
						return ch[k]
					end

					local bb = wep.BlowbackBoneMods
					if not bb or not bb[k] then
						return
					end

					local statNow = wep._tfa_vmbm_stat
					local seqOk = false

					if wep.SequenceEnabled then
						seqOk = wep.SequenceEnabled[ACT_VM_RELOAD_EMPTY] and true or false
					end

					if not (seqOk and TFA and TFA.Enum and TFA.Enum.ReloadStatus and TFA.Enum.ReloadStatus[statNow] and wep.Blowback_PistolMode) then
						local cur = wep.BlowbackCurrent or 0
						local src = bb[k]

						src.pos = src.pos_og * cur
						src.angle = src.angle_og * cur
						src.scale = Lerp(cur, onevec, src.scale_og)

						return src
					end
				end
			})
		end

		local statNow = self._tfa_vmbm_stat
		local seqOk = false
		if self.SequenceEnabled then
			seqOk = self.SequenceEnabled[ACT_VM_RELOAD_EMPTY] and true or false
		end

		if not (seqOk and TFA and TFA.Enum and TFA.Enum.ReloadStatus and TFA.Enum.ReloadStatus[statNow] and self.Blowback_PistolMode) then
			self.BlowbackCurrent = math.Approach(self.BlowbackCurrent, 0, self.BlowbackCurrent * FrameTime() * 30)
		end

		local keys = self._tfa_vmbm_keys
		local keyset = self._tfa_vmbm_keyset

		if not keys then
			keys = {}
			self._tfa_vmbm_keys = keys
		end

		if not keyset then
			keyset = {}
			self._tfa_vmbm_keyset = keyset
		end

		for k in pairs(keyset) do
			keyset[k] = nil
		end

		for i = #keys, 1, -1 do
			keys[i] = nil
		end

		local function addKey(k)
			if not k or k == "wepEnt" then return end
			if keyset[k] then return end
			keyset[k] = true
			keys[#keys + 1] = k
		end

		for k in pairs(self.ViewModelBoneMods) do
			addKey(k)
		end

		for k in pairs(self.BlowbackBoneMods) do
			addKey(k)
		end

		for k in pairs(self.ViewModelBoneMods_Children) do
			addKey(k)
		end

		local boneCache = self._tfa_vm_bonecache
		if self._tfa_vm_bonecache_ent ~= vm then
			self._tfa_vm_bonecache_ent = vm
			boneCache = {}
			self._tfa_vm_bonecache = boneCache
			self._tfa_vm_bonecache_model = vm:GetModel()
		elseif self._tfa_vm_bonecache_model ~= vm:GetModel() then
			self._tfa_vm_bonecache_model = vm:GetModel()
			boneCache = {}
			self._tfa_vm_bonecache = boneCache
		end

		for i = 1, #keys do
			local k = keys[i]
			local v = self.ViewModelBoneMods[k]
			if not v then goto cont_bone end

			local bone = boneCache[k]
			if bone == nil then
				bone = vm:LookupBone(k)
				if bone == nil then bone = -1 end
				boneCache[k] = bone
			end

			if bone < 0 then goto cont_bone end

			local sc = v.scale or onevec
			local an = v.angle or angle_zero
			local ps = v.pos or vector_origin

			if vm:GetManipulateBoneScale(bone) ~= sc then
				vm:ManipulateBoneScale(bone, sc)
			end

			if vm:GetManipulateBoneAngles(bone) ~= an then
				vm:ManipulateBoneAngles(bone, an)
			end

			if vm:GetManipulateBonePosition(bone) ~= ps then
				vm:ManipulateBonePosition(bone, ps)
			end

			::cont_bone::
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

function SWEP:ResetBonePositions(val)
	if SERVER then
		self:CallOnClient("ResetBonePositions", "")
		return
	end

	local vm = self.Owner:GetViewModel()
	if not IsValid(vm) then return end
	if not vm:GetBoneCount() then return end

	for i = 0, vm:GetBoneCount() do
		vm:ManipulateBoneScale(i, Vector(1, 1, 1))
		vm:ManipulateBoneAngles(i, Angle(0, 0, 0))
		vm:ManipulateBonePosition(i, vector_origin)
	end
end

function SWEP:UpdateWMBonePositions(wm)
	if not self.WorldModelBoneMods then
		self.WorldModelBoneMods = {}
	end

	local WM_BoneMods = self:GetStat("WorldModelBoneMods", self.WorldModelBoneMods)
	if table.Count(WM_BoneMods) <= 0 then return end
	if not wm:GetBoneCount() then return end

	local wbones = {}

	for i = 0, wm:GetBoneCount() do
		local bonename = wm:GetBoneName(i)

		if WM_BoneMods[bonename] then
			wbones[bonename] = WM_BoneMods[bonename]
		else
			wbones[bonename] = {
				scale = onevec,
				pos = vector_origin,
				angle = angle_zero
			}
		end
	end

	for k, v in pairs(wbones) do
		local bone = wm:LookupBone(k)
		if not bone or bone == -1 then goto cont_wm end

		local s = Vector(v.scale.x, v.scale.y, v.scale.z)
		local p = Vector(v.pos.x, v.pos.y, v.pos.z)

		local childscale = Vector(1, 1, 1)
		local cur = wm:GetBoneParent(bone)

		while cur ~= -1 do
			local parentName = wm:GetBoneName(cur)
			local parent = wbones[parentName]
			if parent and parent.scale then
				childscale = childscale * parent.scale
			end
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

		::cont_wm::
	end
end

function SWEP:ResetWMBonePositions(wm)
	if SERVER then
		self:CallOnClient("ResetWMBonePositions", "")
		return
	end

	if not wm then
		wm = self
	end

	if not IsValid(wm) then return end
	if not wm:GetBoneCount() then return end

	for i = 0, wm:GetBoneCount() do
		wm:ManipulateBoneScale(i, Vector(1, 1, 1))
		wm:ManipulateBoneAngles(i, Angle(0, 0, 0))
		wm:ManipulateBonePosition(i, vector_origin)
	end
end
