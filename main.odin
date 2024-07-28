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

canvas_scale :: 1.0
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
    position = raylib.Vector3{10, 2.5, 10},
    target = raylib.Vector3{0, 0, 0},
    up = raylib.Vector3{0, 1, 0},
    fovy = 45,
    projection = raylib.CameraProjection.PERSPECTIVE,
}

gray_cube_position := raylib.Vector3{0, 0, 0}
red_cube_position := raylib.Vector3{3, 1, 2}
green_cube_position := raylib.Vector3{-3, 1, 0}
blue_cube_position := raylib.Vector3{0, 1, -3}

black_wall_position := raylib.Vector3{-5, 0, -2.5}

aberration_shader : Shader
grayscale_shader : Shader
bloom_shader : Shader

aberration_offset : raylib.Vector3 = raylib.Vector3{0.009, 0.006, -0.006}
grayscale_color_diffuse : raylib.Vector4 = raylib.Vector4{0.5, 0.5, 0.5, 1}

draw_game_canvas :: proc() {
    raylib.ClearBackground(raylib.RAYWHITE)

    raylib.BeginMode3D(camera);
        raylib.DrawGrid(10, 1)
        raylib.DrawCube(gray_cube_position, 2, 2, 2, raylib.GRAY)
        raylib.DrawCubeWires(gray_cube_position, 2, 2, 2, raylib.LIGHTGRAY)
    
        raylib.DrawCube(red_cube_position, 1, 1, 1, raylib.RED)
        raylib.DrawCubeWires(red_cube_position, 1, 1, 1, raylib.MAROON)

        raylib.DrawCube(green_cube_position, 1, 1, 1, raylib.GREEN)
        raylib.DrawCubeWires(green_cube_position, 1, 1, 1, raylib.DARKGREEN)

        raylib.DrawCube(blue_cube_position, 1, 1, 1, raylib.BLUE)
        raylib.DrawCubeWires(blue_cube_position, 1, 1, 1, raylib.DARKBLUE)

        raylib.DrawCube(black_wall_position, 1, 10, 20, raylib.BLACK)
    raylib.EndMode3D()

    if grayscale_shader.enabled { shader_process(&grayscale_shader) }
    if aberration_shader.enabled { shader_process(&aberration_shader) }
    if bloom_shader.enabled { shader_process(&bloom_shader) }
}

main :: proc() {
    raylib.InitWindow(initial_width, initial_height, game_title)
    defer raylib.CloseWindow()

    raylib.SetTargetFPS(60)
    raylib.SetExitKey(nil)
    raylib.DisableCursor()

    canvas_texture = raylib.LoadRenderTexture(canvas_width, canvas_height)
    defer raylib.UnloadRenderTexture(canvas_texture)

    window_texture = raylib.LoadRenderTexture(initial_width, initial_height)
    defer raylib.UnloadRenderTexture(window_texture)

    aberration_shader = shader_load(nil, "shaders/chromatic_aberration.frag")
    shader_add_uniform(&aberration_shader, "offset", &aberration_offset, raylib.ShaderUniformDataType.VEC3)
    defer shader_unload(&aberration_shader)

    grayscale_shader = shader_load(nil, "shaders/grayscale.frag")
    shader_add_uniform(&grayscale_shader, "colorDiffuse", &grayscale_color_diffuse, raylib.ShaderUniformDataType.VEC4)
    defer shader_unload(&grayscale_shader)


    bloom_shader = shader_load(nil, "shaders/bloom.frag")
    defer shader_unload(&bloom_shader)

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
            raylib.UpdateCamera(&camera, raylib.CameraMode.FIRST_PERSON)
        }

        if raylib.IsKeyPressed(raylib.KeyboardKey.Q) && raylib.IsKeyDown(raylib.KeyboardKey.LEFT_CONTROL) {
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

            if game_state == GameState.Editing { draw_edit_menu() }
            if game_state == GameState.Paused  { draw_pause_menu() }
        } raylib.EndDrawing()

        free_all(context.temp_allocator)
    }

    free_all(context.allocator)
}
