precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

//Let's declare our Ray objects with an origin and a direction.
struct Ray { 
	vec3 origin;
	vec3 dir;
};
    
//boilerplate function for rotating points - I wrote one myself but it was much less impressive and concise than this so I replaced it.
//still don't really get matrices but this takes a point and axes and does some magic. will come back later to figure this whole
//matrix multiplication thing out.
vec3 rotate( vec3 pos, float x, float y, float z )
{
	mat3 rotX = mat3( 1.0, 0.0, 0.0, 0.0, cos( x ), -sin( x ), 0.0, sin( x ), cos( x ) );
	mat3 rotY = mat3( cos( y ), 0.0, sin( y ), 0.0, 1.0, 0.0, -sin(y), 0.0, cos(y) );
	mat3 rotZ = mat3( cos( z ), -sin( z ), 0.0, sin( z ), cos( z ), 0.0, 0.0, 0.0, 1.0 );

	return rotX * rotY * rotZ * pos;
}

//THIS is the actual mandelbulb formula - again still some reading to do but the point of this function, like any SDF, is to take
//in a test point and figure out the distance to the fractal edge itself, positive or negative. 
float hit( vec3 p )
{
	p = rotate( p, 0., 0., 0.0 );
	p.xyz = p.xyz;
	vec3 z = p;
	vec3 dz=vec3(0.0);
	float power = 2.0;
	float r, theta, phi;
	float dr = 1.0;
	
	float t0 = 1.0;
	for(int i = 0; i < 16; ++i) {
		r = length(z);
		if(r > 2.0) continue;
		theta = atan(z.y / z.x);
        #ifdef phase_shift_on
		phi = asin(z.z / r) + iTime*0.1;
        #else
        phi = asin(z.z / r);
        #endif
		
		dr = pow(r, power - 1.0) * dr * power + 1.0;
	
		r = pow(r, power);
		theta = theta * power;
		phi = phi * power;
		
		z = r * vec3(cos(theta)*cos(phi), sin(theta)*cos(phi), sin(phi)) + p;
		
		t0 = min(t0, r);
	}
	return 0.5 * log(r) * r / dr;
}

//Bridge between the fragment shader and the mandelbulb formula above: converts Rays to 3d vector points to test with. 
float distToScene(in Ray r) {
    return hit(r.origin);
}

vec3 lerp(vec3 colorone, vec3 colortwo, float value)
{
	return (colorone + value*(colortwo-colorone));
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
	uv = uv * 2.0 - 1.0;
    uv.x *= u_resolution.x / u_resolution.y;
    
    Ray ray = Ray(vec3(-1.35, 0.0, -0.5), normalize(vec3(uv, 1.)));
	vec3 col = vec3(0.0, 0.0, 0.0);
    //now march it!
    for (int i=0; i<64; i++) {
        //run this part 100 times: calculate the distance between the current ray position and the fractal
        float dist = distToScene(ray); 
    	if (dist < 0.0004) {
            //if we're less than 0.001 away from it then assume we've hit it, and set the color accordingly
            col = vec3(1.0 / (float(i)/6.0));
            break;
        }
        //otherwise march forward the maximum amount and try again. if you never hit the fractal, the color will remain black.
        ray.origin += ray.dir * dist;
    }
    //output the colour we got multiplied by a tint: in this case red with a smidge of green and blue. Try messing with the vec3 arguments below to produce other colours.
	//fragColor.rgb = col * vec3(0.6, 0.15, 0.05);

	vec3 lerpcolor = vec3(vec3(1., 0.890, 0.890));
	if(col.r > 0.0){
		lerpcolor = lerp(vec3(0.894, 0.847, 0.862), vec3(0.788, 0.8, 0.835), pow((col.r*4.),2.)/1. + 0.2);
	}
	if(col.r > 0.3){
		lerpcolor = lerp(vec3(0.576, 0.709, 0.776), vec3(0.), 0.4);
	}
    

    gl_FragColor = vec4(lerpcolor, 1.0);
}