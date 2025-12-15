TFA = TFA or {}
TFA.Attachments = TFA.Attachments or {}
TFA.Attachments.Atts = TFA.Attachments.Atts or {}

TFA.Attachments.Colors = TFA.Attachments.Colors or {
    active = Color(252, 151, 50, 255),
    error = Color(225, 0, 0, 255),
    background = Color(15, 15, 15, 64),
    primary = Color(245, 245, 245, 255),
    secondary = Color(153, 253, 220, 255),
    ["+"] = Color(128, 255, 128, 255),
    ["-"] = Color(255, 128, 128, 255),
    ["="] = Color(192, 192, 192, 255)
}

TFA.Attachments.UIPadding = TFA.Attachments.UIPadding or 2
TFA.Attachments.Path = TFA.Attachments.Path or "tfa/att/"
TFA_ATTACHMENT_ISUPDATING = TFA_ATTACHMENT_ISUPDATING or false
TFA.AttachmentColors = TFA.AttachmentColors or TFA.Attachments.Colors

if not TFA.AddSound then
    function TFA.AddSound(id, channel, volume, level, pitch, path)
        if not id then return end

        local snd = path or pitch
        if not snd then return end

        sound.Add({
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
        local h = ScrH()
        if h <= 0 then return val end
        return val * (h / 1080)
    end
end

if not ScaleW then
    function ScaleW(val)
        local w = ScrW()
        if w <= 0 then return val end
        return val * (w / 1920)
    end
end


if CLIENT then
    if not ConVarExists("cl_tfa_changelog") then
        CreateClientConVar("cl_tfa_changelog", "0", true, false)
    end
end

TFA.Effects = TFA.Effects or {}
function TFA.Effects.Create(name, data)
    util.Effect(name, data)
end
