#version 330
in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
const vec3 ntsc_gray = vec3(0.299, 0.587, 0.114);

void main() {
    vec4 texelColor = texture(texture0, fragTexCoord) * fragColor;
    float gray = dot(texelColor.rgb, ntsc_gray);
    gl_FragColor = vec4(gray, gray, gray, texelColor.a);
}
