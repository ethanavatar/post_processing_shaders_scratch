package main
import "core:fmt"
import "vendor:raylib"

gui_text_entry :: proc(
    bounds: raylib.Rectangle,
    label: cstring,
    body: ^cstring,
    font_size: i32,
    is_active: ^bool,
) {
    label_bounds := bounds
    label_bounds.x -= cast(f32)raylib.MeasureText(label, font_size) / 2
    raylib.GuiLabel(label_bounds, label)

    mouse_pos := raylib.GetMousePosition()
    collision := raylib.CheckCollisionPointRec(mouse_pos, bounds)

    inner_color := raylib.LIGHTGRAY
    if collision {
        raylib.SetMouseCursor(raylib.MouseCursor.IBEAM)
        inner_color = raylib.WHITE
    }

    raylib.DrawRectangleRec(bounds, inner_color)
    raylib.DrawRectangleLinesEx(bounds, 1, raylib.DARKGRAY)

    if collision && raylib.IsMouseButtonPressed(raylib.MouseButton.LEFT) {
        is_active^ = true
    }

    if is_active^ {
        raylib.DrawText(body^, cast(i32)bounds.x + 5, cast(i32)bounds.y + 5, font_size, raylib.BLACK)
    } else {
        raylib.DrawText(body^, cast(i32)bounds.x + 5, cast(i32)bounds.y + 5, font_size, raylib.DARKGRAY)
    }
}

