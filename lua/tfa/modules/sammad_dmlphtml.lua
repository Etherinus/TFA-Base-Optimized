if SERVER then AddCSLuaFile() return end

local pairs = pairs
local isstring = isstring
local typeFn = type
local tostring = tostring

local table_insert = table.insert
local table_remove = table.remove
local table_concat = table.concat
local hook_Add = hook.Add

local gui_EnableScreenClicker = gui.EnableScreenClicker
local gui_InternalCursorMoved = gui.InternalCursorMoved
local gui_InternalMousePressed = gui.InternalMousePressed
local gui_InternalMouseReleased = gui.InternalMouseReleased

local RealTime = RealTime
local MsgC = MsgC
local ColorFn = Color
local input_GetCursorPos = input.GetCursorPos
local math_Round = math.Round
local vgui_GetWorldPanel = vgui.GetWorldPanel

local unpackFn = unpack or table.unpack
local surface_PlaySound = surface and surface.PlaySound

local JS_CallbackHack = [[(function(){
    var funcname = '%s';
    window[funcname] = function(){
        _gm[funcname].apply(_gm, arguments);
    }
})();]]

local FilterCVar = CreateClientConVar("js_console_filter", 0, true, false)
local FILTER_ALL = 0

local PANEL = {}
DEFINE_BASECLASS("Panel")

function PANEL:Init()
    self.JS = nil
    self.Callbacks = {}
    self.MouseActions = {}
    self.URL = "about:blank"
    self._loading = false
    self._nextUrlPoll = 0
    self._inThink = false

    local consoleFuncs = { "log", "error", "debug", "warn", "info" }
    for i = 1, #consoleFuncs do
        local func = consoleFuncs[i]
        self:AddFunction("console", func, function(param)
            self:ConsoleMessage(param, func)
        end)
    end

    self:AddFunction("gmod", "getUrl", function(url)
        self:SetURL(url)
    end)

    hook_Add("HUDPaint", self, function()
        self:HUDPaint()
    end)
end

function PANEL:Think()
    if self._inThink then return end
    self._inThink = true

    local isLoading = self:IsLoading()
    if isLoading then
        if not self._loading then
            self._loading = true
            self:FetchPageURL()
            self:OnStartLoading()
        end
    else
        if self._loading then
            self._loading = false
            self:FetchPageURL()

            local callbacksWindow = self.Callbacks.window
            if callbacksWindow then
                for funcname in pairs(callbacksWindow) do
                    self:RunJavascript(JS_CallbackHack:format(funcname))
                end
            end

            self:OnFinishLoading()
        end

        local jsQueue = self.JS
        if jsQueue then
            for i = 1, #jsQueue do
                self:RunJavascript(jsQueue[i])
                jsQueue[i] = nil
            end
            self.JS = nil
        end
    end

    local now = RealTime()
    if self._nextUrlPoll < now then
        self:FetchPageURL()
        self._nextUrlPoll = now + 1
    end

    self._inThink = false
end

function PANEL:FetchPageURL()
    self:RunJavascript("gmod.getUrl(window.location.href);")
end

function PANEL:GetURL()
    return self.URL
end

function PANEL:SetURL(url)
    if not url then url = "about:blank" end
    local current = self.URL
    if current ~= url then
        self:OnURLChanged(url, current)
    end
    self.URL = url
end

function PANEL:OnURLChanged(newUrl, oldUrl)
end

function PANEL:SetSize(w, h, fullscreen)
    local keyboardEnabled = self:IsKeyboardInputEnabled()
    local mouseEnabled = self:IsMouseInputEnabled()

    if fullscreen then
        local cw, ch = self:GetSize()
        self._OrigSize = { w = cw, h = ch }
        self:ParentToHUD()
    elseif self._OrigSize then
        w = self._OrigSize.w
        h = self._OrigSize.h
        self._OrigSize = nil
        self:SetParent(vgui_GetWorldPanel())
    else
        self._OrigSize = nil
    end

    self:SetKeyboardInputEnabled(keyboardEnabled)
    self:SetMouseInputEnabled(mouseEnabled)

    if w and h then
        BaseClass.SetSize(self, w, h)
    end
end

function PANEL:OpenURL(url)
    self:SetURL(url)
    BaseClass.OpenURL(self, url)
end

function PANEL:SetHTML(html)
    BaseClass.SetHTML(self, html)
end

function PANEL:OnStartLoading()
end

function PANEL:OnFinishLoading()
end

