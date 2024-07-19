package main
import "core:fmt"
import "vendor:raylib"

game_title :: "Shader Postprocessing Scratchpad"

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

main :: proc() {
    raylib.InitWindow(initial_width, initial_height, game_title)
    raylib.SetTargetFPS(60)
    raylib.DisableCursor()

    canvas_texture = raylib.LoadRenderTexture(canvas_width, canvas_height)
    defer raylib.UnloadRenderTexture(canvas_texture)

    window_texture = raylib.LoadRenderTexture(initial_width, initial_height)
    defer raylib.UnloadRenderTexture(window_texture)

    chromatic_aberration := raylib.LoadShader(
        // Vertex shader.
        // Nothing, because its a post-processing effect
        nil,

        // Fragment shader
        // uniform vec3 offset;
        "chromatic_aberration.frag",
    )
    defer raylib.UnloadShader(chromatic_aberration)

    offset := raylib.Vector3{0.009, 0.006, -0.006}
    offset_location := raylib.GetShaderLocation(chromatic_aberration, "offset")

    camera := raylib.Camera3D{
        position = raylib.Vector3{10, 10, 10},
        target = raylib.Vector3{0, 0, 0},
        up = raylib.Vector3{0, 1, 0},
        fovy = 45,
        projection = raylib.CameraProjection.PERSPECTIVE,
    }

    cube_position := raylib.Vector3{0, 0, 0}

    for should_close == false && raylib.WindowShouldClose() == false {
        raylib.UpdateCamera(&camera, raylib.CameraMode.FREE)
        
        raylib.BeginTextureMode(canvas_texture)
            raylib.ClearBackground(raylib.RAYWHITE)

            raylib.BeginMode3D(camera)
                raylib.DrawGrid(10, 1)
                raylib.DrawCube(cube_position, 2, 2, 2, raylib.GRAY)
                raylib.DrawCubeWires(cube_position, 2, 2, 2, raylib.LIGHTGRAY)
            raylib.EndMode3D()

            raylib.BeginShaderMode(chromatic_aberration)
                raylib.SetShaderValue(chromatic_aberration, offset_location, &offset, raylib.ShaderUniformDataType.VEC3)
                raylib.DrawTextureRec(
                    canvas_texture.texture,
                    raylib.Rectangle{0, 0, cast(f32)canvas_width, -cast(f32)canvas_height},
                    raylib.Vector2{0, 0},
                    raylib.WHITE,
                )
            raylib.EndShaderMode()

        raylib.EndTextureMode()

        raylib.BeginDrawing()
            raylib.ClearBackground(raylib.RAYWHITE)

            raylib.DrawTexturePro(
                canvas_texture.texture,
                canvas_source, canvas_dest,
                raylib.Vector2{0, 0}, 0,
                raylib.WHITE,
            )
        raylib.EndDrawing()
    }

    raylib.CloseWindow()
}
