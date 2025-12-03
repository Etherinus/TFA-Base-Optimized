if CLIENT and not TFASleekFontCreated then
    local fontdata = {
        font = "Roboto-Regular",
        size = 36,
        antialias = true,
        shadow = false
    }

    surface.CreateFont("TFASleek", fontdata)

    fontdata.size = 30
    surface.CreateFont("TFASleekMedium", fontdata)

    fontdata.size = 24
    surface.CreateFont("TFASleekSmall", fontdata)

    fontdata.size = 18
    surface.CreateFont("TFASleekTiny", fontdata)

    TFASleekFontCreated = true
    TFASleekFontHeight = draw.GetFontHeight("TFASleek")
    TFASleekFontHeightMedium = draw.GetFontHeight("TFASleekMedium")
    TFASleekFontHeightSmall = draw.GetFontHeight("TFASleekSmall")
    TFASleekFontHeightTiny = draw.GetFontHeight("TFASleekTiny")
end
