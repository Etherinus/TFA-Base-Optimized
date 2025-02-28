if SERVER then AddCSLuaFile() return end

local PANEL = {}
DEFINE_BASECLASS("Panel")

local pairs = pairs
local isstring = isstring
local table = table
local hook = hook
local gui = gui
local RealTime = RealTime
local MsgC = MsgC
local Color = Color
local input = input
local math = math
local vgui = vgui

local JS_CallbackHack = [[(function(){
    var funcname = '%s';
    window[funcname] = function(){
        _gm[funcname].apply(_gm, arguments);
    }
})();]]

local FilterCVar = CreateClientConVar("js_console_filter", 0, true, false)
local FILTER_ALL = 0

function PANEL:Init()
    self.JS = {}
    self.Callbacks = {}
    self.MouseActions = {}
    self.URL = "about:blank"

    local console_funcs = {"log", "error", "debug", "warn", "info"}

    for _, func in pairs(console_funcs) do
        self:AddFunction("console", func, function(param)
            self:ConsoleMessage(param, func)
        end)
    end

    self:AddFunction("gmod", "getUrl", function(url)
        self:SetURL(url)
    end)

    hook.Add("HUDPaint", self, function()
        self:HUDPaint()
    end)
end

function PANEL:Think()
    if self:IsLoading() then
        if not self._loading then
            self:FetchPageURL()
            self._loading = true
            self:OnStartLoading()
        end
    else
        if self._loading then
            self:FetchPageURL()

            if self.Callbacks.window then
                for funcname in pairs(self.Callbacks.window) do
                    self:RunJavascript(JS_CallbackHack:format(funcname))
                end
            end

            self._loading = nil
            self:OnFinishLoading()
        end

        if self.JS then
            for _, v in pairs(self.JS) do
                self:RunJavascript(v)
            end
            self.JS = nil
        end
    end

    if not self._nextUrlPoll or self._nextUrlPoll < RealTime() then
        self:FetchPageURL()
        self._nextUrlPoll = RealTime() + 1
    end
end

function PANEL:FetchPageURL()
    local js = "gmod.getUrl(window.location.href);"
    self:RunJavascript(js)
end

function PANEL:GetURL()
    return self.URL
end

function PANEL:SetURL(url)
    local current = self.URL
    if current ~= url then
        self:OnURLChanged(url, current)
    end
    self.URL = url
end

function PANEL:OnURLChanged(new, old)

end

function PANEL:SetSize(w, h, fullscreen)
    local keyboardEnabled = self:IsKeyboardInputEnabled()
    local mouseEnabled = self:IsMouseInputEnabled()

    if fullscreen then
        local cw, ch = self:GetSize()
        self._OrigSize = {w = cw, h = ch}
        self:ParentToHUD()
    elseif self._OrigSize then
        w, h = self._OrigSize.w, self._OrigSize.h
        self._OrigSize = nil
        self:SetParent(vgui.GetWorldPanel())
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
    if not (self.JS or self:IsLoading()) then
        return self:RunJavascript(js)
    end
    self.JS = self.JS or {}
    table.insert(self.JS, js)
    self:Think()
end

PANEL.QueueJavaScript = PANEL.QueueJavascript
PANEL.Call = PANEL.QueueJavascript

PANEL.ConsoleColors = {
    ["default"] = Color(255, 160, 255),
    ["text"]    = Color(255, 255, 255),
    ["error"]   = Color(235, 57, 65),
    ["warn"]    = Color(227, 181, 23),
    ["info"]    = Color(100, 173, 229)
}

function PANEL:ConsoleMessage(...)
    local filterLevel = FilterCVar:GetInt()
    local args = {...}
    local msg = args[1]

    if #args == 3 and filterLevel > FILTER_ALL then
        local script = args[2]
        local linenum = args[3]
        local col = self.ConsoleColors.error
        local out = {"[JavaScript]", msg, ",", script, ":", linenum, "\n"}
        MsgC(col, table.concat(out, " "))
        return
    end

    if not isstring(msg) then
        msg = "*js variable* (" .. type(msg) .. ": " .. tostring(msg) .. ")"
    end

    if msg:StartWith("PLAY:") then
        local soundpath = msg:sub(7)
        surface.PlaySound(soundpath)
        return
    end

    if filterLevel == FILTER_ALL then return end

    local func = args[2]
    local prefixColor = self.ConsoleColors.default
    local prefix = "[HTML"

    if func and func:len() > 0 and func ~= "log" then
        if self.ConsoleColors[func] then
            prefixColor = self.ConsoleColors[func]
        end
        prefix = prefix .. ":" .. func:upper()
    end
    prefix = prefix .. "] "

    MsgC(prefixColor, prefix)
    MsgC(self.ConsoleColors.text, msg, "\n")
end

local JSObjects = {
    window = "_gm",
    this   = "_gm",
    _gm    = "window"
}

function PANEL:OnCallback(obj, func, args)
    obj = JSObjects[obj] or obj
    if not self.Callbacks[obj] then return end

    local f = self.Callbacks[obj][func]
    if f then
        return f(unpack(args))
    end
end

function PANEL:AddFunction(obj, funcname, func)
    if obj == "this" then
        obj = "window"
    end

    if not self.Callbacks[obj] then
        self:NewObject(obj)
        self.Callbacks[obj] = {}
    end

    self:NewObjectCallback(JSObjects[obj] or obj, funcname)
    self.Callbacks[obj][funcname] = func
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
    table.insert(self.MouseActions, {
        x = math.Round(x * w),
        y = math.Round(y * h),
        tick = 0
    })
end

function PANEL:HandleMouseActions()
    if #self.MouseActions == 0 then return end
    local action = self.MouseActions[1]
    action.tick = action.tick + 1

    if action.tick == 1 then
        self._handlingMouseAction = true
        self:SetZPos(32767)
        self:MoveToCursor(action.x, action.y)
        self:MakePopup()
        gui.EnableScreenClicker(true)
        gui.InternalCursorMoved(0, 0)
    elseif action.tick == 2 then
        local cx, cy = input.GetCursorPos()
        gui.InternalCursorMoved(cx, cy)
    elseif action.tick == 3 then
        gui.InternalMousePressed(MOUSE_LEFT)
        gui.InternalMouseReleased(MOUSE_LEFT)
    elseif action.tick > 3 then
        gui.EnableScreenClicker(false)
        self:SetKeyboardInputEnabled(false)
        self:SetMouseInputEnabled(false)
        self:SetZPos(-32768)
        table.remove(self.MouseActions, 1)
        self._handlingMouseAction = nil
    end
end

function PANEL:MoveToCursor(xoffset, yoffset)
    xoffset = xoffset or 0
    yoffset = yoffset or 0
    local cx, cy = input.GetCursorPos()
    self:SetPos(cx - xoffset, cy - yoffset)
end

derma.DefineControl("DMediaPlayerHTML", "", PANEL, "Awesomium")
