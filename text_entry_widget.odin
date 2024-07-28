package main
import "core:fmt"
import "core:strings"
import "vendor:raylib"

TextEntry :: struct {
    body: cstring,
    is_focused: bool,
    cursor_position: i32,
    cursor_blink_timer: f32,
}

draw_text_entry :: proc(
    element: ^TextEntry,
    bounds: raylib.Rectangle,
    label: cstring,
    font_size: i32,
    centered: bool,
) -> raylib.Vector2 {
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
        font_size, font_color,
    )

    if !element.is_focused {
        return raylib.Vector2{
            bounds.x + bounds.width,
            bounds.y + bounds.height,
        }
    }

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

    key : raylib.KeyboardKey = get_key_pressed_with_repeats()
    key_handler: #partial switch key {
    case raylib.KeyboardKey.BACKSPACE: key_backspace(element)
    case raylib.KeyboardKey.DELETE:    key_delete(element)
    case raylib.KeyboardKey.RIGHT:     key_right(element)
    case raylib.KeyboardKey.LEFT:      key_left(element)
    case raylib.KeyboardKey.ENTER:     element.is_focused = false
    }

    char : rune = raylib.GetCharPressed()
    char_handler: switch cast(i32)char {
    case 0: break char_handler
    case:
        if !rune_is_ascii(char) { break char_handler }
        element.body = cstring_insert_at(
            element.body,
            cast(int)element.cursor_position,
            char,
            context.allocator
        )
        element.cursor_position += 1
    }

    return raylib.Vector2{
        bounds.x + bounds.width,
        bounds.y + bounds.height,
    }
}

@(private)
key_backspace :: proc(
    element: ^TextEntry,
) {
    if element.cursor_position <= 0 { return }
    element.cursor_position -= 1
    element.body = cstring_remove_at(
        element.body,
        cast(int)element.cursor_position,
        context.allocator
    )
}

@(private)
key_delete :: proc(
    element: ^TextEntry,
) {
    if cast(int)element.cursor_position >= len(element.body) { return }
    element.body = cstring_remove_at(
        element.body,
        cast(int)element.cursor_position,
        context.allocator
    )
}

@(private)
key_right :: proc(
    element: ^TextEntry,
) {
    if cast(int)element.cursor_position >= len(element.body) { return }
    element.cursor_position += 1
}

@(private)
key_left :: proc(
    element: ^TextEntry,
) {
    if element.cursor_position <= 0 { return }
    element.cursor_position -= 1
}
