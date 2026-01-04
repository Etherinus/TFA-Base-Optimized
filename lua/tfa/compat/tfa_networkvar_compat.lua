if SERVER then AddCSLuaFile() end

local FindMetaTable = FindMetaTable
local IsValid = IsValid
local CurTime = CurTime
local tonumber = tonumber
local tostring = tostring
local pairs = pairs
local ipairs = ipairs
local pcall = pcall
local setmetatable = setmetatable
local rawget = rawget
local rawset = rawset
local unpack = unpack or table.unpack
local string_Explode = string.Explode
local string_find = string.find
local util_SharedRandom = util and util.SharedRandom

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

local function markExplicit(ent, name)
    local exp = ent.__tfa_nw_explicit
    if not exp then
        exp = {}
        ent.__tfa_nw_explicit = exp
    end
    exp[name] = true
end

local function ensureNW2(ent)
    if ent.__tfa_nw2_ensured then return end
    ent.__tfa_nw2_ensured = true

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

    local getterName = "Get" .. name
    local setterName = "Set" .. name

    if varType == "Bool" then
        if ent[setterName] == nil then
            ent[setterName] = function(self, val)
                ensureNW2(self)
                markExplicit(self, name)
                self:SetNW2Bool(name, val and true or false)
            end
        end
        if ent[getterName] == nil then
            ent[getterName] = function(self, fallback)
                ensureNW2(self)
                if fallback == nil then fallback = default end
                return self:GetNW2Bool(name, fallback or false)
            end
        end
        return
    end

    if varType == "Int" then
        if ent[setterName] == nil then
            ent[setterName] = function(self, val)
                ensureNW2(self)
                markExplicit(self, name)
                self:SetNW2Int(name, val or 0)
            end
        end
        if ent[getterName] == nil then
            ent[getterName] = function(self, fallback)
                ensureNW2(self)
                if fallback == nil then fallback = default end
                return self:GetNW2Int(name, fallback or 0)
            end
        end
        return
    end

    if varType == "Float" then
        if ent[setterName] == nil then
            ent[setterName] = function(self, val)
                ensureNW2(self)
                markExplicit(self, name)
                self:SetNW2Float(name, val or 0)
            end
        end
        if ent[getterName] == nil then
            ent[getterName] = function(self, fallback)
                ensureNW2(self)
                if fallback == nil then fallback = default end
                return self:GetNW2Float(name, fallback or 0)
            end
        end
        return
    end

    if varType == "Entity" then
        if ent[setterName] == nil then
            ent[setterName] = function(self, val)
                ensureNW2(self)
                markExplicit(self, name)
                self:SetNW2Entity(name, val)
            end
        end
        if ent[getterName] == nil then
            ent[getterName] = function(self, fallback)
                ensureNW2(self)
                if fallback == nil then fallback = default end
                return self:GetNW2Entity(name, fallback)
            end
        end
        return
    end

    if varType == "String" then
        if ent[setterName] == nil then
            ent[setterName] = function(self, val)
                ensureNW2(self)
                markExplicit(self, name)
                self:SetNW2String(name, val or "")
            end
        end
        if ent[getterName] == nil then
            ent[getterName] = function(self, fallback)
                ensureNW2(self)
                if fallback == nil then fallback = default end
                return self:GetNW2String(name, fallback or "")
            end
        end
        return
    end

    local fieldName = "__tfa_fallback_" .. name

    if ent[setterName] == nil then
        ent[setterName] = function(self, val)
            markExplicit(self, name)
            self[fieldName] = val
        end
    end

    if ent[getterName] == nil then
        ent[getterName] = function(self, fallback)
            local val = self[fieldName]
            if val == nil then val = default end
            if val == nil then val = fallback end
            return val
        end
    end
end

local function wrapSetter(ent, name)
    local wrapMap = ent.__tfa_nw_wrapped_setters
    if not wrapMap then
        wrapMap = {}
        ent.__tfa_nw_wrapped_setters = wrapMap
    end

    if wrapMap[name] then return end

    local setterName = "Set" .. name
    local orig = ent[setterName]
    if not orig then return end

    wrapMap[name] = orig

    ent[setterName] = function(self, val)
        markExplicit(self, name)
        return orig(self, val)
    end
end

if not wepMeta.NetworkVarTFA then
    function wepMeta:NetworkVarTFA(varType, name, default)
        local counts = self.__TFA_NWVarCounts
        if not counts then
            counts = {}
            self.__TFA_NWVarCounts = counts
        end

        local start = defaultStarts[varType] or 0
        local index = counts[varType]
        if index == nil then index = start end
        counts[varType] = index + 1

        local ok = pcall(self.NetworkVar, self, varType, index, name)
        if not ok then
            defineFallback(self, varType, name, default)
        end

        wrapSetter(self, name)

        if default ~= nil and SERVER then
            local exp = self.__tfa_nw_explicit
            if not exp or exp[name] ~= true then
                local setter = self["Set" .. name]
                if setter then
                    pcall(setter, self, default)
                end
            end
        end

        return index
    end
