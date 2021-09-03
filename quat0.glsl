precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

//Let's declare our Ray objects with an origin and a direction.
struct Ray { 
	vec3 origin;
	vec3 dir;
};


vec4 qsqr( in vec4 a ) // square a quaterion
{
    return vec4( a.x*a.x - a.y*a.y - a.z*a.z - a.w*a.w,
                 2.0*a.x*a.y,
                 2.0*a.x*a.z,
                 2.0*a.x*a.w );
}
vec4 qmul( in vec4 a, in vec4 b)
{
    return vec4(
        a.x * b.x - a.y * b.y - a.z * b.z - a.w * b.w,
        a.y * b.x + a.x * b.y + a.z * b.w - a.w * b.z, 
        a.z * b.x + a.x * b.z + a.w * b.y - a.y * b.w,
        a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y );

}
vec4 qconj( in vec4 a )
{
    return vec4( a.x, -a.yzw );
}

float qlength2( in vec4 q )
{
    return dot(q,q);
}

vec4 quatGen(float divisor){
	return vec4(sqrt(1.-(sin(3.14/divisor))*(sin(3.14/divisor))), sin(3.14/divisor), 0. , 0.);
}
    
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


float hitBrot(vec3 point){
		vec4 c = vec4(point.xyz, 0.);
		//c = qmul(quatGen(4.), c);
			// iterate
			float di =  1.0;
			vec4 z  = vec4(0.0);
			float m2 = 0.0;
			vec4 dz = vec4(0.0);
			for( int i=0; i<20; i++ )
			{
				if( m2>1024.0 ) { di=0.0; break; }

				// Z' -> 2·Z·Z' + 1
				dz = 2.0*vec4(qmul(z, dz)) + vec4(1.0,0.0,0.,0.);
					
				// Z -> Z² + c			
				z = vec4( qsqr(z) ) + c;
					
				m2 = dot(z,z);
			}

			// distance	
			// d(c) = |Z|·log|Z|/|Z'|
			float d = 0.5*sqrt(dot(z,z)/dot(dz,dz))*log(dot(z,z));
			if( di>0.5 ) d=0.0;

			return d;
	
}

float clipSphere(vec3 point){
	if(length(point) > 2.){
		return 1.;
	} else {
		return 0.;
	}
}


//Bridge between the fragment shader and the mandelbulb formula above: converts Rays to 3d vector points to test with. 
float distToScene(in Ray r) {
    return hitBrot(r.origin);
}

vec3 lerp(vec3 colorone, vec3 colortwo, float value)
{
	return (colorone + value*(colortwo-colorone));
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
	uv = uv * 2.0 - 1.0;
    uv.x *= u_resolution.x / u_resolution.y;
    
    Ray ray = Ray(vec3(-0.5, 0.0, -2.), 0.6*normalize(vec3(uv, 1.)));
	vec3 col = vec3(length(uv)/8.0);
    //now march it!
    for (int i=0; i<256; i++) {
        //run this part 100 times: calculate the distance between the current ray position and the fractal
		float dist = distToScene(ray); 
    	if (dist < 0.001) {
            //if we're less than 0.001 away from it then assume we've hit it, and set the color accordingly
            col = vec3(1.0 / (float(i)/10.0));
            break;
        }
        //otherwise march forward the maximum amount and try again. if you never hit the fractal, the color will remain black.
        ray.origin += ray.dir * dist;
    }

	vec3 lerpcolor = vec3((1. - col.r) * vec3(0.905, 0.878, 0.788));
		if(col.r > 0.2){
			lerpcolor = lerp(vec3(0.756, 0.811, 0.752), vec3(0.419, 0.478, 0.631), pow(col.r, 0.5) + 0.2);
		}
		if(col.r > 0.35){
			lerpcolor = lerp(vec3(0.06, 0.196, 0.3), vec3(0.), col.r);
		}

    gl_FragColor = vec4(lerpcolor, 1.0);
}