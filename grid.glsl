precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
	uv = uv * 2.0 - 1.0;
    uv.x *= u_resolution.x / u_resolution.y;
    
    
	vec3 color = vec3(sin(abs(uv.x)));
	float thickness = 0.002;
	if(abs(uv.y) < thickness){
		color = vec3(1.);
	}
	if(abs(uv.x) < thickness){
		color = vec3(1.);
	}

    gl_FragColor = vec4(color, 1.0);
}