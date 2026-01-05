if SERVER then AddCSLuaFile() return end
if browserpool then return end

local table_insert = table.insert
local table_remove = table.remove
local table_KeyFromValue = table.KeyFromValue
local vgui_Create = vgui.Create
local pairs = pairs
local IsValid = IsValid
local ErrorNoHalt = ErrorNoHalt
local debug_Trace = debug.Trace
local next = next

browserpool = browserpool or {}

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
        panel = vgui_Create("DMediaPlayerHTML")
    end

    panel:Stop()
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

local function removePromise(promise)
    local id = promise:GetId()
    if not pending[id] then
        ErrorNoHalt("browserpool: Failed to remove promise.\n")
        debug_Trace()
        return false
    end

    pending[id] = nil
    numPending = numPending - 1

    return true
end

local BrowserPromise = {}
BrowserPromise.__index = BrowserPromise

local function newPromise(callback, id)
    return setmetatable(
        {
            cb = callback,
            id = id
        },
        BrowserPromise
    )
end

function BrowserPromise:GetId()
    return self.id
end

function BrowserPromise:Resolve(value)
    self.cb(value)
end

function BrowserPromise:Cancel(reason)
    self.cb(false, reason)
    removePromise(self)
end

function browserpool.get(callback)
    numRequests = numRequests + 1

    if #available > 0 then
        local panel = table_remove(available)
        table_insert(active, panel)
        callback(panel)
        return
    end

    if numActive < numMax then
        local panel = setupPanel()
        numActive = numActive + 1
        table_insert(active, panel)
        callback(panel)
        return
    end

    local promise = newPromise(callback, numRequests)
    pending[numRequests] = promise
    numPending = numPending + 1

    return promise
end

function browserpool.release(panel, destroy)
    if not IsValid(panel) then
        return false
    end

    local key = table_KeyFromValue(active, panel)
    if not key then
        ErrorNoHalt("browserpool: Attempted to release unactive browser.\n")
        debug_Trace()

        if IsValid(panel) then
            panel:Remove()
        end

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
        if not table_remove(active, key) then
            ErrorNoHalt("browserpool: Failed to remove panel from active browsers.\n")
            debug_Trace()

            if IsValid(panel) then
                panel:Remove()
            end

            return false
        end

        if numActive > numMin then
            panel:Remove()
            numActive = numActive - 1
        elseif not destroy then
            setupPanel(panel)
            table_insert(available, panel)
        end
    end

    return true
end