end

if not wepMeta.GetStatL then
    function wepMeta:GetStatL(stat)
        local getStat = self.GetStat
        if getStat then
            return getStat(self, stat)
        end

        local tbl = self
        if not stat or stat == "" then return tbl end

        local parts = string_Explode(".", stat, false)
        for i = 1, #parts do
            local key = parts[i]
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
            local getIS = self.GetIronSights
            local is = getIS and getIS(self)
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
        if util_SharedRandom then
            return util_SharedRandom(tostring(id or "tfa_shared"), min, max, seed)
        end
        return min
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

local dbg = debug
local reg = dbg and dbg.getregistry and dbg.getregistry()
local dmgMeta = (reg and reg.CTakeDamageInfo) or FindMetaTable("CTakeDamageInfo")

if dmgMeta then
    if not dmgMeta.SetBaseDamage and dmgMeta.SetDamage then
        function dmgMeta:SetBaseDamage(val)
            return self:SetDamage(val)
        end
    end

    if not dmgMeta.GetBaseDamage and dmgMeta.GetDamage then
        function dmgMeta:GetBaseDamage()
            return self:GetDamage()
        end
    end
end

if CLIENT then
    local pendingCreates = {}
    local NULL = NULL
    local timer_Simple = timer and timer.Simple
    local render_IsRendering = render and render.IsRendering
    local isfunction = isfunction

    local function newProxy()
        local proxy = {
            __tfa_pending_fields = {},
            __tfa_pending_calls = {},
            __tfa_target = nil
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

        local fields = proxy.__tfa_pending_fields
        for k, v in pairs(fields) do
            ent[k] = v
        end

        local calls = proxy.__tfa_pending_calls
        for i = 1, #calls do
            local call = calls[i]
            local fn = ent[call[1]]
            if isfunction(fn) then
                pcall(fn, ent, unpack(call[2]))
            end
        end

        proxy.__tfa_pending_fields = {}
        proxy.__tfa_pending_calls = {}
    end

    local function scheduleCreate(entry, oldFunc, classname, args, hasIsRendering)
        if not timer_Simple then
            pendingCreates[entry.key] = nil
            return
        end

        entry.tries = (entry.tries or 0) + 1
        if entry.tries > 32 then
            pendingCreates[entry.key] = nil
            return
        end

        timer_Simple(0, function()
            if hasIsRendering and render_IsRendering and render_IsRendering() then
                scheduleCreate(entry, oldFunc, classname, args, hasIsRendering)
                return
            end

            local ok, ent = pcall(oldFunc, classname, unpack(args))
            if ok and IsValid(ent) then
                flushProxy(entry.proxy, ent)
            end

            pendingCreates[entry.key] = nil
        end)
    end

    local function createSafe(oldFunc, classname, args, hasIsRendering, key)
        if not oldFunc then return NULL end

        local trackKey = key or classname
        local entry = pendingCreates[trackKey]
        if entry then
            return entry.proxy or NULL
        end

        if hasIsRendering and render_IsRendering and render_IsRendering() then
            local proxy = newProxy()
            entry = { key = trackKey, proxy = proxy, tries = 0 }
            pendingCreates[trackKey] = entry
            scheduleCreate(entry, oldFunc, classname, args, hasIsRendering)
            return proxy
        end

        local ok, result = pcall(oldFunc, classname, unpack(args))
        if ok then
            return result
        end

        local err = tostring(result or "")
        if string_find(err, "while rendering", 1, true) then
            local proxy = newProxy()
            entry = { key = trackKey, proxy = proxy, tries = 0 }
            pendingCreates[trackKey] = entry
            scheduleCreate(entry, oldFunc, classname, args, hasIsRendering)
            return proxy
        end

        return NULL
    end

    local oldCreateClientside = ents and ents.CreateClientside
    if oldCreateClientside then
        local hasIsRendering = render_IsRendering and true or false
        function ents.CreateClientside(classname, ...)
            return createSafe(oldCreateClientside, classname, { ... }, hasIsRendering)
        end
    end

    local oldCreate = ents and ents.Create
    if oldCreate then
        local hasIsRendering = render_IsRendering and true or false
        function ents.Create(classname, ...)
            return createSafe(oldCreate, classname, { ... }, hasIsRendering)
        end
    end
end
