TFA = TFA or {}
TFA.Attachments = TFA.Attachments or {}
TFA.Attachments.Atts = TFA.Attachments.Atts or {}

local ColorFn = Color
local ScrWFn = ScrW
local ScrHFn = ScrH

local attachments = TFA.Attachments

if not attachments.Colors then
    attachments.Colors = {
        active = ColorFn(252, 151, 50, 255),
        error = ColorFn(225, 0, 0, 255),
        background = ColorFn(15, 15, 15, 64),
        primary = ColorFn(245, 245, 245, 255),
        secondary = ColorFn(153, 253, 220, 255),
        ["+"] = ColorFn(128, 255, 128, 255),
        ["-"] = ColorFn(255, 128, 128, 255),
        ["="] = ColorFn(192, 192, 192, 255)
    }
end

attachments.UIPadding = attachments.UIPadding or 2
attachments.Path = attachments.Path or "tfa/att/"

TFA_ATTACHMENT_ISUPDATING = TFA_ATTACHMENT_ISUPDATING or false
TFA.AttachmentColors = TFA.AttachmentColors or attachments.Colors

local soundAdd = sound and sound.Add
local typeFn = type

if not TFA.AddSound then
    function TFA.AddSound(id, channel, volume, level, pitch, path)
        if not id or not soundAdd then return end

        local snd = path
        if snd == nil then
            local tp = typeFn(pitch)
            if tp == "string" or tp == "table" then
                snd = pitch
            end
        end

        if snd == nil then return end

        soundAdd({
            name = id,
            channel = channel or CHAN_AUTO,
            volume = volume or 1,
            level = level or 75,
            pitch = pitch or { 100, 100 },
            sound = snd
        })
    end
end

if not ScaleH then
    function ScaleH(val)
        local h = ScrHFn()
        if h <= 0 then return val end
        return val * (h / 1080)
    end
end

if not ScaleW then
    function ScaleW(val)
        local w = ScrWFn()
        if w <= 0 then return val end
        return val * (w / 1920)
    end
end

if CLIENT then
    local ConVarExistsFn = ConVarExists
    local CreateClientConVarFn = CreateClientConVar

    if ConVarExistsFn and CreateClientConVarFn and not ConVarExistsFn("cl_tfa_changelog") then
        CreateClientConVarFn("cl_tfa_changelog", "0", true, false)
    end
end

TFA.Effects = TFA.Effects or {}

do
    local utilEffect = util and util.Effect
    function TFA.Effects.Create(name, data)
        if not utilEffect or not name or name == "" then return end
        utilEffect(name, data)
    end
end
