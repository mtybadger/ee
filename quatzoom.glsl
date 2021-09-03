#version 300 es
precision mediump float;
out vec4 outColor;

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
	return vec4(sqrt(1.-(sin(3.14/divisor))*(sin(3.14/divisor))),  0., sin(3.14/divisor), 0.);
}
    
//boilerplate function for rotating points - I wrote one myself but it was much less impressive and concise than this so I replaced it.
//still don't really get matrices but this takes a point and axes and does some magic. will come back later to figure this whole
//matrix multiplication thing out.
mat4x4 q2m( in vec4 q )
{
    return mat4x4( q.x, -q.y, -q.z, -q.w,
                   q.y,  q.x, -q.w,  q.z,
                   q.z,  q.w,  q.x, -q.y,
                   q.w, -q.z,  q.y, q.x );
}


float hitBrot(vec3 point){
		vec4 c = vec4(point.xyz, 0.);
		float index = 3.;
		vec4 q1 = normalize( cos( index*vec4(1.0,1.8,1.1,1.5) + vec4(0.0,1.0,5.0,4.0) ) );
		vec4 q2 = normalize( cos( index*vec4(1.9,1.7,1.4,1.3) + vec4(3.0,2.0,6.0,5.0) ) );
    	c = q2m(q2)*c*q2m(q1);
			// iterate
			float di =  1.0;
			vec4 z  = vec4(0.0);
			float m2 = 0.0;
			vec4 dz = vec4(0.0);
			for( int i=0; i<64; i++)
			{
				z.zy = -z.yz;
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
    
    Ray ray = Ray(vec3(-1.4, 0.0, -0.9), 0.2*normalize(vec3(uv, 1.)));
	vec3 col = vec3(0.);
    //now march it!
    for (int i=0; i<256; i++) {
        //run this part 100 times: calculate the distance between the current ray position and the fractal
		float dist = distToScene(ray); 
    	if (dist < 0.0002) {
            //if we're less than 0.001 away from it then assume we've hit it, and set the color accordingly
			float iterationScalar = min((1.0 / (float(i)/30.)), 0.7);
            col = vec3(0.7412, 0.8431, 1.0) * iterationScalar;
            break;
        }
        //otherwise march forward the maximum amount and try again. if you never hit the fractal, the color will remain black.
        ray.origin += ray.dir * dist;
    }

	vec3 lerpcolor = vec3(col.r * vec3(0.0, 0.15, 0.4));
		if(col.r > 0.2){
			lerpcolor = lerp(vec3(0.05, 0.321, 0.729), vec3(0.98, 0.501, 0.447), pow(col.r, 0.5) + 0.2);
		}
		if(col.r > 0.35){
			lerpcolor = lerp(vec3(1., 0.85, 0.725), vec3(0.85), 0.);
		}

    outColor = vec4(lerpcolor, 1.0);
}