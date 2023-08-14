#define PLATFORM_WEBGL

uniform sampler2D   u_scene;
uniform sampler2D   u_buffer0;
uniform sampler2D   u_doubleBuffer0; // 512x512
uniform sampler2D   u_doubleBuffer1; // 1.0x1.0

uniform vec3        u_camera;
uniform vec2        u_resolution;
uniform float       u_time;
uniform int         u_frame;

varying vec2        v_texcoord;
varying vec4        v_position;

#include "lygia/space/ratio.glsl"
#include "lygia/space/sqTile.glsl"
#include "lygia/color/palette/hue.glsl"
#include "lygia/draw/circle.glsl"

void main() {
    vec4 color = vec4(vec3(0.0), 1.0);
    vec2 pixel = 1.0/u_resolution;
    vec2 st = gl_FragCoord.xy * pixel;
    vec2 uv = v_texcoord;

#if defined(BACKGROUND)

    color.rg += uv;

#elif defined(POSTPROCESSING)
    st /= 2.0;

    float frq = 20.0;
    float amp = 0.1;
    st.x += cos(st.y * frq + u_time) * amp;
    st.y += cos(st.x * frq + u_time) * amp;

    color.rgb = texture2D(u_scene, st).rgb;

#endif

    gl_FragColor = color;
}