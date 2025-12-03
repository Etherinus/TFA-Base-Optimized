if CLIENT and not TFASleekFontCreated then
    local surface_CreateFont = surface.CreateFont
    local draw_GetFontHeight = draw.GetFontHeight

    local fontdata = {
        font = "Roboto-Regular",
        size = 36,
        antialias = true,
        shadow = false
    }

    surface_CreateFont("TFASleek", fontdata)

    fontdata.size = 30
    surface_CreateFont("TFASleekMedium", fontdata)

    fontdata.size = 24
    surface_CreateFont("TFASleekSmall", fontdata)

    fontdata.size = 18
    surface_CreateFont("TFASleekTiny", fontdata)

    TFASleekFontCreated = true
    TFASleekFontHeight = draw_GetFontHeight("TFASleek")
    TFASleekFontHeightMedium = draw_GetFontHeight("TFASleekMedium")
    TFASleekFontHeightSmall = draw_GetFontHeight("TFASleekSmall")
    TFASleekFontHeightTiny = draw_GetFontHeight("TFASleekTiny")
end
