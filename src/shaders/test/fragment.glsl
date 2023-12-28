uniform vec2 u_resolution;
uniform float u_time;
uniform vec3 u_color1;
uniform vec3 u_color2;
uniform vec2 u_mouse;
varying vec2 vUv;


//	Simplex 3D Noise 
//	by Ian McEwan, Ashima Arts
//
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}

float snoise(vec3 v){ 
    const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
    const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

    // First corner
    vec3 i  = floor(v + dot(v, C.yyy) );
    vec3 x0 =   v - i + dot(i, C.xxx) ;

    // Other corners
    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min( g.xyz, l.zxy );
    vec3 i2 = max( g.xyz, l.zxy );

    //  x0 = x0 - 0. + 0.0 * C 
    vec3 x1 = x0 - i1 + 1.0 * C.xxx;
    vec3 x2 = x0 - i2 + 2.0 * C.xxx;
    vec3 x3 = x0 - 1. + 3.0 * C.xxx;

    // Permutations
    i = mod(i, 289.0 ); 
    vec4 p = permute( permute( permute( 
                i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
            + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
            + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

    // Gradients
    // ( N*N points uniformly over a square, mapped onto an octahedron.)
    float n_ = 1.0/7.0; // N=7
    vec3  ns = n_ * D.wyz - D.xzx;

    vec4 j = p - 49.0 * floor(p * ns.z *ns.z);  //  mod(p,N*N)

    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

    vec4 x = x_ *ns.x + ns.yyyy;
    vec4 y = y_ *ns.x + ns.yyyy;
    vec4 h = 1.0 - abs(x) - abs(y);

    vec4 b0 = vec4( x.xy, y.xy );
    vec4 b1 = vec4( x.zw, y.zw );

    vec4 s0 = floor(b0)*2.0 + 1.0;
    vec4 s1 = floor(b1)*2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));

    vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
    vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

    vec3 p0 = vec3(a0.xy,h.x);
    vec3 p1 = vec3(a0.zw,h.y);
    vec3 p2 = vec3(a1.xy,h.z);
    vec3 p3 = vec3(a1.zw,h.w);

    //Normalise gradients
    vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;

    // Mix final noise value
    vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
    m = m * m;
    return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), 
                                    dot(p2,x2), dot(p3,x3) ) );
}

// Simple white noise function
float grainNoise(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

// Function to calculate luminance
float luminance(vec3 color) {
    return dot(color, vec3(0.299, 0.587, 0.114));
}


void main() {
    // Normalize screen coordinates
    vec2 st = vUv;
    st.x *= u_resolution.x / u_resolution.y;

    // Create time variable for animation
    float t = u_time * 0.1;

    // Calculate a noise value to create randomness
    float noiseValue = snoise(vec3(st * 0.5, t)); // Adjust the scale for smoother noise

    // Smooth transition factors
    float transitionSmoothness = 0.1; // Adjust for sharper or smoother transitions
    float noiseFactor = smoothstep(-transitionSmoothness, transitionSmoothness, noiseValue);

    // Interpolate between the two colors using the smoothstep-ed noise value
    vec3 color = mix(u_color1, u_color2, noiseFactor);

    // Create an additional factor based on the position for vertical gradient
    float verticalGradient = smoothstep(0.0, 0.8, st.y);

    // Mix the current color with black based on the vertical gradient to darken the bottom
    color = mix(color, vec3(0.0, 0.0, 0.0), 1.0 - verticalGradient);

    // Calculate grain noise
    float grain = grainNoise(vUv * u_time);

    // Adjust grain intensity and mix it with the final color
    float grainIntensity = 0.2; // Adjust this value for more or less grain
    vec3 grainyColor = mix(color, vec3(grain), grainIntensity);

    // Calculate distance from the mouse position
    float distanceFromMouse = distance(u_mouse, st);

    // Define the radius within which the color blend occurs
    float blendRadius = 0.2; // Adjust as needed for the blending area

    // Calculate the blend factor based on the distance
    float blendFactor = smoothstep(blendRadius, 0.9, distanceFromMouse);

    // Define the green color
    vec3 yellowColor = u_color1;

    // Calculate luminance of the existing and yellow colors
    float luminanceExisting = luminance(grainyColor);
    float luminanceYellow = luminance(yellowColor);

    // Blend based on luminance
    vec3 blendedColor = mix(grainyColor, yellowColor, luminanceYellow / (luminanceExisting + luminanceYellow));

    // Apply the blend factor
    vec3 finalColor = mix(grainyColor, blendedColor, blendFactor);

    // Output the final color
    gl_FragColor = vec4(finalColor, 1.0);
}