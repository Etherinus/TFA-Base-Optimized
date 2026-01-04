if CLIENT and surface and surface.GetTextureID then
    local surface_GetTextureID = surface.GetTextureID

    TFA_SCOPE_ACOG = TFA_SCOPE_ACOG or {
        scopetex = surface_GetTextureID("scope/gdcw_closedsight"),
        reticletex = surface_GetTextureID("scope/gdcw_acogchevron"),
        dottex = surface_GetTextureID("scope/gdcw_acogcross")
    }

    TFA_SCOPE_MILDOT = TFA_SCOPE_MILDOT or {
        scopetex = surface_GetTextureID("scope/gdcw_scopesight")
    }

    TFA_SCOPE_SVD = TFA_SCOPE_SVD or {
        scopetex = surface_GetTextureID("scope/gdcw_svdsight")
    }

    TFA_SCOPE_PARABOLIC = TFA_SCOPE_PARABOLIC or {
        scopetex = surface_GetTextureID("scope/gdcw_parabolicsight")
    }

    TFA_SCOPE_ELCAN = TFA_SCOPE_ELCAN or {
        scopetex = surface_GetTextureID("scope/gdcw_elcansight"),
        reticletex = surface_GetTextureID("scope/gdcw_elcanreticle")
    }

    TFA_SCOPE_GREENDUPLEX = TFA_SCOPE_GREENDUPLEX or {
        scopetex = surface_GetTextureID("scope/gdcw_closedsight"),
        reticletex = surface_GetTextureID("scope/gdcw_nvgilluminatedduplex")
    }

    TFA_SCOPE_AIMPOINT = TFA_SCOPE_AIMPOINT or {
        scopetex = surface_GetTextureID("scope/gdcw_closedsight"),
        reticletex = surface_GetTextureID("scope/aimpoint")
    }

    TFA_SCOPE_MATADOR = TFA_SCOPE_MATADOR or {
        scopetex = surface_GetTextureID("scope/rocketscope")
    }

    if TFA_SCOPE_SCOPESCALE == nil then TFA_SCOPE_SCOPESCALE = 4 end
    if TFA_SCOPE_RETICLESCALE == nil then TFA_SCOPE_RETICLESCALE = 1 end
    if TFA_SCOPE_DOTSCALE == nil then TFA_SCOPE_DOTSCALE = 1 end
end
