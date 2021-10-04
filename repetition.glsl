#version 300 es

precision mediump float;
out vec4 outColor;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;


vec3 lerp(vec3 colorone, vec3 colortwo, float value)
{
    return (colorone + value*(colortwo-colorone));
}

void main() {
	vec2 uv = gl_FragCoord.xy / u_resolution.xy;
	uv = uv * 2.0 - 1.0;
    uv.x *= u_resolution.x / u_resolution.y;

	uv = (uv * pow(2.7418, -5.6));
    uv.x += 0.37;
    uv.y += 0.093;

    // Time varying pixel color
    vec3 col = vec3(abs(uv.x), abs(uv.y), 0.);
    
    float x = 0.;
    float y = 0.;
    int iMax = 240;
    int i = 0;
    while(x*x + y*y <= 4. && i < iMax)
	{
		float tempX = x*x - y*y + uv.x;
        y = 2.*x*y + uv.y;
        x = tempX;
        i+=1;
	}
    
    vec3 color = vec3(1.);
    float dist = sqrt((uv.x)*(uv.x) + uv.y*uv.y);
    bool onLine1 = false;
    bool onLine2 = false;
    bool onLine3 = false;
    /*
    if(abs(uv.x)<0.005){
        onLine1 = true;
    }
    if(abs(uv.y)<0.005){
        onLine1 = true;
    }
    if(abs(mod(uv.x, 1.))<0.01  && abs(uv.y) <0.03){
        onLine1 = true;
    }
    if(abs(mod(uv.y, 1.))<0.01  && abs(uv.x) <0.03){
        onLine1 = true;
    }

    if(abs(mod(uv.x, 0.00025))<0.000002){
        onLine2 = true;
    }
    if(abs(mod(uv.y, 0.00025))<0.000002){
        onLine2 = true;
    }

    if(abs(mod(uv.x, 0.00005))<0.000002){
        onLine3 = true;
    }
    if(abs(mod(uv.y, 0.00005))<0.000002){
        onLine3 = true;
    }*/

    if(onLine1){
        color = vec3(0.);
    } else if(onLine2){
        color = vec3(0.7);
    } else if(onLine3){
        color = vec3(0.9);
    }

    float image = (float(i)/ 200.5) - (30./180.5);
    color *= (vec3(1.) - image);

    // Output to screen
    outColor = vec4(color,1.0);
}