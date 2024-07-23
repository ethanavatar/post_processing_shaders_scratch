package main
import "vendor:raylib"

gui_draw_frag_shader_widget :: proc(
    shader : ^Shader,
    shader_name : string,
) {
    if shader == nil { return }
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
}
