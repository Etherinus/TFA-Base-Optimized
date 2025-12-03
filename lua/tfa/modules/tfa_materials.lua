if CLIENT then
    local surface_GetTextureID = surface.GetTextureID

    TFA_SCOPE_ACOG = {
        scopetex = surface_GetTextureID("scope/gdcw_closedsight"),
        reticletex = surface_GetTextureID("scope/gdcw_acogchevron"),
        dottex = surface_GetTextureID("scope/gdcw_acogcross")
    }

    TFA_SCOPE_MILDOT = {
        scopetex = surface_GetTextureID("scope/gdcw_scopesight")
    }

    TFA_SCOPE_SVD = {
        scopetex = surface_GetTextureID("scope/gdcw_svdsight")
    }

    TFA_SCOPE_PARABOLIC = {
        scopetex = surface_GetTextureID("scope/gdcw_parabolicsight")
    }

    TFA_SCOPE_ELCAN = {
        scopetex = surface_GetTextureID("scope/gdcw_elcansight"),
        reticletex = surface_GetTextureID("scope/gdcw_elcanreticle")
    }

    TFA_SCOPE_GREENDUPLEX = {
        scopetex = surface_GetTextureID("scope/gdcw_closedsight"),
        reticletex = surface_GetTextureID("scope/gdcw_nvgilluminatedduplex")
    }

    TFA_SCOPE_AIMPOINT = {
        scopetex = surface_GetTextureID("scope/gdcw_closedsight"),
        reticletex = surface_GetTextureID("scope/aimpoint")
    }

    TFA_SCOPE_MATADOR = {
        scopetex = surface_GetTextureID("scope/rocketscope")
    }

    TFA_SCOPE_SCOPESCALE = 4
    TFA_SCOPE_RETICLESCALE = 1
    TFA_SCOPE_DOTSCALE = 1
end
