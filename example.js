import { WebGLRenderer, PerspectiveCamera, Scene, BoxGeometry, ShaderMaterial, Mesh, Vector2, Vector3 } from 'three';

import vertexShader from './shaders/vertex.glsl';
import fragmentShader from './shaders/fragment.glsl';

import { GlslSandbox } from './index.js';

let W = window,
    D = document;

let width = W.innerWidth;
let height = W.innerHeight;
let pixelRatio = W.devicePixelRatio;

const renderer = new WebGLRenderer();
renderer.setPixelRatio(pixelRatio);
renderer.setSize(width, height);
D.body.appendChild(renderer.domElement);

const uniforms = {
    u_camera: { value: new Vector3() },
};

// GLSL Buffers
const glsl_sandbox = new GlslSandbox(renderer, uniforms);
glsl_sandbox.load(shader_frag);

// SPHERE
const material = new ShaderMaterial({
    vertexShader,
    fragmentShader,
    uniforms,
    defines: glsl_sandbox.defines,
});

const mesh = new Mesh(new BoxGeometry(1, 1, 1), material);
const scene = new Scene();
const cam = new PerspectiveCamera(45, width / height, 0.001, 200);
cam.position.z = 3;
scene.add(mesh);

const draw = () => {
    uniforms.u_camera.value = cam.position;

    // // 2D main shader
    // glsl_sandbox.renderMain();

    // 3D Scene
    glsl_sandbox.renderScene(scene, cam);

    requestAnimationFrame(draw);
};

const resize = () => {
    width = W.innerWidth;
    height = W.innerHeight;
    pixelRatio = W.devicePixelRatio;

    renderer.setPixelRatio(pixelRatio);
    renderer.setSize(width, height);

    glsl_sandbox.setSize(width, height);

    material.uniforms.u_resolution.value = new Vector2(width, height);

    cam.aspect = width / height;
    cam.updateProjectionMatrix();
    draw();
};

W.addEventListener("resize", resize);
resize();

draw();