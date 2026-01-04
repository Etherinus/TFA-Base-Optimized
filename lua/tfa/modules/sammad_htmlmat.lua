if SERVER then AddCSLuaFile() end

local CLIENT = CLIENT

local ipairs = ipairs
local pairs = pairs
local tostring = tostring
local typeFn = type

local table_insert = table.insert
local table_remove = table.remove
local table_concat = table.concat

local timer_Create = timer.Create
local timer_Remove = timer.Remove

local string_Replace = string.Replace

local MaterialFn = Material
local CreateMaterialFn = CreateMaterial
local IsValid = IsValid

local table_Merge = table.Merge
local table_Copy = table.Copy

local HTML_MATERIALS_ENABLED = false

local DefaultMat = MaterialFn("vgui/white")
local fallbackMatToken = "!" .. DefaultMat:GetName()

local cache = {}
local downloads = {}
local downloadsByKey = {}
local styles = {}

local UpdateTimerName = "HtmlMatUpdate"
local TimerRunning = false

local DefaultWidth = 2048
local DefaultStyle = {}

local embedHtml = [[
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
</head>
<body>
<script>
    var src = '%s';
</script>
<img id="mat">
<style>
    html, body {
        width: 100%%;
        height: 100%%;
        margin: 0;
        padding: 0;
        overflow: hidden;
    }
    %s
</style>
<script>
    var mat = document.getElementById('mat');
    mat.onload = function() {
        setTimeout(function() {
            gmod.imageLoaded();
        }, 100);
    };
    mat.onerror = function() {
        gmod.imageLoaded();
    };
    mat.src = src;
</script>
</body>
</html>
]]

local function nextPow2(n)
    n = tonumber(n) or 0
    if n <= 0 then return 1 end
    local p = 1
    while p < n do
        p = p * 2
    end
    return p
end

function GetHTMLMaterialVL(url, callbackfunc)
    if not CLIENT then return end

    if not HTML_MATERIALS_ENABLED then
        if callbackfunc then
            callbackfunc(fallbackMatToken)
        end
        return
    end

    HTMLMaterial(url, HTMLMAT_STYLE_COVER_IMG, function(mat)
        if not mat then
            if callbackfunc then callbackfunc(fallbackMatToken) end
            return
        end

        local matName = mat.GetName and mat:GetName()
        if not matName or matName == "" then
            if callbackfunc then callbackfunc(fallbackMatToken) end
            return
        end

        local matdata = {
            ["$basetexture"] = matName,
            ["$bumpmap"] = "null-bumpmap",
            ["$phongexponenttexture"] = "models/exp_gun",
            ["$model"] = 1,
            ["$phong"] = 1,
            ["$phongboost"] = 1,
            ["$phongalbedoboost"] = 35,
            ["$phongfresnelranges"] = "[.83 .83 1]",
            ["$phongalbedotint"] = 1,
            ["$envmap"] = "env_cubemap",
            ["$envmaptint"] = "[0.05 0.05 0.05]",
            ["$envmapfresnel"] = 1
        }

        local uid = string_Replace(matName, "__vgui_texture_", "")
        local outName = "WebMaterial_" .. uid
        CreateMaterialFn(outName, "VertexLitGeneric", matdata)

        if callbackfunc then
            callbackfunc("!" .. outName)
        end
    end)
end

local function updateCache(download)
    local browser = download.browser
    if not IsValid(browser) then return false end
    if browser.UpdateHTMLTexture then browser:UpdateHTMLTexture() end
    if browser.GetHTMLMaterial then
        cache[download.key] = browser:GetHTMLMaterial()
        return true
    end
    return false
end

local function cleanupDownloadByIndex(idx)
    local download = downloads[idx]
    if not download then return end

    downloadsByKey[download.key] = nil
    table_remove(downloads, idx)

    if #downloads == 0 and TimerRunning then
        timer_Remove(UpdateTimerName)
        TimerRunning = false
    end
end

local function updateMaterials()
    for i = #downloads, 1, -1 do
        local d = downloads[i]
        if not d or not IsValid(d.browser) then
            cleanupDownloadByIndex(i)
        else
            updateCache(d)
        end
    end
end

local function onImageLoaded(key, browser)
    local idx = downloadsByKey[key]
    if idx then
        downloadsByKey[key] = nil
        if browserpool and browserpool.release then
            browserpool.release(browser, true)
        else
            if IsValid(browser) then browser:Remove() end
        end
        table_remove(downloads, idx)

        for i = idx, #downloads do
            local d = downloads[i]
            if d then
                downloadsByKey[d.key] = i
            end
        end
    end

    if #downloads == 0 and TimerRunning then
        timer_Remove(UpdateTimerName)
        TimerRunning = false
    end
end

local MAT_STR_TABLE = { "", "@", "" }

