package main
import "vendor:raylib"

@(private) last_key_pressed : raylib.KeyboardKey = raylib.KeyboardKey.KEY_NULL

get_key_pressed_with_repeats :: proc() -> raylib.KeyboardKey {
    key : raylib.KeyboardKey = raylib.GetKeyPressed()
    if key != raylib.KeyboardKey.KEY_NULL {
        last_key_pressed = key
        return key
    }

    if last_key_pressed == raylib.KeyboardKey.KEY_NULL {
        return raylib.KeyboardKey.KEY_NULL
    }

    if raylib.IsKeyPressedRepeat(last_key_pressed) {
        return last_key_pressed
    }

    if raylib.IsKeyUp(last_key_pressed) {
        last_key_pressed = raylib.KeyboardKey.KEY_NULL
    }

    return raylib.KeyboardKey.KEY_NULL
}
