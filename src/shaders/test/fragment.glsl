uniform float u_time;
uniform vec2 u_resolution;
uniform vec3 u_color1;
uniform vec3 u_color2;
varying vec2 vUv;

void main() {
    vec2 position = (vUv - 0.5) * 2.0;
    position.x *= u_resolution.x / u_resolution.y;

    // Decrease the frequency to make the wave wider
    float frequency = 1.0;
    // Increase the amplitude to make the wave taller
    float amplitude = 0.5;
    // Adjust the sine function to make the wave bigger
    float wave = sin(position.x * frequency + u_time) * amplitude;

    // Adjust the distanceToCenter for the bigger wave
    float distanceToCenter = abs(position.y - wave);

    // Use a very soft smoothstep to make the edges of the sine wave very blurry
    float blurAmount = 0.5; // Adjust this value to increase/decrease the blur
    float gradient = smoothstep(0.1, 0.1 + blurAmount, distanceToCenter);

    // Base color and the color at the center of the wave
    vec3 baseColor = u_color2; // Black
    vec3 centerColor = vec3(0.0, 0.0, 0.0); // Black

    // Interpolate between the base color and the center color based on the gradient
    vec3 color = mix(baseColor, centerColor, gradient);

    // Output the color
    gl_FragColor = vec4(color, 1.0);
}