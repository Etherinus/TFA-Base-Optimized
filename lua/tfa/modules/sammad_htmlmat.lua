if SERVER then AddCSLuaFile() end

local ipairs = ipairs
local pairs = pairs
local table = table
local timer = timer
local ceil = math.ceil
local log = math.log
local pow = math.pow
local string = string
local Material = Material
local type = type

local function dosomething()
end

local HTML_MATERIALS_ENABLED = false
local fallback_mat = Material("vgui/white")
local fallback_mat_token = "!" .. fallback_mat:GetName()

function GetHTMLMaterialVL(url, callbackfunc)
    if not CLIENT then return end
    if not HTML_MATERIALS_ENABLED then
        if callbackfunc then
            callbackfunc(fallback_mat_token)
        end
        return
    end

    HTMLMaterial(url, HTMLMAT_STYLE_COVER_IMG, function(mat)
        local matdata = {
            ["$basetexture"]          = mat:GetName(),
            ["$bumpmap"]              = "null-bumpmap",
            ["$phongexponenttexture"] = "models/exp_gun",
            ["$model"]                = 1,
            ["$phong"]                = 1,
            ["$phongboost"]           = 1,
            ["$phongalbedoboost"]     = 35,
            ["$phongfresnelranges"]   = "[.83 .83 1]",
            ["$phongalbedotint"]      = 1,
            ["$envmap"]               = "env_cubemap",
            ["$envmaptint"]           = "[0.05 0.05 0.05]",
            ["$envmapfresnel"]        = 1
        }

        local uid = string.Replace(mat:GetName(), "__vgui_texture_", "")
        local vertexmat = CreateMaterial("WebMaterial_" .. uid, "VertexLitGeneric", matdata)
        if vertexmat then
            dosomething()
        end

        if callbackfunc then
            callbackfunc("!" .. "WebMaterial_" .. uid)
        end
    end)
end

local cache = {}
local downloads = {}
local styles = {}

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

local UpdateTimerName = "HtmlMatUpdate"
local TimerRunning = false

local DefaultMat = Material("vgui/white")
local DefaultWidth = 2048
local DefaultStyle = {}

local function updateCache(download)
    download.browser:UpdateHTMLTexture()
    cache[download.key] = download.browser:GetHTMLMaterial()
end

local function updateMaterials()
    for _, download in ipairs(downloads) do
        updateCache(download)
    end
end

local function onImageLoaded(key, browser)
    local idx
    for i, v in pairs(downloads) do
        if v.key == key then
            idx = i
            break
        end
    end

    if idx then
        browserpool.release(browser, true)
        table.remove(downloads, idx)
    end

    if #downloads == 0 and TimerRunning then
        timer.Remove(UpdateTimerName)
        TimerRunning = false
    end
end

local function enqueueUrl(url, styleName, key, callback)
    if not HTML_MATERIALS_ENABLED then
        if type(callback) == "function" then
            callback(DefaultMat)
        end
        cache[key] = DefaultMat
        return
    end

    cache[key] = DefaultMat

    browserpool.get(function(browser)
        local style = styles[styleName] or DefaultStyle
        local w = style.width or DefaultWidth
        local h = style.height or w
        browser:SetSize(w, h)

        local download = {
            url = url,
            key = key,
            browser = browser
        }
        table.insert(downloads, download)

        browser:AddFunction("gmod", "imageLoaded", function()
            updateCache(download)
            onImageLoaded(key, browser)
            if type(callback) == "function" then
                callback(cache[key])
            end
        end)

        if not TimerRunning then
            timer.Create(UpdateTimerName, 0.05, 0, updateMaterials)
            TimerRunning = true
        end

        local html = (style.html or embedHtml):format(url, style.css or '')
        browser:SetHTML(html)
    end)
end

local MAT_STR_TABLE = {"", "@", ""}

function HTMLMaterial(url, style, callback)
    if not url then return DefaultMat end
    if not HTML_MATERIALS_ENABLED then
        if type(callback) == "function" then
            callback(DefaultMat)
        end
        return DefaultMat
    end

    local key

    if style then
        MAT_STR_TABLE[1] = url
        MAT_STR_TABLE[3] = style
        key = table.concat(MAT_STR_TABLE)
    else
        key = url
    end

    if cache[key] == nil then
        enqueueUrl(url, style, key, callback)
    elseif callback then
        callback(cache[key])
    end

    return cache[key]
end

if CLIENT then
    local surface = surface
    local color_white = color_white

    local function CeilPower2(n)
        return pow(2, ceil(log(n) / log(2)))
    end

    function DrawHTMLMaterial(url, styleName, w, h)
        local mat = HTMLMaterial(url, styleName)
        local style = styles[styleName] or DefaultStyle

        local width = style.width or DefaultWidth
        local height = style.height or width

        local scaleX = w / width
        local scaleY = h / height

        width = CeilPower2(width)
        height = CeilPower2(height)

        surface.SetDrawColor(color_white)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(0, 0, scaleX * width, scaleY * height)
    end
end

function AddHTMLMaterialStyle(name, params, base)
    params = params or {}
    if base then
        table.Merge(params, table.Copy(styles[base] or {}))
    end
    styles[name] = params
end

HTMLMAT_STYLE_BLUR       = "htmlmat.style.blur"
HTMLMAT_STYLE_GRAYSCALE  = "htmlmat.style.grayscale"
HTMLMAT_STYLE_SEPIA      = "htmlmat.style.sepia"
HTMLMAT_STYLE_INVERT     = "htmlmat.style.invert"
HTMLMAT_STYLE_CIRCLE     = "htmlmat.style.circle"
HTMLMAT_STYLE_COVER      = "htmlmat.style.cover"
HTMLMAT_STYLE_COVER_IMG  = "htmlmat.style.coverimg"

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
