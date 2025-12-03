if SERVER then AddCSLuaFile() end

local wepMeta = FindMetaTable("Weapon")
if not wepMeta then return end

local defaultStarts = {
	Bool = 4,
	Float = 2,
	Int = 4,
	Entity = 1,
	String = 0,
	Angle = 0,
	Vector = 0
}

local function ensureNW2(ent)
	ent.SetNW2Bool = ent.SetNW2Bool or ent.SetNWBool
	ent.GetNW2Bool = ent.GetNW2Bool or ent.GetNWBool
	ent.SetNW2Int = ent.SetNW2Int or ent.SetNWInt
	ent.GetNW2Int = ent.GetNW2Int or ent.GetNWInt
	ent.SetNW2Float = ent.SetNW2Float or ent.SetNWFloat
	ent.GetNW2Float = ent.GetNW2Float or ent.GetNWFloat
	ent.SetNW2String = ent.SetNW2String or ent.SetNWString
	ent.GetNW2String = ent.GetNW2String or ent.GetNWString
	ent.SetNW2Entity = ent.SetNW2Entity or ent.SetNWEntity
	ent.GetNW2Entity = ent.GetNW2Entity or ent.GetNWEntity
end

local function defineFallback(ent, varType, name, default)
	ensureNW2(ent)

	local getter = "Get" .. name
	local setter = "Set" .. name

	if varType == "Bool" then
		ent[setter] = ent[setter] or function(self, val)
			ensureNW2(self)
			self:SetNW2Bool(name, val and true or false)
		end
		ent[getter] = ent[getter] or function(self, fallback)
			ensureNW2(self)
			if fallback == nil then
				fallback = default
			end
			return self:GetNW2Bool(name, fallback or false)
		end
	elseif varType == "Int" then
		ent[setter] = ent[setter] or function(self, val)
			ensureNW2(self)
			self:SetNW2Int(name, val or 0)
		end
		ent[getter] = ent[getter] or function(self, fallback)
			ensureNW2(self)
			if fallback == nil then
				fallback = default
			end
			return self:GetNW2Int(name, fallback or 0)
		end
	elseif varType == "Float" then
		ent[setter] = ent[setter] or function(self, val)
			ensureNW2(self)
			self:SetNW2Float(name, val or 0)
		end
		ent[getter] = ent[getter] or function(self, fallback)
			ensureNW2(self)
			if fallback == nil then
				fallback = default
			end
			return self:GetNW2Float(name, fallback or 0)
		end
	elseif varType == "Entity" then
		ent[setter] = ent[setter] or function(self, val)
			ensureNW2(self)
			self:SetNW2Entity(name, val)
		end
		ent[getter] = ent[getter] or function(self, fallback)
			ensureNW2(self)
			return self:GetNW2Entity(name, fallback)
		end
	elseif varType == "String" then
		ent[setter] = ent[setter] or function(self, val)
			ensureNW2(self)
			self:SetNW2String(name, val or "")
		end
		ent[getter] = ent[getter] or function(self, fallback)
			ensureNW2(self)
			if fallback == nil then
				fallback = default
			end
			return self:GetNW2String(name, fallback or "")
		end
	else
		ent[setter] = ent[setter] or function(self, val)
			self["__tfa_fallback_" .. name] = val
		end
		ent[getter] = ent[getter] or function(self, fallback)
			local val = self["__tfa_fallback_" .. name]
			if val == nil then
				val = default
			end
			if val == nil then
				val = fallback
			end
			return val
		end
	end
end

if not wepMeta.NetworkVarTFA then
	function wepMeta:NetworkVarTFA(varType, name, default)
		self.__TFA_NWVarCounts = self.__TFA_NWVarCounts or {}

		local start = defaultStarts[varType] or 0
		if self.__TFA_NWVarCounts[varType] == nil then
			self.__TFA_NWVarCounts[varType] = start
		end

		local index = self.__TFA_NWVarCounts[varType]
		self.__TFA_NWVarCounts[varType] = index + 1

		local ok, err = pcall(self.NetworkVar, self, varType, index, name)
		if not ok then
			defineFallback(self, varType, name, default)
		elseif default ~= nil then
			local setter = self["Set" .. name]
			if setter then
				setter(self, default)
			end
		end

		return index
	end
end

if not wepMeta.GetStatL then
	function wepMeta:GetStatL(stat)
		if self.GetStat then
			return self:GetStat(stat)
		end

		local tbl = self
		if not stat or stat == "" then return tbl end

		for _, key in ipairs(string.Explode(".", stat, false)) do
			if tbl and tbl[key] ~= nil then
				tbl = tbl[key]
			else
				return nil
			end
		end

		return tbl
	end
end

if not wepMeta.ScheduleStatus then
	function wepMeta:ScheduleStatus(status, len)
		if not self.SetStatus or not self.SetStatusEnd then return end
		self:SetStatus(status or 0)
		self:SetStatusEnd(CurTime() + (len or 0))
	end
end

if not wepMeta.GetAnimationRate then
	function wepMeta:GetAnimationRate()
		return 1
	end
end

if not wepMeta.GetIronSightsProgress then
	function wepMeta:GetIronSightsProgress()
		local prog = self.IronSightsProgress
		if prog == nil then
			local is = self.GetIronSights and self:GetIronSights()
			return is and 1 or 0
		end
		return prog
	end
end

