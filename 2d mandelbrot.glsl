#version 300 es

precision mediump float;
out vec4 outColor;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

vec3 palette[4] = vec3[4](vec3(0.), vec3(0.5), vec3(0.75), vec3(1.));

vec3 lerp(vec3 colorone, vec3 colortwo, float value)
{
    return (colorone + value*(colortwo-colorone));
}

void main() {
	vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float fac = 2.5;
	uv = uv * fac - (0.5 * fac);
    uv.x *= u_resolution.x / u_resolution.y;

	//uv = (uv / (pow(u_time, 3.)) * 5.);
    uv.x = uv.x - 0.2;
    //uv.y = uv.y + 0.1;


    // Time varying pixel color
    vec3 col = vec3(abs(uv.x), abs(uv.y), 0.);
    
    float x = 0.;
    float y = 0.;
    int iMax = 50;
    int i = 0;
    float n = 2.;
    while(x*x + y*y <= 4. && i < iMax)
	{
		float tempX = pow((x*x+y*y), n/2.)*cos(n*atan(y,x)) + uv.x;
        //xtmp=x^3-3*x*y^2 + a
        //y=3*x^2*y-y^3 + b
        y = pow((x*x+y*y), n/2.)*sin(n*atan(y,x)) + uv.y;
        x = tempX;
        i++;
	}
    
    vec3 color = vec3(1.);
    float dist = sqrt((x)*(x) + y*y);
    bool onLine = false;


    if(onLine){
        color = vec3(0.);
    } else {
            float col = float(i + 1) - log(log(dist))/log(2.) - 3.;
            color = vec3(pow(col, 2.)*0.0008);
        
    }
    
    

    // Output to screen
    outColor = vec4(color,1.0);
}