local function enqueueUrl(url, styleName, key, callback)
    cache[key] = DefaultMat

    if not HTML_MATERIALS_ENABLED then
        if typeFn(callback) == "function" then
            callback(DefaultMat)
        end
        return
    end

    if not browserpool or not browserpool.get then
        if typeFn(callback) == "function" then
            callback(DefaultMat)
        end
        return
    end

    browserpool.get(function(browser)
        if not IsValid(browser) then
            if typeFn(callback) == "function" then
                callback(DefaultMat)
            end
            return
        end

        local style = styles[styleName] or DefaultStyle
        local w = style.width or DefaultWidth
        local h = style.height or w

        if browser.SetSize then
            browser:SetSize(w, h)
        end

        local download = {
            url = url,
            key = key,
            browser = browser
        }

        downloads[#downloads + 1] = download
        downloadsByKey[key] = #downloads

        if browser.AddFunction then
            browser:AddFunction("gmod", "imageLoaded", function()
                updateCache(download)
                onImageLoaded(key, browser)

                if typeFn(callback) == "function" then
                    callback(cache[key] or DefaultMat)
                end
            end)
        end

        if not TimerRunning then
            timer_Create(UpdateTimerName, 0.05, 0, updateMaterials)
            TimerRunning = true
        end

        local html = (style.html or embedHtml):format(url, style.css or "")
        if browser.SetHTML then
            browser:SetHTML(html)
        end
    end)
end

function HTMLMaterial(url, style, callback)
    if not url or url == "" then
        if typeFn(callback) == "function" then
            callback(DefaultMat)
        end
        return DefaultMat
    end

    if not HTML_MATERIALS_ENABLED then
        if typeFn(callback) == "function" then
            callback(DefaultMat)
        end
        return DefaultMat
    end

    local key
    if style then
        MAT_STR_TABLE[1] = url
        MAT_STR_TABLE[3] = style
        key = table_concat(MAT_STR_TABLE)
    else
        key = url
    end

    local cached = cache[key]
    if cached == nil then
        enqueueUrl(url, style, key, callback)
        return cache[key] or DefaultMat
    end

    if typeFn(callback) == "function" then
        callback(cached)
    end

    return cached
end

if CLIENT then
    local surfaceSetDrawColor = surface.SetDrawColor
    local surfaceSetMaterial = surface.SetMaterial
    local surfaceDrawTexturedRect = surface.DrawTexturedRect
    local color_white = color_white

    function DrawHTMLMaterial(url, styleName, w, h)
        w = tonumber(w) or 0
        h = tonumber(h) or 0

        local mat = HTMLMaterial(url, styleName)
        local style = styles[styleName] or DefaultStyle

        local width = style.width or DefaultWidth
        local height = style.height or width

        local scaleX = width > 0 and (w / width) or 1
        local scaleY = height > 0 and (h / height) or 1

        local pw = nextPow2(width)
        local ph = nextPow2(height)

        surfaceSetDrawColor(color_white)
        surfaceSetMaterial(mat)
        surfaceDrawTexturedRect(0, 0, scaleX * pw, scaleY * ph)
    end
end

function AddHTMLMaterialStyle(name, params, base)
    if not name or name == "" then return end
    params = params or {}

    if base then
        local merged = table_Copy(styles[base] or {})
        table_Merge(merged, params)
        styles[name] = merged
        return
    end

    styles[name] = params
end

HTMLMAT_STYLE_BLUR = "htmlmat.style.blur"
HTMLMAT_STYLE_GRAYSCALE = "htmlmat.style.grayscale"
HTMLMAT_STYLE_SEPIA = "htmlmat.style.sepia"
HTMLMAT_STYLE_INVERT = "htmlmat.style.invert"
HTMLMAT_STYLE_CIRCLE = "htmlmat.style.circle"
HTMLMAT_STYLE_COVER = "htmlmat.style.cover"
HTMLMAT_STYLE_COVER_IMG = "htmlmat.style.coverimg"

AddHTMLMaterialStyle(HTMLMAT_STYLE_BLUR, {
    css = [[
        img {
            -webkit-filter: blur(8px);
            -webkit-transform: scale(1.1, 1.1);
        }
    ]]
})

AddHTMLMaterialStyle(HTMLMAT_STYLE_GRAYSCALE, {
    css = [[
        img { -webkit-filter: grayscale(1); }
    ]]
})

AddHTMLMaterialStyle(HTMLMAT_STYLE_SEPIA, {
    css = [[
        img { -webkit-filter: sepia(1); }
    ]]
})

AddHTMLMaterialStyle(HTMLMAT_STYLE_INVERT, {
    css = [[
        img { -webkit-filter: invert(1); }
    ]]
})

AddHTMLMaterialStyle(HTMLMAT_STYLE_CIRCLE, {
    css = [[
        img { border-radius: 50%; }
    ]]
})

AddHTMLMaterialStyle(HTMLMAT_STYLE_COVER, {
    html = [[
        <script>var src = '%s';</script>
        <style type="text/css">
            html, body {
                width: 100%%;
                height: 100%%;
                margin: 0;
                padding: 0;
                overflow: hidden;
            }
            #mat {
                background: no-repeat 50%% 50%%;
                background-size: cover;
                width: 100%%;
                height: 100%%;
            }
            %s
        </style>
        <div id="mat"></div>
        <script type="application/javascript">
            var mat = document.getElementById('mat');
            mat.style.backgroundImage = 'url(' + src + ')';
            var img = new Image();
            img.onload = function() {
                setTimeout(function() {
                    gmod.imageLoaded();
                }, 100);
            };
            img.onerror = gmod.imageLoaded.bind(gmod);
            img.src = src;
        </script>
    ]]
})

AddHTMLMaterialStyle(HTMLMAT_STYLE_COVER_IMG, {
    html = [[
        <script>var src = '%s';</script>
        <style type="text/css">
            html, body {
                width: 100%%;
                height: 100%%;
                margin: 0;
                padding: 0;
                overflow: hidden;
            }
            img {
                width: auto;
                height: auto;
                position: absolute;
                top: 50%%;
                left: 50%%;
                -webkit-transform: translate(-50%%, -50%%);
            }
            %s
        </style>
        <img id="mat">
        <script type="application/javascript">
            var mat = document.getElementById('mat');
            mat.onload = function() {
                if (mat.width > mat.height) {
                    mat.style.height = '100%%';
                } else {
                    mat.style.width = '100%%';
                }
                setTimeout(function() {
                    gmod.imageLoaded();
                }, 100);
            };
            mat.onerror = function() {
                gmod.imageLoaded();
            };
            mat.src = src;
        </script>
    ]]
})