if not wepMeta.SetIronSightsProgress then
	function wepMeta:SetIronSightsProgress(val)
		self.IronSightsProgress = val or 0
	end
end

if not wepMeta.UpdateBonePositions then
	function wepMeta:UpdateBonePositions(vm)
		-- Compat stub for SWEP Construction Kit bone handling
	end
end

if not wepMeta.EmitSoundNet then
	function wepMeta:EmitSoundNet(snd, lvl, pitch, volume)
		if not snd or snd == "" then return end
		self:EmitSound(snd, lvl, pitch, volume)
	end
end

if not wepMeta.SharedRandom then
	function wepMeta:SharedRandom(id, min, max, seed)
		min = tonumber(min) or 0
		max = tonumber(max) or 1
		return util.SharedRandom(tostring(id or "tfa_shared"), min, max, seed)
	end
end

if not wepMeta.SetComboCount then
	function wepMeta:SetComboCount(val)
		self.ComboCount = val or 0
	end
end

if not wepMeta.GetComboCount then
	function wepMeta:GetComboCount()
		return self.ComboCount or 0
	end
end

if not wepMeta.GetActivityEnabled then
	function wepMeta:GetActivityEnabled()
		return true
	end
end

if CLIENT then
	local pendingCreates = {}

	local function newProxy()
		local proxy = {
			__tfa_pending_fields = {},
			__tfa_pending_calls = {}
		}

		local meta = {}
		function meta:__index(k)
			if k == "__tfa_target" or k == "__tfa_pending_fields" or k == "__tfa_pending_calls" then
				return rawget(self, k)
			end

			local target = rawget(self, "__tfa_target")
			if target then
				return target[k]
			end

			return function(_, ...)
				local calls = rawget(self, "__tfa_pending_calls")
				calls[#calls + 1] = { k, { ... } }
				return nil
			end
		end

		function meta:__newindex(k, v)
			if k == "__tfa_target" or k == "__tfa_pending_fields" or k == "__tfa_pending_calls" then
				rawset(self, k, v)
				return
			end

			local target = rawget(self, "__tfa_target")
			if target then
				target[k] = v
				return
			end

			local fields = rawget(self, "__tfa_pending_fields")
			fields[k] = v
		end

		setmetatable(proxy, meta)
		return proxy
	end

	local function flushProxy(proxy, ent)
		if not proxy or not ent then return end
		proxy.__tfa_target = ent
		for k, v in pairs(proxy.__tfa_pending_fields) do
			ent[k] = v
		end

		for _, call in ipairs(proxy.__tfa_pending_calls) do
			local fn = ent[call[1]]
			if isfunction(fn) then
				pcall(fn, ent, unpack(call[2]))
			end
		end

		proxy.__tfa_pending_fields = {}
		proxy.__tfa_pending_calls = {}
	end

	local function createSafe(oldFunc, classname, args, hasIsRendering, key)
		local trackKey = key or classname
		local entry = pendingCreates[trackKey]

		if entry and entry.proxy and entry.ready then
			return entry.proxy
		end

		if hasIsRendering and render.IsRendering() then
			if not entry then
				local proxy = newProxy()
				entry = { proxy = proxy, ready = false }
				pendingCreates[trackKey] = entry

				timer.Simple(0, function()
					if hasIsRendering and render.IsRendering() then return end
					local ok, ent = pcall(oldFunc, classname, unpack(args))
					if ok and IsValid(ent) then
						entry.ready = true
						flushProxy(proxy, ent)
						pendingCreates[trackKey] = nil
					else
						pendingCreates[trackKey] = nil
					end
				end)
			end

			return entry.proxy or NULL
		end

		local ok, result = pcall(oldFunc, classname, unpack(args))
		if ok then
			return result
		end

		local err = tostring(result or "")
		if string.find(err, "while rendering", 1, true) then
			if not entry then
				local proxy = newProxy()
				entry = { proxy = proxy, ready = false }
				pendingCreates[trackKey] = entry

				timer.Simple(0, function()
					if hasIsRendering and render.IsRendering() then return end
					local ok2, ent = pcall(oldFunc, classname, unpack(args))
					if ok2 and IsValid(ent) then
						entry.ready = true
						flushProxy(proxy, ent)
						pendingCreates[trackKey] = nil
					else
						pendingCreates[trackKey] = nil
					end
				end)
			end

			return entry.proxy or NULL
		end

		return NULL
	end

	local oldCreateClientside = ents.CreateClientside
	if oldCreateClientside then
		local hasIsRendering = render and isfunction(render.IsRendering)
		function ents.CreateClientside(classname, ...)
			return createSafe(oldCreateClientside, classname, { ... }, hasIsRendering)
		end
	end

	local oldCreate = ents.Create
	if oldCreate then
		local hasIsRendering = render and isfunction(render.IsRendering)
		function ents.Create(classname, ...)
			return createSafe(oldCreate, classname, { ... }, hasIsRendering)
		end
	end
end

TFA = TFA or {}
TFA.FillMissingMetaValues = TFA.FillMissingMetaValues or function() end

TFA.Particles = TFA.Particles or {}

TFA.Particles.FollowMuzzle = TFA.Particles.FollowMuzzle or function() end

if not TFA.Particles.RegisterParticleThink then
	function TFA.Particles.RegisterParticleThink(particle, func)
		if not IsValid(particle) then return end
		if func then
			particle._TFA_FollowFunc = func
		end
	end
end
