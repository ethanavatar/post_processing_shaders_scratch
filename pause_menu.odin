package main
import "vendor:raylib"

draw_pause_menu :: proc() {
    raylib.DrawRectangle(0, 0, initial_width, initial_height, raylib.Fade(raylib.BLACK, 0.8))
    text : cstring = "Paused"
    text_center := raylib.MeasureText(text, 50) / 2
    window_center_x : i32 = initial_width / 2
    window_center_y : i32 = initial_height / 2
    raylib.DrawText(text, window_center_x - text_center, window_center_y - 50 - 100, 50, raylib.WHITE)

    raylib.DrawText("Press ESC to resume", window_center_x - 200, window_center_y + 50 - 100, 20, raylib.GRAY)
    raylib.DrawText("Press TAB to enter edit mode", window_center_x - 200, window_center_y + 80 - 100, 20, raylib.GRAY)
    raylib.DrawText("Press Ctrl+Q to quit", window_center_x - 200, window_center_y + 110 - 100, 20, raylib.GRAY)
}
