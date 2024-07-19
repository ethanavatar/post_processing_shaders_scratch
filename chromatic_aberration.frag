#version 330 core
uniform sampler2D screen_texture;
uniform vec3 offset;

//uniform vec2 focal_point;

void main() {
    vec2 size = textureSize(screen_texture, 0).xy;
    vec2 coord = gl_FragCoord.xy / size;

    vec2 focal_point = vec2(0.5, 0.5);
    vec2 direction = coord - focal_point;

    gl_FragColor = texture2D(screen_texture, coord);
    gl_FragColor.r = texture2D(screen_texture, coord + direction * offset.x).r;
    gl_FragColor.g = texture2D(screen_texture, coord + direction * offset.y).g;
    gl_FragColor.b = texture2D(screen_texture, coord + direction * offset.z).b;
}
