package main
import "core:fmt"
import "core:strconv"
import "core:strings"
import "vendor:raylib"

game_title :: "Shader Postprocessing Scratchpad"

GameState :: enum {
    Playing,
    Editing,
    Paused,
}

game_state := GameState.Playing

initial_width :: 1200
initial_height :: 800

canvas_scale :: 0.5
canvas_width :: cast(i32)(initial_width * canvas_scale)
canvas_height :: cast(i32)(initial_height * canvas_scale)

should_close := false
canvas_texture : raylib.RenderTexture2D
window_texture : raylib.RenderTexture2D

canvas_source := raylib.Rectangle{
    0, 0,
    cast(f32)canvas_width, -cast(f32)canvas_height
}
canvas_dest := raylib.Rectangle{
    0, 0,
    cast(f32)initial_width, cast(f32)initial_height
}

camera := raylib.Camera3D{
    position = raylib.Vector3{10, 10, 10},
    target = raylib.Vector3{0, 0, 0},
    up = raylib.Vector3{0, 1, 0},
    fovy = 45,
    projection = raylib.CameraProjection.PERSPECTIVE,
}

gray_cube_position := raylib.Vector3{0, 0, 0}
red_cube_position := raylib.Vector3{3, 1, 2}
green_cube_position := raylib.Vector3{-3, 1, 0}
blue_cube_position := raylib.Vector3{0, 1, -3}

chromatic_aberration_enabled := false
chromatic_aberration : raylib.Shader
offset : raylib.Vector3
offset_location : i32

draw_game_canvas :: proc() {
    raylib.ClearBackground(raylib.RAYWHITE)

    raylib.BeginMode3D(camera)
        raylib.DrawGrid(10, 1)
        raylib.DrawCube(gray_cube_position, 2, 2, 2, raylib.GRAY)
        raylib.DrawCubeWires(gray_cube_position, 2, 2, 2, raylib.LIGHTGRAY)
    
        raylib.DrawCube(red_cube_position, 1, 1, 1, raylib.RED)
        raylib.DrawCubeWires(red_cube_position, 1, 1, 1, raylib.MAROON)

        raylib.DrawCube(green_cube_position, 1, 1, 1, raylib.GREEN)
        raylib.DrawCubeWires(green_cube_position, 1, 1, 1, raylib.DARKGREEN)

        raylib.DrawCube(blue_cube_position, 1, 1, 1, raylib.BLUE)
        raylib.DrawCubeWires(blue_cube_position, 1, 1, 1, raylib.DARKBLUE)
    raylib.EndMode3D()

    raylib.BeginShaderMode(chromatic_aberration)
        if chromatic_aberration_enabled {
            raylib.SetShaderValue(chromatic_aberration, offset_location, &offset, raylib.ShaderUniformDataType.VEC3)
            raylib.DrawTextureRec(
                canvas_texture.texture,
                raylib.Rectangle{0, 0, cast(f32)canvas_width, -cast(f32)canvas_height},
                raylib.Vector2{0, 0},
                raylib.WHITE,
            )
        }
    raylib.EndShaderMode()
}

float_to_cstring :: proc(f : f32, buffer : []u8) -> cstring {
    return strings.unsafe_string_to_cstring(
        strconv.ftoa(buffer, cast(f64)f, 'f', 4, 32)
    )
}

main :: proc() {
    raylib.InitWindow(initial_width, initial_height, game_title)
    raylib.SetTargetFPS(60)
    raylib.SetExitKey(nil)
    raylib.DisableCursor()

    canvas_texture = raylib.LoadRenderTexture(canvas_width, canvas_height)
    defer raylib.UnloadRenderTexture(canvas_texture)

    window_texture = raylib.LoadRenderTexture(initial_width, initial_height)
    defer raylib.UnloadRenderTexture(window_texture)

    chromatic_aberration = raylib.LoadShader(
        // Vertex shader.
        // Nothing, because its a post-processing effect
        nil,

        // Fragment shader
        // uniform vec3 offset;
        "chromatic_aberration.frag",
    )
    defer raylib.UnloadShader(chromatic_aberration)

    offset = raylib.Vector3{0.009, 0.006, -0.006}
    offset_location = raylib.GetShaderLocation(chromatic_aberration, "offset")

    for should_close == false && raylib.WindowShouldClose() == false {
        if raylib.IsKeyPressed(raylib.KeyboardKey.TAB) {
            if game_state == GameState.Playing {
                game_state = GameState.Editing
                raylib.EnableCursor()
            } else {
                game_state = GameState.Playing
                raylib.DisableCursor()
            }
        }

        if raylib.IsKeyPressed(raylib.KeyboardKey.ESCAPE) {
            if game_state == GameState.Playing {
                game_state = GameState.Paused
                raylib.EnableCursor()
            } else {
                game_state = GameState.Playing
                raylib.DisableCursor()
            }
        }

        if (game_state == GameState.Playing) {
            raylib.UpdateCamera(&camera, raylib.CameraMode.FREE)
        }

        if raylib.IsKeyPressed(raylib.KeyboardKey.X) {
            should_close = true
        }
        
        raylib.BeginTextureMode(canvas_texture); {
            draw_game_canvas()
        } raylib.EndTextureMode()

        raylib.BeginDrawing(); {
            raylib.ClearBackground(raylib.RAYWHITE)

            raylib.DrawTexturePro(
                canvas_texture.texture,
                canvas_source, canvas_dest,
                raylib.Vector2{0, 0}, 0,
                raylib.WHITE,
            )

            if game_state == GameState.Editing {
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
            }

            if game_state == GameState.Paused {
                raylib.DrawRectangle(0, 0, initial_width, initial_height, raylib.Fade(raylib.BLACK, 0.8))
                text : cstring = "Paused"
                text_center := raylib.MeasureText(text, 50) / 2
                window_center_x : i32 = initial_width / 2
                window_center_y : i32 = initial_height / 2
                raylib.DrawText(text, window_center_x - text_center, window_center_y - 50 - 100, 50, raylib.WHITE)

                raylib.DrawText("Press ESC to resume", window_center_x - 200, window_center_y + 50 - 100, 20, raylib.GRAY)
                raylib.DrawText("Press TAB to enter edit mode", window_center_x - 200, window_center_y + 80 - 100, 20, raylib.GRAY)
                raylib.DrawText("Press X to quit", window_center_x - 200, window_center_y + 110 - 100, 20, raylib.GRAY)
            }
        } raylib.EndDrawing()
    }

    raylib.CloseWindow()
}