function PANEL:QueueJavascript(js)
    if not js or js == "" then return end

    if not (self.JS or self:IsLoading()) then
        self:RunJavascript(js)
        return
    end

    local q = self.JS
    if not q then
        q = {}
        self.JS = q
    end

    q[#q + 1] = js
    self:Think()
end

PANEL.QueueJavaScript = PANEL.QueueJavascript
PANEL.Call = PANEL.QueueJavascript

PANEL.ConsoleColors = {
    default = ColorFn(255, 160, 255),
    text = ColorFn(255, 255, 255),
    error = ColorFn(235, 57, 65),
    warn = ColorFn(227, 181, 23),
    info = ColorFn(100, 173, 229)
}

function PANEL:ConsoleMessage(...)
    local filterLevel = FilterCVar:GetInt()
    local args = { ... }
    local msg = args[1]

    if #args == 3 and filterLevel > FILTER_ALL then
        local script = args[2]
        local linenum = args[3]
        local out = { "[JavaScript]", msg, ",", script, ":", linenum, "\n" }
        MsgC(self.ConsoleColors.error, table_concat(out, " "))
        return
    end

    if not isstring(msg) then
        msg = "*js variable* (" .. typeFn(msg) .. ": " .. tostring(msg) .. ")"
    end

    if msg:StartWith("PLAY:") then
        if surface_PlaySound then
            local soundpath = msg:sub(7)
            if soundpath and soundpath ~= "" then
                surface_PlaySound(soundpath)
            end
        end
        return
    end

    if filterLevel == FILTER_ALL then
        return
    end

    local func = args[2]
    local prefixColor = self.ConsoleColors.default
    local prefix = "[HTML"

    if func and func:len() > 0 and func ~= "log" then
        local colorOverride = self.ConsoleColors[func]
        if colorOverride then
            prefixColor = colorOverride
        end
        prefix = prefix .. ":" .. func:upper()
    end

    prefix = prefix .. "] "

    MsgC(prefixColor, prefix)
    MsgC(self.ConsoleColors.text, msg, "\n")
end

local JSObjects = {
    window = "_gm",
    this = "_gm",
    _gm = "window"
}

function PANEL:OnCallback(obj, func, args)
    obj = JSObjects[obj] or obj

    local callbacks = self.Callbacks[obj]
    if not callbacks then return end

    local f = callbacks[func]
    if f then
        return f(unpackFn(args))
    end
end

function PANEL:AddFunction(obj, funcname, func)
    if obj == "this" then obj = "window" end

    local cb = self.Callbacks[obj]
    if not cb then
        self:NewObject(obj)
        cb = {}
        self.Callbacks[obj] = cb
    end

    self:NewObjectCallback(JSObjects[obj] or obj, funcname)
    cb[funcname] = func
end

local JS_RemoveScrollbars = "document.body.style.overflow = 'hidden';"

function PANEL:RemoveScrollbars()
    self:QueueJavascript(JS_RemoveScrollbars)
end

function PANEL:OpeningURL(url)
end

function PANEL:FinishedURL(url)
end

function PANEL:HUDPaint()
    self:HandleMouseActions()
end

function PANEL:InjectMouseClick(x, y)
    if self._handlingMouseAction then return end

    local w, h = self:GetSize()
    self.MouseActions[#self.MouseActions + 1] = {
        x = math_Round((x or 0) * w),
        y = math_Round((y or 0) * h),
        tick = 0
    }
end

function PANEL:HandleMouseActions()
    local actions = self.MouseActions
    if #actions == 0 then return end

    local action = actions[1]
    action.tick = action.tick + 1

    if action.tick == 1 then
        self._handlingMouseAction = true
        self:SetZPos(32767)
        self:MoveToCursor(action.x, action.y)
        self:MakePopup()
        gui_EnableScreenClicker(true)
        gui_InternalCursorMoved(0, 0)
        return
    end

    if action.tick == 2 then
        local cx, cy = input_GetCursorPos()
        gui_InternalCursorMoved(cx, cy)
        return
    end

    if action.tick == 3 then
        gui_InternalMousePressed(MOUSE_LEFT)
        gui_InternalMouseReleased(MOUSE_LEFT)
        return
    end

    gui_EnableScreenClicker(false)
    self:SetKeyboardInputEnabled(false)
    self:SetMouseInputEnabled(false)
    self:SetZPos(-32768)
    table_remove(actions, 1)
    self._handlingMouseAction = false
end

function PANEL:MoveToCursor(xoffset, yoffset)
    xoffset = xoffset or 0
    yoffset = yoffset or 0

    local cx, cy = input_GetCursorPos()
    self:SetPos(cx - xoffset, cy - yoffset)
end

derma.DefineControl("DMediaPlayerHTML", "", PANEL, "Awesomium")
