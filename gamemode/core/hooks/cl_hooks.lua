function GM:HUDPaint()
end

function GM:LoadFonts()
    surface.CreateFont("ow.fonts.default", {
        font = "Arial",
        size = 16,
        weight = 500
    })

    surface.CreateFont("ow.fonts.default.bold", {
        font = "Arial",
        size = 16,
        weight = 700
    })

    surface.CreateFont("ow.fonts.default.italic", {
        font = "Arial",
        size = 16,
        weight = 500,
        italic = true
    })

    surface.CreateFont("ow.fonts.default.large", {
        font = "Arial",
        size = 24,
        weight = 500
    })

    surface.CreateFont("ow.fonts.default.large.bold", {
        font = "Arial",
        size = 24,
        weight = 700
    })

    surface.CreateFont("ow.fonts.default.xlarge", {
        font = "Arial",
        size = 32,
        weight = 500
    })

    surface.CreateFont("ow.fonts.default.xlarge.bold", {
        font = "Arial",
        size = 32,
        weight = 700
    })

    hook.Call("PostCreateFonts")
end