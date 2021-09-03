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
float hit( vec3 r )
{
	r = rotate( r, 1.0, 0.0, 0.0 );
	vec3 zn = vec3( r.xyz );
	float rad = 0.0;
	float hit = 0.0;
	float p = 8.0;
	float d = 1.0;
	for( int i = 0; i < 36; i++ )
	{
		
			rad = length( zn );

			if( rad > 2.0 )
			{	
				hit = 0.5 * log(rad) * rad / d;
			}else{

			float th = atan( length( zn.xy ), zn.z );
			float phi = atan( zn.y, zn.x );		
			float rado = pow(rad,8.0);
			d = pow(rad, 7.0) * 7.0 * d + 1.0;
			


			float sint = sin( th * p );
			zn.x = rado * sint * cos( phi * p );
			zn.y = rado * sint * sin( phi * p );
			zn.z = rado * cos( th * p ) ;
			zn += r;
			}
			
	}
	
	return hit;
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
    
    Ray ray = Ray(vec3(0.0, 0.0, -2.0 + (sin(u_time) * 0.5)), normalize(vec3(uv, 1.)));
	vec3 col = vec3(0.);
    //now march it!
    for (int i=0; i<64; i++) {
        //run this part 100 times: calculate the distance between the current ray position and the fractal
        float dist = distToScene(ray); 
    	if (dist < 0.001) {
            //if we're less than 0.001 away from it then assume we've hit it, and set the color accordingly
            col = vec3(1.0 / (float(i)/3.0));
            break;
        }
        //otherwise march forward the maximum amount and try again. if you never hit the fractal, the color will remain black.
        ray.origin += ray.dir * dist;
    }
    //output the colour we got multiplied by a tint: in this case red with a smidge of green and blue. Try messing with the vec3 arguments below to produce other colours.
	//fragColor.rgb = col * vec3(0.6, 0.15, 0.05);

	vec3 lerpcolor = vec3(col.r * vec3(0.09, 0., 0.33));
	if(col.r > 0.1){
		lerpcolor = lerp(vec3(0.24, 0.0, 1.), vec3(0.682, 0.0, 0.9), pow(col.r, 0.5) + 0.2);
	}
	if(col.r > 0.3){
		lerpcolor = lerp(vec3(0.3176, 0.8471, 0.5804), vec3(0.85), 0.);
	}
    

    gl_FragColor = vec4(lerpcolor, 1.0);
}