package main
import "vendor:raylib"

SHADER_MAX_UNIFORMS :: 32

ShaderUniform :: struct {
    name : cstring,
    location : i32,
    value : rawptr,
    value_type : raylib.ShaderUniformDataType,
}

Shader :: struct {
    shader : raylib.Shader,
    uniforms : [dynamic]ShaderUniform,
    enabled : bool,
}

shader_load :: proc(
    vert_shader_path : cstring,
    frag_shader_path : cstring,
    allocator := context.allocator,
) -> Shader {
    result : Shader
    result.enabled = true
    result.shader = raylib.LoadShader(vert_shader_path, frag_shader_path)
    result.uniforms = make([dynamic]ShaderUniform, 0, SHADER_MAX_UNIFORMS, allocator)
    return result
}

shader_unload :: proc(
    shader : ^Shader,
    allocator := context.allocator,
) {
    raylib.UnloadShader(shader.shader)
    delete(shader.uniforms)
}

shader_add_uniform :: proc(
    shader : ^Shader,
    name : cstring,
    value : rawptr,
    value_type : raylib.ShaderUniformDataType,
) {
    uniform : ShaderUniform
    uniform.name = name
    uniform.location = raylib.GetShaderLocation(shader.shader, name)
    uniform.value = value
    uniform.value_type = value_type
    append(&shader.uniforms, uniform)
}

shader_update_uniforms :: proc(
    shader : ^Shader,
) {
    for i in 0..<len(shader.uniforms) {
        uniform := shader.uniforms[i]
        raylib.SetShaderValue(
            shader.shader,
            uniform.location,
            uniform.value,
            uniform.value_type
        )
    }
}

shader_process :: proc(
    shader : ^Shader,
) {
    if !shader.enabled { return }
    raylib.BeginShaderMode(shader.shader); {
        shader_update_uniforms(shader)
        raylib.DrawTextureRec(
            canvas_texture.texture,
            raylib.Rectangle{0, 0, cast(f32)canvas_width, -cast(f32)canvas_height},
            raylib.Vector2{0, 0},
            raylib.WHITE,
        )
    }; raylib.EndShaderMode()
}
