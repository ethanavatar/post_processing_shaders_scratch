package main
import "core:fmt"
import "core:strings"
import "vendor:raylib"

TextEntry :: struct {
    body: cstring,
    is_focused: bool,
    cursor_position: i32,
    cursor_blink_timer: f32,
    //key_repeat_timer: f32, // TODO: Implement key repeat
}

update_text_entry :: proc(
    element: ^TextEntry,
    bounds: raylib.Rectangle,
    label: cstring,
    font_size: i32,
    centered: bool,
) {
    half_font_size := font_size / 2
    label_bounds := bounds
    label_bounds.x -= cast(f32)(raylib.MeasureText(label, font_size) + half_font_size)
    label_bounds.y += cast(f32)half_font_size
    raylib.DrawText(label, cast(i32)label_bounds.x, cast(i32)label_bounds.y, font_size, raylib.DARKGRAY)

    mouse_pos := raylib.GetMousePosition()
    collision := raylib.CheckCollisionPointRec(mouse_pos, bounds)

    inner_color := raylib.LIGHTGRAY
    if collision {
        raylib.SetMouseCursor(raylib.MouseCursor.IBEAM)
        inner_color = raylib.WHITE
    }

    raylib.DrawRectangleRec(bounds, inner_color)
    raylib.DrawRectangleLinesEx(bounds, 1, raylib.DARKGRAY)

    if raylib.IsMouseButtonPressed(raylib.MouseButton.LEFT) {
        element.is_focused = collision
        element.cursor_blink_timer = 0
        element.cursor_position = cast(i32)len(element.body)
    }

    font_color := raylib.DARKGRAY
    if element.is_focused {
        font_color = raylib.BLACK
    }

    x_offset : i32 = cast(i32)bounds.x + half_font_size
    y_offset : i32 = cast(i32)bounds.y + half_font_size
    if centered {
        text_center : i32 = raylib.MeasureText(element.body, font_size) / 2
        x_offset = cast(i32)bounds.x + cast(i32)(bounds.width / 2) - text_center
    }

    raylib.DrawText(
        element.body,
        x_offset, y_offset,
        font_size,
        font_color,
    )

    if element.is_focused {
        cursor_x := x_offset + raylib.MeasureText(element.body, font_size)
        _, after_cursor := cstring_split_at(element.body, cast(int)element.cursor_position, context.temp_allocator)
        cursor_x -= raylib.MeasureText(after_cursor, font_size)
        cursor_y := y_offset

        if element.cursor_blink_timer < 0.5 {
            raylib.DrawRectangle(cursor_x, cursor_y, 2, font_size, raylib.BLACK)
        }
        element.cursor_blink_timer += raylib.GetFrameTime()
        if element.cursor_blink_timer > 1 {
            element.cursor_blink_timer = 0
        }

        if raylib.IsKeyPressed(raylib.KeyboardKey.BACKSPACE) {
            if element.cursor_position > 0 {
                element.cursor_position -= 1
                element.body = cstring_remove_at(element.body, cast(int)element.cursor_position, context.temp_allocator)
            }
        }

        if raylib.IsKeyPressed(raylib.KeyboardKey.RIGHT) {
            if cast(int)element.cursor_position < len(element.body) {
                element.cursor_position += 1
            }
        }

        if raylib.IsKeyPressed(raylib.KeyboardKey.LEFT) {
            if element.cursor_position > 0 {
                element.cursor_position -= 1
            }
        }

        if raylib.IsKeyPressed(raylib.KeyboardKey.DELETE) {
            if cast(int)element.cursor_position < len(element.body) {
                element.body = cstring_remove_at(element.body, cast(int)element.cursor_position, context.temp_allocator)
            }
        }

        if raylib.IsKeyPressed(raylib.KeyboardKey.ENTER) {
            element.is_focused = false
        }

        key : rune = raylib.GetCharPressed()
        if key != cast(rune)0 {
            if rune_is_ascii(key) {
                element.body = cstring_insert_at(element.body, cast(int)element.cursor_position, key, context.temp_allocator)
                element.cursor_position += 1
            }
        }

    }
}

