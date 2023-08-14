uniform float   u_time;

varying vec2    v_texcoord;
varying vec3    v_normal;
varying vec4    v_position;

#include "lygia/math/const.glsl"
#include "lygia/math/rotate4dX.glsl"
#include "lygia/math/rotate4dY.glsl"
#include "lygia/math/rotate4dZ.glsl"

void main(void) {
    v_position = vec4(position, 1.0);

    mat4 rot =  rotate4dY(u_time * 0.5) *
                rotate4dX(PI*0.2) * 
                rotate4dZ(PI*0.25);

    v_position = rot * v_position;

    v_normal = normalize( (rot * vec4(normal,1.0)).xyz );
    v_texcoord = uv;
    
    gl_Position = projectionMatrix * modelViewMatrix * v_position;
}