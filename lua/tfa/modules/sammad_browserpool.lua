if browserpool then return end

if SERVER then
	AddCSLuaFile()
	return
end

local table = table
local vgui = vgui
local pairs = pairs
local IsValid = IsValid

browserpool = {}
local available = {}
local active = {}
local pending = {}

local numMin = 2
local numMax = 4
local numActive = 0
local numPending = 0
local numRequests = 0
local defaultUrl = "about:blank"
local JS_RemoveProp = "delete %s.%s;"

local function setupPanel(panel)
	if not panel then
		panel = vgui.Create("DMediaPlayerHTML")
	end

	panel:Stop()
	panel:SetPos(0, 0)
	panel:SetKeyboardInputEnabled(false)
	panel:SetMouseInputEnabled(false)
	panel:SetPaintedManually(true)
	panel:OpenURL(defaultUrl)

	for obj, tbl in pairs(panel.Callbacks) do
		if obj ~= "console" then
			for funcname, _ in pairs(tbl) do
				panel:QueueJavascript(JS_RemoveProp:format(obj, funcname))
			end
		end
	end

	return panel
end

local function removePromise(promise)
	local id = promise:GetId()
	if not pending[id] then
		ErrorNoHalt("browserpool: Failed to remove promise.\n")
		debug.Trace()
		return false
	end

	pending[id] = nil
	numPending = numPending - 1
	return true
end

local BrowserPromise = {}
local BrowserPromiseMeta = { __index = BrowserPromise }

function BrowserPromise:New(callback, id)
	return setmetatable({ __cb = callback, __id = id }, BrowserPromiseMeta)
end

function BrowserPromise:GetId()
	return self.__id
end

function BrowserPromise:Resolve(value)
	self.__cb(value)
end

function BrowserPromise:Cancel(reason)
	self.__cb(false, reason)
	removePromise(self)
end

function browserpool.get(callback)
	numRequests = numRequests + 1
	local panel

	if #available > 0 then
		panel = table.remove(available)
		table.insert(active, panel)
		callback(panel)
	elseif numActive < numMax then
		panel = setupPanel()
		numActive = numActive + 1
		table.insert(active, panel)
		callback(panel)
	else
		local promise = BrowserPromise:New(callback, numRequests)
		pending[numRequests] = promise
		numPending = numPending + 1
		return promise
	end
end

function browserpool.release(panel, destroy)
	if not IsValid(panel) then return false end

	local key = table.KeyFromValue(active, panel)
	if not key then
		ErrorNoHalt("browserpool: Attempted to release unactive browser.\n")
		debug.Trace()
		if IsValid(panel) then panel:Remove() end
		return false
	end

	if numPending > 0 and not destroy then
		setupPanel(panel)
		local id = next(pending)
		if id then
			local promise = pending[id]
			promise:Resolve(panel)
			removePromise(promise)
		end
	else
		if not table.remove(active, key) then
			ErrorNoHalt("browserpool: Failed to remove panel from active browsers.\n")
			debug.Trace()
			if IsValid(panel) then panel:Remove() end
			return false
		end

		if numActive > numMin then
			panel:Remove()
			numActive = numActive - 1
		elseif not destroy then
			setupPanel(panel)
			table.insert(available, panel)
		end
	end

	return true
end
