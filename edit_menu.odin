package main
import "vendor:raylib"

te : TextEntry = {
    body = "Hello, Sailor!",
    is_focused = false,
} 

draw_edit_menu :: proc() {
    raylib.DrawText("Editing", 10, 10, 20, raylib.GRAY)
    text_buffer := [32]u8{}
    
    raylib.GuiSliderBar(
        raylib.Rectangle{100, 40, 200, 20},
        "Red offset",
        float_to_cstring(offset.x, text_buffer[:]),
        &offset.x,
        -0.1, 0.1,
    )

    raylib.GuiSliderBar(
        raylib.Rectangle{100, 70, 200, 20},
        "Green offset",
        float_to_cstring(offset.y, text_buffer[:]),
        &offset.y,
        -0.1, 0.1,
    )

    raylib.GuiSliderBar(
        raylib.Rectangle{100, 100, 200, 20},
        "Blue offset",
        float_to_cstring(offset.z, text_buffer[:]),
        &offset.z,
        -0.1, 0.1,
    )

    raylib.GuiToggle(
        raylib.Rectangle{100, 130, 200, 20},
        "Chromatic Aberration",
        &chromatic_aberration_enabled,
    )

    raylib.GuiSliderBar(
        raylib.Rectangle{100, 190, 200, 20},
        "Diffuse Red",
        float_to_cstring(color_diffuse.x, text_buffer[:]),
        &color_diffuse.y,
        0, 1,
    )

    raylib.GuiSliderBar(
        raylib.Rectangle{100, 220, 200, 20},
        "Diffuse Green",
        float_to_cstring(color_diffuse.y, text_buffer[:]),
        &color_diffuse.z,
        0, 1,
    )

    raylib.GuiSliderBar(
        raylib.Rectangle{100, 250, 200, 20},
        "Diffuse Blue",
        float_to_cstring(color_diffuse.z, text_buffer[:]),
        &color_diffuse.w,
        0, 1,
    )

    raylib.GuiSliderBar(
        raylib.Rectangle{100, 280, 200, 20},
        "Diffuse Alpha",
        float_to_cstring(color_diffuse.w, text_buffer[:]),
        &color_diffuse.w,
        0, 1,
    )

    raylib.GuiToggle(
        raylib.Rectangle{100, 310, 200, 20},
        "Grayscale",
        &grayscale_enabled,
    )

    raylib.GuiToggle(
        raylib.Rectangle{100, 340, 200, 20},
        "Bloom",
        &bloom_enabled,
    )

    draw_text_entry(
        &te,
        raylib.Rectangle{100, 370, 200, 35},
        "Label",
        20, true,
    )
}
