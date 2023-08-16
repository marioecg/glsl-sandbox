import { WebGLRenderer, PerspectiveCamera, Scene, BoxGeometry, ShaderMaterial, Mesh, Vector2, Vector3 } from 'three';
import { resolveLygia } from 'resolve-lygia';

import { GlslSandbox } from '../index.js';

let W = window,
    D = document;

let width = W.innerWidth;
let height = W.innerHeight;
let pixelRatio = W.devicePixelRatio;

const renderer = new WebGLRenderer();
renderer.setPixelRatio(pixelRatio);
renderer.setSize(width, height);
D.body.appendChild(renderer.domElement);

const shader_frag = resolveLygia(/* glsl */`
uniform sampler2D   u_doubleBuffer0;

uniform vec2        u_resolution;
uniform vec2        u_mouse;
uniform float       u_time;

#include "lygia/space/ratio.glsl"
#include "lygia/generative/random.glsl"
#include "lygia/sdf/circleSDF.glsl"
#include "lygia/draw/fill.glsl"
#include "lygia/simulate/grayscott.glsl"

void main() {
    vec3 color = vec3(0.0);
    vec2 pixel = 1. / u_resolution;
    vec2 mouse = u_mouse * pixel;
    vec2 st = gl_FragCoord.xy * pixel;

#ifdef DOUBLE_BUFFER_0
    vec2 sst = ratio(st - mouse + 0.5, u_resolution);
    float src = fill( circleSDF(sst), 0.05 ) * random(st);
    color = grayscott(u_doubleBuffer0, st, pixel, src);

#else
    color = texture2D(u_doubleBuffer0, st).rgb;
    
#endif

    gl_FragColor = vec4(color, 1.0);
}`);

// GLSL Buffers
const glsl_sandbox = new GlslSandbox(renderer);
glsl_sandbox.load(shader_frag);

const draw = () => {
    glsl_sandbox.renderMain();
    requestAnimationFrame(draw);
};

const resize = () => {
    width = W.innerWidth;
    height = W.innerHeight;
    pixelRatio = W.devicePixelRatio;

    renderer.setPixelRatio(pixelRatio);
    renderer.setSize(width, height);

    glsl_sandbox.setSize(width, height);
};

W.addEventListener("resize", resize);
resize();

draw();