#define PLATFORM_WEBGL

uniform sampler2D   u_scene;
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

#ifdef BACKGROUND
    // This renders the background of the 3D scene

    st = ratio(st, u_resolution);
    st += vec2(cos(u_time * 0.5), sin(u_time * 0.2)) * 0.5;
    color.rgb += hue( fract(u_time * 0.1) ) * circle(st, 0.025);

#elif defined(DOUBLE_BUFFER_0)
    // First Ping Pong Buffer for the grid 
    // for circles trail that will be rendered in the surface of the cube.
    // Notice this double buffer will be always 512x512

    color = texture2D(u_doubleBuffer0, st) * 0.99;

    float amount = 10.0;
    vec4 t = sqTile(uv, amount);
    float time = t.z + t.w + u_time * 4.0;
    t.xy += vec2(cos(time * 0.5), sin(time * 0.2)) * 0.2;
    color.rgb += hue( fract((t.z + t.w) / amount) + u_time * 0.1) * circle(t.xy, 0.1) * 0.05;
    color.a = 1.0;

#elif defined(DOUBLE_BUFFER_1)
    // Second Ping Pong Buffer for making the entire scene
    // (background and cube - width dots - ) create trails
    // Notice this double buffer will be resize to match the screen size

    color += texture2D(u_doubleBuffer1, st) * 0.99;
    vec4 scene = texture2D(u_scene, st);
    color.rgb += scene.rgb * scene.a * 0.1;

#elif defined(POSTPROCESSING)
    // This is the final postprocessing pass where displays the 
    // content of the second double buffer (the one with the trails)
    // instead of the scene directly to screen. 
    // Comment both the "#elif defined(POSTPROCESSING)" and 
    // and next line to see the actual scene
    color = texture2D(u_doubleBuffer1, st);

#else
    // This is the main shade if it's rendered as a 2D scene
    // and the cube's surface when rendered a 3D scene 

    color = texture2D(u_doubleBuffer0, uv);

#endif

    gl_FragColor = color;
}