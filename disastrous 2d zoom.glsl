#version 300 es

precision mediump float;
out vec4 outColor;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

vec3 palette[4] = vec3[4](vec3(0.9725, 0.0, 0.0), vec3(1.0, 0.5333, 0.0), vec3(1.0, 0.9608, 0.4078), vec3(0.));

vec3 lerp(vec3 colorone, vec3 colortwo, float value)
{
    return (colorone + value*(colortwo-colorone));
}

void main() {
	vec2 uv = gl_FragCoord.xy / u_resolution.xy;
	uv = uv * 2.0 - 1.0;
    uv.x *= u_resolution.x / u_resolution.y;

	uv = (uv / (u_time*u_time) * 2.5);
    uv.x = uv.x - 0.7492;
    uv.y = uv.y + 0.1;


    // Time varying pixel color
    vec3 col = vec3(abs(uv.x), abs(uv.y), 0.);
    
    float x = 0.;
    float y = 0.;
    int iMax = 100;
    int i = 0;
    while(x*x + y*y <= 4. && i < iMax)
	{
		float tempX = x*x - y*y + uv.x;
        y = 2.*x*y + uv.y;
        x = tempX;
        i++;
	}
    
    vec3 color = vec3(0.);
    float dist = sqrt((uv.x)*(uv.x) + uv.y*uv.y);
    bool onLine = false;
    if(onLine){
        color = vec3(1.);
    } else {
        color = palette[int(mod(float(i - 2), 4.))];
    }
    
    

    // Output to screen
    outColor = vec4(color,1.0);
}