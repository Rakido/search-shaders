uniform float time;
varying vec2 vUv;
float PI = 3.14;

void main() {
    vec3 pos = vec3(position.x, position.y, position.z);
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}