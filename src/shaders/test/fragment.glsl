#define layers 5 //int how many layers
#define speed 0.25 //float speed multiplyer
#define scale 1.2 //float scale multiplyer
uniform vec2 u_resolution;
uniform float u_time;
uniform vec3 u_color1;
uniform vec3 u_color2;



vec3 hash( vec3 p )
{
	p = vec3( dot(p,vec3(127.1,311.7, 74.7)),
			  dot(p,vec3(269.5,183.3,246.1)),
			  dot(p,vec3(113.5,271.9,124.6)));
	p = -1.0 + 2.0*fract(sin(p)*43758.5453123);

	return p;
}
float noise( in vec3 p )
{
    vec3 i = floor( p );
    vec3 f = fract( p );
	
	vec3 u = f*f*(3.0-2.0*f);

    return mix( mix( mix( dot( hash( i + vec3(0.0,0.0,0.0) ), f - vec3(0.0,0.0,0.0) ), 
                          dot( hash( i + vec3(1.0,0.0,0.0) ), f - vec3(1.0,0.0,0.0) ), u.x),
                     mix( dot( hash( i + vec3(0.0,1.0,0.0) ), f - vec3(0.0,1.0,0.0) ), 
                          dot( hash( i + vec3(1.0,1.0,0.0) ), f - vec3(1.0,1.0,0.0) ), u.x), u.y),
                mix( mix( dot( hash( i + vec3(0.0,0.0,1.0) ), f - vec3(0.0,0.0,1.0) ), 
                          dot( hash( i + vec3(1.0,0.0,1.0) ), f - vec3(1.0,0.0,1.0) ), u.x),
                     mix( dot( hash( i + vec3(0.0,1.0,1.0) ), f - vec3(0.0,1.0,1.0) ), 
                          dot( hash( i + vec3(1.0,1.0,1.0) ), f - vec3(1.0,1.0,1.0) ), u.x), u.y), u.z );
}


void main() {
    // Convert fragCoord to gl_FragCoord
    vec2 uv = (gl_FragCoord.xy - u_resolution.xy * 0.5) / u_resolution.y;
    float t = u_time * speed;
    uv *= scale;

    float h = noise(vec3(uv*2.,t));
    //uv distortion loop 
    for (int n = 1; n < layers; n++){
        float i = float(n);
        uv -= vec2(0.7 / i * sin(i * uv.y+i + t*5. + h * i) + 20.8, 0.4 / i * sin(uv.x+4.-i+h + t*5. + 0.3 * i) + 1.6);
    }

    uv -= vec2(1.2 * sin(uv.x + t + h) + 1.8, 0.4 * sin(uv.y + t + 0.3*h) + 1.6);

    // Time varying pixel color
    vec3 col = vec3(.5 * sin(uv.x) + 0.5, .5 * sin(uv.x + uv.y) + 0.5, .5 * sin(uv.y) + 0.8)*0.8;

    // Soften the sine wave by reducing its amplitude
    float sineAmplitude = 0.3; // lower this value for softer transitions
    float sineFrequency = 1.0; // adjust frequency if needed

    // Compute color based on the softened sine wave
    vec3 color = mix(
        u_color1,
        u_color2,
        smoothstep(0.9, 1.0, sineAmplitude * sin(sineFrequency * uv.y + t * 1.5 + h))
    );

    // Mix in black based on the vertical position
    float verticalFade = smoothstep(0.8, 0.8, uv.x); // adjust for a softer vertical gradient
    color = mix(color, vec3(1.0), verticalFade);
    color = mix(col, color, verticalFade);
    // Output to screen
    gl_FragColor = vec4(color, 1.0);

}