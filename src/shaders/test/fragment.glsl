uniform float iTime;
uniform vec3 iResolution;
varying vec2 vUv;
uniform vec3 u_color1;
uniform vec3 u_color2;

vec3 calcSine(vec2 uv, 
    float frequency, float amplitude, float shift, float offset,
    vec3 color, float width, float exponent) {
    float y = sin(iTime * frequency + shift + uv.x) * amplitude + offset;
    float scale = pow(smoothstep(width, 0.0, distance(y, uv.y)), exponent);
    return color * scale;
}

void main() {
    vec2 uv = vUv;
    vec3 color = vec3(0.0);
    
    color += calcSine(uv, 2.0, 0.25, 0.0, 0.5,vec3(0.0, 0.0, 0.0), 0.3, 1.0);
    color += calcSine(uv, 2.6, 0.25, 0.2, 0.5, u_color1, 0.3, 1.0);
    color += calcSine(uv, 2.9, 0.25, 0.4, 0.5, u_color2, 0.3, 1.0);
    
    gl_FragColor = vec4(color,1.0);
}