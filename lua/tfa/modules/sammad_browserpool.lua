if SERVER then AddCSLuaFile() return end
if browserpool then return end

local table_insert = table.insert
local table_remove = table.remove
local IsValid = IsValid
local ErrorNoHalt = ErrorNoHalt
local debug_Trace = debug.Trace
local pairs = pairs
local next = next
local tostring = tostring

local vgui_Create = vgui and vgui.Create
local NULL = NULL

browserpool = browserpool or {}

local available = {}
local active = {}
local activeIndex = {}
local pending = {}
local pendingQueue = {}
local pendingHead = 1

local numMin = 2
local numMax = 4
local numActive = 0

local defaultUrl = "about:blank"
local JS_RemoveProp = "delete %s.%s;"

local function setupPanel(panel)
    if not panel then
        if not vgui_Create then return nil end
        panel = vgui_Create("DMediaPlayerHTML") or vgui_Create("Awesomium") or vgui_Create("DHTML")
        if not panel then return nil end
        panel:SetVisible(false)
    end

    if panel.Stop then panel:Stop() end
    panel:SetPos(0, 0)
    panel:SetKeyboardInputEnabled(false)
    panel:SetMouseInputEnabled(false)
    panel:SetPaintedManually(true)
    panel:OpenURL(defaultUrl)

    local callbacks = panel.Callbacks
    if callbacks then
        for obj, tbl in pairs(callbacks) do
            if obj ~= "console" and tbl then
                for funcname in pairs(tbl) do
                    panel:QueueJavascript(JS_RemoveProp:format(obj, funcname))
                end
            end
        end
    end

    return panel
end

local function activeAdd(panel)
    local idx = #active + 1
    active[idx] = panel
    activeIndex[panel] = idx
end

local function activeRemove(panel)
    local idx = activeIndex[panel]
    if not idx then return false end

    local last = #active
    local lastPanel = active[last]

    active[idx] = lastPanel
    active[last] = nil

    activeIndex[panel] = nil
    if lastPanel then
        activeIndex[lastPanel] = idx
    end

    return true
end

local function pendingEnqueue(promise)
    local id = promise.id
    pending[id] = promise
    pendingQueue[#pendingQueue + 1] = id
end

local function pendingDequeue()
    for i = pendingHead, #pendingQueue do
        local id = pendingQueue[i]
        pendingQueue[i] = nil
        pendingHead = i + 1
        if id ~= nil then
            local p = pending[id]
            if p then
                pending[id] = nil
                return p
            end
        end
    end

    pendingQueue = {}
    pendingHead = 1
    return nil
end

local BrowserPromise = {}
BrowserPromise.__index = BrowserPromise

local function newPromise(callback, id)
    return setmetatable({ cb = callback, id = id }, BrowserPromise)
end

function BrowserPromise:GetId()
    return self.id
end

function BrowserPromise:Resolve(value)
    local cb = self.cb
    if cb then
        self.cb = nil
        cb(value)
    end
end

function BrowserPromise:Cancel(reason)
    local cb = self.cb
    if cb then
        self.cb = nil
        cb(false, reason)
    end
    pending[self.id] = nil
end

local numRequests = 0

function browserpool.get(callback)
    if type(callback) ~= "function" then return nil end

    numRequests = numRequests + 1

    local panel = available[#available]
    if panel then
        available[#available] = nil
        activeAdd(panel)
        callback(panel)
        return
    end

    if numActive < numMax then
        panel = setupPanel(nil)
        if not panel then
            callback(NULL)
            return NULL
        end

        numActive = numActive + 1
        activeAdd(panel)
        callback(panel)
        return
    end

    local promise = newPromise(callback, numRequests)
    pendingEnqueue(promise)
    return promise
end

function browserpool.release(panel, destroy)
    if not IsValid(panel) then
        return false
    end

    if not activeIndex[panel] then
        ErrorNoHalt("browserpool: Attempted to release unactive browser.\n")
        debug_Trace()
        if IsValid(panel) then
            panel:Remove()
        end
        return false
    end

    if destroy then
        activeRemove(panel)
        if IsValid(panel) then
            panel:Remove()
        end
        numActive = numActive - 1
        if numActive < 0 then numActive = 0 end
        return true
    end

    local promise = pendingDequeue()
    if promise then
        setupPanel(panel)
        promise:Resolve(panel)
        return true
    end

    activeRemove(panel)

    if numActive > numMin then
        if IsValid(panel) then
            panel:Remove()
        end
        numActive = numActive - 1
        if numActive < 0 then numActive = 0 end
        return true
    end

    setupPanel(panel)
    available[#available + 1] = panel
    return true
end

function browserpool.stats()
    local a = #available
    local b = #active
    local p = 0
    for _ in pairs(pending) do p = p + 1 end
    return {
        available = a,
        active = b,
        allocated = numActive,
        pending = p,
        requests = numRequests
    }
end
